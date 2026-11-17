import { Router } from "express";
import { authRouter } from "../modules/auth/auth.routes";
import { superAdminRouter } from "../modules/super-admin/superAdmin.routes";
import { businessRouter } from "../modules/business/business.routes";
import { buyersRouter, sellersRouter } from "../modules/partners/partners.routes";
import {
  goodsRouter,
  goodsLotsRouter,
  goodsEntriesRouter,
  inventoryRouter,
} from "../modules/goods/goods.routes";
import {
  smartChartsRouter,
  auctionsRouter,
} from "../modules/smart-chart/smartChart.routes";
import {
  purchasesRouter,
  salesRouter,
  paymentsRouter,
  advancesRouter,
} from "../modules/billing/billing.routes";
import {
  reportsRouter,
  documentsRouter,
} from "../modules/reports/reports.routes";
import { publicRouter } from "../modules/public/public.routes";
import { dailyTallyRouter } from "../modules/daily-tally/dailyTally.routes";
import { mobileSyncRouter } from "../modules/mobile-sync/mobileSync.routes";
import { prisma } from "../config/prisma";
import { sendSuccess } from "../utils/response";

export const apiV1Router = Router();

// Public SaaS Plans & Platform Metadata endpoint for Public Website
apiV1Router.get("/public/plans", async (_req, res, next) => {
  try {
    const [plans, platform] = await Promise.all([
      prisma.subscriptionPlan.findMany({
        where: { isActive: true, isArchived: false },
        orderBy: { monthlyPrice: "asc" },
        include: { planFeatures: true },
      }),
      prisma.platformSetting.findFirst(),
    ]);
    return sendSuccess(res, { plans, platform });
  } catch (err) {
    next(err);
  }
});

apiV1Router.use("/public", publicRouter);
apiV1Router.use("/auth", authRouter);
apiV1Router.use("/super-admin", superAdminRouter);
apiV1Router.use("/business", businessRouter);
apiV1Router.use("/buyers", buyersRouter);
apiV1Router.use("/sellers", sellersRouter);
apiV1Router.use("/goods", goodsRouter);
apiV1Router.use("/goods-lots", goodsLotsRouter);
apiV1Router.use("/goods-entries", goodsEntriesRouter);
apiV1Router.use("/inventory", inventoryRouter);
apiV1Router.use("/smart-charts", smartChartsRouter);
apiV1Router.use("/auctions", auctionsRouter);
apiV1Router.use("/purchases", purchasesRouter);
apiV1Router.use("/sales", salesRouter);
apiV1Router.use("/payments", paymentsRouter);
apiV1Router.use("/advances", advancesRouter);
apiV1Router.use("/reports", reportsRouter);
apiV1Router.use("/documents", documentsRouter);
apiV1Router.use("/daily-tally", dailyTallyRouter);
apiV1Router.use("/mobile-sync", mobileSyncRouter);
