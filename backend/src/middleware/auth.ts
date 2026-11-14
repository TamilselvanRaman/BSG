import { Request, Response, NextFunction } from "express";
import { verifyAccessToken, JwtAccessPayload } from "../utils/crypto";
import { AppError } from "../utils/response";
import { prisma } from "../config/prisma";

declare global {
  namespace Express {
    interface Request {
      user?: JwtAccessPayload;
      tenantId?: string;
    }
  }
}

export async function authenticate(req: Request, _res: Response, next: NextFunction) {
  try {
    const authHeader = req.headers.authorization;
    const token =
      authHeader && authHeader.startsWith("Bearer ")
        ? authHeader.slice(7).trim()
        : req.cookies?.accessToken;

    if (!token) {
      throw new AppError(401, "UNAUTHORIZED", "Authentication required. Missing access token.");
    }

    const payload = verifyAccessToken(token);
    req.user = payload;

    if (payload.tenantId) {
      req.tenantId = payload.tenantId;
    }

    next();
  } catch (err) {
    if (err instanceof AppError) {
      return next(err);
    }
    return next(new AppError(401, "INVALID_TOKEN", "Invalid or expired access token."));
  }
}

export function requireRoles(...allowedRoles: Array<"SUPER_ADMIN" | "ADMIN" | "BUSINESS_USER">) {
  return (req: Request, _res: Response, next: NextFunction) => {
    if (!req.user) {
      return next(new AppError(401, "UNAUTHORIZED", "Authentication required."));
    }
    if (!allowedRoles.includes(req.user.role)) {
      return next(
        new AppError(
          403,
          "FORBIDDEN_ROLE",
          `Access denied. Required role: ${allowedRoles.join(" or ")}.`
        )
      );
    }
    next();
  };
}

export function requirePermission(permissionCode: string) {
  return (req: Request, _res: Response, next: NextFunction) => {
    if (!req.user) {
      return next(new AppError(401, "UNAUTHORIZED", "Authentication required."));
    }
    // SUPER_ADMIN and Business ADMIN have full access to their respective scopes
    if (req.user.role === "SUPER_ADMIN" || req.user.role === "ADMIN") {
      return next();
    }
    if (!req.user.permissions.includes(permissionCode)) {
      return next(
        new AppError(
          403,
          "FORBIDDEN_PERMISSION",
          `You do not have permission '${permissionCode}' to perform this action.`
        )
      );
    }
    next();
  };
}

/**
 * Enforces strict multi-tenant isolation.
 * Extracts tenantId strictly from the verified JWT token.
 * Rejects any cross-tenant spoofing attempt in query or body parameters.
 */
export async function requireTenantScope(req: Request, _res: Response, next: NextFunction) {
  try {
    if (!req.user) {
      throw new AppError(401, "UNAUTHORIZED", "Authentication required.");
    }

    const tokenTenantId = req.user.tenantId;
    if (!tokenTenantId) {
      throw new AppError(
        403,
        "TENANT_REQUIRED",
        "This endpoint requires an active business tenant workspace."
      );
    }

    // Verify if caller tried to spoof another tenantId in body or query
    const bodyTenantId = req.body && typeof req.body === "object" ? req.body.tenantId : undefined;
    const queryTenantId = typeof req.query.tenantId === "string" ? req.query.tenantId : undefined;

    if (
      (bodyTenantId && bodyTenantId !== tokenTenantId) ||
      (queryTenantId && queryTenantId !== tokenTenantId)
    ) {
      throw new AppError(
        403,
        "CROSS_TENANT_VIOLATION",
        "Cross-tenant access attempt blocked. You may only access your assigned business tenant."
      );
    }

    const tenant = await prisma.tenant.findUnique({
      where: { id: tokenTenantId },
      select: { id: true, status: true, deletedAt: true },
    });

    if (!tenant || tenant.deletedAt) {
      throw new AppError(404, "TENANT_NOT_FOUND", "Assigned business workspace was not found.");
    }

    if (tenant.status === "SUSPENDED" || tenant.status === "CANCELLED") {
      throw new AppError(
        403,
        "TENANT_SUSPENDED",
        `Your business workspace is currently ${tenant.status.toLowerCase()}. Please contact support or renew your subscription.`
      );
    }

    req.tenantId = tokenTenantId;
    next();
  } catch (err) {
    next(err);
  }
}

/**
 * Enforces SaaS subscription status, expiry, feature flags, and record quotas.
 */
export function enforceSubscriptionQuota(
  resourceType?: "USERS" | "GOODS" | "PARTNERS" | "REPORTS" | "PDF_EXPORT" | "SMART_CHART"
) {
  return async (req: Request, _res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId;
      if (!tenantId) {
        return next();
      }

      const activeSub = await prisma.subscription.findFirst({
        where: { tenantId },
        orderBy: { createdAt: "desc" },
        include: { plan: true },
      });

      if (!activeSub) {
        throw new AppError(
          402,
          "SUBSCRIPTION_REQUIRED",
          "No active subscription found for this business. Please subscribe to a plan."
        );
      }

      const now = new Date();
      if (
        activeSub.status === "EXPIRED" ||
        activeSub.status === "SUSPENDED" ||
        activeSub.status === "CANCELLED" ||
        activeSub.endDate < now
      ) {
        throw new AppError(
          402,
          "SUBSCRIPTION_EXPIRED",
          "Your SaaS subscription has expired or is inactive. Please upgrade or renew your plan to continue."
        );
      }

      const plan = activeSub.plan;

      if (resourceType === "REPORTS" && !plan.enableReports) {
        throw new AppError(
          403,
          "PLAN_FEATURE_DISABLED",
          `Your current plan (${plan.name}) does not include advanced reports. Please upgrade your subscription.`
        );
      }

      if (resourceType === "PDF_EXPORT" && !plan.enablePdfExport) {
        throw new AppError(
          403,
          "PLAN_FEATURE_DISABLED",
          `Your current plan (${plan.name}) does not include PDF generation. Please upgrade your subscription.`
        );
      }

      if (resourceType === "SMART_CHART" && !plan.enableSmartChart) {
        throw new AppError(
          403,
          "PLAN_FEATURE_DISABLED",
          `Your current plan (${plan.name}) does not include Smart Chart & Auction modules.`
        );
      }

      if (req.method === "POST") {
        if (resourceType === "USERS") {
          const userCount = await prisma.user.count({
            where: { tenantId, deletedAt: null },
          });
          if (userCount >= plan.maxUsers) {
            throw new AppError(
              402,
              "QUOTA_EXCEEDED_USERS",
              `User limit reached (${plan.maxUsers} users on ${plan.name} plan). Upgrade your plan to add more employees.`
            );
          }
        } else if (resourceType === "GOODS") {
          const goodsCount = await prisma.goods.count({
            where: { tenantId, deletedAt: null },
          });
          if (goodsCount >= plan.maxGoodsRecords) {
            throw new AppError(
              402,
              "QUOTA_EXCEEDED_GOODS",
              `Goods limit reached (${plan.maxGoodsRecords} items on ${plan.name} plan). Upgrade your plan to add more goods.`
            );
          }
        } else if (resourceType === "PARTNERS") {
          const [buyerCount, sellerCount] = await Promise.all([
            prisma.buyer.count({ where: { tenantId, deletedAt: null } }),
            prisma.seller.count({ where: { tenantId, deletedAt: null } }),
          ]);
          if (buyerCount + sellerCount >= plan.maxBuyersAndSellers) {
            throw new AppError(
              402,
              "QUOTA_EXCEEDED_PARTNERS",
              `Buyer & Seller limit reached (${plan.maxBuyersAndSellers} partners on ${plan.name} plan). Upgrade your plan to add more partners.`
            );
          }
        }
      }

      next();
    } catch (err) {
      next(err);
    }
  };
}
