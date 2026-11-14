import { Router, Request, Response, NextFunction } from "express";
import { z } from "zod";
import { prisma } from "../../config/prisma";
import { authenticate, requireTenantScope, requirePermission } from "../../middleware/auth";
import { AppError, sendSuccess, parsePagination } from "../../utils/response";
import { calculateBillTotals, round2, round3 } from "../../utils/financialMath";
import { recordAuditLog } from "../../utils/auditLogger";

export const purchasesRouter = Router();
export const salesRouter = Router();
export const paymentsRouter = Router();
export const advancesRouter = Router();

purchasesRouter.use(authenticate, requireTenantScope);
salesRouter.use(authenticate, requireTenantScope);
paymentsRouter.use(authenticate, requireTenantScope);
advancesRouter.use(authenticate, requireTenantScope);

const billItemInputSchema = z.object({
  goodsId: z.string().uuid(),
  lotId: z.string().uuid().optional(),
  bagsCount: z.coerce.number().int().min(1).default(1),
  grossWeight: z.coerce.number().positive(),
  tareWeight: z.coerce.number().min(0).default(0),
  unit: z.string().default("KG"),
  unitPrice: z.coerce.number().min(0),
  costPrice: z.coerce.number().min(0).optional(),
});

// ============================================================================
// PURCHASE BILL BOOK (/api/v1/purchases) — Spec Section D
// ============================================================================

purchasesRouter.get(
  "/",
  requirePermission("purchases:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const { page, limit, skip, search } = parsePagination(req.query);
      const status = typeof req.query.status === "string" ? req.query.status : undefined;
      const sellerId = typeof req.query.sellerId === "string" ? req.query.sellerId : undefined;

      const where: Record<string, unknown> = { tenantId };
      if (status) where.status = status;
      if (sellerId) where.sellerId = sellerId;
      if (search) {
        where.OR = [
          { billNumber: { contains: search } },
          { seller: { name: { contains: search } } },
          { vehicleNumber: { contains: search } },
        ];
      }

      const [items, total] = await Promise.all([
        prisma.purchaseBill.findMany({
          where,
          skip,
          take: limit,
          orderBy: { billDate: "desc" },
          include: {
            seller: { select: { id: true, name: true, code: true, phone: true, villageOrCity: true } },
            items: { include: { goods: { select: { id: true, name: true, code: true, unit: true } } } },
          },
        }),
        prisma.purchaseBill.count({ where }),
      ]);

      return sendSuccess(res, items, "Purchase bills retrieved.", 200, {
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

purchasesRouter.post(
  "/",
  requirePermission("purchases:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const schema = z.object({
        billNumber: z.string().optional(),
        billDate: z.coerce.date().optional(),
        sellerId: z.string().uuid(),
        vehicleNumber: z.string().optional(),
        referenceNumber: z.string().optional(),
        isDraft: z.boolean().default(false),
        labourCharge: z.coerce.number().min(0).default(0),
        otherCharges: z.coerce.number().min(0).default(0),
        discountAmount: z.coerce.number().min(0).default(0),
        taxAmount: z.coerce.number().min(0).default(0),
        paidAmount: z.coerce.number().min(0).default(0),
        paymentMethod: z.enum(["CASH", "UPI", "BANK_TRANSFER", "CHEQUE", "WALLET"]).default("CASH"),
        notes: z.string().optional(),
        items: z.array(billItemInputSchema).min(1),
      });
      const body = schema.parse(req.body);

      const created = await prisma.$transaction(async (tx) => {
        const seller = await tx.seller.findFirst({
          where: { id: body.sellerId, tenantId, deletedAt: null },
        });
        if (!seller) throw new AppError(404, "SELLER_NOT_FOUND", "Seller not found.");

        const previousBalance = Number(seller.currentBalance);
        const calc = calculateBillTotals({
          items: body.items,
          labourCharge: body.labourCharge,
          otherCharges: body.otherCharges,
          discountAmount: body.discountAmount,
          taxAmount: body.taxAmount,
          paidOrReceivedAmount: body.paidAmount,
          previousBalance,
        });

        const billNumber = body.billNumber || `PB-${Date.now().toString().slice(-6)}`;
        const status = body.isDraft ? "DRAFT" : calc.status;

        const bill = await tx.purchaseBill.create({
          data: {
            tenantId,
            billNumber,
            billDate: body.billDate ?? new Date(),
            sellerId: seller.id,
            vehicleNumber: body.vehicleNumber ?? null,
            referenceNumber: body.referenceNumber ?? null,
            status,
            subtotal: calc.subtotal,
            labourCharge: calc.labourCharge,
            otherCharges: calc.otherCharges,
            discountAmount: calc.discountAmount,
            taxAmount: calc.taxAmount,
            grandTotal: calc.grandTotal,
            paidAmount: calc.paidOrReceivedAmount,
            outstandingAmount: calc.outstandingAmount,
            previousBalance: calc.previousBalance,
            closingBalance: calc.closingBalance,
            notes: body.notes ?? null,
            createdBy: req.user!.sub,
            items: {
              create: body.items.map((item, idx) => ({
                goodsId: item.goodsId,
                lotId: item.lotId ?? null,
                bagsCount: calc.lines[idx].bagsCount,
                grossWeight: calc.lines[idx].grossWeight,
                tareWeight: calc.lines[idx].tareWeight,
                quantity: calc.lines[idx].netQuantity,
                unit: item.unit,
                unitPrice: calc.lines[idx].unitPrice,
                lineTotal: calc.lines[idx].lineTotal,
              })),
            },
          },
          include: { seller: true, items: { include: { goods: true } } },
        });

        if (!body.isDraft) {
          // 1. Update stock & record inventory inward transactions
          for (let i = 0; i < body.items.length; i++) {
            const rawItem = body.items[i];
            const compLine = calc.lines[i];
            const goods = await tx.goods.findFirst({
              where: { id: rawItem.goodsId, tenantId },
            });
            if (!goods) throw new AppError(404, "GOODS_NOT_FOUND", "Goods item not found.");

            const newStock = round3(Number(goods.currentStock) + compLine.netQuantity);
            await tx.goods.update({
              where: { id: goods.id },
              data: {
                currentStock: newStock,
                purchasePrice: compLine.unitPrice,
                updatedBy: req.user!.sub,
              },
            });

            await tx.inventoryTransaction.create({
              data: {
                tenantId,
                goodsId: goods.id,
                lotId: rawItem.lotId ?? null,
                type: "PURCHASE_INWARD",
                referenceId: bill.id,
                referenceNumber: bill.billNumber,
                inwardQuantity: compLine.netQuantity,
                outwardQuantity: 0,
                balanceQuantity: newStock,
                unitCost: compLine.unitPrice,
                notes: `Purchase Bill ${bill.billNumber}`,
                createdBy: req.user!.sub,
              },
            });
          }

          // 2. Seller Ledger Credit for Purchase Bill Grand Total
          let runningBal = round2(previousBalance + calc.grandTotal);
          await tx.sellerLedgerEntry.create({
            data: {
              tenantId,
              sellerId: seller.id,
              entryType: "PURCHASE_BILL",
              referenceId: bill.id,
              referenceNo: bill.billNumber,
              description: `Purchase Bill ${bill.billNumber}`,
              debitAmount: 0,
              creditAmount: calc.grandTotal,
              runningBalance: runningBal,
              createdBy: req.user!.sub,
            },
          });

          // 3. On-spot Payment to Seller if paidAmount > 0
          if (calc.paidOrReceivedAmount > 0) {
            const receiptNo = `PMT-${Date.now().toString().slice(-6)}`;
            await tx.payment.create({
              data: {
                tenantId,
                receiptNumber: receiptNo,
                direction: "OUTBOUND_TO_SELLER",
                sellerId: seller.id,
                purchaseBillId: bill.id,
                method: body.paymentMethod,
                amount: calc.paidOrReceivedAmount,
                status: "SUCCESS",
                notes: `On-spot payment for ${bill.billNumber}`,
                createdBy: req.user!.sub,
              },
            });

            runningBal = round2(runningBal - calc.paidOrReceivedAmount);
            await tx.sellerLedgerEntry.create({
              data: {
                tenantId,
                sellerId: seller.id,
                entryType: "PAYMENT_MADE",
                referenceId: bill.id,
                referenceNo: receiptNo,
                description: `On-spot payment against ${bill.billNumber}`,
                debitAmount: calc.paidOrReceivedAmount,
                creditAmount: 0,
                runningBalance: runningBal,
                createdBy: req.user!.sub,
              },
            });
          }

          await tx.seller.update({
            where: { id: seller.id },
            data: { currentBalance: runningBal, updatedBy: req.user!.sub },
          });
        }

        return bill;
      });

      await recordAuditLog({
        tenantId,
        userId: req.user!.sub,
        action: "PURCHASE_BILL_CREATED",
        entityType: "PurchaseBill",
        entityId: created.id,
      });

      return sendSuccess(res, created, "Purchase bill saved.", 201);
    } catch (err) {
      next(err);
    }
  }
);

purchasesRouter.get(
  "/:id",
  requirePermission("purchases:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const bill = await prisma.purchaseBill.findFirst({
        where: { id: req.params.id, tenantId },
        include: {
          seller: true,
          items: { include: { goods: true, lot: true } },
          payments: true,
        },
      });
      if (!bill) throw new AppError(404, "BILL_NOT_FOUND", "Purchase bill not found.");
      return sendSuccess(res, bill);
    } catch (err) {
      next(err);
    }
  }
);

purchasesRouter.patch(
  "/:id",
  requirePermission("purchases:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const existing = await prisma.purchaseBill.findFirst({
        where: { id: req.params.id, tenantId },
      });
      if (!existing) throw new AppError(404, "BILL_NOT_FOUND", "Purchase bill not found.");
      if (existing.status === "CANCELLED") {
        throw new AppError(400, "BILL_CANCELLED", "Cannot edit a cancelled bill.");
      }

      const updated = await prisma.purchaseBill.update({
        where: { id: existing.id },
        data: {
          notes: req.body.notes ?? existing.notes,
          vehicleNumber: req.body.vehicleNumber ?? existing.vehicleNumber,
          referenceNumber: req.body.referenceNumber ?? existing.referenceNumber,
          updatedBy: req.user!.sub,
        },
      });
      return sendSuccess(res, updated, "Purchase bill updated.");
    } catch (err) {
      next(err);
    }
  }
);

purchasesRouter.post(
  "/:id/cancel",
  requirePermission("purchases:cancel"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const { reason } = z.object({ reason: z.string().min(3) }).parse(req.body);

      const cancelled = await prisma.$transaction(async (tx) => {
        const bill = await tx.purchaseBill.findFirst({
          where: { id: req.params.id, tenantId },
          include: { items: true, seller: true },
        });
        if (!bill) throw new AppError(404, "BILL_NOT_FOUND", "Purchase bill not found.");
        if (bill.status === "CANCELLED") {
          throw new AppError(400, "ALREADY_CANCELLED", "Purchase bill is already cancelled.");
        }

        if (bill.status !== "DRAFT") {
          // Reverse stock inward
          for (const item of bill.items) {
            const goods = await tx.goods.findUnique({ where: { id: item.goodsId } });
            if (goods) {
              const newStock = round3(Math.max(0, Number(goods.currentStock) - Number(item.quantity)));
              await tx.goods.update({
                where: { id: goods.id },
                data: { currentStock: newStock },
              });
              await tx.inventoryTransaction.create({
                data: {
                  tenantId,
                  goodsId: goods.id,
                  type: "BILL_CANCEL_REVERSAL",
                  referenceId: bill.id,
                  referenceNumber: bill.billNumber,
                  inwardQuantity: 0,
                  outwardQuantity: item.quantity,
                  balanceQuantity: newStock,
                  unitCost: item.unitPrice,
                  notes: `Cancelled Purchase Bill ${bill.billNumber}: ${reason}`,
                  createdBy: req.user!.sub,
                },
              });
            }
          }

          // Reverse Seller Ledger & Balance
          const netEffect = round2(Number(bill.grandTotal) - Number(bill.paidAmount));
          const newSellerBal = round2(Number(bill.seller.currentBalance) - netEffect);
          await tx.seller.update({
            where: { id: bill.sellerId },
            data: { currentBalance: newSellerBal },
          });

          await tx.sellerLedgerEntry.create({
            data: {
              tenantId,
              sellerId: bill.sellerId,
              entryType: "BILL_CANCELLATION",
              referenceId: bill.id,
              referenceNo: bill.billNumber,
              description: `Cancelled ${bill.billNumber}: ${reason}`,
              debitAmount: netEffect > 0 ? netEffect : 0,
              creditAmount: netEffect < 0 ? Math.abs(netEffect) : 0,
              runningBalance: newSellerBal,
              createdBy: req.user!.sub,
            },
          });
        }

        return tx.purchaseBill.update({
          where: { id: bill.id },
          data: {
            status: "CANCELLED",
            cancelReason: reason,
            cancelledAt: new Date(),
            cancelledBy: req.user!.sub,
          },
        });
      });

      await recordAuditLog({
        tenantId,
        userId: req.user!.sub,
        action: "PURCHASE_BILL_CANCELLED",
        entityType: "PurchaseBill",
        entityId: cancelled.id,
        metadata: { reason },
      });

      return sendSuccess(res, cancelled, "Purchase bill cancelled with stock and ledger reversal.");
    } catch (err) {
      next(err);
    }
  }
);

// ============================================================================
// SALES BILL BOOK (/api/v1/sales) — Spec Section D
// ============================================================================

salesRouter.get(
  "/",
  requirePermission("sales:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const { page, limit, skip, search } = parsePagination(req.query);
      const status = typeof req.query.status === "string" ? req.query.status : undefined;
      const buyerId = typeof req.query.buyerId === "string" ? req.query.buyerId : undefined;

      const where: Record<string, unknown> = { tenantId };
      if (status) where.status = status;
      if (buyerId) where.buyerId = buyerId;
      if (search) {
        where.OR = [
          { billNumber: { contains: search } },
          { buyer: { name: { contains: search } } },
          { vehicleNumber: { contains: search } },
        ];
      }

      const [items, total] = await Promise.all([
        prisma.salesBill.findMany({
          where,
          skip,
          take: limit,
          orderBy: { billDate: "desc" },
          include: {
            buyer: { select: { id: true, name: true, code: true, phone: true, villageOrCity: true } },
            items: { include: { goods: { select: { id: true, name: true, code: true, unit: true } } } },
          },
        }),
        prisma.salesBill.count({ where }),
      ]);

      return sendSuccess(res, items, "Sales bills retrieved.", 200, {
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

salesRouter.post(
  "/",
  requirePermission("sales:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const schema = z.object({
        billNumber: z.string().optional(),
        billDate: z.coerce.date().optional(),
        buyerId: z.string().uuid(),
        vehicleNumber: z.string().optional(),
        referenceNumber: z.string().optional(),
        isRmcApplicable: z.boolean().default(false),
        rmcPermitNumber: z.string().optional(),
        rmcCessPercent: z.coerce.number().min(0).default(1),
        isDraft: z.boolean().default(false),
        labourCharge: z.coerce.number().min(0).default(0),
        otherCharges: z.coerce.number().min(0).default(0),
        discountAmount: z.coerce.number().min(0).default(0),
        taxAmount: z.coerce.number().min(0).default(0),
        receivedAmount: z.coerce.number().min(0).default(0),
        paymentMethod: z.enum(["CASH", "UPI", "BANK_TRANSFER", "CHEQUE", "WALLET"]).default("CASH"),
        notes: z.string().optional(),
        items: z.array(billItemInputSchema).min(1),
      });
      const body = schema.parse(req.body);

      const created = await prisma.$transaction(async (tx) => {
        const buyer = await tx.buyer.findFirst({
          where: { id: body.buyerId, tenantId, deletedAt: null },
        });
        if (!buyer) throw new AppError(404, "BUYER_NOT_FOUND", "Buyer not found.");

        const previousBalance = Number(buyer.currentBalance);
        const calc = calculateBillTotals({
          items: body.items,
          labourCharge: body.labourCharge,
          isRmcApplicable: body.isRmcApplicable,
          rmcCessPercent: body.rmcCessPercent,
          otherCharges: body.otherCharges,
          discountAmount: body.discountAmount,
          taxAmount: body.taxAmount,
          paidOrReceivedAmount: body.receivedAmount,
          previousBalance,
        });

        const billNumber = body.billNumber || `SB-${Date.now().toString().slice(-6)}`;
        const status = body.isDraft ? "DRAFT" : calc.status;

        // Fetch goods cost prices for gross profit tracking
        const goodsMap = new Map<string, { purchasePrice: number; currentStock: number }>();
        for (const item of body.items) {
          const g = await tx.goods.findFirst({ where: { id: item.goodsId, tenantId } });
          if (!g) throw new AppError(404, "GOODS_NOT_FOUND", "Goods item not found.");
          goodsMap.set(g.id, {
            purchasePrice: Number(g.purchasePrice),
            currentStock: Number(g.currentStock),
          });
        }

        const bill = await tx.salesBill.create({
          data: {
            tenantId,
            billNumber,
            billDate: body.billDate ?? new Date(),
            buyerId: buyer.id,
            vehicleNumber: body.vehicleNumber ?? null,
            referenceNumber: body.referenceNumber ?? null,
            isRmcApplicable: body.isRmcApplicable,
            rmcPermitNumber: body.rmcPermitNumber ?? null,
            status,
            subtotal: calc.subtotal,
            labourCharge: calc.labourCharge,
            rmcCessAmount: calc.rmcCessAmount,
            otherCharges: calc.otherCharges,
            discountAmount: calc.discountAmount,
            taxAmount: calc.taxAmount,
            grandTotal: calc.grandTotal,
            receivedAmount: calc.paidOrReceivedAmount,
            outstandingAmount: calc.outstandingAmount,
            previousBalance: calc.previousBalance,
            closingBalance: calc.closingBalance,
            notes: body.notes ?? null,
            createdBy: req.user!.sub,
            items: {
              create: body.items.map((item, idx) => ({
                goodsId: item.goodsId,
                lotId: item.lotId ?? null,
                bagsCount: calc.lines[idx].bagsCount,
                grossWeight: calc.lines[idx].grossWeight,
                tareWeight: calc.lines[idx].tareWeight,
                quantity: calc.lines[idx].netQuantity,
                unit: item.unit,
                costPrice:
                  item.costPrice ?? goodsMap.get(item.goodsId)?.purchasePrice ?? 0,
                unitPrice: calc.lines[idx].unitPrice,
                lineTotal: calc.lines[idx].lineTotal,
              })),
            },
          },
          include: { buyer: true, items: { include: { goods: true } } },
        });

        if (!body.isDraft) {
          // 1. Deduct stock & update GoodsLot if linked
          for (let i = 0; i < body.items.length; i++) {
            const rawItem = body.items[i];
            const compLine = calc.lines[i];
            const gInfo = goodsMap.get(rawItem.goodsId)!;
            const newStock = round3(Math.max(0, gInfo.currentStock - compLine.netQuantity));

            await tx.goods.update({
              where: { id: rawItem.goodsId },
              data: { currentStock: newStock, updatedBy: req.user!.sub },
            });

            if (rawItem.lotId) {
              const lot = await tx.goodsLot.findFirst({
                where: { id: rawItem.lotId, tenantId },
              });
              if (lot) {
                const newSold = round3(Number(lot.soldQuantity) + compLine.netQuantity);
                const newRem = round3(Math.max(0, Number(lot.initialQuantity) - newSold));
                await tx.goodsLot.update({
                  where: { id: lot.id },
                  data: {
                    soldQuantity: newSold,
                    remainingQuantity: newRem,
                    status: newRem <= 0 ? "SOLD_OUT" : "PARTIAL",
                  },
                });
              }
            }

            await tx.inventoryTransaction.create({
              data: {
                tenantId,
                goodsId: rawItem.goodsId,
                lotId: rawItem.lotId ?? null,
                type: "SALE_OUTWARD",
                referenceId: bill.id,
                referenceNumber: bill.billNumber,
                inwardQuantity: 0,
                outwardQuantity: compLine.netQuantity,
                balanceQuantity: newStock,
                unitCost: gInfo.purchasePrice,
                notes: `Sales Bill ${bill.billNumber}`,
                createdBy: req.user!.sub,
              },
            });
          }

          // 2. Buyer Ledger Debit for Sales Bill Grand Total
          let runningBal = round2(previousBalance + calc.grandTotal);
          await tx.buyerLedgerEntry.create({
            data: {
              tenantId,
              buyerId: buyer.id,
              entryType: "SALE_BILL",
              referenceId: bill.id,
              referenceNo: bill.billNumber,
              description: `Sales Bill ${bill.billNumber}`,
              debitAmount: calc.grandTotal,
              creditAmount: 0,
              runningBalance: runningBal,
              createdBy: req.user!.sub,
            },
          });

          // 3. On-spot Receipt from Buyer if receivedAmount > 0
          if (calc.paidOrReceivedAmount > 0) {
            const receiptNo = `RCP-${Date.now().toString().slice(-6)}`;
            await tx.payment.create({
              data: {
                tenantId,
                receiptNumber: receiptNo,
                direction: "INBOUND_FROM_BUYER",
                buyerId: buyer.id,
                salesBillId: bill.id,
                method: body.paymentMethod,
                amount: calc.paidOrReceivedAmount,
                status: "SUCCESS",
                notes: `On-spot receipt for ${bill.billNumber}`,
                createdBy: req.user!.sub,
              },
            });

            runningBal = round2(runningBal - calc.paidOrReceivedAmount);
            await tx.buyerLedgerEntry.create({
              data: {
                tenantId,
                buyerId: buyer.id,
                entryType: "PAYMENT_RECEIVED",
                referenceId: bill.id,
                referenceNo: receiptNo,
                description: `On-spot receipt against ${bill.billNumber}`,
                debitAmount: 0,
                creditAmount: calc.paidOrReceivedAmount,
                runningBalance: runningBal,
                createdBy: req.user!.sub,
              },
            });
          }

          await tx.buyer.update({
            where: { id: buyer.id },
            data: { currentBalance: runningBal, updatedBy: req.user!.sub },
          });
        }

        return bill;
      });

      await recordAuditLog({
        tenantId,
        userId: req.user!.sub,
        action: "SALES_BILL_CREATED",
        entityType: "SalesBill",
        entityId: created.id,
      });

      return sendSuccess(res, created, "Sales bill saved.", 201);
    } catch (err) {
      next(err);
    }
  }
);

salesRouter.get(
  "/:id",
  requirePermission("sales:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const bill = await prisma.salesBill.findFirst({
        where: { id: req.params.id, tenantId },
        include: {
          buyer: true,
          items: { include: { goods: true, lot: true } },
          payments: true,
        },
      });
      if (!bill) throw new AppError(404, "BILL_NOT_FOUND", "Sales bill not found.");
      return sendSuccess(res, bill);
    } catch (err) {
      next(err);
    }
  }
);

salesRouter.patch(
  "/:id",
  requirePermission("sales:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const existing = await prisma.salesBill.findFirst({
        where: { id: req.params.id, tenantId },
      });
      if (!existing) throw new AppError(404, "BILL_NOT_FOUND", "Sales bill not found.");
      if (existing.status === "CANCELLED") {
        throw new AppError(400, "BILL_CANCELLED", "Cannot edit a cancelled bill.");
      }

      const updated = await prisma.salesBill.update({
        where: { id: existing.id },
        data: {
          notes: req.body.notes ?? existing.notes,
          vehicleNumber: req.body.vehicleNumber ?? existing.vehicleNumber,
          referenceNumber: req.body.referenceNumber ?? existing.referenceNumber,
          updatedBy: req.user!.sub,
        },
      });
      return sendSuccess(res, updated, "Sales bill updated.");
    } catch (err) {
      next(err);
    }
  }
);

salesRouter.post(
  "/:id/cancel",
  requirePermission("sales:cancel"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const { reason } = z.object({ reason: z.string().min(3) }).parse(req.body);

      const cancelled = await prisma.$transaction(async (tx) => {
        const bill = await tx.salesBill.findFirst({
          where: { id: req.params.id, tenantId },
          include: { items: true, buyer: true },
        });
        if (!bill) throw new AppError(404, "BILL_NOT_FOUND", "Sales bill not found.");
        if (bill.status === "CANCELLED") {
          throw new AppError(400, "ALREADY_CANCELLED", "Sales bill is already cancelled.");
        }

        if (bill.status !== "DRAFT") {
          for (const item of bill.items) {
            const goods = await tx.goods.findUnique({ where: { id: item.goodsId } });
            if (goods) {
              const newStock = round3(Number(goods.currentStock) + Number(item.quantity));
              await tx.goods.update({
                where: { id: goods.id },
                data: { currentStock: newStock },
              });
              await tx.inventoryTransaction.create({
                data: {
                  tenantId,
                  goodsId: goods.id,
                  type: "BILL_CANCEL_REVERSAL",
                  referenceId: bill.id,
                  referenceNumber: bill.billNumber,
                  inwardQuantity: item.quantity,
                  outwardQuantity: 0,
                  balanceQuantity: newStock,
                  unitCost: item.costPrice,
                  notes: `Cancelled Sales Bill ${bill.billNumber}: ${reason}`,
                  createdBy: req.user!.sub,
                },
              });
            }
          }

          const netEffect = round2(Number(bill.grandTotal) - Number(bill.receivedAmount));
          const newBuyerBal = round2(Number(bill.buyer.currentBalance) - netEffect);
          await tx.buyer.update({
            where: { id: bill.buyerId },
            data: { currentBalance: newBuyerBal },
          });

          await tx.buyerLedgerEntry.create({
            data: {
              tenantId,
              buyerId: bill.buyerId,
              entryType: "BILL_CANCELLATION",
              referenceId: bill.id,
              referenceNo: bill.billNumber,
              description: `Cancelled ${bill.billNumber}: ${reason}`,
              debitAmount: netEffect < 0 ? Math.abs(netEffect) : 0,
              creditAmount: netEffect > 0 ? netEffect : 0,
              runningBalance: newBuyerBal,
              createdBy: req.user!.sub,
            },
          });
        }

        return tx.salesBill.update({
          where: { id: bill.id },
          data: {
            status: "CANCELLED",
            cancelReason: reason,
            cancelledAt: new Date(),
            cancelledBy: req.user!.sub,
          },
        });
      });

      await recordAuditLog({
        tenantId,
        userId: req.user!.sub,
        action: "SALES_BILL_CANCELLED",
        entityType: "SalesBill",
        entityId: cancelled.id,
        metadata: { reason },
      });

      return sendSuccess(res, cancelled, "Sales bill cancelled with stock and ledger reversal.");
    } catch (err) {
      next(err);
    }
  }
);

// ============================================================================
// PAYMENTS (/api/v1/payments) — Spec Section F
// ============================================================================

paymentsRouter.get(
  "/",
  requirePermission("payments:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const payments = await prisma.payment.findMany({
        where: { tenantId },
        orderBy: { paymentDate: "desc" },
        take: 100,
        include: {
          buyer: { select: { id: true, name: true, code: true, phone: true } },
          seller: { select: { id: true, name: true, code: true, phone: true } },
          purchaseBill: { select: { id: true, billNumber: true } },
          salesBill: { select: { id: true, billNumber: true } },
        },
      });
      return sendSuccess(res, payments);
    } catch (err) {
      next(err);
    }
  }
);

paymentsRouter.post(
  "/",
  requirePermission("payments:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const schema = z.object({
        direction: z.enum(["INBOUND_FROM_BUYER", "OUTBOUND_TO_SELLER"]),
        buyerId: z.string().uuid().optional(),
        sellerId: z.string().uuid().optional(),
        salesBillId: z.string().uuid().optional(),
        purchaseBillId: z.string().uuid().optional(),
        method: z
          .enum(["CASH", "UPI", "BANK_TRANSFER", "CHEQUE", "WALLET", "ADJUSTMENT"])
          .default("CASH"),
        amount: z.coerce.number().positive(),
        paymentDate: z.coerce.date().optional(),
        transactionRef: z.string().optional(),
        notes: z.string().optional(),
      });
      const body = schema.parse(req.body);

      const created = await prisma.$transaction(async (tx) => {
        const receiptNumber = `PMT-${Date.now().toString().slice(-6)}`;
        const amount = round2(body.amount);

        if (body.direction === "INBOUND_FROM_BUYER") {
          if (!body.buyerId) throw new AppError(400, "BUYER_REQUIRED", "buyerId is required.");
          const buyer = await tx.buyer.findFirst({
            where: { id: body.buyerId, tenantId, deletedAt: null },
          });
          if (!buyer) throw new AppError(404, "BUYER_NOT_FOUND", "Buyer not found.");

          const newBal = round2(Number(buyer.currentBalance) - amount);
          await tx.buyer.update({
            where: { id: buyer.id },
            data: { currentBalance: newBal },
          });

          if (body.salesBillId) {
            const sb = await tx.salesBill.findFirst({
              where: { id: body.salesBillId, tenantId },
            });
            if (sb) {
              const newRec = round2(Number(sb.receivedAmount) + amount);
              const newOut = round2(Math.max(0, Number(sb.grandTotal) - newRec));
              await tx.salesBill.update({
                where: { id: sb.id },
                data: {
                  receivedAmount: newRec,
                  outstandingAmount: newOut,
                  status: newOut <= 0 ? "PAID" : "PARTIALLY_PAID",
                },
              });
            }
          }

          const payment = await tx.payment.create({
            data: {
              tenantId,
              receiptNumber,
              paymentDate: body.paymentDate ?? new Date(),
              direction: body.direction,
              buyerId: buyer.id,
              salesBillId: body.salesBillId ?? null,
              method: body.method,
              amount,
              transactionRef: body.transactionRef ?? null,
              notes: body.notes ?? null,
              createdBy: req.user!.sub,
            },
            include: { buyer: true, salesBill: true },
          });

          await tx.buyerLedgerEntry.create({
            data: {
              tenantId,
              buyerId: buyer.id,
              entryType: "PAYMENT_RECEIVED",
              referenceId: payment.id,
              referenceNo: receiptNumber,
              description: body.notes || `Payment received (${body.method})`,
              debitAmount: 0,
              creditAmount: amount,
              runningBalance: newBal,
              createdBy: req.user!.sub,
            },
          });

          return payment;
        } else {
          if (!body.sellerId) throw new AppError(400, "SELLER_REQUIRED", "sellerId is required.");
          const seller = await tx.seller.findFirst({
            where: { id: body.sellerId, tenantId, deletedAt: null },
          });
          if (!seller) throw new AppError(404, "SELLER_NOT_FOUND", "Seller not found.");

          const newBal = round2(Number(seller.currentBalance) - amount);
          await tx.seller.update({
            where: { id: seller.id },
            data: { currentBalance: newBal },
          });

          if (body.purchaseBillId) {
            const pb = await tx.purchaseBill.findFirst({
              where: { id: body.purchaseBillId, tenantId },
            });
            if (pb) {
              const newPaid = round2(Number(pb.paidAmount) + amount);
              const newOut = round2(Math.max(0, Number(pb.grandTotal) - newPaid));
              await tx.purchaseBill.update({
                where: { id: pb.id },
                data: {
                  paidAmount: newPaid,
                  outstandingAmount: newOut,
                  status: newOut <= 0 ? "PAID" : "PARTIALLY_PAID",
                },
              });
            }
          }

          const payment = await tx.payment.create({
            data: {
              tenantId,
              receiptNumber,
              paymentDate: body.paymentDate ?? new Date(),
              direction: body.direction,
              sellerId: seller.id,
              purchaseBillId: body.purchaseBillId ?? null,
              method: body.method,
              amount,
              transactionRef: body.transactionRef ?? null,
              notes: body.notes ?? null,
              createdBy: req.user!.sub,
            },
            include: { seller: true, purchaseBill: true },
          });

          await tx.sellerLedgerEntry.create({
            data: {
              tenantId,
              sellerId: seller.id,
              entryType: "PAYMENT_MADE",
              referenceId: payment.id,
              referenceNo: receiptNumber,
              description: body.notes || `Payment made (${body.method})`,
              debitAmount: amount,
              creditAmount: 0,
              runningBalance: newBal,
              createdBy: req.user!.sub,
            },
          });

          return payment;
        }
      });

      return sendSuccess(res, created, "Payment recorded and ledger updated.", 201);
    } catch (err) {
      next(err);
    }
  }
);

paymentsRouter.get(
  "/:id",
  requirePermission("payments:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const payment = await prisma.payment.findFirst({
        where: { id: req.params.id, tenantId },
        include: { buyer: true, seller: true, salesBill: true, purchaseBill: true },
      });
      if (!payment) throw new AppError(404, "PAYMENT_NOT_FOUND", "Payment not found.");
      return sendSuccess(res, payment);
    } catch (err) {
      next(err);
    }
  }
);

paymentsRouter.get(
  "/:id/receipt",
  requirePermission("payments:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const payment = await prisma.payment.findFirst({
        where: { id: req.params.id, tenantId },
        include: {
          buyer: true,
          seller: true,
          salesBill: true,
          purchaseBill: true,
          tenant: { include: { businessProfile: true } },
        },
      });
      if (!payment) throw new AppError(404, "PAYMENT_NOT_FOUND", "Payment not found.");
      return sendSuccess(res, payment);
    } catch (err) {
      next(err);
    }
  }
);

// ============================================================================
// ADVANCES (/api/v1/advances) — Spec Section F
// ============================================================================

advancesRouter.get(
  "/",
  requirePermission("advances:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const advances = await prisma.advance.findMany({
        where: { tenantId },
        orderBy: { advanceDate: "desc" },
        include: {
          buyer: { select: { id: true, name: true, code: true, phone: true } },
          seller: { select: { id: true, name: true, code: true, phone: true } },
          adjustments: true,
        },
      });
      return sendSuccess(res, advances);
    } catch (err) {
      next(err);
    }
  }
);

advancesRouter.post(
  "/",
  requirePermission("advances:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const schema = z.object({
        direction: z.enum(["INBOUND_FROM_BUYER", "OUTBOUND_TO_SELLER"]),
        buyerId: z.string().uuid().optional(),
        sellerId: z.string().uuid().optional(),
        method: z.enum(["CASH", "UPI", "BANK_TRANSFER", "CHEQUE", "WALLET"]).default("CASH"),
        amount: z.coerce.number().positive(),
        notes: z.string().optional(),
      });
      const body = schema.parse(req.body);
      const amount = round2(body.amount);
      const advanceNumber = `ADV-${Date.now().toString().slice(-6)}`;

      const created = await prisma.$transaction(async (tx) => {
        const adv = await tx.advance.create({
          data: {
            tenantId,
            advanceNumber,
            direction: body.direction,
            buyerId: body.buyerId ?? null,
            sellerId: body.sellerId ?? null,
            method: body.method,
            originalAmount: amount,
            adjustedAmount: 0,
            remainingAmount: amount,
            status: "OPEN",
            notes: body.notes ?? null,
            createdBy: req.user!.sub,
          },
          include: { buyer: true, seller: true },
        });

        if (body.direction === "INBOUND_FROM_BUYER" && body.buyerId) {
          const buyer = await tx.buyer.findFirst({ where: { id: body.buyerId, tenantId } });
          if (buyer) {
            const newBal = round2(Number(buyer.currentBalance) - amount);
            await tx.buyer.update({ where: { id: buyer.id }, data: { currentBalance: newBal } });
            await tx.buyerLedgerEntry.create({
              data: {
                tenantId,
                buyerId: buyer.id,
                entryType: "ADVANCE_RECEIVED",
                referenceId: adv.id,
                referenceNo: advanceNumber,
                description: `Advance received (${advanceNumber})`,
                debitAmount: 0,
                creditAmount: amount,
                runningBalance: newBal,
                createdBy: req.user!.sub,
              },
            });
          }
        } else if (body.direction === "OUTBOUND_TO_SELLER" && body.sellerId) {
          const seller = await tx.seller.findFirst({ where: { id: body.sellerId, tenantId } });
          if (seller) {
            const newBal = round2(Number(seller.currentBalance) - amount);
            await tx.seller.update({ where: { id: seller.id }, data: { currentBalance: newBal } });
            await tx.sellerLedgerEntry.create({
              data: {
                tenantId,
                sellerId: seller.id,
                entryType: "ADVANCE_ISSUED",
                referenceId: adv.id,
                referenceNo: advanceNumber,
                description: `Advance issued (${advanceNumber})`,
                debitAmount: amount,
                creditAmount: 0,
                runningBalance: newBal,
                createdBy: req.user!.sub,
              },
            });
          }
        }

        return adv;
      });

      return sendSuccess(res, created, "Advance recorded.", 201);
    } catch (err) {
      next(err);
    }
  }
);

advancesRouter.get(
  "/:id",
  requirePermission("advances:read"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const adv = await prisma.advance.findFirst({
        where: { id: req.params.id, tenantId },
        include: { buyer: true, seller: true, adjustments: true },
      });
      if (!adv) throw new AppError(404, "ADVANCE_NOT_FOUND", "Advance not found.");
      return sendSuccess(res, adv);
    } catch (err) {
      next(err);
    }
  }
);

advancesRouter.post(
  "/:id/adjust",
  requirePermission("advances:write"),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tenantId = req.tenantId!;
      const schema = z.object({
        salesBillId: z.string().uuid().optional(),
        purchaseBillId: z.string().uuid().optional(),
        amount: z.coerce.number().positive(),
      });
      const body = schema.parse(req.body);

      const updated = await prisma.$transaction(async (tx) => {
        const adv = await tx.advance.findFirst({
          where: { id: req.params.id, tenantId },
        });
        if (!adv) throw new AppError(404, "ADVANCE_NOT_FOUND", "Advance not found.");

        const adjAmount = round2(Math.min(body.amount, Number(adv.remainingAmount)));
        if (adjAmount <= 0) {
          throw new AppError(400, "NO_REMAINING_ADVANCE", "No remaining advance balance to adjust.");
        }

        const newAdjusted = round2(Number(adv.adjustedAmount) + adjAmount);
        const newRemaining = round2(Number(adv.originalAmount) - newAdjusted);

        await tx.advanceAdjustment.create({
          data: {
            advanceId: adv.id,
            salesBillId: body.salesBillId ?? null,
            purchaseBillId: body.purchaseBillId ?? null,
            adjustedAmount: adjAmount,
            createdBy: req.user!.sub,
          },
        });

        if (body.salesBillId) {
          const sb = await tx.salesBill.findFirst({ where: { id: body.salesBillId, tenantId } });
          if (sb) {
            const newRec = round2(Number(sb.receivedAmount) + adjAmount);
            const newOut = round2(Math.max(0, Number(sb.grandTotal) - newRec));
            await tx.salesBill.update({
              where: { id: sb.id },
              data: {
                receivedAmount: newRec,
                outstandingAmount: newOut,
                status: newOut <= 0 ? "PAID" : "PARTIALLY_PAID",
              },
            });
          }
        }

        if (body.purchaseBillId) {
          const pb = await tx.purchaseBill.findFirst({
            where: { id: body.purchaseBillId, tenantId },
          });
          if (pb) {
            const newPaid = round2(Number(pb.paidAmount) + adjAmount);
            const newOut = round2(Math.max(0, Number(pb.grandTotal) - newPaid));
            await tx.purchaseBill.update({
              where: { id: pb.id },
              data: {
                paidAmount: newPaid,
                outstandingAmount: newOut,
                status: newOut <= 0 ? "PAID" : "PARTIALLY_PAID",
              },
            });
          }
        }

        return tx.advance.update({
          where: { id: adv.id },
          data: {
            adjustedAmount: newAdjusted,
            remainingAmount: newRemaining,
            status: newRemaining <= 0 ? "FULLY_ADJUSTED" : "PARTIALLY_ADJUSTED",
          },
          include: { adjustments: true },
        });
      });

      return sendSuccess(res, updated, "Advance adjusted against bill.");
    } catch (err) {
      next(err);
    }
  }
);
