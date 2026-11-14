import { Router, Request, Response, NextFunction } from "express";
import fs from "fs";
import { z } from "zod";
import { prisma } from "../../config/prisma";
import {
  authenticate,
  requireTenantScope,
  requirePermission,
  enforceSubscriptionQuota,
} from "../../middleware/auth";
import { AppError, sendSuccess } from "../../utils/response";
import { round2 } from "../../utils/financialMath";
import { generateDocumentPdf, PdfGenerationInput } from "../../utils/pdfGenerator";

export const reportsRouter = Router();
export const documentsRouter = Router();

reportsRouter.use(
  authenticate,
  requireTenantScope,
  enforceSubscriptionQuota("REPORTS")
);
documentsRouter.use(
  authenticate,
  requireTenantScope,
  enforceSubscriptionQuota("PDF_EXPORT")
);

function parseDateRange(query: Record<string, unknown>) {
  const startDate = query.startDate ? new Date(String(query.startDate)) : undefined;
  const endDate = query.endDate ? new Date(String(query.endDate)) : undefined;
  return { startDate, endDate };
}

// GET /api/v1/reports/daily-summary — Spec Section H
reportsRouter.get(
  "/daily-summary",
  requirePermission("reports:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const { startDate, endDate } = parseDateRange(req.query);

      const dateFilter =
        startDate || endDate
          ? {
              ...(startDate ? { gte: startDate } : {}),
              ...(endDate ? { lte: endDate } : {}),
            }
          : undefined;

      const [entries, purchases, sales, payments] = await Promise.all([
        prisma.goodsEntry.findMany({
          where: { tenantId, ...(dateFilter ? { entryDate: dateFilter } : {}) },
          include: {
            seller: { select: { name: true, phone: true, villageOrCity: true } },
            goods: { select: { name: true, unit: true } },
          },
          orderBy: { entryDate: "desc" },
        }),
        prisma.purchaseBill.findMany({
          where: {
            tenantId,
            status: { not: "CANCELLED" },
            ...(dateFilter ? { billDate: dateFilter } : {}),
          },
          include: {
            seller: { select: { name: true, phone: true, villageOrCity: true } },
          },
          orderBy: { billDate: "desc" },
        }),
        prisma.salesBill.findMany({
          where: {
            tenantId,
            status: { not: "CANCELLED" },
            ...(dateFilter ? { billDate: dateFilter } : {}),
          },
          include: {
            buyer: { select: { name: true, phone: true, villageOrCity: true } },
          },
          orderBy: { billDate: "desc" },
        }),
        prisma.payment.findMany({
          where: { tenantId, ...(dateFilter ? { paymentDate: dateFilter } : {}) },
          include: {
            buyer: { select: { name: true } },
            seller: { select: { name: true } },
          },
          orderBy: { paymentDate: "desc" },
        }),
      ]);

      return sendSuccess(res, {
        totals: {
          goodsEntriesCount: entries.length,
          totalPurchaseAmount: round2(purchases.reduce((s, p) => s + Number(p.grandTotal), 0)),
          totalSalesAmount: round2(sales.reduce((s, b) => s + Number(b.grandTotal), 0)),
          totalCollections: round2(
            payments
              .filter((p) => p.direction === "INBOUND_FROM_BUYER")
              .reduce((s, p) => s + Number(p.amount), 0)
          ),
          totalPayouts: round2(
            payments
              .filter((p) => p.direction === "OUTBOUND_TO_SELLER")
              .reduce((s, p) => s + Number(p.amount), 0)
          ),
        },
        entries,
        purchases,
        sales,
        payments,
      });
    } catch (err) {
      next(err);
    }
  }
);

// GET /api/v1/reports/sales
reportsRouter.get(
  "/sales",
  requirePermission("reports:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const { startDate, endDate } = parseDateRange(req.query);
      const isRmcOnly = req.query.rmcOnly === "true";

      const where: Record<string, unknown> = {
        tenantId,
        status: { not: "CANCELLED" },
      };
      if (isRmcApplicableFilter(isRmcOnly)) where.isRmcApplicable = true;
      if (startDate || endDate) {
        where.billDate = {
          ...(startDate ? { gte: startDate } : {}),
          ...(endDate ? { lte: endDate } : {}),
        };
      }

      const bills = await prisma.salesBill.findMany({
        where,
        orderBy: { billDate: "desc" },
        include: {
          buyer: { select: { id: true, name: true, code: true, phone: true, villageOrCity: true } },
          items: { include: { goods: { select: { name: true, code: true } } } },
        },
      });

      const summary = {
        billCount: bills.length,
        subtotal: round2(bills.reduce((s, b) => s + Number(b.subtotal), 0)),
        labourCharge: round2(bills.reduce((s, b) => s + Number(b.labourCharge), 0)),
        rmcCessAmount: round2(bills.reduce((s, b) => s + Number(b.rmcCessAmount), 0)),
        grandTotal: round2(bills.reduce((s, b) => s + Number(b.grandTotal), 0)),
        receivedAmount: round2(bills.reduce((s, b) => s + Number(b.receivedAmount), 0)),
        outstandingAmount: round2(bills.reduce((s, b) => s + Number(b.outstandingAmount), 0)),
      };

      return sendSuccess(res, { summary, bills });
    } catch (err) {
      next(err);
    }
  }
);

function isRmcApplicableFilter(flag: boolean): boolean {
  return flag === true;
}

// GET /api/v1/reports/purchases
reportsRouter.get(
  "/purchases",
  requirePermission("reports:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const { startDate, endDate } = parseDateRange(req.query);

      const where: Record<string, unknown> = {
        tenantId,
        status: { not: "CANCELLED" },
      };
      if (startDate || endDate) {
        where.billDate = {
          ...(startDate ? { gte: startDate } : {}),
          ...(endDate ? { lte: endDate } : {}),
        };
      }

      const bills = await prisma.purchaseBill.findMany({
        where,
        orderBy: { billDate: "desc" },
        include: {
          seller: { select: { id: true, name: true, code: true, phone: true, villageOrCity: true } },
          items: { include: { goods: { select: { name: true, code: true } } } },
        },
      });

      const summary = {
        billCount: bills.length,
        subtotal: round2(bills.reduce((s, b) => s + Number(b.subtotal), 0)),
        labourCharge: round2(bills.reduce((s, b) => s + Number(b.labourCharge), 0)),
        grandTotal: round2(bills.reduce((s, b) => s + Number(b.grandTotal), 0)),
        paidAmount: round2(bills.reduce((s, b) => s + Number(b.paidAmount), 0)),
        outstandingAmount: round2(bills.reduce((s, b) => s + Number(b.outstandingAmount), 0)),
      };

      return sendSuccess(res, { summary, bills });
    } catch (err) {
      next(err);
    }
  }
);

// GET /api/v1/reports/inventory
reportsRouter.get(
  "/inventory",
  requirePermission("reports:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const goods = await prisma.goods.findMany({
        where: { tenantId, deletedAt: null },
        include: { category: true },
        orderBy: { name: "asc" },
      });
      const lots = await prisma.goodsLot.findMany({
        where: { tenantId },
        include: { seller: { select: { name: true } }, goods: { select: { name: true } } },
        orderBy: { arrivalDate: "desc" },
      });

      return sendSuccess(res, { goods, lots });
    } catch (err) {
      next(err);
    }
  }
);

// GET /api/v1/reports/outstanding
reportsRouter.get(
  "/outstanding",
  requirePermission("reports:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const [buyers, sellers] = await Promise.all([
        prisma.buyer.findMany({
          where: { tenantId, deletedAt: null, currentBalance: { gt: 0 } },
          orderBy: { currentBalance: "desc" },
        }),
        prisma.seller.findMany({
          where: { tenantId, deletedAt: null, currentBalance: { gt: 0 } },
          orderBy: { currentBalance: "desc" },
        }),
      ]);

      return sendSuccess(res, {
        totalBuyerReceivable: round2(buyers.reduce((s, b) => s + Number(b.currentBalance), 0)),
        totalSellerPayable: round2(sellers.reduce((s, b) => s + Number(b.currentBalance), 0)),
        buyers,
        sellers,
      });
    } catch (err) {
      next(err);
    }
  }
);

// GET /api/v1/reports/profit-loss — Gross Profit Report (Spec Section H)
reportsRouter.get(
  "/profit-loss",
  requirePermission("reports:profit_loss"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const { startDate, endDate } = parseDateRange(req.query);

      const where: Record<string, unknown> = {
        tenantId,
        status: { not: "CANCELLED" },
      };
      if (startDate || endDate) {
        where.billDate = {
          ...(startDate ? { gte: startDate } : {}),
          ...(endDate ? { lte: endDate } : {}),
        };
      }

      const salesBills = await prisma.salesBill.findMany({
        where,
        include: { items: { include: { goods: true } }, buyer: true },
        orderBy: { billDate: "desc" },
      });

      let totalSalesRevenue = 0;
      let totalCostOfGoodsSold = 0;

      const lineBreakdown = salesBills.flatMap((bill) =>
        bill.items.map((item) => {
          const qty = Number(item.quantity);
          const revenue = Number(item.lineTotal);
          const costBasis = round2(qty * Number(item.costPrice));
          const grossProfit = round2(revenue - costBasis);

          totalSalesRevenue += revenue;
          totalCostOfGoodsSold += costBasis;

          return {
            billNumber: bill.billNumber,
            billDate: bill.billDate,
            buyerName: bill.buyer.name,
            goodsName: item.goods.name,
            quantity: qty,
            unit: item.unit,
            costPrice: Number(item.costPrice),
            sellingPrice: Number(item.unitPrice),
            revenue: round2(revenue),
            costOfGoodsSold: costBasis,
            grossProfit,
          };
        })
      );

      totalSalesRevenue = round2(totalSalesRevenue);
      totalCostOfGoodsSold = round2(totalCostOfGoodsSold);
      const netGrossProfit = round2(totalSalesRevenue - totalCostOfGoodsSold);
      const marginPercent =
        totalSalesRevenue > 0 ? round2((netGrossProfit / totalSalesRevenue) * 100) : 0;

      return sendSuccess(res, {
        summary: {
          totalSalesRevenue,
          totalCostOfGoodsSold,
          netGrossProfit,
          marginPercent,
        },
        items: lineBreakdown,
      });
    } catch (err) {
      next(err);
    }
  }
);

// GET /api/v1/reports/smart-charts
reportsRouter.get(
  "/smart-charts",
  requirePermission("reports:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const [smartCharts, auctions] = await Promise.all([
        prisma.smartChart.findMany({
          where: { tenantId },
          include: { items: { include: { goods: true } } },
          orderBy: { chartDate: "desc" },
        }),
        prisma.auction.findMany({
          where: { tenantId },
          include: { items: { include: { goods: true, buyer: true } } },
          orderBy: { auctionDate: "desc" },
        }),
      ]);

      return sendSuccess(res, { smartCharts, auctions });
    } catch (err) {
      next(err);
    }
  }
);

// ============================================================================
// PDF & DOCUMENT GENERATION (/api/v1/documents) — Spec Section 17
// ============================================================================

documentsRouter.post(
  "/pdf",
  requirePermission("documents:generate"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const schema = z.object({
        documentType: z.enum([
          "PURCHASE_BILL",
          "SALES_BILL",
          "PAYMENT_RECEIPT",
          "BUYER_LEDGER",
          "SELLER_LEDGER",
          "SMART_CHART_REPORT",
        ]),
        referenceId: z.string().uuid(),
      });
      const body = schema.parse(req.body);

      const profile = await prisma.businessProfile.findUnique({ where: { tenantId } });
      const businessName = profile?.businessName ?? "CLICK Smart Chart Business";
      const businessAddress = [profile?.addressLine1, profile?.city, profile?.state]
        .filter(Boolean)
        .join(", ");

      let pdfInput: PdfGenerationInput;
      let docNumber = `DOC-${Date.now().toString().slice(-6)}`;

      if (body.documentType === "SALES_BILL") {
        const bill = await prisma.salesBill.findFirst({
          where: { id: body.referenceId, tenantId },
          include: { buyer: true, items: { include: { goods: true } } },
        });
        if (!bill) throw new AppError(404, "BILL_NOT_FOUND", "Sales bill not found.");
        docNumber = bill.billNumber;
        pdfInput = {
          businessName,
          businessAddress,
          businessPhone: profile?.phone,
          gstNumber: profile?.gstNumber ?? undefined,
          documentTitle: "TAX / SALES BILL",
          documentNumber: bill.billNumber,
          documentDate: bill.billDate.toISOString().slice(0, 10),
          partyLabel: "Buyer Details",
          partyName: bill.buyer.name,
          partyPhone: bill.buyer.phone,
          partyAddress: bill.buyer.villageOrCity ?? bill.buyer.address ?? undefined,
          paymentStatus: bill.status,
          columns: [
            { header: "Goods", key: "goods" },
            { header: "Bags", key: "bags", align: "right" },
            { header: "Net Qty", key: "qty", align: "right" },
            { header: "Rate", key: "rate", align: "right" },
            { header: "Line Total", key: "total", align: "right" },
          ],
          rows: bill.items.map((item) => ({
            goods: item.goods.name,
            bags: item.bagsCount,
            qty: `${item.quantity} ${item.unit}`,
            rate: Number(item.unitPrice).toFixed(2),
            total: Number(item.lineTotal).toFixed(2),
          })),
          summaryRows: [
            { label: "Subtotal:", value: `INR ${Number(bill.subtotal).toFixed(2)}` },
            { label: "Labour Charge:", value: `INR ${Number(bill.labourCharge).toFixed(2)}` },
            { label: "RMC / Market Cess:", value: `INR ${Number(bill.rmcCessAmount).toFixed(2)}` },
            { label: "Grand Total:", value: `INR ${Number(bill.grandTotal).toFixed(2)}` },
            { label: "Received Amount:", value: `INR ${Number(bill.receivedAmount).toFixed(2)}` },
            { label: "Previous Balance:", value: `INR ${Number(bill.previousBalance).toFixed(2)}` },
            { label: "Closing Balance Due:", value: `INR ${Number(bill.closingBalance).toFixed(2)}` },
          ],
          notes: bill.notes ?? undefined,
          footerText: profile?.documentFooter ?? undefined,
        };
      } else if (body.documentType === "PURCHASE_BILL") {
        const bill = await prisma.purchaseBill.findFirst({
          where: { id: body.referenceId, tenantId },
          include: { seller: true, items: { include: { goods: true } } },
        });
        if (!bill) throw new AppError(404, "BILL_NOT_FOUND", "Purchase bill not found.");
        docNumber = bill.billNumber;
        pdfInput = {
          businessName,
          businessAddress,
          businessPhone: profile?.phone,
          gstNumber: profile?.gstNumber ?? undefined,
          documentTitle: "PURCHASE BILL / PATTI",
          documentNumber: bill.billNumber,
          documentDate: bill.billDate.toISOString().slice(0, 10),
          partyLabel: "Seller / Farmer Details",
          partyName: bill.seller.name,
          partyPhone: bill.seller.phone,
          partyAddress: bill.seller.villageOrCity ?? bill.seller.address ?? undefined,
          paymentStatus: bill.status,
          columns: [
            { header: "Goods", key: "goods" },
            { header: "Bags", key: "bags", align: "right" },
            { header: "Net Qty", key: "qty", align: "right" },
            { header: "Rate", key: "rate", align: "right" },
            { header: "Line Total", key: "total", align: "right" },
          ],
          rows: bill.items.map((item) => ({
            goods: item.goods.name,
            bags: item.bagsCount,
            qty: `${item.quantity} ${item.unit}`,
            rate: Number(item.unitPrice).toFixed(2),
            total: Number(item.lineTotal).toFixed(2),
          })),
          summaryRows: [
            { label: "Subtotal:", value: `INR ${Number(bill.subtotal).toFixed(2)}` },
            { label: "Labour / Hamali:", value: `INR ${Number(bill.labourCharge).toFixed(2)}` },
            { label: "Grand Total:", value: `INR ${Number(bill.grandTotal).toFixed(2)}` },
            { label: "Paid On-Spot:", value: `INR ${Number(bill.paidAmount).toFixed(2)}` },
            { label: "Closing Payable:", value: `INR ${Number(bill.closingBalance).toFixed(2)}` },
          ],
          notes: bill.notes ?? undefined,
          footerText: profile?.documentFooter ?? undefined,
        };
      } else {
        const payment = await prisma.payment.findFirst({
          where: { id: body.referenceId, tenantId },
          include: { buyer: true, seller: true },
        });
        if (!payment) throw new AppError(404, "RECORD_NOT_FOUND", "Reference record not found.");
        docNumber = payment.receiptNumber;
        const party = payment.buyer ?? payment.seller;
        pdfInput = {
          businessName,
          businessAddress,
          businessPhone: profile?.phone,
          documentTitle: "OFFICIAL PAYMENT RECEIPT",
          documentNumber: payment.receiptNumber,
          documentDate: payment.paymentDate.toISOString().slice(0, 10),
          partyLabel: payment.buyer ? "Received From Buyer" : "Paid To Seller",
          partyName: party?.name ?? "Counter Party",
          partyPhone: party?.phone,
          paymentStatus: payment.status,
          columns: [
            { header: "Receipt #", key: "receipt" },
            { header: "Method", key: "method" },
            { header: "Reference", key: "ref" },
            { header: "Amount", key: "amount", align: "right" },
          ],
          rows: [
            {
              receipt: payment.receiptNumber,
              method: payment.method,
              ref: payment.transactionRef ?? "-",
              amount: `INR ${Number(payment.amount).toFixed(2)}`,
            },
          ],
          summaryRows: [
            { label: "Total Settled:", value: `INR ${Number(payment.amount).toFixed(2)}` },
          ],
          notes: payment.notes ?? undefined,
        };
      }

      const fileName = `${body.documentType.toLowerCase()}-${docNumber}-${Date.now()}.pdf`;
      const { filePath, fileSizeBytes } = await generateDocumentPdf(tenantId, fileName, pdfInput);

      const docRecord = await prisma.businessDocument.create({
        data: {
          tenantId,
          documentNumber: docNumber,
          documentType: body.documentType,
          referenceId: body.referenceId,
          title: `${pdfInput.documentTitle} (${docNumber})`,
          filePath,
          fileSizeBytes,
          createdBy: req.user!.sub,
        },
      });

      return sendSuccess(
        res,
        {
          id: docRecord.id,
          documentNumber: docRecord.documentNumber,
          documentType: docRecord.documentType,
          title: docRecord.title,
          downloadUrl: `/api/v1/documents/${docRecord.id}/download`,
        },
        "PDF document generated.",
        201
      );
    } catch (err) {
      next(err);
    }
  }
);

documentsRouter.get(
  "/:id",
  requirePermission("documents:generate"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const doc = await prisma.businessDocument.findFirst({
        where: { id: req.params.id, tenantId },
      });
      if (!doc) throw new AppError(404, "DOCUMENT_NOT_FOUND", "Document not found.");
      return sendSuccess(res, doc);
    } catch (err) {
      next(err);
    }
  }
);

documentsRouter.get(
  "/:id/download",
  requirePermission("documents:generate"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const doc = await prisma.businessDocument.findFirst({
        where: { id: req.params.id, tenantId },
      });
      if (!doc || !fs.existsSync(doc.filePath)) {
        throw new AppError(404, "DOCUMENT_NOT_FOUND", "PDF file not found on server.");
      }

      res.setHeader("Content-Type", doc.mimeType);
      res.setHeader(
        "Content-Disposition",
        `attachment; filename="${doc.documentNumber}.pdf"`
      );
      fs.createReadStream(doc.filePath).pipe(res);
    } catch (err) {
      next(err);
    }
  }
);
