import { Response } from "express";

export class AppError extends Error {
  public readonly statusCode: number;
  public readonly code: string;
  public readonly details?: unknown;

  constructor(statusCode: number, code: string, message: string, details?: unknown) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

export function sendSuccess<T>(
  res: Response,
  data: T,
  message = "Success",
  statusCode = 200,
  meta?: Record<string, unknown>
) {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    ...(meta ? { meta } : {}),
  });
}

export function parsePagination(query: Record<string, unknown>) {
  const page = Math.max(1, Number(query.page) || 1);
  const limit = Math.min(100, Math.max(1, Number(query.limit) || 20));
  const skip = (page - 1) * limit;
  const search = typeof query.search === "string" ? query.search.trim() : "";
  return { page, limit, skip, search };
}
