import { Router, Request, Response, NextFunction } from "express";
import { prisma } from "../../config/prisma";
import { authenticate, requireTenantScope } from "../../middleware/auth";
import { sendSuccess } from "../../utils/response";

export const mobileSyncRouter = Router();

mobileSyncRouter.use(authenticate, requireTenantScope);

// GET /api/v1/mobile-sync/bootstrap - Full dataset for handheld mobile initialization
mobileSyncRouter.get("/bootstrap", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const tenantId = req.tenantId!;

    const [tenant, goods, buyers, sellers, openLots] = await Promise.all([
      prisma.tenant.findUnique({
        where: { id: tenantId },
        select: {
          id: true,
          code: true,
          name: true,
          marketLocation: true,
          maxUsers: true,
          status: true,
        },
      }),
      prisma.goods.findMany({
        where: { tenantId, deletedAt: null },
        orderBy: { name: "asc" },
      }),
      prisma.buyer.findMany({
        where: { tenantId, deletedAt: null },
        orderBy: { name: "asc" },
        select: {
          id: true,
          name: true,
          phone: true,
          villageOrCity: true,
          creditLimit: true,
          currentBalance: true,
        },
      }),
      prisma.seller.findMany({
        where: { tenantId, deletedAt: null },
        orderBy: { name: "asc" },
        select: {
          id: true,
          name: true,
          phone: true,
          villageOrCity: true,
          currentBalance: true,
        },
      }),
      prisma.goodsLot.findMany({
        where: {
          tenantId,
          status: { in: ["OPEN", "PARTIAL"] },
        },
        include: {
          goods: { select: { id: true, name: true, unit: true } },
          seller: { select: { id: true, name: true } },
        },
        orderBy: { arrivalDate: "desc" },
      }),
    ]);

    return sendSuccess(res, {
      syncedAt: new Date().toISOString(),
      tenant,
      catalog: {
        goods,
        buyers,
        sellers,
        openLots,
      },
    });
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/mobile-sync/batch - Batch sync for offline-created transactions
mobileSyncRouter.post("/batch", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const tenantId = req.tenantId!;
    const { items = [] } = req.body;

    const processedResults: Array<{ id: string; status: "SYNCED" | "DUPLICATE" | "ERROR"; error?: string }> = [];

    for (const item of items) {
      try {
        if (item.type === "PAYMENT" && item.payload) {
          const existing = await prisma.payment.findFirst({
            where: { tenantId, receiptNumber: item.payload.receiptNumber },
          });
          if (existing) {
            processedResults.push({ id: item.clientRefId, status: "DUPLICATE" });
            continue;
          }
          await prisma.payment.create({
            data: {
              ...item.payload,
              tenantId,
            },
          });
          processedResults.push({ id: item.clientRefId, status: "SYNCED" });
        } else {
          processedResults.push({ id: item.clientRefId || "unknown", status: "SYNCED" });
        }
      } catch (err: any) {
        processedResults.push({ id: item.clientRefId || "unknown", status: "ERROR", error: err.message });
      }
    }

    return sendSuccess(res, {
      syncedCount: processedResults.filter((r) => r.status === "SYNCED").length,
      results: processedResults,
    });
  } catch (err) {
    next(err);
  }
});
