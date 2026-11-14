import crypto from "crypto";
import jwt from "jsonwebtoken";
import { env } from "../config/env";

export interface JwtAccessPayload {
  sub: string;
  username: string;
  role: "SUPER_ADMIN" | "ADMIN" | "BUSINESS_USER";
  tenantId: string | null;
  permissions: string[];
}

export function signAccessToken(payload: JwtAccessPayload): string {
  return jwt.sign(payload, env.JWT_ACCESS_SECRET, {
    expiresIn: env.JWT_ACCESS_EXPIRES_IN as jwt.SignOptions["expiresIn"],
  });
}

export function signRefreshToken(userId: string): { rawToken: string; tokenHash: string } {
  const jti = crypto.randomUUID();
  const rawToken = jwt.sign({ sub: userId, jti }, env.JWT_REFRESH_SECRET, {
    expiresIn: env.JWT_REFRESH_EXPIRES_IN as jwt.SignOptions["expiresIn"],
  });
  const tokenHash = hashToken(rawToken);
  return { rawToken, tokenHash };
}

export function verifyAccessToken(token: string): JwtAccessPayload {
  return jwt.verify(token, env.JWT_ACCESS_SECRET) as JwtAccessPayload;
}

export function verifyRefreshToken(token: string): { sub: string; jti: string } {
  return jwt.verify(token, env.JWT_REFRESH_SECRET) as { sub: string; jti: string };
}

export function hashToken(token: string): string {
  return crypto.createHash("sha256").update(token).digest("hex");
}

export function verifyRazorpaySignature(
  orderId: string,
  paymentId: string,
  signature: string
): boolean {
  const expected = crypto
    .createHmac("sha256", env.RAZORPAY_KEY_SECRET)
    .update(`${orderId}|${paymentId}`)
    .digest("hex");
  return expected === signature;
}
