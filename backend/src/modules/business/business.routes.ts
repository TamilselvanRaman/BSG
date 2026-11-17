import { Router, Request, Response, NextFunction } from "express";
import bcrypt from "bcryptjs";
import { z } from "zod";
import { prisma } from "../../config/prisma";
import {
  authenticate,
  requireTenantScope,
  requireRoles,
  enforceSubscriptionQuota,
} from "../../middleware/auth";
import { AppError, sendSuccess } from "../../utils/response";
import { recordAuditLog } from "../../utils/auditLogger";

export const businessRouter = Router();

businessRouter.use(authenticate, requireTenantScope);

// GET /api/v1/business/dashboard
businessRouter.get("/dashboard", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const tenantId = req.tenantId!;

    const [
      totalGoods,
      totalBuyers,
      totalSellers,
      activeLots,
      purchasesAgg,
      salesAgg,
      buyersBalanceAgg,
      sellersBalanceAgg,
      allGoods,
      recentPurchases,
      recentSales,
      recentPayments,
      activeSubscription,
    ] = await Promise.all([
      prisma.goods.count({ where: { tenantId, deletedAt: null } }),
      prisma.buyer.count({ where: { tenantId, deletedAt: null } }),
      prisma.seller.count({ where: { tenantId, deletedAt: null } }),
      prisma.goodsLot.count({ where: { tenantId, status: { in: ["OPEN", "PARTIAL"] } } }),
      prisma.purchaseBill.aggregate({
        where: { tenantId, status: { not: "CANCELLED" } },
        _sum: { grandTotal: true, outstandingAmount: true },
        _count: { _all: true },
      }),
      prisma.salesBill.aggregate({
        where: { tenantId, status: { not: "CANCELLED" } },
        _sum: { grandTotal: true, outstandingAmount: true },
        _count: { _all: true },
      }),
      prisma.buyer.aggregate({
        where: { tenantId, deletedAt: null },
        _sum: { currentBalance: true },
      }),
      prisma.seller.aggregate({
        where: { tenantId, deletedAt: null },
        _sum: { currentBalance: true },
      }),
      prisma.goods.findMany({
        where: { tenantId, deletedAt: null },
        select: {
          id: true,
          name: true,
          code: true,
          unit: true,
          currentStock: true,
          minimumStock: true,
          purchasePrice: true,
          sellingPrice: true,
        },
      }),
      prisma.purchaseBill.findMany({
        where: { tenantId },
        orderBy: { billDate: "desc" },
        take: 5,
        include: { seller: { select: { name: true, code: true } } },
      }),
      prisma.salesBill.findMany({
        where: { tenantId },
        orderBy: { billDate: "desc" },
        take: 5,
        include: { buyer: { select: { name: true, code: true } } },
      }),
      prisma.payment.findMany({
        where: { tenantId },
        orderBy: { paymentDate: "desc" },
        take: 6,
        include: {
          buyer: { select: { name: true } },
          seller: { select: { name: true } },
        },
      }),
      prisma.subscription.findFirst({
        where: { tenantId },
        orderBy: { createdAt: "desc" },
        include: { plan: true },
      }),
    ]);

    const totalInventoryValue = allGoods.reduce(
      (sum, g) => sum + Number(g.currentStock) * Number(g.purchasePrice),
      0
    );
    const lowStockItems = allGoods.filter(
      (g) => Number(g.currentStock) <= Number(g.minimumStock)
    );

    return sendSuccess(res, {
      metrics: {
        totalGoods,
        totalBuyers,
        totalSellers,
        activeLots,
        totalPurchasesAmount: Number(purchasesAgg._sum.grandTotal ?? 0),
        totalPurchasesCount: purchasesAgg._count._all,
        totalSalesAmount: Number(salesAgg._sum.grandTotal ?? 0),
        totalSalesCount: salesAgg._count._all,
        totalInventoryValue: Math.round(totalInventoryValue * 100) / 100,
        totalReceivables: Number(buyersBalanceAgg._sum.currentBalance ?? 0),
        totalPayables: Number(sellersBalanceAgg._sum.currentBalance ?? 0),
        pendingSalesCollection: Number(salesAgg._sum.outstandingAmount ?? 0),
        pendingPurchasePayable: Number(purchasesAgg._sum.outstandingAmount ?? 0),
        lowStockCount: lowStockItems.length,
      },
      lowStockItems,
      recentPurchases,
      recentSales,
      recentPayments,
      subscription: activeSubscription,
    });
  } catch (err) {
    next(err);
  }
});

// GET /api/v1/business/search (Global Search across Buyers, Sellers, Goods Entries, Bills, Lots)
businessRouter.get("/search", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const tenantId = req.tenantId!;
    const q = typeof req.query.q === "string" ? req.query.q.trim() : "";
    if (!q) {
      return sendSuccess(res, { buyers: [], sellers: [], lots: [], salesBills: [], purchaseBills: [] });
    }

    const [buyers, sellers, lots, salesBills, purchaseBills] = await Promise.all([
      prisma.buyer.findMany({
        where: {
          tenantId,
          deletedAt: null,
          OR: [{ name: { contains: q } }, { phone: { contains: q } }, { code: { contains: q } }],
        },
        take: 5,
      }),
      prisma.seller.findMany({
        where: {
          tenantId,
          deletedAt: null,
          OR: [{ name: { contains: q } }, { phone: { contains: q } }, { code: { contains: q } }],
        },
        take: 5,
      }),
      prisma.goodsLot.findMany({
        where: { tenantId, lotNumber: { contains: q } },
        take: 5,
        include: { seller: { select: { name: true } }, goods: { select: { name: true } } },
      }),
      prisma.salesBill.findMany({
        where: { tenantId, billNumber: { contains: q } },
        take: 5,
        include: { buyer: { select: { name: true } } },
      }),
      prisma.purchaseBill.findMany({
        where: { tenantId, billNumber: { contains: q } },
        take: 5,
        include: { seller: { select: { name: true } } },
      }),
    ]);

    return sendSuccess(res, { buyers, sellers, lots, salesBills, purchaseBills });
  } catch (err) {
    next(err);
  }
});

// GET /api/v1/business/profile
businessRouter.get("/profile", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const tenantId = req.tenantId!;
    const [profile, settings, subscription, tenant] = await Promise.all([
      prisma.businessProfile.findUnique({ where: { tenantId } }),
      prisma.businessSettings.findUnique({ where: { tenantId } }),
      prisma.subscription.findFirst({
        where: { tenantId },
        orderBy: { createdAt: "desc" },
        include: { plan: true },
      }),
      prisma.tenant.findUnique({
        where: { id: tenantId },
        select: {
          id: true,
          code: true,
          name: true,
          status: true,
          maxUsers: true,
          licenseKey: true,
          trialEndsAt: true,
          subscriptionEndsAt: true,
          enabledFeatures: true,
          city: true,
          marketLocation: true,
        },
      }),
    ]);
    return sendSuccess(res, { profile, settings, subscription, tenant });
  } catch (err) {
    next(err);
  }
});

// PATCH /api/v1/business/profile
businessRouter.patch(
  "/profile",
  requireRoles("ADMIN"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const { profile, settings } = req.body;

      const updatedProfile = profile
        ? await prisma.businessProfile.upsert({
            where: { tenantId },
            update: profile,
            create: { tenantId, businessName: profile.businessName ?? "My Business", phone: profile.phone ?? "", ...profile },
          })
        : await prisma.businessProfile.findUnique({ where: { tenantId } });

      const updatedSettings = settings
        ? await prisma.businessSettings.upsert({
            where: { tenantId },
            update: settings,
            create: { tenantId, supportedUnits: ["KG", "BAG", "QUINTAL"], ...settings },
          })
        : await prisma.businessSettings.findUnique({ where: { tenantId } });

      await recordAuditLog({
        tenantId,
        userId: req.user!.sub,
        action: "BUSINESS_PROFILE_UPDATED",
        entityType: "BusinessProfile",
        entityId: tenantId,
      });

      return sendSuccess(
        res,
        { profile: updatedProfile, settings: updatedSettings },
        "Business profile and customization settings updated."
      );
    } catch (err) {
      next(err);
    }
  }
);

// GET /api/v1/business/users
businessRouter.get(
  "/users",
  requireRoles("ADMIN"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const [users, availablePermissions, tenant, activeSessionsCount] = await Promise.all([
        prisma.user.findMany({
          where: { tenantId, deletedAt: null },
          orderBy: { createdAt: "desc" },
          select: {
            id: true,
            username: true,
            fullName: true,
            email: true,
            phone: true,
            status: true,
            lastLoginAt: true,
            createdAt: true,
            role: { select: { code: true, name: true } },
            userPermissions: { include: { permission: true } },
          },
        }),
        prisma.permission.findMany({
          where: { NOT: { module: "PLATFORM" } },
          orderBy: { code: "asc" },
        }),
        prisma.tenant.findUnique({
          where: { id: tenantId },
          select: {
            id: true,
            maxUsers: true,
            licenseKey: true,
            trialEndsAt: true,
            enabledFeatures: true,
          },
        }),
        prisma.activeUserSession.count({
          where: { tenantId },
        }),
      ]);
      return sendSuccess(res, {
        users,
        availablePermissions,
        maxUsers: tenant?.maxUsers ?? 3,
        licenseKey: tenant?.licenseKey,
        trialEndsAt: tenant?.trialEndsAt,
        activeSessionsCount,
      });
    } catch (err) {
      next(err);
    }
  }
);

// POST /api/v1/business/users
businessRouter.post(
  "/users",
  requireRoles("ADMIN"),
  enforceSubscriptionQuota("USERS"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const schema = z.object({
        username: z.string().min(3),
        fullName: z.string().min(2),
        email: z.string().email().optional(),
        phone: z.string().optional(),
        password: z.string().min(6),
        roleType: z.enum(["ADMIN", "BUSINESS_USER"]).default("BUSINESS_USER"),
        designation: z.string().optional(),
        permissions: z.array(z.string()).default([]),
      });
      const body = schema.parse(req.body);

      const targetRoleCode = body.roleType === "ADMIN" ? "ADMIN" : "BUSINESS_USER";
      const targetRole = await prisma.role.findUnique({ where: { code: targetRoleCode } });
      if (!targetRole) throw new AppError(500, "ROLE_MISSING", `${targetRoleCode} role not found.`);

      const passwordHash = await bcrypt.hash(body.password, 12);

      const created = await prisma.$transaction(async (tx) => {
        const user = await tx.user.create({
          data: {
            tenantId,
            roleId: targetRole.id,
            username: body.username,
            fullName: body.fullName,
            email: body.email ?? null,
            phone: body.phone ?? null,
            passwordHash,
            status: "ACTIVE",
            createdBy: req.user!.sub,
          },
        });

        await tx.tenantUser.create({
          data: {
            tenantId,
            userId: user.id,
            designation: body.designation ?? (body.roleType === "ADMIN" ? "Sub Admin / Manager" : "Staff / Operator"),
            isPrimary: false,
          },
        });

        if (body.permissions.length > 0) {
          const permRecords = await tx.permission.findMany({
            where: { code: { in: body.permissions } },
          });
          for (const perm of permRecords) {
            await tx.userPermission.create({
              data: {
                userId: user.id,
                permissionId: perm.id,
                granted: true,
                updatedBy: req.user!.sub,
              },
            });
          }
        }

        return user;
      });

      await recordAuditLog({
        tenantId,
        userId: req.user!.sub,
        action: "EMPLOYEE_CREATED",
        entityType: "User",
        entityId: created.id,
      });

      return sendSuccess(
        res,
        { id: created.id, username: created.username, fullName: created.fullName },
        "Employee user created.",
        201
      );
    } catch (err) {
      next(err);
    }
  }
);

// PATCH /api/v1/business/users/:id
businessRouter.patch(
  "/users/:id",
  requireRoles("ADMIN"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const target = await prisma.user.findFirst({
        where: { id: req.params.id, tenantId, deletedAt: null },
      });
      if (!target) throw new AppError(404, "USER_NOT_FOUND", "Employee not found in this business.");

      const schema = z.object({
        fullName: z.string().min(2).optional(),
        email: z.string().email().optional(),
        phone: z.string().optional(),
        status: z.enum(["ACTIVE", "SUSPENDED", "DEACTIVATED"]).optional(),
      });
      const body = schema.parse(req.body);

      const updated = await prisma.user.update({
        where: { id: target.id },
        data: { ...body, updatedBy: req.user!.sub },
      });

      return sendSuccess(res, {
        id: updated.id,
        username: updated.username,
        fullName: updated.fullName,
        status: updated.status,
      });
    } catch (err) {
      next(err);
    }
  }
);

// POST /api/v1/business/users/:id/reset-password
businessRouter.post(
  "/users/:id/reset-password",
  requireRoles("ADMIN"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const target = await prisma.user.findFirst({
        where: { id: req.params.id, tenantId, deletedAt: null },
      });
      if (!target) throw new AppError(404, "USER_NOT_FOUND", "Employee not found in this business.");

      const { newPassword } = z.object({ newPassword: z.string().min(6) }).parse(req.body);
      const passwordHash = await bcrypt.hash(newPassword, 12);

      await prisma.$transaction([
        prisma.user.update({
          where: { id: target.id },
          data: { passwordHash, failedLoginAttempts: 0, lockedUntil: null },
        }),
        prisma.refreshToken.updateMany({
          where: { userId: target.id, revokedAt: null },
          data: { revokedAt: new Date() },
        }),
      ]);

      return sendSuccess(res, { reset: true }, "Employee password reset.");
    } catch (err) {
      next(err);
    }
  }
);

// PATCH /api/v1/business/users/:id/permissions
businessRouter.patch(
  "/users/:id/permissions",
  requireRoles("ADMIN"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const target = await prisma.user.findFirst({
        where: { id: req.params.id, tenantId, deletedAt: null },
      });
      if (!target) throw new AppError(404, "USER_NOT_FOUND", "Employee not found in this business.");

      const { permissions } = z
        .object({
          permissions: z.array(
            z.object({
              code: z.string(),
              granted: z.boolean(),
            })
          ),
        })
        .parse(req.body);

      const permRecords = await prisma.permission.findMany({
        where: { code: { in: permissions.map((p) => p.code) } },
      });
      const permMap = new Map(permRecords.map((p) => [p.code, p.id]));

      await prisma.$transaction(
        permissions
          .filter((p) => permMap.has(p.code))
          .map((p) => {
            const permissionId = permMap.get(p.code)!;
            return prisma.userPermission.upsert({
              where: { userId_permissionId: { userId: target.id, permissionId } },
              update: { granted: p.granted, updatedBy: req.user!.sub },
              create: {
                userId: target.id,
                permissionId,
                granted: p.granted,
                updatedBy: req.user!.sub,
              },
            });
          })
      );

      await recordAuditLog({
        tenantId,
        userId: req.user!.sub,
        action: "EMPLOYEE_PERMISSIONS_UPDATED",
        entityType: "User",
        entityId: target.id,
        metadata: { permissions },
      });

      return sendSuccess(res, { updated: true }, "Employee permissions updated.");
    } catch (err) {
      next(err);
    }
  }
);
