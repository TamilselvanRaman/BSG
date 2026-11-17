import { Router, Request, Response, NextFunction } from "express";
import bcrypt from "bcryptjs";
import crypto from "crypto";
import { z } from "zod";
import { prisma } from "../../config/prisma";
import { authenticate, requireRoles } from "../../middleware/auth";
import { AppError, sendSuccess, parsePagination } from "../../utils/response";
import { recordAuditLog } from "../../utils/auditLogger";
import { verifyRazorpaySignature } from "../../utils/crypto";

export const ALL_MANDI_FEATURES = [
  "MULTI_PRODUCT_LOTS",
  "MULTI_PRODUCT_BILLING",
  "BAG_WEIGHMENT_SCALE",
  "DAILY_CASH_TALLY",
  "SMART_CHART_AUCTION",
  "PARTNER_LEDGERS",
  "CUSTOMER_ADVANCES",
  "FINANCIAL_REPORTS",
  "WHATSAPP_INVOICES",
  "MOBILE_APP_SYNC",
];

export const superAdminRouter = Router();

superAdminRouter.use(authenticate, requireRoles("SUPER_ADMIN"));

// GET /api/v1/super-admin/dashboard
superAdminRouter.get("/dashboard", async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const [
      totalBusinesses,
      activeBusinesses,
      suspendedBusinesses,
      totalUsers,
      activeSubscriptions,
      trialSubscriptions,
      expiredSubscriptions,
      paymentsAgg,
      pendingPaymentsCount,
      recentBusinesses,
      recentPayments,
    ] = await Promise.all([
      prisma.tenant.count({ where: { deletedAt: null } }),
      prisma.tenant.count({ where: { status: "ACTIVE", deletedAt: null } }),
      prisma.tenant.count({ where: { status: "SUSPENDED", deletedAt: null } }),
      prisma.user.count({ where: { deletedAt: null } }),
      prisma.subscription.count({ where: { status: "ACTIVE" } }),
      prisma.subscription.count({ where: { status: "TRIAL" } }),
      prisma.subscription.count({ where: { status: "EXPIRED" } }),
      prisma.subscriptionPayment.aggregate({
        where: { status: "SUCCESS" },
        _sum: { amount: true },
      }),
      prisma.subscriptionPayment.count({ where: { status: "PENDING" } }),
      prisma.tenant.findMany({
        where: { deletedAt: null },
        orderBy: { createdAt: "desc" },
        take: 6,
        include: {
          subscriptions: {
            orderBy: { createdAt: "desc" },
            take: 1,
            include: { plan: true },
          },
        },
      }),
      prisma.subscriptionPayment.findMany({
        orderBy: { createdAt: "desc" },
        take: 6,
        include: { tenant: { select: { name: true, code: true } } },
      }),
    ]);

    const activeSubsWithPlans = await prisma.subscription.findMany({
      where: { status: "ACTIVE" },
      include: { plan: true },
    });

    const mrr = activeSubsWithPlans.reduce((sum, sub) => {
      const monthly =
        sub.billingCycle === "ANNUAL"
          ? Number(sub.plan.annualPrice) / 12
          : Number(sub.plan.monthlyPrice);
      return sum + monthly;
    }, 0);

    const totalRevenue = Number(paymentsAgg._sum.amount ?? 0);
    const totalSubCount = activeSubscriptions + trialSubscriptions + expiredSubscriptions;
    const conversionRate =
      totalSubCount > 0 ? Math.round((activeSubscriptions / totalSubCount) * 1000) / 10 : 0;

    return sendSuccess(res, {
      metrics: {
        totalBusinesses,
        activeBusinesses,
        suspendedBusinesses,
        totalUsers,
        activeSubscriptions,
        trialSubscriptions,
        expiredSubscriptions,
        monthlyRecurringRevenue: Math.round(mrr * 100) / 100,
        totalSaasRevenue: totalRevenue,
        pendingPayments: pendingPaymentsCount,
        subscriptionConversionRate: conversionRate,
      },
      recentRegistrations: recentBusinesses,
      recentTransactions: recentPayments,
    });
  } catch (err) {
    next(err);
  }
});

// GET /api/v1/super-admin/businesses
superAdminRouter.get("/businesses", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page, limit, skip, search } = parsePagination(req.query);
    const status = typeof req.query.status === "string" ? req.query.status : undefined;

    const where: Record<string, unknown> = { deletedAt: null };
    if (status) where.status = status;
    if (search) {
      where.OR = [
        { name: { contains: search } },
        { code: { contains: search } },
        { ownerEmail: { contains: search } },
        { ownerPhone: { contains: search } },
      ];
    }

    const [items, total] = await Promise.all([
      prisma.tenant.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          businessProfile: true,
          subscriptions: {
            orderBy: { createdAt: "desc" },
            take: 1,
            include: { plan: true },
          },
          _count: {
            select: { users: true, buyers: true, sellers: true, goods: true, activeSessions: true },
          },
        },
      }),
      prisma.tenant.count({ where }),
    ]);

    return sendSuccess(res, items, "Businesses retrieved.", 200, {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    });
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/super-admin/businesses
superAdminRouter.post("/businesses", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const schema = z.object({
      name: z.string().min(2),
      ownerEmail: z.string().email(),
      ownerPhone: z.string().min(8),
      adminUsername: z.string().min(3),
      adminPassword: z.string().min(6),
      adminFullName: z.string().min(2),
      city: z.string().optional(),
      marketLocation: z.string().optional(),
      trialDays: z.number().int().min(1).max(365).default(30),
      maxUsers: z.number().int().min(1).max(20).default(3),
      enableAllFeatures: z.boolean().default(true),
      enabledFeatures: z.array(z.string()).optional(),
      planId: z.string().optional(),
      status: z.enum(["ACTIVE", "TRIAL", "SUSPENDED"]).default("TRIAL"),
    });
    const body = schema.parse(req.body);

    const adminRole = await prisma.role.findUnique({ where: { code: "ADMIN" } });
    if (!adminRole) throw new AppError(500, "ROLE_MISSING", "Admin role not found.");

    const plan = body.planId
      ? await prisma.subscriptionPlan.findUnique({ where: { id: body.planId } })
      : await prisma.subscriptionPlan.findFirst({ where: { isActive: true } });
    if (!plan) throw new AppError(404, "PLAN_NOT_FOUND", "Subscription plan not found.");

    const passwordHash = await bcrypt.hash(body.adminPassword, 12);
    const code = `SH-${Date.now().toString().slice(-4)}`;
    const slug = `${body.name.toLowerCase().replace(/[^a-z0-9]+/g, "-")}-${crypto
      .randomBytes(2)
      .toString("hex")}`;
    const licenseKey = `BSG-LIC-${Date.now().toString(36).toUpperCase()}-${crypto
      .randomBytes(3)
      .toString("hex")
      .toUpperCase()}`;
    const trialEndsAt = new Date(Date.now() + body.trialDays * 24 * 60 * 60 * 1000);
    const featuresToSave = body.enableAllFeatures
      ? ALL_MANDI_FEATURES
      : (body.enabledFeatures ?? ALL_MANDI_FEATURES);

    const created = await prisma.$transaction(async (tx) => {
      const tenant = await tx.tenant.create({
        data: {
          code,
          name: body.name,
          slug,
          status: body.status,
          ownerEmail: body.ownerEmail,
          ownerPhone: body.ownerPhone,
          licenseKey,
          maxUsers: body.maxUsers,
          trialEndsAt,
          enabledFeatures: featuresToSave,
          city: body.city ?? null,
          marketLocation: body.marketLocation ?? null,
          createdBy: req.user!.sub,
        },
      });

      await tx.businessProfile.create({
        data: {
          tenantId: tenant.id,
          businessName: body.name,
          phone: body.ownerPhone,
          email: body.ownerEmail,
          city: body.city ?? null,
          addressLine1: body.marketLocation ?? null,
        },
      });

      await tx.businessSettings.create({
        data: {
          tenantId: tenant.id,
          supportedUnits: ["KG", "BAG", "QUINTAL", "CRATE", "BOX"],
        },
      });

      const adminUser = await tx.user.create({
        data: {
          tenantId: tenant.id,
          roleId: adminRole.id,
          username: body.adminUsername,
          email: body.ownerEmail,
          phone: body.ownerPhone,
          fullName: body.adminFullName,
          passwordHash,
          status: "ACTIVE",
          createdBy: req.user!.sub,
        },
      });

      await tx.tenantUser.create({
        data: {
          tenantId: tenant.id,
          userId: adminUser.id,
          designation: "Business Admin / Owner",
          isPrimary: true,
        },
      });

      const sub = await tx.subscription.create({
        data: {
          tenantId: tenant.id,
          planId: plan.id,
          status: body.status === "ACTIVE" ? "ACTIVE" : "TRIAL",
          billingCycle: "MONTHLY",
          startDate: new Date(),
          endDate: trialEndsAt,
          trialEndsAt,
        },
      });

      return { tenant, adminUser, subscription: sub };
    });

    await recordAuditLog({
      userId: req.user!.sub,
      tenantId: created.tenant.id,
      action: "SUPER_ADMIN_CREATED_BUSINESS",
      entityType: "Tenant",
      entityId: created.tenant.id,
      ipAddress: req.ip,
    });

    return sendSuccess(res, created, "Business and Admin created.", 201);
  } catch (err) {
    next(err);
  }
});

// GET /api/v1/super-admin/businesses/:id
superAdminRouter.get("/businesses/:id", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const tenant = await prisma.tenant.findUnique({
      where: { id: req.params.id },
      include: {
        businessProfile: true,
        businessSettings: true,
        users: {
          where: { deletedAt: null },
          select: {
            id: true,
            username: true,
            fullName: true,
            email: true,
            phone: true,
            status: true,
            lastLoginAt: true,
            role: true,
          },
        },
        subscriptions: {
          orderBy: { createdAt: "desc" },
          include: { plan: true },
        },
        auditLogs: {
          orderBy: { createdAt: "desc" },
          take: 20,
        },
      },
    });
    if (!tenant) throw new AppError(404, "TENANT_NOT_FOUND", "Business not found.");
    return sendSuccess(res, tenant);
  } catch (err) {
    next(err);
  }
});

// PATCH /api/v1/super-admin/businesses/:id
superAdminRouter.patch("/businesses/:id", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const schema = z.object({
      name: z.string().min(2).optional(),
      ownerEmail: z.string().email().optional(),
      ownerPhone: z.string().min(8).optional(),
      status: z.enum(["ACTIVE", "TRIAL", "SUSPENDED", "EXPIRED", "CANCELLED"]).optional(),
    });
    const body = schema.parse(req.body);

    const updated = await prisma.tenant.update({
      where: { id: req.params.id },
      data: { ...body, updatedBy: req.user!.sub },
    });

    await recordAuditLog({
      userId: req.user!.sub,
      tenantId: updated.id,
      action: "SUPER_ADMIN_UPDATED_BUSINESS",
      entityType: "Tenant",
      entityId: updated.id,
      metadata: body,
    });

    return sendSuccess(res, updated, "Business updated.");
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/super-admin/businesses/:id/activate
superAdminRouter.post(
  "/businesses/:id/activate",
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const updated = await prisma.tenant.update({
        where: { id: req.params.id },
        data: { status: "ACTIVE", updatedBy: req.user!.sub },
      });
      await recordAuditLog({
        userId: req.user!.sub,
        tenantId: updated.id,
        action: "BUSINESS_ACTIVATED",
        entityType: "Tenant",
        entityId: updated.id,
      });
      return sendSuccess(res, updated, "Business activated.");
    } catch (err) {
      next(err);
    }
  }
);

// POST /api/v1/super-admin/businesses/:id/suspend
superAdminRouter.post(
  "/businesses/:id/suspend",
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const updated = await prisma.tenant.update({
        where: { id: req.params.id },
        data: { status: "SUSPENDED", updatedBy: req.user!.sub },
      });
      await recordAuditLog({
        userId: req.user!.sub,
        tenantId: updated.id,
        action: "BUSINESS_SUSPENDED",
        entityType: "Tenant",
        entityId: updated.id,
      });
      return sendSuccess(res, updated, "Business suspended.");
    } catch (err) {
      next(err);
    }
  }
);

// DELETE /api/v1/super-admin/businesses/:id
superAdminRouter.delete(
  "/businesses/:id",
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const updated = await prisma.tenant.update({
        where: { id: req.params.id },
        data: { deletedAt: new Date(), status: "CANCELLED", updatedBy: req.user!.sub },
      });
      await recordAuditLog({
        userId: req.user!.sub,
        tenantId: updated.id,
        action: "BUSINESS_SOFT_DELETED",
        entityType: "Tenant",
        entityId: updated.id,
      });
      return sendSuccess(res, { id: updated.id, deleted: true }, "Business deleted.");
    } catch (err) {
      next(err);
    }
  }
);

// POST /api/v1/super-admin/businesses/:id/features
superAdminRouter.post(
  "/businesses/:id/features",
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { features, enableAll } = z
        .object({
          features: z.array(z.string()).optional(),
          enableAll: z.boolean().optional(),
        })
        .parse(req.body);

      const featuresToSave = enableAll ? ALL_MANDI_FEATURES : (features ?? ALL_MANDI_FEATURES);

      const updated = await prisma.tenant.update({
        where: { id: req.params.id },
        data: {
          enabledFeatures: featuresToSave,
          updatedBy: req.user!.sub,
        },
      });

      await recordAuditLog({
        userId: req.user!.sub,
        tenantId: updated.id,
        action: "TENANT_FEATURES_UPDATED",
        entityType: "Tenant",
        entityId: updated.id,
        metadata: { enabledFeatures: featuresToSave, enableAll },
      });

      return sendSuccess(res, { id: updated.id, enabledFeatures: updated.enabledFeatures }, "Features updated.");
    } catch (err) {
      next(err);
    }
  }
);

// POST /api/v1/super-admin/businesses/:id/license/extend-trial
superAdminRouter.post(
  "/businesses/:id/license/extend-trial",
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { additionalDays } = z
        .object({ additionalDays: z.number().int().min(1).max(365).default(14) })
        .parse(req.body);

      const tenant = await prisma.tenant.findUnique({ where: { id: req.params.id } });
      if (!tenant) throw new AppError(404, "TENANT_NOT_FOUND", "Shop not found.");

      const baseDate = tenant.trialEndsAt && tenant.trialEndsAt > new Date()
        ? tenant.trialEndsAt
        : new Date();
      const newTrialEndsAt = new Date(baseDate.getTime() + additionalDays * 24 * 60 * 60 * 1000);

      const updated = await prisma.tenant.update({
        where: { id: tenant.id },
        data: {
          status: "TRIAL",
          trialEndsAt: newTrialEndsAt,
          updatedBy: req.user!.sub,
        },
      });

      await recordAuditLog({
        userId: req.user!.sub,
        tenantId: updated.id,
        action: "TRIAL_EXTENDED",
        entityType: "Tenant",
        entityId: updated.id,
        metadata: { additionalDays, newTrialEndsAt },
      });

      return sendSuccess(
        res,
        { id: updated.id, status: updated.status, trialEndsAt: updated.trialEndsAt },
        `Trial extended by ${additionalDays} days.`
      );
    } catch (err) {
      next(err);
    }
  }
);

// POST /api/v1/super-admin/businesses/:id/license/activate-subscription
superAdminRouter.post(
  "/businesses/:id/license/activate-subscription",
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { durationMonths, maxUsers } = z
        .object({
          durationMonths: z.number().int().min(1).max(60).default(12),
          maxUsers: z.number().int().min(1).max(20).default(3),
        })
        .parse(req.body);

      const tenant = await prisma.tenant.findUnique({ where: { id: req.params.id } });
      if (!tenant) throw new AppError(404, "TENANT_NOT_FOUND", "Shop not found.");

      const now = new Date();
      const subscriptionEndsAt = new Date(now.getTime() + durationMonths * 30 * 24 * 60 * 60 * 1000);

      const updated = await prisma.tenant.update({
        where: { id: tenant.id },
        data: {
          status: "ACTIVE",
          maxUsers,
          subscriptionEndsAt,
          updatedBy: req.user!.sub,
        },
      });

      await recordAuditLog({
        userId: req.user!.sub,
        tenantId: updated.id,
        action: "SUBSCRIPTION_ACTIVATED_BY_ADMIN",
        entityType: "Tenant",
        entityId: updated.id,
        metadata: { durationMonths, maxUsers, subscriptionEndsAt },
      });

      return sendSuccess(
        res,
        { id: updated.id, status: updated.status, subscriptionEndsAt: updated.subscriptionEndsAt, maxUsers },
        "Subscription activated successfully."
      );
    } catch (err) {
      next(err);
    }
  }
);

// POST /api/v1/super-admin/businesses/:id/license/regenerate-key
superAdminRouter.post(
  "/businesses/:id/license/regenerate-key",
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const newKey = `BSG-LIC-${Date.now().toString(36).toUpperCase()}-${crypto
        .randomBytes(3)
        .toString("hex")
        .toUpperCase()}`;

      const updated = await prisma.tenant.update({
        where: { id: req.params.id },
        data: { licenseKey: newKey, updatedBy: req.user!.sub },
      });

      return sendSuccess(res, { id: updated.id, licenseKey: updated.licenseKey }, "License key regenerated.");
    } catch (err) {
      next(err);
    }
  }
);

// GET /api/v1/super-admin/businesses/:id/license/certificate
superAdminRouter.get(
  "/businesses/:id/license/certificate",
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenant = await prisma.tenant.findUnique({
        where: { id: req.params.id },
        include: { businessProfile: true },
      });
      if (!tenant) throw new AppError(404, "TENANT_NOT_FOUND", "Shop not found.");

      const payload = {
        licenseKey: tenant.licenseKey,
        shopName: tenant.name,
        shopCode: tenant.code,
        ownerName: tenant.businessProfile?.businessName ?? tenant.name,
        ownerPhone: tenant.ownerPhone,
        ownerEmail: tenant.ownerEmail,
        city: tenant.city ?? tenant.businessProfile?.city ?? "Tamil Nadu",
        marketLocation: tenant.marketLocation ?? tenant.businessProfile?.addressLine1 ?? "Mandi Market",
        status: tenant.status,
        maxUsers: tenant.maxUsers,
        trialEndsAt: tenant.trialEndsAt,
        subscriptionEndsAt: tenant.subscriptionEndsAt,
        enabledFeatures: tenant.enabledFeatures ?? ALL_MANDI_FEATURES,
        issuedAt: tenant.createdAt,
      };

      return sendSuccess(res, payload, "License certificate data retrieved.");
    } catch (err) {
      next(err);
    }
  }
);

// GET /api/v1/super-admin/businesses/:id/active-sessions
superAdminRouter.get(
  "/businesses/:id/active-sessions",
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const sessions = await prisma.activeUserSession.findMany({
        where: { tenantId: req.params.id },
        include: {
          user: {
            select: { id: true, username: true, fullName: true, role: { select: { name: true } } },
          },
        },
        orderBy: { lastActiveAt: "desc" },
      });

      const tenant = await prisma.tenant.findUnique({
        where: { id: req.params.id },
        select: { maxUsers: true },
      });

      return sendSuccess(res, {
        sessions,
        maxUsers: tenant?.maxUsers ?? 3,
        occupiedSeats: sessions.length,
      });
    } catch (err) {
      next(err);
    }
  }
);

// DELETE /api/v1/super-admin/businesses/:id/active-sessions/:userId
superAdminRouter.delete(
  "/businesses/:id/active-sessions/:userId",
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      await prisma.activeUserSession.deleteMany({
        where: { tenantId: req.params.id, userId: req.params.userId },
      });

      return sendSuccess(res, { revoked: true }, "User session revoked and seat freed.");
    } catch (err) {
      next(err);
    }
  }
);

// GET /api/v1/super-admin/admins
superAdminRouter.get("/admins", async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const admins = await prisma.user.findMany({
      where: { role: { code: "ADMIN" }, deletedAt: null },
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        username: true,
        fullName: true,
        email: true,
        phone: true,
        status: true,
        lastLoginAt: true,
        tenantId: true,
        tenant: { select: { id: true, name: true, code: true, status: true } },
      },
    });
    return sendSuccess(res, admins);
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/super-admin/admins
superAdminRouter.post("/admins", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const schema = z.object({
      tenantId: z.string().uuid(),
      username: z.string().min(3),
      fullName: z.string().min(2),
      email: z.string().email().optional(),
      phone: z.string().optional(),
      password: z.string().min(6),
    });
    const body = schema.parse(req.body);
    const adminRole = await prisma.role.findUnique({ where: { code: "ADMIN" } });
    if (!adminRole) throw new AppError(500, "ROLE_MISSING", "Admin role missing.");

    const passwordHash = await bcrypt.hash(body.password, 12);
    const admin = await prisma.user.create({
      data: {
        tenantId: body.tenantId,
        roleId: adminRole.id,
        username: body.username,
        fullName: body.fullName,
        email: body.email ?? null,
        phone: body.phone ?? null,
        passwordHash,
        status: "ACTIVE",
        createdBy: req.user!.sub,
      },
    });

    await recordAuditLog({
      userId: req.user!.sub,
      tenantId: body.tenantId,
      action: "ADMIN_ACCOUNT_CREATED",
      entityType: "User",
      entityId: admin.id,
    });

    return sendSuccess(
      res,
      { id: admin.id, username: admin.username, fullName: admin.fullName, tenantId: admin.tenantId },
      "Admin account created.",
      201
    );
  } catch (err) {
    next(err);
  }
});

// PATCH /api/v1/super-admin/admins/:id
superAdminRouter.patch("/admins/:id", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const schema = z.object({
      fullName: z.string().min(2).optional(),
      email: z.string().email().optional(),
      phone: z.string().optional(),
      status: z.enum(["ACTIVE", "SUSPENDED", "DEACTIVATED"]).optional(),
      tenantId: z.string().uuid().optional(),
    });
    const body = schema.parse(req.body);
    const updated = await prisma.user.update({
      where: { id: req.params.id },
      data: { ...body, updatedBy: req.user!.sub },
    });
    return sendSuccess(res, {
      id: updated.id,
      username: updated.username,
      status: updated.status,
      tenantId: updated.tenantId,
    });
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/super-admin/admins/:id/reset-password
superAdminRouter.post(
  "/admins/:id/reset-password",
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { newPassword } = z.object({ newPassword: z.string().min(6) }).parse(req.body);
      const passwordHash = await bcrypt.hash(newPassword, 12);
      await prisma.$transaction([
        prisma.user.update({
          where: { id: req.params.id },
          data: { passwordHash, failedLoginAttempts: 0, lockedUntil: null },
        }),
        prisma.refreshToken.updateMany({
          where: { userId: req.params.id, revokedAt: null },
          data: { revokedAt: new Date() },
        }),
      ]);
      await recordAuditLog({
        userId: req.user!.sub,
        action: "SUPER_ADMIN_RESET_ADMIN_PASSWORD",
        entityType: "User",
        entityId: req.params.id,
      });
      return sendSuccess(res, { reset: true }, "Admin password reset and active sessions revoked.");
    } catch (err) {
      next(err);
    }
  }
);

// GET /api/v1/super-admin/plans
superAdminRouter.get("/plans", async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const plans = await prisma.subscriptionPlan.findMany({
      orderBy: { monthlyPrice: "asc" },
      include: { planFeatures: true, _count: { select: { subscriptions: true } } },
    });
    return sendSuccess(res, plans);
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/super-admin/plans
superAdminRouter.post("/plans", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const schema = z.object({
      code: z.string().min(2),
      name: z.string().min(2),
      description: z.string().optional(),
      monthlyPrice: z.coerce.number().min(0),
      annualPrice: z.coerce.number().min(0),
      trialDays: z.coerce.number().int().min(0).default(14),
      maxUsers: z.coerce.number().int().min(1).default(5),
      maxGoodsRecords: z.coerce.number().int().min(10).default(500),
      maxBuyersAndSellers: z.coerce.number().int().min(10).default(1000),
      maxStorageMb: z.coerce.number().int().min(100).default(1024),
      enableSmartChart: z.boolean().default(true),
      enableAuctions: z.boolean().default(true),
      enableReports: z.boolean().default(true),
      enablePdfExport: z.boolean().default(true),
      enableBackup: z.boolean().default(false),
      enableApiAccess: z.boolean().default(false),
      enableMobileAccess: z.boolean().default(true),
      enableWhatsApp: z.boolean().default(false),
    });
    const body = schema.parse(req.body);
    const plan = await prisma.subscriptionPlan.create({ data: body });
    return sendSuccess(res, plan, "Subscription plan created.", 201);
  } catch (err) {
    next(err);
  }
});

// PATCH /api/v1/super-admin/plans/:id
superAdminRouter.patch("/plans/:id", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const plan = await prisma.subscriptionPlan.update({
      where: { id: req.params.id },
      data: req.body,
    });
    return sendSuccess(res, plan, "Subscription plan updated.");
  } catch (err) {
    next(err);
  }
});

// DELETE /api/v1/super-admin/plans/:id
superAdminRouter.delete("/plans/:id", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const plan = await prisma.subscriptionPlan.update({
      where: { id: req.params.id },
      data: { isActive: false, isArchived: true },
    });
    return sendSuccess(res, plan, "Subscription plan archived.");
  } catch (err) {
    next(err);
  }
});

// GET /api/v1/super-admin/subscriptions
superAdminRouter.get("/subscriptions", async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const subs = await prisma.subscription.findMany({
      orderBy: { createdAt: "desc" },
      include: {
        tenant: { select: { id: true, name: true, code: true, status: true } },
        plan: true,
      },
    });
    return sendSuccess(res, subs);
  } catch (err) {
    next(err);
  }
});

// PATCH /api/v1/super-admin/subscriptions/:id
superAdminRouter.patch(
  "/subscriptions/:id",
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const schema = z.object({
        planId: z.string().uuid().optional(),
        status: z
          .enum(["TRIAL", "ACTIVE", "PAST_DUE", "EXPIRED", "SUSPENDED", "CANCELLED"])
          .optional(),
        billingCycle: z.enum(["MONTHLY", "ANNUAL"]).optional(),
        endDate: z.coerce.date().optional(),
        notes: z.string().optional(),
      });
      const body = schema.parse(req.body);
      const updated = await prisma.subscription.update({
        where: { id: req.params.id },
        data: body,
        include: { plan: true, tenant: true },
      });

      await recordAuditLog({
        userId: req.user!.sub,
        tenantId: updated.tenantId,
        action: "SUBSCRIPTION_MODIFIED",
        entityType: "Subscription",
        entityId: updated.id,
        metadata: body,
      });

      return sendSuccess(res, updated, "Subscription updated.");
    } catch (err) {
      next(err);
    }
  }
);

// GET /api/v1/super-admin/payments
superAdminRouter.get("/payments", async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const payments = await prisma.subscriptionPayment.findMany({
      orderBy: { createdAt: "desc" },
      include: {
        tenant: { select: { id: true, name: true, code: true } },
        subscription: { include: { plan: { select: { name: true, code: true } } } },
        invoices: true,
      },
    });
    return sendSuccess(res, payments);
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/super-admin/payments/verify-razorpay
superAdminRouter.post(
  "/payments/verify-razorpay",
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const schema = z.object({
        paymentRecordId: z.string().uuid(),
        razorpayOrderId: z.string(),
        razorpayPaymentId: z.string(),
        razorpaySignature: z.string(),
      });
      const body = schema.parse(req.body);

      const isValid = verifyRazorpaySignature(
        body.razorpayOrderId,
        body.razorpayPaymentId,
        body.razorpaySignature
      );

      if (!isValid) {
        throw new AppError(400, "INVALID_SIGNATURE", "Razorpay payment signature verification failed.");
      }

      const updated = await prisma.subscriptionPayment.update({
        where: { id: body.paymentRecordId },
        data: {
          status: "SUCCESS",
          gatewayOrderId: body.razorpayOrderId,
          gatewayPaymentId: body.razorpayPaymentId,
          gatewaySignature: body.razorpaySignature,
          paidAt: new Date(),
        },
      });

      return sendSuccess(res, updated, "Razorpay payment verified and settled.");
    } catch (err) {
      next(err);
    }
  }
);

// GET /api/v1/super-admin/reports
superAdminRouter.get("/reports", async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const [byPlan, byStatus, paymentSummary] = await Promise.all([
      prisma.subscription.groupBy({
        by: ["planId"],
        _count: { _all: true },
      }),
      prisma.tenant.groupBy({
        by: ["status"],
        _count: { _all: true },
      }),
      prisma.subscriptionPayment.groupBy({
        by: ["status"],
        _sum: { amount: true },
        _count: { _all: true },
      }),
    ]);

    return sendSuccess(res, {
      subscriptionsByPlan: byPlan,
      tenantsByStatus: byStatus,
      paymentSummary,
    });
  } catch (err) {
    next(err);
  }
});

// GET /api/v1/super-admin/audit-logs
superAdminRouter.get("/audit-logs", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page, limit, skip } = parsePagination(req.query);
    const [logs, total] = await Promise.all([
      prisma.auditLog.findMany({
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          tenant: { select: { name: true, code: true } },
          user: { select: { username: true, fullName: true } },
        },
      }),
      prisma.auditLog.count(),
    ]);
    return sendSuccess(res, logs, "Audit logs retrieved.", 200, { page, limit, total });
  } catch (err) {
    next(err);
  }
});

// GET /api/v1/super-admin/settings
superAdminRouter.get("/settings", async (_req: Request, res: Response, next: NextFunction) => {
  try {
    let settings = await prisma.platformSetting.findFirst();
    if (!settings) {
      settings = await prisma.platformSetting.create({ data: {} });
    }
    return sendSuccess(res, settings);
  } catch (err) {
    next(err);
  }
});

// PATCH /api/v1/super-admin/settings
superAdminRouter.patch("/settings", async (req: Request, res: Response, next: NextFunction) => {
  try {
    let settings = await prisma.platformSetting.findFirst();
    if (!settings) {
      settings = await prisma.platformSetting.create({ data: { ...req.body, updatedBy: req.user!.sub } });
    } else {
      settings = await prisma.platformSetting.update({
        where: { id: settings.id },
        data: { ...req.body, updatedBy: req.user!.sub },
      });
    }
    await recordAuditLog({
      userId: req.user!.sub,
      action: "PLATFORM_SETTINGS_UPDATED",
      entityType: "PlatformSetting",
      entityId: settings.id,
    });
    return sendSuccess(res, settings, "Platform settings saved.");
  } catch (err) {
    next(err);
  }
});
