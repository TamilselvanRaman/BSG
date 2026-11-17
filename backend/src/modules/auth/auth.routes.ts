import { Router, Request, Response, NextFunction } from "express";
import bcrypt from "bcryptjs";
import crypto from "crypto";
import { z } from "zod";
import { prisma } from "../../config/prisma";
import { AppError, sendSuccess } from "../../utils/response";
import {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
  hashToken,
} from "../../utils/crypto";
import { authenticate } from "../../middleware/auth";
import { recordAuditLog } from "../../utils/auditLogger";

export const authRouter = Router();

const loginSchema = z.object({
  username: z.string().min(2),
  password: z.string().min(4),
  rememberMe: z.boolean().optional(),
});

const registerBusinessSchema = z.object({
  businessName: z.string().min(2),
  ownerFullName: z.string().min(2),
  username: z.string().min(3).regex(/^[a-zA-Z0-9_.-]+$/),
  password: z.string().min(6),
  email: z.string().email(),
  phone: z.string().min(8),
  city: z.string().optional(),
  gstNumber: z.string().optional(),
  planCode: z.string().optional(),
});

function getRedirectPath(role: "SUPER_ADMIN" | "ADMIN" | "BUSINESS_USER"): string {
  if (role === "SUPER_ADMIN") return "/super-admin/dashboard";
  if (role === "ADMIN") return "/admin/dashboard";
  return "/workspace/dashboard";
}

// POST /api/v1/auth/login
authRouter.post("/login", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const body = loginSchema.parse(req.body);

    const user = await prisma.user.findUnique({
      where: { username: body.username },
      include: {
        role: {
          include: {
            rolePermissions: { include: { permission: true } },
          },
        },
        userPermissions: { include: { permission: true } },
        tenant: true,
      },
    });

    if (!user || user.deletedAt) {
      throw new AppError(401, "INVALID_CREDENTIALS", "Invalid username or password.");
    }

    if (user.lockedUntil && user.lockedUntil > new Date()) {
      throw new AppError(
        423,
        "ACCOUNT_LOCKED",
        "Account is temporarily locked due to multiple failed login attempts. Please try again later."
      );
    }

    const passwordValid = await bcrypt.compare(body.password, user.passwordHash);
    if (!passwordValid) {
      const attempts = user.failedLoginAttempts + 1;
      const lockedUntil = attempts >= 5 ? new Date(Date.now() + 15 * 60 * 1000) : null;
      await prisma.user.update({
        where: { id: user.id },
        data: { failedLoginAttempts: attempts, lockedUntil },
      });
      await recordAuditLog({
        tenantId: user.tenantId,
        userId: user.id,
        action: "AUTH_LOGIN_FAILED",
        entityType: "User",
        entityId: user.id,
        ipAddress: req.ip,
      });
      throw new AppError(401, "INVALID_CREDENTIALS", "Invalid username or password.");
    }

    if (user.status !== "ACTIVE") {
      throw new AppError(
        403,
        `ACCOUNT_${user.status}`,
        `Your account status is ${user.status}. Please contact your administrator.`
      );
    }

    if (
      user.role.code !== "SUPER_ADMIN" &&
      user.tenant &&
      (user.tenant.status === "SUSPENDED" || user.tenant.status === "CANCELLED")
    ) {
      throw new AppError(
        403,
        "TENANT_SUSPENDED",
        `Business workspace '${user.tenant.name}' is currently ${user.tenant.status.toLowerCase()}.`
      );
    }

    // Check maximum 3 users concurrent seat quota per tenant
    if (user.role.code !== "SUPER_ADMIN" && user.tenantId && user.tenant) {
      const maxAllowed = user.tenant.maxUsers ?? 3;
      const staleThreshold = new Date(Date.now() - 24 * 60 * 60 * 1000);
      await prisma.activeUserSession.deleteMany({
        where: { tenantId: user.tenantId, lastActiveAt: { lt: staleThreshold } },
      });

      const currentSessions = await prisma.activeUserSession.findMany({
        where: { tenantId: user.tenantId },
      });
      const activeUserIds = new Set(currentSessions.map((s) => s.userId));

      if (!activeUserIds.has(user.id) && activeUserIds.size >= maxAllowed) {
        throw new AppError(
          403,
          "SEAT_LIMIT_EXCEEDED",
          `Maximum ${maxAllowed} user seats allowed for this shop license (${activeUserIds.size}/${maxAllowed} active). Please log out on another device or contact Admin.`
        );
      }

      await prisma.activeUserSession.upsert({
        where: { tenantId_userId: { tenantId: user.tenantId, userId: user.id } },
        create: {
          tenantId: user.tenantId,
          userId: user.id,
          deviceInfo: (req.headers["user-agent"] ?? "Web Browser").slice(0, 190),
          ipAddress: req.ip ?? null,
          lastActiveAt: new Date(),
        },
        update: {
          deviceInfo: (req.headers["user-agent"] ?? "Web Browser").slice(0, 190),
          ipAddress: req.ip ?? null,
          lastActiveAt: new Date(),
        },
      });
    }

    // Compute effective permissions
    const rolePermSet = new Set(
      user.role.rolePermissions.map((rp) => rp.permission.code)
    );
    for (const up of user.userPermissions) {
      if (up.granted) {
        rolePermSet.add(up.permission.code);
      } else {
        rolePermSet.delete(up.permission.code);
      }
    }
    const permissions = Array.from(rolePermSet);

    const accessToken = signAccessToken({
      sub: user.id,
      username: user.username,
      role: user.role.code,
      tenantId: user.tenantId,
      permissions,
    });

    const { rawToken: refreshToken, tokenHash } = signRefreshToken(user.id);
    const expiresDays = body.rememberMe ? 30 : 7;

    await prisma.$transaction([
      prisma.user.update({
        where: { id: user.id },
        data: {
          failedLoginAttempts: 0,
          lockedUntil: null,
          lastLoginAt: new Date(),
        },
      }),
      prisma.refreshToken.create({
        data: {
          userId: user.id,
          tokenHash,
          deviceInfo: req.headers["user-agent"] ?? "Unknown",
          ipAddress: req.ip ?? null,
          expiresAt: new Date(Date.now() + expiresDays * 24 * 60 * 60 * 1000),
        },
      }),
    ]);

    await recordAuditLog({
      tenantId: user.tenantId,
      userId: user.id,
      action: "AUTH_LOGIN_SUCCESS",
      entityType: "User",
      entityId: user.id,
      ipAddress: req.ip,
    });

    res.cookie("refreshToken", refreshToken, {
      httpOnly: true,
      sameSite: "lax",
      secure: process.env.NODE_ENV === "production",
      maxAge: expiresDays * 24 * 60 * 60 * 1000,
    });

    return sendSuccess(res, {
      accessToken,
      refreshToken,
      redirectTo: getRedirectPath(user.role.code),
      user: {
        id: user.id,
        username: user.username,
        fullName: user.fullName,
        email: user.email,
        phone: user.phone,
        role: user.role.code,
        tenantId: user.tenantId,
        tenantName: user.tenant?.name ?? null,
        tenant: user.tenant
          ? {
              id: user.tenant.id,
              code: user.tenant.code,
              name: user.tenant.name,
              status: user.tenant.status,
              licenseKey: user.tenant.licenseKey,
              maxUsers: user.tenant.maxUsers,
              trialEndsAt: user.tenant.trialEndsAt,
              subscriptionEndsAt: user.tenant.subscriptionEndsAt,
              enabledFeatures: user.tenant.enabledFeatures,
            }
          : null,
        permissions,
      },
    });
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/auth/register-business
authRouter.post("/register-business", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const body = registerBusinessSchema.parse(req.body);

    const existingUser = await prisma.user.findFirst({
      where: { OR: [{ username: body.username }, { email: body.email }] },
    });
    if (existingUser) {
      throw new AppError(409, "USER_EXISTS", "Username or email is already registered.");
    }

    const adminRole = await prisma.role.findUnique({ where: { code: "ADMIN" } });
    if (!adminRole) {
      throw new AppError(500, "ROLE_NOT_INITIALIZED", "System roles are not seeded.");
    }

    const plan =
      (body.planCode
        ? await prisma.subscriptionPlan.findUnique({ where: { code: body.planCode } })
        : null) ??
      (await prisma.subscriptionPlan.findFirst({
        where: { isActive: true },
        orderBy: { monthlyPrice: "asc" },
      }));

    if (!plan) {
      throw new AppError(500, "PLAN_NOT_FOUND", "No active subscription plan available.");
    }

    const passwordHash = await bcrypt.hash(body.password, 12);
    const slug = `${body.businessName
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-|-$/g, "")}-${crypto.randomBytes(2).toString("hex")}`;
    const tenantCode = `BIZ-${Date.now().toString().slice(-6)}`;
    const trialEndsAt = new Date(Date.now() + plan.trialDays * 24 * 60 * 60 * 1000);

    const result = await prisma.$transaction(async (tx) => {
      const tenant = await tx.tenant.create({
        data: {
          code: tenantCode,
          name: body.businessName,
          slug,
          status: "TRIAL",
          ownerEmail: body.email,
          ownerPhone: body.phone,
        },
      });

      await tx.businessProfile.create({
        data: {
          tenantId: tenant.id,
          businessName: body.businessName,
          phone: body.phone,
          email: body.email,
          city: body.city ?? null,
          gstNumber: body.gstNumber ?? null,
        },
      });

      await tx.businessSettings.create({
        data: {
          tenantId: tenant.id,
          supportedUnits: ["KG", "BAG", "QUINTAL", "CRATE", "BOX"],
        },
      });

      const user = await tx.user.create({
        data: {
          tenantId: tenant.id,
          roleId: adminRole.id,
          username: body.username,
          email: body.email,
          phone: body.phone,
          fullName: body.ownerFullName,
          passwordHash,
          status: "ACTIVE",
        },
      });

      await tx.tenantUser.create({
        data: {
          tenantId: tenant.id,
          userId: user.id,
          designation: "Owner / Business Admin",
          isPrimary: true,
        },
      });

      const subscription = await tx.subscription.create({
        data: {
          tenantId: tenant.id,
          planId: plan.id,
          status: "TRIAL",
          billingCycle: "MONTHLY",
          startDate: new Date(),
          endDate: trialEndsAt,
          trialEndsAt,
        },
      });

      return { tenant, user, subscription };
    });

    await recordAuditLog({
      tenantId: result.tenant.id,
      userId: result.user.id,
      action: "BUSINESS_REGISTERED",
      entityType: "Tenant",
      entityId: result.tenant.id,
      ipAddress: req.ip,
    });

    return sendSuccess(
      res,
      {
        tenantId: result.tenant.id,
        tenantCode: result.tenant.code,
        businessName: result.tenant.name,
        username: result.user.username,
        subscriptionStatus: result.subscription.status,
        trialEndsAt: result.subscription.trialEndsAt,
      },
      "Business registered successfully with trial subscription.",
      201
    );
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/auth/refresh
authRouter.post("/refresh", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const rawToken = req.body?.refreshToken || req.cookies?.refreshToken;
    if (!rawToken) {
      throw new AppError(401, "MISSING_REFRESH_TOKEN", "Refresh token is required.");
    }

    verifyRefreshToken(rawToken);
    const tokenHash = hashToken(rawToken);

    const stored = await prisma.refreshToken.findUnique({
      where: { tokenHash },
      include: {
        user: {
          include: {
            role: { include: { rolePermissions: { include: { permission: true } } } },
            userPermissions: { include: { permission: true } },
          },
        },
      },
    });

    if (!stored || stored.revokedAt || stored.expiresAt < new Date()) {
      throw new AppError(401, "INVALID_REFRESH_TOKEN", "Refresh token is expired or revoked.");
    }

    const user = stored.user;
    if (user.status !== "ACTIVE") {
      throw new AppError(403, "ACCOUNT_INACTIVE", "User account is not active.");
    }

    const rolePermSet = new Set(user.role.rolePermissions.map((rp) => rp.permission.code));
    for (const up of user.userPermissions) {
      if (up.granted) rolePermSet.add(up.permission.code);
      else rolePermSet.delete(up.permission.code);
    }
    const permissions = Array.from(rolePermSet);

    const newAccessToken = signAccessToken({
      sub: user.id,
      username: user.username,
      role: user.role.code,
      tenantId: user.tenantId,
      permissions,
    });

    const { rawToken: newRefreshToken, tokenHash: newHash } = signRefreshToken(user.id);

    await prisma.$transaction([
      prisma.refreshToken.update({
        where: { id: stored.id },
        data: { revokedAt: new Date(), replacedBy: newHash },
      }),
      prisma.refreshToken.create({
        data: {
          userId: user.id,
          tokenHash: newHash,
          deviceInfo: req.headers["user-agent"] ?? "Unknown",
          ipAddress: req.ip ?? null,
          expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
        },
      }),
    ]);

    return sendSuccess(res, {
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    });
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/auth/logout
authRouter.post("/logout", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const rawToken = req.body?.refreshToken || req.cookies?.refreshToken;
    if (rawToken) {
      const tokenHash = hashToken(rawToken);
      await prisma.refreshToken.updateMany({
        where: { tokenHash, revokedAt: null },
        data: { revokedAt: new Date() },
      });
    }
    res.clearCookie("refreshToken");
    return sendSuccess(res, { loggedOut: true }, "Logged out successfully.");
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/auth/logout-all
authRouter.post("/logout-all", authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    await prisma.refreshToken.updateMany({
      where: { userId: req.user!.sub, revokedAt: null },
      data: { revokedAt: new Date() },
    });
    res.clearCookie("refreshToken");
    return sendSuccess(res, { loggedOutAll: true }, "Revoked sessions across all devices.");
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/auth/forgot-password
authRouter.post("/forgot-password", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { usernameOrEmail } = z.object({ usernameOrEmail: z.string().min(2) }).parse(req.body);
    const user = await prisma.user.findFirst({
      where: { OR: [{ username: usernameOrEmail }, { email: usernameOrEmail }] },
    });

    if (!user) {
      return sendSuccess(res, { sent: true }, "If the account exists, a password reset token has been generated.");
    }

    const rawResetToken = crypto.randomBytes(24).toString("hex");
    const tokenHash = hashToken(rawResetToken);

    await prisma.passwordResetToken.create({
      data: {
        userId: user.id,
        tokenHash,
        expiresAt: new Date(Date.now() + 30 * 60 * 1000),
      },
    });

    return sendSuccess(
      res,
      {
        sent: true,
        resetTokenPreview: process.env.NODE_ENV !== "production" ? rawResetToken : undefined,
      },
      "Password reset instructions issued."
    );
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/auth/reset-password
authRouter.post("/reset-password", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { token, newPassword } = z
      .object({ token: z.string().min(10), newPassword: z.string().min(6) })
      .parse(req.body);

    const tokenHash = hashToken(token);
    const resetRecord = await prisma.passwordResetToken.findUnique({
      where: { tokenHash },
    });

    if (!resetRecord || resetRecord.usedAt || resetRecord.expiresAt < new Date()) {
      throw new AppError(400, "INVALID_RESET_TOKEN", "Reset token is invalid or expired.");
    }

    const passwordHash = await bcrypt.hash(newPassword, 12);

    await prisma.$transaction([
      prisma.user.update({
        where: { id: resetRecord.userId },
        data: { passwordHash, failedLoginAttempts: 0, lockedUntil: null },
      }),
      prisma.passwordResetToken.update({
        where: { id: resetRecord.id },
        data: { usedAt: new Date() },
      }),
      prisma.refreshToken.updateMany({
        where: { userId: resetRecord.userId, revokedAt: null },
        data: { revokedAt: new Date() },
      }),
    ]);

    return sendSuccess(res, { reset: true }, "Password has been reset successfully.");
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/auth/change-password
authRouter.post("/change-password", authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { currentPassword, newPassword } = z
      .object({ currentPassword: z.string().min(4), newPassword: z.string().min(6) })
      .parse(req.body);

    const user = await prisma.user.findUnique({ where: { id: req.user!.sub } });
    if (!user) {
      throw new AppError(404, "USER_NOT_FOUND", "User not found.");
    }

    const valid = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!valid) {
      throw new AppError(400, "INVALID_PASSWORD", "Current password is incorrect.");
    }

    const passwordHash = await bcrypt.hash(newPassword, 12);
    await prisma.user.update({
      where: { id: user.id },
      data: { passwordHash },
    });

    return sendSuccess(res, { updated: true }, "Password updated successfully.");
  } catch (err) {
    next(err);
  }
});

// GET /api/v1/auth/me
authRouter.get("/me", authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user!.sub },
      include: {
        role: true,
        tenant: {
          include: {
            businessProfile: true,
            businessSettings: true,
            subscriptions: {
              orderBy: { createdAt: "desc" },
              take: 1,
              include: { plan: true },
            },
          },
        },
      },
    });

    if (!user) {
      throw new AppError(404, "USER_NOT_FOUND", "Authenticated user not found.");
    }

    return sendSuccess(res, {
      id: user.id,
      username: user.username,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      role: user.role.code,
      status: user.status,
      tenantId: user.tenantId,
      permissions: req.user!.permissions,
      redirectTo: getRedirectPath(user.role.code),
      tenant: user.tenant
        ? {
            id: user.tenant.id,
            code: user.tenant.code,
            name: user.tenant.name,
            status: user.tenant.status,
            profile: user.tenant.businessProfile,
            settings: user.tenant.businessSettings,
            activeSubscription: user.tenant.subscriptions[0] ?? null,
          }
        : null,
    });
  } catch (err) {
    next(err);
  }
});
