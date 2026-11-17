import { Router, Request, Response, NextFunction } from "express";
import { z } from "zod";
import { prisma } from "../../config/prisma";
import { sendSuccess, AppError } from "../../utils/response";

export const publicRouter = Router();

const contactInquirySchema = z.object({
  fullName: z.string().min(2, "Full name is required"),
  businessName: z.string().min(2, "Business name is required"),
  phone: z.string().min(8, "Valid contact phone is required"),
  email: z.string().email("Valid email address is required"),
  businessDomain: z.string().default("Vegetable & Fruit Mandi"),
  marketYardCity: z.string().min(2, "Market yard city or state is required"),
  notes: z.string().optional(),
});

// POST /api/v1/public/contact-inquiries
publicRouter.post("/contact-inquiries", async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parseResult = contactInquirySchema.safeParse(req.body);
    if (!parseResult.success) {
      throw new AppError(400, "VALIDATION_ERROR", parseResult.error.errors[0].message);
    }

    const { fullName, businessName, phone, email, businessDomain, marketYardCity, notes } = parseResult.data;

    const inquiry = await prisma.contactInquiry.create({
      data: {
        fullName,
        businessName,
        phone,
        email,
        businessDomain,
        marketYardCity,
        notes: notes || null,
        status: "NEW",
      },
    });

    return sendSuccess(
      res,
      { inquiry },
      "Mandi consultation inquiry submitted successfully. Our engineering desk will connect shortly.",
      201
    );
  } catch (err) {
    next(err);
  }
});

// GET /api/v1/public/telemetry
publicRouter.get("/telemetry", async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const [totalTenants, totalSalesBills, totalGoodsLots] = await Promise.all([
      prisma.tenant.count({ where: { status: "ACTIVE" } }),
      prisma.salesBill.count({ where: { status: { not: "CANCELLED" } } }),
      prisma.goodsLot.count(),
    ]);

    return sendSuccess(res, {
      telemetry: {
        bagsWeighedDaily: "50K+",
        mandiTurnoverProcessed: "₹150Cr+",
        acidLedgerBalance: "100%",
        offlineFloorDowntime: "0 sec",
        activeMandiShops: totalTenants,
        totalBillsProcessed: totalSalesBills,
        totalArrivalLots: totalGoodsLots,
        serverRegion: "ap-south-1 (Mumbai)",
        status: "OPERATIONAL",
      },
    });
  } catch (err) {
    next(err);
  }
});
