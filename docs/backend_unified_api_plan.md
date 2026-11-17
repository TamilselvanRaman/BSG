# Unified Backend Architecture & Implementation Plan: Mobile App + Web Admin

## Goal Description
Consolidate and establish `backend/` (`s:\Project\BuyerSellerManagementAPPSaas\backend`) as the **single, unified backend engine** powering both:
1. **The Handheld Android Mobile App** (`mobile/lib/` - Flutter 3.x), and
2. **The Store Admin & Super Admin Web Application** (`web/src/` - Next.js 15),

while keeping `web/` **strictly frontend-only** (zero backend/database code in `web/`, purely React UI components consuming `backend/` REST APIs via `apiFetch`).

---

## Architectural Mapping: Mobile Screens & Web Pages to Backend Endpoints

Every screen in the mobile app and every page in the web app maps directly to dedicated, tenant-isolated endpoints in `backend/`:

```
               ┌────────────────────────────────────────────────────────┐
               │              Unified Multi-Tenant Engine               │
               │         `backend/` (Node.js + Express + Prisma)        │
               │                 Base URL: `/api/v1`                    │
               └───────────────────────────┬────────────────────────────┘
                                           │
             ┌─────────────────────────────┴─────────────────────────────┐
             ▼                                                           ▼
┌─────────────────────────┐                                 ┌─────────────────────────┐
│     Mobile App (Flutter) │                                 │     Web App (Next.js)   │
│  `mobile/lib/`          │                                 │  `web/src/`             │
│  (Strict Handheld UI)   │                                 │  (Strict Presentation)  │
├─────────────────────────┤                                 ├─────────────────────────┤
│ • Handheld Login        │ ── POST /auth/login ─────────── │ • Store / Admin Login   │
│ • Home Dashboard        │ ── GET /business/profile ────── │ • Dashboard & mOS       │
│ • Arrival Lots          │ ── /goods-lots, /goods-entries ─│ • Goods & Lots Inward   │
│ • Multi-Product Bills   │ ── /sales (Bag Weighment) ───── │ • Cash & Credit Bills   │
│ • Daily Cash Tally      │ ── /daily-tally [NEW] ───────── │ • Daily Cash Summary    │
│ • Buyer/Supplier Ledger │ ── /buyers, /sellers, /payments ─│ • Partner Ledgers       │
│ • Reports (Buyer/Crop)  │ ── /reports/* ───────────────── │ • Financial & Tax P&L   │
│ • Global Search         │ ── /search/global [NEW] ─────── │ • Global Topbar Search  │
│ • Mobile Sync (Offline) │ ── /mobile-sync [NEW] ───────── │ • Super Admin Portal    │
└─────────────────────────┘                                 └─────────────────────────┘
```

### 1. Mobile App Screen Analysis & Backend API Map
| Mobile Screen / Path | User Action / Capability | Backend Endpoint | Status in Backend |
|---|---|---|---|
| `login_screen.dart` | Shop ID + Phone/Username + Password login | `POST /api/v1/auth/login` | Implemented (enforces max 3 users) |
| `home_screen.dart` | Today's sales, arrivals, pending dues, cash | `GET /api/v1/business/profile`, `GET /api/v1/reports/daily-summary` | Implemented |
| `lots_list_screen.dart` | View all arrival lots, remaining bags/kg | `GET /api/v1/goods-lots` | Implemented |
| `create_lot_screen.dart` | Multi-crop inward arrival, gross/tare weights | `POST /api/v1/goods-lots`, `POST /api/v1/goods-entries` | Enhanced (multi-crop support) |
| `lot_details_screen.dart` | Lot ledger, bags sold, remaining stock | `GET /api/v1/goods-lots/:id` | Implemented |
| `stock_summary_screen.dart` | Live mandi stock balance across goods | `GET /api/v1/inventory/stock-summary` | Implemented |
| `bills_list_screen.dart` | All / Cash / Credit bills list with filters | `GET /api/v1/sales` | Implemented |
| `create_cash_bill_screen.dart` | Multi-product items, bag-by-bag weighment scale, instant cash settlement | `POST /api/v1/sales` (with `billType: "CASH"`, `bagWeights`) | Enhanced (bag weighment table) |
| `create_credit_bill_screen.dart` | Credit invoice to registered buyer, due date | `POST /api/v1/sales` (with `billType: "CREDIT"`) | Enhanced (buyer balance update) |
| `bill_details_screen.dart` | View invoice, print/share receipt, cancel bill | `GET /api/v1/sales/:id`, `POST /api/v1/sales/:id/cancel` | Implemented (auto rollback stock & ledger) |
| `received_amount_screen.dart` | Record buyer cash/UPI payment against bill | `POST /api/v1/payments` | Implemented |
| `daily_tally_dashboard_screen.dart` | Daily cash balance, receipts, expenses | `GET /api/v1/daily-tally/today` | **Needs New Endpoint** |
| `create_daily_tally_screen.dart` | Cash breakdown, denominations, physical vs system closing | `POST /api/v1/daily-tally` | **Needs New Endpoint** |
| `daily_tally_history_screen.dart` | Historical cash reconciliation records | `GET /api/v1/daily-tally` | **Needs New Endpoint** |
| `users_landing_screen.dart` | Buyer & Supplier directory | `GET /api/v1/buyers`, `GET /api/v1/sellers` | Implemented |
| `customer_ledger_screen.dart` | Running buyer account debit/credit statement | `GET /api/v1/buyers/:id/ledger` | Implemented |
| `supplier_ledger_screen.dart` | Running supplier account debit/credit statement | `GET /api/v1/sellers/:id/ledger` | Implemented |
| `reports_landing_screen.dart` | Drilldown reports (By Buyer, Crop, Date) | `GET /api/v1/reports/sales`, `GET /api/v1/reports/purchases` | Enhanced (drill-down filters) |
| `global_search_screen.dart` | Cross-entity search (buyers, lots, bills) | `GET /api/v1/search/global` | **Needs New Endpoint** |

### 2. Web Application Page Analysis & Backend API Map
| Web Page / Feature | User Action / Capability | Backend Endpoint | Status in Backend |
|---|---|---|---|
| `/login` | Store Admin & Staff Authentication | `POST /api/v1/auth/login` | Implemented |
| `/super-admin/dashboard` | Multi-Tenant Governance, Licensing, Quotas, Plans, Audit | `/api/v1/super-admin/*` (12 endpoints) | Implemented |
| `/admin/dashboard` (Tab A) | mOS Executive Telemetry & Quick Actions | `GET /api/v1/reports/daily-summary`, `GET /api/v1/business/profile` | Implemented |
| Smart Chart (Tab B) | Real-time lot bidding & buyer allotments | `/api/v1/smart-charts/*`, `/api/v1/auctions/*` | Implemented |
| Goods & Lots (Tab C) | Lot inward entries, multiple crop storage | `/api/v1/goods-lots/*`, `/api/v1/goods-entries/*` | Implemented |
| Bill Books (Tab D) | Purchase & Sales bills register, cancel bills | `/api/v1/sales/*`, `/api/v1/purchases/*` | Implemented |
| Buyers & Sellers (Tab E) | Master partner directory, credit limits | `/api/v1/buyers/*`, `/api/v1/sellers/*` | Implemented |
| Ledgers & Advances (Tab F) | Double-entry statements & advance deductions | `/api/v1/advances/*`, `/api/v1/payments/*` | Implemented |
| Inventory & Stock (Tab G) | Real-time stock counts, audit adjustments | `/api/v1/inventory/*` | Implemented |
| Reports (Tab H) | P&L, GST reports, daily summaries, export | `/api/v1/reports/*` | Implemented |
| Employees & RBAC (Tab I) | Max 3 user seats, concurrent sessions | `GET/POST /api/v1/business/users` | Implemented |
| Business Settings (Tab J) | Store profile, bill prefixes, invoice format | `GET/PATCH /api/v1/business/profile` | Implemented |

---

## User Review Required

> [!IMPORTANT]
> **Strict Separation of Concerns**: `web/` will strictly serve as client-side UI. No backend logic, direct database drivers, or private secrets will be placed in `web/`. All state transitions, validations, financial calculations, and data persistence will happen exclusively in `backend/`.

> [!NOTE]
> **Database Migrations / Schema Additions**:
> 1. `DailyTally` model will be added to `backend/prisma/schema.prisma` to support the mobile Daily Cash Tally and denomination breakdown.
> 2. `bagWeights` JSON field will be added to `SalesBillItem` and `PurchaseBillItem` to store the exact bag-by-bag weights (e.g., 52kg, 53kg, 53kg) entered on mobile and web bills.
> 3. `items` JSON field or relation on `GoodsLot` to store multi-crop details when a farmer brings multiple commodities in a single vehicle entry.

---

## Proposed Changes

### Component 1: Database Schema Enhancements (`backend/prisma/schema.prisma`)

#### [MODIFY] `backend/prisma/schema.prisma`
- Add `DailyTally` model with full denomination counter, cash receipts, payouts, and discrepancy calculation:
  ```prisma
  model DailyTally {
    id                   String    @id @default(uuid())
    tenantId             String
    tallyNumber          String
    tallyDate            DateTime  @default(now())
    openingCash          Decimal   @db.Decimal(14, 2)
    cashSales            Decimal   @default(0.00) @db.Decimal(14, 2)
    outstandingReceived  Decimal   @default(0.00) @db.Decimal(14, 2)
    otherCashReceived    Decimal   @default(0.00) @db.Decimal(14, 2)
    gpay1Received        Decimal   @default(0.00) @db.Decimal(14, 2)
    gpay2Received        Decimal   @default(0.00) @db.Decimal(14, 2)
    labourExpense        Decimal   @default(0.00) @db.Decimal(12, 2)
    transportExpense     Decimal   @default(0.00) @db.Decimal(12, 2)
    rentExpense          Decimal   @default(0.00) @db.Decimal(12, 2)
    utilitiesExpense     Decimal   @default(0.00) @db.Decimal(12, 2)
    teaExpense           Decimal   @default(0.00) @db.Decimal(12, 2)
    otherExpense         Decimal   @default(0.00) @db.Decimal(12, 2)
    partyPayments        Json?     // [{ partyName, amount, mode, reference }]
    bankDeposit          Decimal   @default(0.00) @db.Decimal(14, 2)
    actualCashCounted    Decimal   @db.Decimal(14, 2)
    pettyCashInHand      Decimal   @default(0.00) @db.Decimal(14, 2)
    denominations        Json?     // { "2000": 0, "500": 10, "200": 5, "100": 20, "50": 10, "coins": 50 }
    expectedCashClosing  Decimal   @db.Decimal(14, 2)
    cashDifference       Decimal   @default(0.00) @db.Decimal(14, 2)
    notes                String?   @db.Text
    createdAt            DateTime  @default(now())
    updatedAt            DateTime  @updatedAt
    createdBy            String?

    tenant               Tenant    @relation(fields: [tenantId], references: [id], onDelete: Cascade)

    @@unique([tenantId, tallyNumber])
    @@index([tenantId, tallyDate])
    @@map("daily_tallies")
  }
  ```
- Add `bagWeights Json?` to `SalesBillItem` and `PurchaseBillItem`:
  ```prisma
  model SalesBillItem {
    ...
    bagWeights Json? // [{ sNo: 1, weight: 52, rate: 2500, amount: 2500 }, ...]
  }
  ```
- Add `multiCropItems Json?` to `GoodsLot`:
  ```prisma
  model GoodsLot {
    ...
    multiCropItems Json? // [{ productName: "Tomato Grade A", bags: 10, weight: 500, costRate: 28 }, ...]
  }
  ```

---

### Component 2: New Backend Modules & Routes (`backend/src/modules/`)

#### [NEW] `backend/src/modules/daily-tally/dailyTally.routes.ts`
- `GET /api/v1/daily-tally/today`: Returns today's live calculated cash position (yesterday's closing cash + today's cash sales + collections - cash expenses - bank deposits) so mobile/web can auto-populate the tally screen.
- `POST /api/v1/daily-tally`: Saves a finalized daily cash reconciliation with physical cash denomination breakdown.
- `GET /api/v1/daily-tally`: Returns historical tallies with date range filters.
- `GET /api/v1/daily-tally/:id`: Retrieves full detail of a specific tally with denomination count.

#### [NEW] `backend/src/modules/search/search.routes.ts`
- `GET /api/v1/search/global?q=...`: High performance unified query searching:
  - `Buyer`: name, phone, code
  - `Seller`: name, phone, code, village
  - `SalesBill`: billNumber, customer name
  - `GoodsLot`: lotNumber, vehicleNumber, commodity
  - `Goods`: name, category
  Returns categorized search results matching both mobile `global_search_screen.dart` and web topbar search.

#### [NEW] `backend/src/modules/mobile-sync/mobileSync.routes.ts`
- `GET /api/v1/mobile-sync/bootstrap`: Single, lightweight payload for mobile app initialization:
  - Current tenant profile & enabled features
  - Active goods & commodity catalog
  - Active buyers & suppliers list
  - Open lots available for billing
  - Pending dues summary
  - Last tally status
- `POST /api/v1/mobile-sync/batch`: Supports offline-queued mobile submissions (bills created in poor mandi network connectivity).

#### [MODIFY] `backend/src/modules/billing/billing.routes.ts`
- Support `bagWeights` in `POST /api/v1/sales`:
  - Validate total bags count and total weight match the sum of individual bags.
  - Automatically calculate line items and gross totals.
- Support `billType: "CASH" | "CREDIT"`:
  - For `CASH`: create payment record automatically, update daily cash drawer.
  - For `CREDIT`: credit buyer running ledger, increment `outstandingAmount`.
- Refactor `POST /api/v1/sales/:id/cancel`:
  - Atomic Prisma transaction: reverts stock back into `GoodsLot`, debits buyer ledger if credit, or logs refund if cash.

#### [MODIFY] `backend/src/modules/reports/reports.routes.ts`
- Enhance `GET /api/v1/reports/sales`:
  - Add query params: `buyerId`, `goodsId`, `startDate`, `endDate`, `billType`.
  - Enables mobile app drill-downs: "By Buyer", "By Crop", "By Product", "By Date".

#### [MODIFY] `backend/src/routes/index.ts`
- Mount `/api/v1/daily-tally`, `/api/v1/search`, `/api/v1/mobile-sync`.

---

### Component 3: Mobile App Backend Integration (`mobile/lib/`)

#### [NEW/MODIFY] `mobile/lib/data/services/api_service.dart`
- Create a dedicated HTTP API client connecting the Flutter mobile app to `http://<SERVER_IP>:4000/api/v1`:
  - Handles JWT authentication token storage and auto-injection in headers.
  - Intercepts 401 and handles token refresh.
  - Passes device info & IP for session quota tracking (max 3 users).
- Connect `AppRepository` to call `ApiService` instead of using static in-memory seed data.

---

### Component 4: Web Application Integrity (`web/src/`)

- Audit `web/src/` to confirm:
  - **Zero server code**: No direct DB connections (`prisma`), no server-only secrets.
  - All communication uses `apiFetch` pointing to `API_BASE_URL`.
  - Next.js acts purely as client-side SPA / static pages consuming the backend.

---

## Verification Plan

### Automated Tests
1. **Prisma Validation**:
   ```powershell
   cd backend
   npx prisma validate
   npx prisma generate
   ```
2. **Backend TypeScript Typecheck**:
   ```powershell
   cd backend
   npx tsc --noEmit
   ```
3. **Web Frontend Typecheck & Build**:
   ```powershell
   cd web
   npm run typecheck
   npm run build
   ```

### Manual & API Verification
1. **Auth & Multi-Tenant Quota**:
   - Log in as Store Admin. Verify response returns `tenant`, `licenseKey`, `maxUsers: 3`, and `enabledFeatures`.
   - Verify 4th concurrent login attempt receives `403 QUOTA_EXCEEDED_USERS`.
2. **Multi-Product Billing with Bag Weighment**:
   - Send `POST /api/v1/sales` with multiple items and bag weights `[52, 53, 53]`.
   - Verify calculated total weight is `158 kg` and line totals are accurate.
3. **Daily Cash Tally**:
   - Test `GET /api/v1/daily-tally/today` returns correct expected closing balance.
   - Test `POST /api/v1/daily-tally` records denomination counts and calculates cash surplus/shortage.
4. **Unified Search**:
   - Test `GET /api/v1/search/global?q=kannan` returns matches across buyers, sellers, and bills.
5. **Mobile Bootstrap**:
   - Test `GET /api/v1/mobile-sync/bootstrap` returns active lots, buyers, sellers, and catalog in one call.
