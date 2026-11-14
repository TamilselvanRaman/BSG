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
import { round2, round3 } from "../../utils/financialMath";

export const goodsRouter = Router();
export const goodsLotsRouter = Router();
export const goodsEntriesRouter = Router();
export const inventoryRouter = Router();

goodsRouter.use(authenticate, requireTenantScope);
goodsLotsRouter.use(authenticate, requireTenantScope);
goodsEntriesRouter.use(authenticate, requireTenantScope);
inventoryRouter.use(authenticate, requireTenantScope);

// ============================================================================
// GOODS CATALOG (/api/v1/goods)
// ============================================================================

goodsRouter.get(
  "/",
  requirePermission("goods:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const { page, limit, skip, search } = parsePagination(req.query);

      const where: Record<string, unknown> = { tenantId, deletedAt: null };
      if (search) {
        where.OR = [
          { name: { contains: search } },
          { code: { contains: search } },
          { customLabel: { contains: search } },
        ];
      }

      const [items, total, categories] = await Promise.all([
        prisma.goods.findMany({
          where,
          skip,
          take: limit,
          orderBy: { name: "asc" },
          include: { category: true },
        }),
        prisma.goods.count({ where }),
        prisma.goodsCategory.findMany({ where: { tenantId }, orderBy: { name: "asc" } }),
      ]);

      return sendSuccess(res, items, "Goods retrieved.", 200, {
        page,
        limit,
        total,
        categories,
      });
    } catch (err) {
      next(err);
    }
  }
);

goodsRouter.post(
  "/",
  requirePermission("goods:write"),
  enforceSubscriptionQuota("GOODS"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const schema = z.object({
        code: z.string().optional(),
        name: z.string().min(2),
        categoryName: z.string().optional(),
        customLabel: z.string().optional(),
        unit: z.string().default("KG"),
        description: z.string().optional(),
        purchasePrice: z.coerce.number().min(0).default(0),
        sellingPrice: z.coerce.number().min(0).default(0),
        openingStock: z.coerce.number().min(0).default(0),
        minimumStock: z.coerce.number().min(0).default(10),
        barcode: z.string().optional(),
      });
      const body = schema.parse(req.body);
      const code = body.code || `GDS-${Date.now().toString().slice(-5)}`;

      const created = await prisma.$transaction(async (tx) => {
        let categoryId: string | null = null;
        if (body.categoryName) {
          const cat = await tx.goodsCategory.upsert({
            where: { tenantId_name: { tenantId, name: body.categoryName } },
            update: {},
            create: { tenantId, name: body.categoryName },
          });
          categoryId = cat.id;
        }

        const item = await tx.goods.create({
          data: {
            tenantId,
            categoryId,
            code,
            name: body.name,
            customLabel: body.customLabel ?? null,
            unit: body.unit,
            description: body.description ?? null,
            purchasePrice: body.purchasePrice,
            sellingPrice: body.sellingPrice,
            currentStock: body.openingStock,
            minimumStock: body.minimumStock,
            barcode: body.barcode ?? null,
            createdBy: req.user!.sub,
          },
          include: { category: true },
        });

        if (body.openingStock > 0) {
          await tx.inventoryTransaction.create({
            data: {
              tenantId,
              goodsId: item.id,
              type: "OPENING_STOCK",
              referenceNumber: "OPEN-STK",
              inwardQuantity: body.openingStock,
              outwardQuantity: 0,
              balanceQuantity: body.openingStock,
              unitCost: body.purchasePrice,
              notes: "Initial opening stock",
              createdBy: req.user!.sub,
            },
          });
        }

        return item;
      });

      return sendSuccess(res, created, "Goods item created.", 201);
    } catch (err) {
      next(err);
    }
  }
);

goodsRouter.get(
  "/:id",
  requirePermission("goods:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const item = await prisma.goods.findFirst({
        where: { id: req.params.id, tenantId, deletedAt: null },
        include: {
          category: true,
          goodsLots: { orderBy: { arrivalDate: "desc" }, take: 15 },
          inventoryTxns: { orderBy: { transactionDate: "desc" }, take: 20 },
        },
      });
      if (!item) throw new AppError(404, "GOODS_NOT_FOUND", "Goods item not found.");
      return sendSuccess(res, item);
    } catch (err) {
      next(err);
    }
  }
);

goodsRouter.patch(
  "/:id",
  requirePermission("goods:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const existing = await prisma.goods.findFirst({
        where: { id: req.params.id, tenantId, deletedAt: null },
      });
      if (!existing) throw new AppError(404, "GOODS_NOT_FOUND", "Goods item not found.");

      const updated = await prisma.goods.update({
        where: { id: existing.id },
        data: { ...req.body, updatedBy: req.user!.sub },
      });
      return sendSuccess(res, updated, "Goods updated.");
    } catch (err) {
      next(err);
    }
  }
);

goodsRouter.delete(
  "/:id",
  requirePermission("goods:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const existing = await prisma.goods.findFirst({
        where: { id: req.params.id, tenantId, deletedAt: null },
      });
      if (!existing) throw new AppError(404, "GOODS_NOT_FOUND", "Goods item not found.");

      await prisma.goods.update({
        where: { id: existing.id },
        data: { deletedAt: new Date(), isActive: false, updatedBy: req.user!.sub },
      });
      return sendSuccess(res, { id: existing.id, deleted: true }, "Goods item archived.");
    } catch (err) {
      next(err);
    }
  }
);

// ============================================================================
// GOODS LOTS (/api/v1/goods-lots)
// ============================================================================

goodsLotsRouter.get(
  "/",
  requirePermission("lots:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const status = typeof req.query.status === "string" ? req.query.status : undefined;
      const sellerId = typeof req.query.sellerId === "string" ? req.query.sellerId : undefined;
      const goodsId = typeof req.query.goodsId === "string" ? req.query.goodsId : undefined;

      const where: Record<string, unknown> = { tenantId };
      if (status) where.status = status;
      if (sellerId) where.sellerId = sellerId;
      if (goodsId) where.goodsId = goodsId;

      const lots = await prisma.goodsLot.findMany({
        where,
        orderBy: { arrivalDate: "desc" },
        include: {
          seller: { select: { id: true, name: true, code: true, phone: true, villageOrCity: true } },
          goods: { select: { id: true, name: true, code: true, unit: true } },
        },
      });
      return sendSuccess(res, lots);
    } catch (err) {
      next(err);
    }
  }
);

goodsLotsRouter.post(
  "/",
  requirePermission("lots:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const schema = z.object({
        lotNumber: z.string().optional(),
        sellerId: z.string().uuid(),
        goodsId: z.string().uuid(),
        vehicleNumber: z.string().optional(),
        bagsOrCount: z.coerce.number().int().min(1).default(1),
        initialQuantity: z.coerce.number().positive(),
        unit: z.string().default("KG"),
        unitPrice: z.coerce.number().min(0),
        notes: z.string().optional(),
      });
      const body = schema.parse(req.body);
      const lotNumber = body.lotNumber || `LOT-${Date.now().toString().slice(-6)}`;
      const totalValue = round2(body.initialQuantity * body.unitPrice);

      const lot = await prisma.goodsLot.create({
        data: {
          tenantId,
          lotNumber,
          sellerId: body.sellerId,
          goodsId: body.goodsId,
          vehicleNumber: body.vehicleNumber ?? null,
          bagsOrCount: body.bagsOrCount,
          initialQuantity: round3(body.initialQuantity),
          soldQuantity: 0,
          remainingQuantity: round3(body.initialQuantity),
          unit: body.unit,
          unitPrice: round2(body.unitPrice),
          totalValue,
          status: "OPEN",
          notes: body.notes ?? null,
          createdBy: req.user!.sub,
        },
        include: { seller: true, goods: true },
      });

      return sendSuccess(res, lot, "Goods lot created.", 201);
    } catch (err) {
      next(err);
    }
  }
);

goodsLotsRouter.get(
  "/:id",
  requirePermission("lots:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const lot = await prisma.goodsLot.findFirst({
        where: { id: req.params.id, tenantId },
        include: {
          seller: true,
          goods: true,
          goodsEntries: true,
          salesBillItems: { include: { salesBill: { include: { buyer: true } } } },
        },
      });
      if (!lot) throw new AppError(404, "LOT_NOT_FOUND", "Lot not found.");
      return sendSuccess(res, lot);
    } catch (err) {
      next(err);
    }
  }
);

goodsLotsRouter.patch(
  "/:id",
  requirePermission("lots:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const existing = await prisma.goodsLot.findFirst({
        where: { id: req.params.id, tenantId },
      });
      if (!existing) throw new AppError(404, "LOT_NOT_FOUND", "Lot not found.");

      const updated = await prisma.goodsLot.update({
        where: { id: existing.id },
        data: req.body,
      });
      return sendSuccess(res, updated, "Goods lot updated.");
    } catch (err) {
      next(err);
    }
  }
);

// ============================================================================
// GOODS ENTRIES (/api/v1/goods-entries) — From Feature Spec Section C
// ============================================================================

goodsEntriesRouter.get(
  "/",
  requirePermission("lots:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const entries = await prisma.goodsEntry.findMany({
        where: { tenantId },
        orderBy: { entryDate: "desc" },
        include: {
          seller: { select: { id: true, name: true, phone: true, villageOrCity: true } },
          goods: { select: { id: true, name: true, code: true, unit: true } },
          lot: { select: { id: true, lotNumber: true, status: true } },
        },
      });
      return sendSuccess(res, entries);
    } catch (err) {
      next(err);
    }
  }
);

goodsEntriesRouter.post(
  "/",
  requirePermission("lots:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const schema = z.object({
        entryNumber: z.string().optional(),
        entryDate: z.coerce.date().optional(),
        sellerId: z.string().uuid(),
        goodsId: z.string().uuid(),
        createOrLinkLotNumber: z.string().optional(),
        partyVillage: z.string().optional(),
        partyPhone: z.string().optional(),
        vehicleNumber: z.string().optional(),
        bagsCount: z.coerce.number().int().min(1).default(1),
        grossWeight: z.coerce.number().positive(),
        tareWeight: z.coerce.number().min(0).default(0),
        unit: z.string().default("KG"),
        costRate: z.coerce.number().min(0),
        sellRate: z.coerce.number().min(0),
        notes: z.string().optional(),
      });
      const body = schema.parse(req.body);

      const entryNumber = body.entryNumber || `GE-${Date.now().toString().slice(-6)}`;
      const netWeight = round3(Math.max(0, body.grossWeight - body.tareWeight));
      const totalCost = round2(netWeight * body.costRate);

      const result = await prisma.$transaction(async (tx) => {
        const goods = await tx.goods.findFirst({
          where: { id: body.goodsId, tenantId, deletedAt: null },
        });
        if (!goods) throw new AppError(404, "GOODS_NOT_FOUND", "Goods item not found.");

        const lotNumber = body.createOrLinkLotNumber || `LOT-${Date.now().toString().slice(-6)}`;
        const lot = await tx.goodsLot.create({
          data: {
            tenantId,
            lotNumber,
            sellerId: body.sellerId,
            goodsId: body.goodsId,
            vehicleNumber: body.vehicleNumber ?? null,
            bagsOrCount: body.bagsCount,
            initialQuantity: netWeight,
            soldQuantity: 0,
            remainingQuantity: netWeight,
            unit: body.unit,
            unitPrice: body.costRate,
            totalValue: totalCost,
            status: "OPEN",
            createdBy: req.user!.sub,
          },
        });

        const entry = await tx.goodsEntry.create({
          data: {
            tenantId,
            entryNumber,
            entryDate: body.entryDate ?? new Date(),
            sellerId: body.sellerId,
            goodsId: body.goodsId,
            lotId: lot.id,
            partyVillage: body.partyVillage ?? null,
            partyPhone: body.partyPhone ?? null,
            vehicleNumber: body.vehicleNumber ?? null,
            bagsCount: body.bagsCount,
            grossWeight: round3(body.grossWeight),
            tareWeight: round3(body.tareWeight),
            netWeight,
            unit: body.unit,
            costRate: round2(body.costRate),
            sellRate: round2(body.sellRate),
            totalCost,
            notes: body.notes ?? null,
            createdBy: req.user!.sub,
          },
          include: { seller: true, goods: true, lot: true },
        });

        return entry;
      });

      return sendSuccess(res, result, "Goods entry and arrival lot recorded.", 201);
    } catch (err) {
      next(err);
    }
  }
);

// ============================================================================
// INVENTORY & STOCK (/api/v1/inventory) — From Feature Spec Section G
// ============================================================================

inventoryRouter.get(
  "/",
  requirePermission("inventory:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const goodsList = await prisma.goods.findMany({
        where: { tenantId, deletedAt: null },
        orderBy: { name: "asc" },
        include: { category: true },
      });

      const txns = await prisma.inventoryTransaction.findMany({
        where: { tenantId },
      });

      const stockTable = goodsList.map((g) => {
        const gTxns = txns.filter((t) => t.goodsId === g.id);
        const opening = gTxns
          .filter((t) => t.type === "OPENING_STOCK")
          .reduce((s, t) => s + Number(t.inwardQuantity), 0);
        const inward = gTxns
          .filter((t) => t.type !== "OPENING_STOCK")
          .reduce((s, t) => s + Number(t.inwardQuantity), 0);
        const outward = gTxns.reduce((s, t) => s + Number(t.outwardQuantity), 0);
        const currentStock = Number(g.currentStock);
        const stockValue = round2(currentStock * Number(g.purchasePrice));

        return {
          id: g.id,
          code: g.code,
          name: g.name,
          category: g.category?.name ?? "General",
          unit: g.unit,
          openingQuantity: round3(opening),
          inwardQuantity: round3(inward),
          outwardQuantity: round3(outward),
          closingQuantity: round3(currentStock),
          minimumStock: Number(g.minimumStock),
          purchasePrice: Number(g.purchasePrice),
          sellingPrice: Number(g.sellingPrice),
          stockValuation: stockValue,
          stockStatus:
            currentStock <= 0
              ? "OUT_OF_STOCK"
              : currentStock <= Number(g.minimumStock)
              ? "LOW_STOCK"
              : "IN_STOCK",
        };
      });

      const totalValuation = round2(stockTable.reduce((s, item) => s + item.stockValuation, 0));

      return sendSuccess(res, {
        totalValuation,
        totalItems: stockTable.length,
        lowStockCount: stockTable.filter((i) => i.stockStatus !== "IN_STOCK").length,
        stockTable,
      });
    } catch (err) {
      next(err);
    }
  }
);

inventoryRouter.get(
  "/transactions",
  requirePermission("inventory:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const goodsId = typeof req.query.goodsId === "string" ? req.query.goodsId : undefined;
      const txns = await prisma.inventoryTransaction.findMany({
        where: { tenantId, ...(goodsId ? { goodsId } : {}) },
        orderBy: { transactionDate: "desc" },
        take: 100,
        include: {
          goods: { select: { name: true, code: true, unit: true } },
          lot: { select: { lotNumber: true } },
        },
      });
      return sendSuccess(res, txns);
    } catch (err) {
      next(err);
    }
  }
);

inventoryRouter.post(
  "/adjustments",
  requirePermission("inventory:adjust"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const schema = z.object({
        goodsId: z.string().uuid(),
        adjustmentType: z.enum(["ADD", "DEDUCT", "DAMAGE_WASTAGE"]),
        quantity: z.coerce.number().positive(),
        notes: z.string().min(2),
      });
      const body = schema.parse(req.body);

      const updated = await prisma.$transaction(async (tx) => {
        const goods = await tx.goods.findFirst({
          where: { id: body.goodsId, tenantId, deletedAt: null },
        });
        if (!goods) throw new AppError(404, "GOODS_NOT_FOUND", "Goods item not found.");

        const current = Number(goods.currentStock);
        const delta = body.adjustmentType === "ADD" ? body.quantity : -body.quantity;
        const newBalance = round3(Math.max(0, current + delta));

        const updatedGoods = await tx.goods.update({
          where: { id: goods.id },
          data: { currentStock: newBalance, updatedBy: req.user!.sub },
        });

        await tx.inventoryTransaction.create({
          data: {
            tenantId,
            goodsId: goods.id,
            type:
              body.adjustmentType === "DAMAGE_WASTAGE" ? "DAMAGE_WASTAGE" : "MANUAL_ADJUSTMENT",
            referenceNumber: `ADJ-${Date.now().toString().slice(-5)}`,
            inwardQuantity: body.adjustmentType === "ADD" ? body.quantity : 0,
            outwardQuantity: body.adjustmentType !== "ADD" ? body.quantity : 0,
            balanceQuantity: newBalance,
            unitCost: goods.purchasePrice,
            notes: body.notes,
            createdBy: req.user!.sub,
          },
        });

        return updatedGoods;
      });

      return sendSuccess(res, updated, "Stock adjustment recorded.", 201);
    } catch (err) {
      next(err);
    }
  }
);

inventoryRouter.get(
  "/low-stock",
  requirePermission("inventory:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const allGoods = await prisma.goods.findMany({
        where: { tenantId, deletedAt: null },
        orderBy: { currentStock: "asc" },
      });
      const lowStock = allGoods.filter(
        (g) => Number(g.currentStock) <= Number(g.minimumStock)
      );
      return sendSuccess(res, lowStock);
    } catch (err) {
      next(err);
    }
  }
);
