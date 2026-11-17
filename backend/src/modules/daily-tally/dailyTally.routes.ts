import { Router, Request, Response, NextFunction } from "express";
import { z } from "zod";
import { prisma } from "../../config/prisma";
import { authenticate, requireTenantScope } from "../../middleware/auth";
import { sendSuccess, AppError } from "../../utils/response";
import { Prisma, PaymentDirection } from "@prisma/client";

export const dailyTallyRouter = Router();

dailyTallyRouter.use(authenticate, requireTenantScope);

// GET /api/v1/daily-tally/today - Computes live drawer cash position for current day
dailyTallyRouter.get("/today", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const tenantId = req.tenantId!;
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    const todayEnd = new Date();
    todayEnd.setHours(23, 59, 59, 999);

    // 1. Get latest closing cash as opening cash
    const lastTally = await prisma.dailyTally.findFirst({
      where: { tenantId, tallyDate: { lt: todayStart } },
      orderBy: { tallyDate: "desc" },
    });
    const openingCash = lastTally ? Number(lastTally.actualCashCounted) : 0;

    // 2. Aggregate today's cash sales
    const cashSalesAgg = await prisma.salesBill.aggregate({
      where: {
        tenantId,
        billDate: { gte: todayStart, lte: todayEnd },
        status: { not: "CANCELLED" },
      },
      _sum: { grandTotal: true },
    });
    const cashSales = Number(cashSalesAgg._sum?.grandTotal || 0);

    // 3. Aggregate today's customer collections (Inbound Payments in Cash)
    const inwardCashAgg = await prisma.payment.aggregate({
      where: {
        tenantId,
        paymentDate: { gte: todayStart, lte: todayEnd },
        direction: PaymentDirection.INBOUND_FROM_BUYER,
        method: "CASH",
        status: "SUCCESS",
      },
      _sum: { amount: true },
    });
    const outstandingReceived = Number(inwardCashAgg._sum?.amount || 0);

    // 4. Aggregate today's outward expenses (Outbound Payments in Cash)
    const outwardCashAgg = await prisma.payment.aggregate({
      where: {
        tenantId,
        paymentDate: { gte: todayStart, lte: todayEnd },
        direction: PaymentDirection.OUTBOUND_TO_SELLER,
        method: "CASH",
        status: "SUCCESS",
      },
      _sum: { amount: true },
    });
    const cashExpenses = Number(outwardCashAgg._sum?.amount || 0);

    const expectedCashClosing = openingCash + cashSales + outstandingReceived - cashExpenses;

    return sendSuccess(res, {
      todayDate: todayStart.toISOString().slice(0, 10),
      openingCash,
      cashSales,
      outstandingReceived,
      cashExpenses,
      expectedCashClosing,
    });
  } catch (err) {
    next(err);
  }
});

const createDailyTallySchema = z.object({
  tallyDate: z.string().optional(),
  openingCash: z.number().nonnegative().default(0),
  cashSales: z.number().nonnegative().default(0),
  outstandingReceived: z.number().nonnegative().default(0),
  otherCashReceived: z.number().nonnegative().default(0),
  gpay1Received: z.number().nonnegative().default(0),
  gpay2Received: z.number().nonnegative().default(0),
  labourExpense: z.number().nonnegative().default(0),
  transportExpense: z.number().nonnegative().default(0),
  rentExpense: z.number().nonnegative().default(0),
  teaExpense: z.number().nonnegative().default(0),
  otherExpense: z.number().nonnegative().default(0),
  bankDeposit: z.number().nonnegative().default(0),
  actualCashCounted: z.number().nonnegative(),
  pettyCashInHand: z.number().nonnegative().default(0),
  denominations: z.record(z.number()).optional(),
  notes: z.string().optional(),
});

// POST /api/v1/daily-tally - Finalize evening cash reconciliation
dailyTallyRouter.post("/", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const tenantId = req.tenantId!;
    const parseResult = createDailyTallySchema.safeParse(req.body);
    if (!parseResult.success) {
      throw new AppError(400, "VALIDATION_ERROR", parseResult.error.errors[0].message);
    }

    const d = parseResult.data;

    // Calculate expected cash closing
    const totalCashIn = d.openingCash + d.cashSales + d.outstandingReceived + d.otherCashReceived;
    const totalCashOut = d.labourExpense + d.transportExpense + d.rentExpense + d.teaExpense + d.otherExpense + d.bankDeposit;
    const expectedCashClosing = totalCashIn - totalCashOut;
    const cashDifference = d.actualCashCounted - expectedCashClosing;

    const status = Math.abs(cashDifference) < 0.01 ? "BALANCED" : cashDifference > 0 ? "SURPLUS" : "SHORTAGE";

    // Generate unique sequential tallyNumber
    const tallyCount = await prisma.dailyTally.count({ where: { tenantId } });
    const now = new Date();
    const dateStr = now.toISOString().slice(0, 10).replace(/-/g, "");
    const tallyNumber = `DT-${dateStr}-${String(tallyCount + 1).padStart(3, "0")}`;

    const tally = await prisma.dailyTally.create({
      data: {
        tenantId,
        tallyNumber,
        tallyDate: d.tallyDate ? new Date(d.tallyDate) : now,
        openingCash: new Prisma.Decimal(d.openingCash),
        cashSales: new Prisma.Decimal(d.cashSales),
        outstandingReceived: new Prisma.Decimal(d.outstandingReceived),
        otherCashReceived: new Prisma.Decimal(d.otherCashReceived),
        gpay1Received: new Prisma.Decimal(d.gpay1Received),
        gpay2Received: new Prisma.Decimal(d.gpay2Received),
        labourExpense: new Prisma.Decimal(d.labourExpense),
        transportExpense: new Prisma.Decimal(d.transportExpense),
        rentExpense: new Prisma.Decimal(d.rentExpense),
        teaExpense: new Prisma.Decimal(d.teaExpense),
        otherExpense: new Prisma.Decimal(d.otherExpense),
        bankDeposit: new Prisma.Decimal(d.bankDeposit),
        expectedCashClosing: new Prisma.Decimal(expectedCashClosing),
        actualCashCounted: new Prisma.Decimal(d.actualCashCounted),
        cashDifference: new Prisma.Decimal(cashDifference),
        pettyCashInHand: new Prisma.Decimal(d.pettyCashInHand),
        denominations: d.denominations || {},
        status,
        auditedBy: req.user?.username || "Store Admin",
        notes: d.notes || null,
        createdBy: req.user?.sub || null,
      },
    });

    return sendSuccess(
      res,
      { tally },
      `Daily cash tally finalized with status: ${status}`,
      201
    );
  } catch (err) {
    next(err);
  }
});

// GET /api/v1/daily-tally - Historical register
dailyTallyRouter.get("/", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const tenantId = req.tenantId!;
    const tallies = await prisma.dailyTally.findMany({
      where: { tenantId },
      orderBy: { tallyDate: "desc" },
      take: 50,
    });

    return sendSuccess(res, { tallies });
  } catch (err) {
    next(err);
  }
});

// GET /api/v1/daily-tally/:id - Single tally details
dailyTallyRouter.get("/:id", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const tenantId = req.tenantId!;
    const tally = await prisma.dailyTally.findFirst({
      where: { id: req.params.id, tenantId },
    });

    if (!tally) {
      throw new AppError(404, "NOT_FOUND", "Daily tally record not found");
    }

    return sendSuccess(res, { tally });
  } catch (err) {
    next(err);
  }
});
