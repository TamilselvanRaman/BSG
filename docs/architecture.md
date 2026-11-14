# System Architecture — CLICK Smart Chart SaaS

## 1. Multi-Tenant Isolation Model
Every business organization is provisioned as a `Tenant` record with a unique UUID (`tenantId`).
- All business tables (`buyers`, `sellers`, `goods`, `goods_lots`, `goods_entries`, `smart_charts`, `auctions`, `purchase_bills`, `sales_bills`, `payments`, `buyer_ledger_entries`, `seller_ledger_entries`, `advances`, `inventory_transactions`, `business_documents`) include a mandatory `tenantId` foreign key and composite indexes.
- `requireTenantScope` middleware extracts `tenantId` exclusively from the signed JWT access token and blocks any cross-tenant parameter tampering with `403 CROSS_TENANT_VIOLATION`.

## 2. Role-Based Access Control (RBAC)
- **SUPER_ADMIN**: Platform-wide governance, tenant lifecycle, subscription plans, SaaS revenue, Razorpay signature verification, maintenance mode, and global audit logs.
- **ADMIN**: Full control over their assigned business tenant workspace, employee management, granular permission toggles, billing, ledgers, and reports.
- **BUSINESS_USER**: Employee account scoped to their assigned business tenant with fine-grained permissions (`UserPermission` overrides on top of `RolePermission`).

## 3. Financial & Stock Integrity
All billing, payment, cancellation, and advance adjustment operations run inside `prisma.$transaction(...)` blocks to ensure atomic updates across bills, stock balances, lot quantities, and partner running-balance ledgers.
