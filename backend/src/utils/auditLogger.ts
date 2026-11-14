import { prisma } from "../config/prisma";
import { logger } from "../config/logger";

export interface AuditLogInput {
  tenantId?: string | null;
  userId?: string | null;
  action: string;
  entityType: string;
  entityId?: string | null;
  ipAddress?: string;
  userAgent?: string;
  metadata?: Record<string, unknown>;
}

export async function recordAuditLog(input: AuditLogInput): Promise<void> {
  try {
    await prisma.auditLog.create({
      data: {
        tenantId: input.tenantId ?? null,
        userId: input.userId ?? null,
        action: input.action,
        entityType: input.entityType,
        entityId: input.entityId ?? null,
        ipAddress: input.ipAddress ?? null,
        userAgent: input.userAgent ?? null,
        metadata: (input.metadata ?? {}) as object,
      },
    });
  } catch (err) {
    logger.warn({ err, input }, "Non-fatal failure recording audit log");
  }
}
