import { Router, Request, Response, NextFunction } from "express";
import { z } from "zod";
import { prisma } from "../../config/prisma";
import {
  authenticate,
  requireTenantScope,
  requirePermission,
  enforceSubscriptionQuota,
} from "../../middleware/auth";
import { AppError, sendSuccess } from "../../utils/response";
import { round2, round3 } from "../../utils/financialMath";

export const smartChartsRouter = Router();
export const auctionsRouter = Router();

smartChartsRouter.use(
  authenticate,
  requireTenantScope,
  enforceSubscriptionQuota("SMART_CHART")
);
auctionsRouter.use(
  authenticate,
  requireTenantScope,
  enforceSubscriptionQuota("SMART_CHART")
);

// ============================================================================
// SMART CHARTS (/api/v1/smart-charts) — Spec Section B
// ============================================================================

smartChartsRouter.get(
  "/",
  requirePermission("smart_chart:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const charts = await prisma.smartChart.findMany({
        where: { tenantId },
        orderBy: { chartDate: "desc" },
        include: {
          items: {
            include: {
              goods: { select: { id: true, name: true, code: true, unit: true } },
              lot: { select: { id: true, lotNumber: true } },
            },
          },
        },
      });
      return sendSuccess(res, charts);
    } catch (err) {
      next(err);
    }
  }
);

smartChartsRouter.post(
  "/",
  requirePermission("smart_chart:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const schema = z.object({
        chartNumber: z.string().optional(),
        title: z.string().min(2),
        chartDate: z.coerce.date().optional(),
        notes: z.string().optional(),
        items: z
          .array(
            z.object({
              goodsId: z.string().uuid(),
              lotId: z.string().uuid().optional(),
              sellerName: z.string().optional(),
              buyerName: z.string().optional(),
              bagsCount: z.coerce.number().int().min(1).default(1),
              quantity: z.coerce.number().positive(),
              unit: z.string().default("KG"),
              rate: z.coerce.number().min(0),
            })
          )
          .default([]),
      });
      const body = schema.parse(req.body);
      const chartNumber = body.chartNumber || `SC-${Date.now().toString().slice(-6)}`;

      const computedItems = body.items.map((item) => ({
        ...item,
        quantity: round3(item.quantity),
        rate: round2(item.rate),
        lineTotal: round2(item.quantity * item.rate),
      }));

      const totalBags = computedItems.reduce((s, i) => s + i.bagsCount, 0);
      const totalWeight = round3(computedItems.reduce((s, i) => s + i.quantity, 0));
      const totalAmount = round2(computedItems.reduce((s, i) => s + i.lineTotal, 0));

      const chart = await prisma.smartChart.create({
        data: {
          tenantId,
          chartNumber,
          title: body.title,
          chartDate: body.chartDate ?? new Date(),
          status: "OPEN",
          totalBags,
          totalWeight,
          totalAmount,
          notes: body.notes ?? null,
          createdBy: req.user!.sub,
          items: {
            create: computedItems.map((i) => ({
              goodsId: i.goodsId,
              lotId: i.lotId ?? null,
              sellerName: i.sellerName ?? null,
              buyerName: i.buyerName ?? null,
              bagsCount: i.bagsCount,
              quantity: i.quantity,
              unit: i.unit,
              rate: i.rate,
              lineTotal: i.lineTotal,
            })),
          },
        },
        include: { items: { include: { goods: true, lot: true } } },
      });

      return sendSuccess(res, chart, "Smart Chart created.", 201);
    } catch (err) {
      next(err);
    }
  }
);

smartChartsRouter.get(
  "/:id",
  requirePermission("smart_chart:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const chart = await prisma.smartChart.findFirst({
        where: { id: req.params.id, tenantId },
        include: { items: { include: { goods: true, lot: true } } },
      });
      if (!chart) throw new AppError(404, "SMART_CHART_NOT_FOUND", "Smart Chart not found.");
      return sendSuccess(res, chart);
    } catch (err) {
      next(err);
    }
  }
);

smartChartsRouter.patch(
  "/:id",
  requirePermission("smart_chart:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const existing = await prisma.smartChart.findFirst({
        where: { id: req.params.id, tenantId },
      });
      if (!existing) throw new AppError(404, "SMART_CHART_NOT_FOUND", "Smart Chart not found.");

      const updated = await prisma.smartChart.update({
        where: { id: existing.id },
        data: req.body,
      });
      return sendSuccess(res, updated, "Smart Chart updated.");
    } catch (err) {
      next(err);
    }
  }
);

smartChartsRouter.post(
  "/:id/items",
  requirePermission("smart_chart:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const chart = await prisma.smartChart.findFirst({
        where: { id: req.params.id, tenantId },
      });
      if (!chart) throw new AppError(404, "SMART_CHART_NOT_FOUND", "Smart Chart not found.");

      const schema = z.object({
        goodsId: z.string().uuid(),
        lotId: z.string().uuid().optional(),
        sellerName: z.string().optional(),
        buyerName: z.string().optional(),
        bagsCount: z.coerce.number().int().min(1).default(1),
        quantity: z.coerce.number().positive(),
        unit: z.string().default("KG"),
        rate: z.coerce.number().min(0),
      });
      const body = schema.parse(req.body);
      const lineTotal = round2(body.quantity * body.rate);

      const updatedChart = await prisma.$transaction(async (tx) => {
        await tx.smartChartItem.create({
          data: {
            smartChartId: chart.id,
            goodsId: body.goodsId,
            lotId: body.lotId ?? null,
            sellerName: body.sellerName ?? null,
            buyerName: body.buyerName ?? null,
            bagsCount: body.bagsCount,
            quantity: round3(body.quantity),
            unit: body.unit,
            rate: round2(body.rate),
            lineTotal,
          },
        });

        const allItems = await tx.smartChartItem.findMany({
          where: { smartChartId: chart.id },
        });

        return tx.smartChart.update({
          where: { id: chart.id },
          data: {
            totalBags: allItems.reduce((s, i) => s + i.bagsCount, 0),
            totalWeight: round3(allItems.reduce((s, i) => s + Number(i.quantity), 0)),
            totalAmount: round2(allItems.reduce((s, i) => s + Number(i.lineTotal), 0)),
          },
          include: { items: { include: { goods: true, lot: true } } },
        });
      });

      return sendSuccess(res, updatedChart, "Item added to Smart Chart.", 201);
    } catch (err) {
      next(err);
    }
  }
);

smartChartsRouter.get(
  "/:id/report",
  requirePermission("smart_chart:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const chart = await prisma.smartChart.findFirst({
        where: { id: req.params.id, tenantId },
        include: { items: { include: { goods: true, lot: true } } },
      });
      if (!chart) throw new AppError(404, "SMART_CHART_NOT_FOUND", "Smart Chart not found.");

      const byGoods: Record<string, { goodsName: string; bags: number; quantity: number; amount: number }> = {};
      for (const item of chart.items) {
        const key = item.goods.name;
        if (!byGoods[key]) {
          byGoods[key] = { goodsName: key, bags: 0, quantity: 0, amount: 0 };
        }
        byGoods[key].bags += item.bagsCount;
        byGoods[key].quantity = round3(byGoods[key].quantity + Number(item.quantity));
        byGoods[key].amount = round2(byGoods[key].amount + Number(item.lineTotal));
      }

      return sendSuccess(res, {
        chart,
        goodsBreakdown: Object.values(byGoods),
      });
    } catch (err) {
      next(err);
    }
  }
);

// ============================================================================
// AUCTIONS (/api/v1/auctions)
// ============================================================================

auctionsRouter.get(
  "/",
  requirePermission("smart_chart:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const auctions = await prisma.auction.findMany({
        where: { tenantId },
        orderBy: { auctionDate: "desc" },
        include: {
          items: {
            include: {
              goods: { select: { id: true, name: true, code: true } },
              buyer: { select: { id: true, name: true, code: true } },
              lot: { select: { id: true, lotNumber: true } },
            },
          },
        },
      });
      return sendSuccess(res, auctions);
    } catch (err) {
      next(err);
    }
  }
);

auctionsRouter.post(
  "/",
  requirePermission("smart_chart:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const schema = z.object({
        auctionNumber: z.string().optional(),
        auctionDate: z.coerce.date().optional(),
        notes: z.string().optional(),
        items: z
          .array(
            z.object({
              goodsId: z.string().uuid(),
              lotId: z.string().uuid().optional(),
              buyerId: z.string().uuid().optional(),
              bagsCount: z.coerce.number().int().min(1).default(1),
              quantity: z.coerce.number().positive(),
              bidPrice: z.coerce.number().positive(),
            })
          )
          .default([]),
      });
      const body = schema.parse(req.body);
      const auctionNumber = body.auctionNumber || `AUC-${Date.now().toString().slice(-6)}`;

      const items = body.items.map((i) => ({
        ...i,
        quantity: round3(i.quantity),
        bidPrice: round2(i.bidPrice),
        totalAmount: round2(i.quantity * i.bidPrice),
      }));

      const totalQuantity = round3(items.reduce((s, i) => s + i.quantity, 0));
      const totalValue = round2(items.reduce((s, i) => s + i.totalAmount, 0));

      const auction = await prisma.auction.create({
        data: {
          tenantId,
          auctionNumber,
          auctionDate: body.auctionDate ?? new Date(),
          status: "OPEN",
          totalQuantity,
          totalValue,
          notes: body.notes ?? null,
          createdBy: req.user!.sub,
          items: {
            create: items.map((i) => ({
              goodsId: i.goodsId,
              lotId: i.lotId ?? null,
              buyerId: i.buyerId ?? null,
              bagsCount: i.bagsCount,
              quantity: i.quantity,
              bidPrice: i.bidPrice,
              totalAmount: i.totalAmount,
            })),
          },
        },
        include: { items: { include: { goods: true, buyer: true, lot: true } } },
      });

      return sendSuccess(res, auction, "Auction created.", 201);
    } catch (err) {
      next(err);
    }
  }
);

auctionsRouter.get(
  "/:id",
  requirePermission("smart_chart:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const auction = await prisma.auction.findFirst({
        where: { id: req.params.id, tenantId },
        include: { items: { include: { goods: true, buyer: true, lot: true } } },
      });
      if (!auction) throw new AppError(404, "AUCTION_NOT_FOUND", "Auction not found.");
      return sendSuccess(res, auction);
    } catch (err) {
      next(err);
    }
  }
);

auctionsRouter.patch(
  "/:id",
  requirePermission("smart_chart:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const existing = await prisma.auction.findFirst({
        where: { id: req.params.id, tenantId },
      });
      if (!existing) throw new AppError(404, "AUCTION_NOT_FOUND", "Auction not found.");

      const updated = await prisma.auction.update({
        where: { id: existing.id },
        data: req.body,
      });
      return sendSuccess(res, updated, "Auction updated.");
    } catch (err) {
      next(err);
    }
  }
);

auctionsRouter.post(
  "/:id/items",
  requirePermission("smart_chart:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const auction = await prisma.auction.findFirst({
        where: { id: req.params.id, tenantId },
      });
      if (!auction) throw new AppError(404, "AUCTION_NOT_FOUND", "Auction not found.");

      const schema = z.object({
        goodsId: z.string().uuid(),
        lotId: z.string().uuid().optional(),
        buyerId: z.string().uuid().optional(),
        bagsCount: z.coerce.number().int().min(1).default(1),
        quantity: z.coerce.number().positive(),
        bidPrice: z.coerce.number().positive(),
      });
      const body = schema.parse(req.body);
      const totalAmount = round2(body.quantity * body.bidPrice);

      const updated = await prisma.$transaction(async (tx) => {
        await tx.auctionItem.create({
          data: {
            auctionId: auction.id,
            goodsId: body.goodsId,
            lotId: body.lotId ?? null,
            buyerId: body.buyerId ?? null,
            bagsCount: body.bagsCount,
            quantity: round3(body.quantity),
            bidPrice: round2(body.bidPrice),
            totalAmount,
          },
        });
        const allItems = await tx.auctionItem.findMany({ where: { auctionId: auction.id } });
        return tx.auction.update({
          where: { id: auction.id },
          data: {
            totalQuantity: round3(allItems.reduce((s, i) => s + Number(i.quantity), 0)),
            totalValue: round2(allItems.reduce((s, i) => s + Number(i.totalAmount), 0)),
          },
          include: { items: { include: { goods: true, buyer: true, lot: true } } },
        });
      });

      return sendSuccess(res, updated, "Auction item recorded.", 201);
    } catch (err) {
      next(err);
    }
  }
);

auctionsRouter.get(
  "/:id/report",
  requirePermission("smart_chart:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const auction = await prisma.auction.findFirst({
        where: { id: req.params.id, tenantId },
        include: { items: { include: { goods: true, buyer: true, lot: true } } },
      });
      if (!auction) throw new AppError(404, "AUCTION_NOT_FOUND", "Auction not found.");
      return sendSuccess(res, auction);
    } catch (err) {
      next(err);
    }
  }
);
