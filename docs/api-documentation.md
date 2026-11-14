# REST API Documentation (`/api/v1`)

Interactive OpenAPI / Swagger documentation is served at `http://localhost:4000/api/docs`.

## Core Endpoint Groups
- **Auth (`/api/v1/auth`)**: `POST /login`, `POST /register-business`, `POST /refresh`, `POST /logout`, `POST /logout-all`, `POST /forgot-password`, `POST /reset-password`, `POST /change-password`, `GET /me`
- **Super Admin (`/api/v1/super-admin`)**: `GET /dashboard`, `GET/POST/PATCH/DELETE /businesses`, `POST /businesses/:id/activate`, `POST /businesses/:id/suspend`, `GET/POST/PATCH /admins`, `GET/POST/PATCH/DELETE /plans`, `GET/PATCH /subscriptions`, `GET /payments`, `POST /payments/verify-razorpay`, `GET /reports`, `GET /audit-logs`, `GET/PATCH /settings`
- **Business Workspace (`/api/v1/business`)**: `GET /dashboard`, `GET /search`, `GET/PATCH /profile`, `GET/POST/PATCH /users`, `POST /users/:id/reset-password`, `PATCH /users/:id/permissions`
- **Partners (`/api/v1/buyers`, `/api/v1/sellers`)**: CRUD, `POST /buyers/bulk-import`, `GET /buyers/:id/ledger`, `GET /sellers/:id/ledger`
- **Goods, Lots & Inventory (`/api/v1/goods`, `/api/v1/goods-lots`, `/api/v1/goods-entries`, `/api/v1/inventory`)**: Catalog CRUD, Arrival Goods Entries, Lot tracking, Stock Summary table, `POST /inventory/adjustments`, `GET /inventory/low-stock`
- **Smart Chart & Auctions (`/api/v1/smart-charts`, `/api/v1/auctions`)**: Create, add items, and generate breakdown reports
- **Billing & Settlements (`/api/v1/purchases`, `/api/v1/sales`, `/api/v1/payments`, `/api/v1/advances`)**: 3-step Purchase & Sales Bill Books, traceable `POST /:id/cancel`, payment receipts, and advance adjustments
- **Reports & PDFs (`/api/v1/reports/*`, `/api/v1/documents/*`)**: `daily-summary`, `sales`, `purchases`, `inventory`, `outstanding`, `profit-loss`, `smart-charts`, and `POST /documents/pdf`
