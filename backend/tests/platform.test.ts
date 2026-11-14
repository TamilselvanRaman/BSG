import { describe, it } from "node:test";
import assert from "node:assert/strict";
import express from "express";
import request from "supertest";
import crypto from "crypto";
import { calculateBillTotals } from "../src/utils/financialMath";
import {
  signAccessToken,
  verifyAccessToken,
  verifyRazorpaySignature,
} from "../src/utils/crypto";
import {
  authenticate,
  requireRoles,
  requirePermission,
  requireTenantScope,
} from "../src/middleware/auth";
import { errorHandler } from "../src/middleware/errorHandler";
import { env } from "../src/config/env";

describe("CLICK Smart Chart SaaS — Financial Math, RBAC & Multi-Tenant Isolation Suite", () => {
  it("computes Purchase/Sales Bill net weight, tare deduction, labour, RMC cess, on-spot payment, and closing balance accurately", () => {
    const result = calculateBillTotals({
      items: [
        { bagsCount: 10, grossWeight: 510, tareWeight: 10, unitPrice: 30, costPrice: 24 },
        { bagsCount: 5, grossWeight: 255, tareWeight: 5, unitPrice: 40, costPrice: 32 },
      ],
      labourCharge: 75,
      isRmcApplicable: true,
      rmcCessPercent: 1.0,
      otherCharges: 25,
      discountAmount: 50,
      taxAmount: 0,
      paidOrReceivedAmount: 10000,
      previousBalance: 4500,
    });

    assert.equal(result.totalBags, 15);
    assert.equal(result.totalNetQuantity, 750);
    assert.equal(result.subtotal, 25000);
    assert.equal(result.rmcCessAmount, 250);
    assert.equal(result.grandTotal, 25300);
    assert.equal(result.outstandingAmount, 15300);
    assert.equal(result.closingBalance, 19800);
    assert.equal(result.status, "PARTIALLY_PAID");
  });

  it("marks bill status as PAID when on-spot received amount equals grandTotal", () => {
    const result = calculateBillTotals({
      items: [{ bagsCount: 2, grossWeight: 100, tareWeight: 0, unitPrice: 20 }],
      paidOrReceivedAmount: 2000,
      previousBalance: 0,
    });
    assert.equal(result.grandTotal, 2000);
    assert.equal(result.outstandingAmount, 0);
    assert.equal(result.status, "PAID");
  });

  it("signs and verifies JWT access payload with role, tenantId, and granular permissions", () => {
    const token = signAccessToken({
      sub: "user-101",
      username: "vinayaka_staff",
      role: "BUSINESS_USER",
      tenantId: "tenant-A",
      permissions: ["sales:read", "sales:write"],
    });

    const decoded = verifyAccessToken(token);
    assert.equal(decoded.sub, "user-101");
    assert.equal(decoded.tenantId, "tenant-A");
    assert.ok(decoded.permissions.includes("sales:write"));
  });

  it("verifies authentic Razorpay HMAC-SHA256 payment signatures and rejects tampered signatures", () => {
    const orderId = "order_click_991";
    const paymentId = "pay_click_882";
    const validSig = crypto
      .createHmac("sha256", env.RAZORPAY_KEY_SECRET)
      .update(`${orderId}|${paymentId}`)
      .digest("hex");

    assert.equal(verifyRazorpaySignature(orderId, paymentId, validSig), true);
    assert.equal(verifyRazorpaySignature(orderId, paymentId, "tampered_signature"), false);
  });

  it("enforces RBAC role & permission guards and blocks cross-tenant spoofing attempts", async () => {
    const testApp = express();
    testApp.use(express.json());

    testApp.get(
      "/super-only",
      authenticate,
      requireRoles("SUPER_ADMIN"),
      (_req, res) => res.json({ ok: true })
    );

    testApp.post(
      "/cancel-bill",
      authenticate,
      requirePermission("sales:cancel"),
      (_req, res) => res.json({ cancelled: true })
    );

    testApp.post(
      "/tenant-protected",
      authenticate,
      requireTenantScope,
      (_req, res) => res.json({ ok: true })
    );

    testApp.use(errorHandler);

    const tenantAToken = signAccessToken({
      sub: "staff-a",
      username: "staff_a",
      role: "BUSINESS_USER",
      tenantId: "tenant-A-uuid",
      permissions: ["sales:read"],
    });

    // 1. Business User cannot access Super Admin route
    const resSuper = await request(testApp)
      .get("/super-only")
      .set("Authorization", `Bearer ${tenantAToken}`);
    assert.equal(resSuper.status, 403);
    assert.equal(resSuper.body.error.code, "FORBIDDEN_ROLE");

    // 2. Business User without 'sales:cancel' cannot cancel bills
    const resCancel = await request(testApp)
      .post("/cancel-bill")
      .set("Authorization", `Bearer ${tenantAToken}`);
    assert.equal(resCancel.status, 403);
    assert.equal(resCancel.body.error.code, "FORBIDDEN_PERMISSION");

    // 3. Tenant A user attempting to spoof tenantId = "tenant-B-uuid" is immediately blocked with 403 CROSS_TENANT_VIOLATION
    const resSpoof = await request(testApp)
      .post("/tenant-protected")
      .set("Authorization", `Bearer ${tenantAToken}`)
      .send({ tenantId: "tenant-B-uuid", name: "Malicious Injection" });
    assert.equal(resSpoof.status, 403);
    assert.equal(resSpoof.body.error.code, "CROSS_TENANT_VIOLATION");
  });
});
