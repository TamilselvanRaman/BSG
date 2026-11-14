import { Router, Request, Response, NextFunction } from "express";
import { z } from "zod";
import { prisma } from "../../config/prisma";
import {
  authenticate,
  requireTenantScope,
  requirePermission,
  enforceSubscriptionQuota,
} from "../../middleware/auth";
import { AppError, sendSuccess, parsePagination } from "../../utils/response";
import { recordAuditLog } from "../../utils/auditLogger";

export const buyersRouter = Router();
export const sellersRouter = Router();

buyersRouter.use(authenticate, requireTenantScope);
sellersRouter.use(authenticate, requireTenantScope);

const partnerInputSchema = z.object({
  code: z.string().min(1).optional(),
  name: z.string().min(2),
  phone: z.string().min(8),
  alternatePhone: z.string().optional(),
  email: z.string().email().optional().or(z.literal("")),
  villageOrCity: z.string().optional(),
  address: z.string().optional(),
  gstNumber: z.string().optional(),
  category: z.enum(["BUYER", "SELLER", "TRANSPORTER", "COMMISSION_AGENT", "CUSTOM"]).optional(),
  customCategory: z.string().optional(),
  vehicleNumber: z.string().optional(),
  openingBalance: z.coerce.number().default(0),
  creditLimit: z.coerce.number().optional(),
  isActive: z.boolean().default(true),
  customData: z.record(z.unknown()).optional(),
});

// ============================================================================
// BUYERS ENDPOINTS (/api/v1/buyers)
// ============================================================================

buyersRouter.get(
  "/",
  requirePermission("partners:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const { page, limit, skip, search } = parsePagination(req.query);
      const category = typeof req.query.category === "string" ? req.query.category : undefined;

      const where: Record<string, unknown> = { tenantId, deletedAt: null };
      if (category) where.category = category;
      if (search) {
        where.OR = [
          { name: { contains: search } },
          { phone: { contains: search } },
          { code: { contains: search } },
          { villageOrCity: { contains: search } },
        ];
      }

      const [items, total] = await Promise.all([
        prisma.buyer.findMany({
          where,
          skip,
          take: limit,
          orderBy: { name: "asc" },
        }),
        prisma.buyer.count({ where }),
      ]);

      return sendSuccess(res, items, "Buyers retrieved.", 200, {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      });
    } catch (err) {
      next(err);
    }
  }
);

buyersRouter.post(
  "/",
  requirePermission("partners:write"),
  enforceSubscriptionQuota("PARTNERS"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const body = partnerInputSchema.parse(req.body);
      const code = body.code || `BYR-${Date.now().toString().slice(-5)}`;

      const created = await prisma.$transaction(async (tx) => {
        const buyer = await tx.buyer.create({
          data: {
            tenantId,
            code,
            name: body.name,
            phone: body.phone,
            alternatePhone: body.alternatePhone ?? null,
            email: body.email || null,
            villageOrCity: body.villageOrCity ?? null,
            address: body.address ?? null,
            gstNumber: body.gstNumber ?? null,
            category: body.category ?? "BUYER",
            customCategory: body.customCategory ?? null,
            openingBalance: body.openingBalance,
            currentBalance: body.openingBalance,
            creditLimit: body.creditLimit ?? null,
            isActive: body.isActive,
            customData: (body.customData ?? {}) as object,
            createdBy: req.user!.sub,
          },
        });

        if (body.openingBalance !== 0) {
          await tx.buyerLedgerEntry.create({
            data: {
              tenantId,
              buyerId: buyer.id,
              entryType: "OPENING_BALANCE",
              referenceNo: "OPEN-BAL",
              description: "Opening Balance",
              debitAmount: body.openingBalance > 0 ? body.openingBalance : 0,
              creditAmount: body.openingBalance < 0 ? Math.abs(body.openingBalance) : 0,
              runningBalance: body.openingBalance,
              createdBy: req.user!.sub,
            },
          });
        }

        return buyer;
      });

      return sendSuccess(res, created, "Buyer created.", 201);
    } catch (err) {
      next(err);
    }
  }
);

buyersRouter.post(
  "/bulk-import",
  requirePermission("partners:write"),
  enforceSubscriptionQuota("PARTNERS"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const { records } = z
        .object({ records: z.array(partnerInputSchema).min(1).max(200) })
        .parse(req.body);

      const createdCount = await prisma.$transaction(async (tx) => {
        let count = 0;
        for (const row of records) {
          const code =
            row.code || `BYR-${Date.now().toString().slice(-4)}-${Math.floor(Math.random() * 900 + 100)}`;
          await tx.buyer.create({
            data: {
              tenantId,
              code,
              name: row.name,
              phone: row.phone,
              villageOrCity: row.villageOrCity ?? null,
              openingBalance: row.openingBalance,
              currentBalance: row.openingBalance,
              createdBy: req.user!.sub,
            },
          });
          count++;
        }
        return count;
      });

      return sendSuccess(res, { importedCount: createdCount }, "Buyers imported successfully.", 201);
    } catch (err) {
      next(err);
    }
  }
);

buyersRouter.get(
  "/:id",
  requirePermission("partners:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const buyer = await prisma.buyer.findFirst({
        where: { id: req.params.id, tenantId, deletedAt: null },
        include: {
          salesBills: { orderBy: { billDate: "desc" }, take: 15 },
          payments: { orderBy: { paymentDate: "desc" }, take: 15 },
          advances: { orderBy: { advanceDate: "desc" }, take: 10 },
        },
      });
      if (!buyer) throw new AppError(404, "BUYER_NOT_FOUND", "Buyer not found in your business.");
      return sendSuccess(res, buyer);
    } catch (err) {
      next(err);
    }
  }
);

buyersRouter.patch(
  "/:id",
  requirePermission("partners:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const existing = await prisma.buyer.findFirst({
        where: { id: req.params.id, tenantId, deletedAt: null },
      });
      if (!existing) throw new AppError(404, "BUYER_NOT_FOUND", "Buyer not found.");

      const body = partnerInputSchema.partial().parse(req.body);
      const updated = await prisma.buyer.update({
        where: { id: existing.id },
        data: {
          ...body,
          customData: body.customData ? (body.customData as object) : undefined,
          updatedBy: req.user!.sub,
        },
      });
      return sendSuccess(res, updated, "Buyer updated.");
    } catch (err) {
      next(err);
    }
  }
);

buyersRouter.delete(
  "/:id",
  requirePermission("partners:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const existing = await prisma.buyer.findFirst({
        where: { id: req.params.id, tenantId, deletedAt: null },
      });
      if (!existing) throw new AppError(404, "BUYER_NOT_FOUND", "Buyer not found.");

      await prisma.buyer.update({
        where: { id: existing.id },
        data: { deletedAt: new Date(), isActive: false, updatedBy: req.user!.sub },
      });
      await recordAuditLog({
        tenantId,
        userId: req.user!.sub,
        action: "BUYER_DELETED",
        entityType: "Buyer",
        entityId: existing.id,
      });
      return sendSuccess(res, { id: existing.id, deleted: true }, "Buyer archived.");
    } catch (err) {
      next(err);
    }
  }
);

buyersRouter.get(
  "/:id/ledger",
  requirePermission("ledgers:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const buyer = await prisma.buyer.findFirst({
        where: { id: req.params.id, tenantId, deletedAt: null },
      });
      if (!buyer) throw new AppError(404, "BUYER_NOT_FOUND", "Buyer not found.");

      const startDate = req.query.startDate ? new Date(String(req.query.startDate)) : undefined;
      const endDate = req.query.endDate ? new Date(String(req.query.endDate)) : undefined;

      const entryWhere: Record<string, unknown> = { tenantId, buyerId: buyer.id };
      if (startDate || endDate) {
        entryWhere.entryDate = {
          ...(startDate ? { gte: startDate } : {}),
          ...(endDate ? { lte: endDate } : {}),
        };
      }

      const entries = await prisma.buyerLedgerEntry.findMany({
        where: entryWhere,
        orderBy: [{ entryDate: "asc" }, { createdAt: "asc" }],
      });

      const totalDebit = entries.reduce((s, e) => s + Number(e.debitAmount), 0);
      const totalCredit = entries.reduce((s, e) => s + Number(e.creditAmount), 0);

      return sendSuccess(res, {
        buyer,
        summary: {
          openingBalance: Number(buyer.openingBalance),
          totalDebit,
          totalCredit,
          closingBalance: Number(buyer.currentBalance),
        },
        entries,
      });
    } catch (err) {
      next(err);
    }
  }
);

// ============================================================================
// SELLERS ENDPOINTS (/api/v1/sellers)
// ============================================================================

sellersRouter.get(
  "/",
  requirePermission("partners:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const { page, limit, skip, search } = parsePagination(req.query);
      const category = typeof req.query.category === "string" ? req.query.category : undefined;

      const where: Record<string, unknown> = { tenantId, deletedAt: null };
      if (category) where.category = category;
      if (search) {
        where.OR = [
          { name: { contains: search } },
          { phone: { contains: search } },
          { code: { contains: search } },
          { villageOrCity: { contains: search } },
        ];
      }

      const [items, total] = await Promise.all([
        prisma.seller.findMany({
          where,
          skip,
          take: limit,
          orderBy: { name: "asc" },
        }),
        prisma.seller.count({ where }),
      ]);

      return sendSuccess(res, items, "Sellers retrieved.", 200, {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      });
    } catch (err) {
      next(err);
    }
  }
);

sellersRouter.post(
  "/",
  requirePermission("partners:write"),
  enforceSubscriptionQuota("PARTNERS"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const body = partnerInputSchema.parse(req.body);
      const code = body.code || `SLR-${Date.now().toString().slice(-5)}`;

      const created = await prisma.$transaction(async (tx) => {
        const seller = await tx.seller.create({
          data: {
            tenantId,
            code,
            name: body.name,
            phone: body.phone,
            alternatePhone: body.alternatePhone ?? null,
            email: body.email || null,
            villageOrCity: body.villageOrCity ?? null,
            address: body.address ?? null,
            gstNumber: body.gstNumber ?? null,
            category: body.category ?? "SELLER",
            customCategory: body.customCategory ?? null,
            vehicleNumber: body.vehicleNumber ?? null,
            openingBalance: body.openingBalance,
            currentBalance: body.openingBalance,
            isActive: body.isActive,
            customData: (body.customData ?? {}) as object,
            createdBy: req.user!.sub,
          },
        });

        if (body.openingBalance !== 0) {
          await tx.sellerLedgerEntry.create({
            data: {
              tenantId,
              sellerId: seller.id,
              entryType: "OPENING_BALANCE",
              referenceNo: "OPEN-BAL",
              description: "Opening Balance",
              debitAmount: body.openingBalance < 0 ? Math.abs(body.openingBalance) : 0,
              creditAmount: body.openingBalance > 0 ? body.openingBalance : 0,
              runningBalance: body.openingBalance,
              createdBy: req.user!.sub,
            },
          });
        }

        return seller;
      });

      return sendSuccess(res, created, "Seller created.", 201);
    } catch (err) {
      next(err);
    }
  }
);

sellersRouter.get(
  "/:id",
  requirePermission("partners:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const seller = await prisma.seller.findFirst({
        where: { id: req.params.id, tenantId, deletedAt: null },
        include: {
          goodsLots: { orderBy: { arrivalDate: "desc" }, take: 15 },
          purchaseBills: { orderBy: { billDate: "desc" }, take: 15 },
          payments: { orderBy: { paymentDate: "desc" }, take: 15 },
          advances: { orderBy: { advanceDate: "desc" }, take: 10 },
        },
      });
      if (!seller) throw new AppError(404, "SELLER_NOT_FOUND", "Seller not found in your business.");
      return sendSuccess(res, seller);
    } catch (err) {
      next(err);
    }
  }
);

sellersRouter.patch(
  "/:id",
  requirePermission("partners:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const existing = await prisma.seller.findFirst({
        where: { id: req.params.id, tenantId, deletedAt: null },
      });
      if (!existing) throw new AppError(404, "SELLER_NOT_FOUND", "Seller not found.");

      const body = partnerInputSchema.partial().parse(req.body);
      const updated = await prisma.seller.update({
        where: { id: existing.id },
        data: {
          ...body,
          customData: body.customData ? (body.customData as object) : undefined,
          updatedBy: req.user!.sub,
        },
      });
      return sendSuccess(res, updated, "Seller updated.");
    } catch (err) {
      next(err);
    }
  }
);

sellersRouter.delete(
  "/:id",
  requirePermission("partners:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const existing = await prisma.seller.findFirst({
        where: { id: req.params.id, tenantId, deletedAt: null },
      });
      if (!existing) throw new AppError(404, "SELLER_NOT_FOUND", "Seller not found.");

      await prisma.seller.update({
        where: { id: existing.id },
        data: { deletedAt: new Date(), isActive: false, updatedBy: req.user!.sub },
      });
      return sendSuccess(res, { id: existing.id, deleted: true }, "Seller archived.");
    } catch (err) {
      next(err);
    }
  }
);

sellersRouter.get(
  "/:id/ledger",
  requirePermission("ledgers:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const seller = await prisma.seller.findFirst({
        where: { id: req.params.id, tenantId, deletedAt: null },
      });
      if (!seller) throw new AppError(404, "SELLER_NOT_FOUND", "Seller not found.");

      const startDate = req.query.startDate ? new Date(String(req.query.startDate)) : undefined;
      const endDate = req.query.endDate ? new Date(String(req.query.endDate)) : undefined;

      const entryWhere: Record<string, unknown> = { tenantId, sellerId: seller.id };
      if (startDate || endDate) {
        entryWhere.entryDate = {
          ...(startDate ? { gte: startDate } : {}),
          ...(endDate ? { lte: endDate } : {}),
        };
      }

      const entries = await prisma.sellerLedgerEntry.findMany({
        where: entryWhere,
        orderBy: [{ entryDate: "asc" }, { createdAt: "asc" }],
      });

      const totalDebit = entries.reduce((s, e) => s + Number(e.debitAmount), 0);
      const totalCredit = entries.reduce((s, e) => s + Number(e.creditAmount), 0);

      return sendSuccess(res, {
        seller,
        summary: {
          openingBalance: Number(seller.openingBalance),
          totalDebit,
          totalCredit,
          closingBalance: Number(seller.currentBalance),
        },
        entries,
      });
    } catch (err) {
      next(err);
    }
  }
);
