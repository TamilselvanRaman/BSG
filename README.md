# CLICK Smart Chart — Multi-Tenant Goods Management SaaS Platform

Production-ready multi-tenant Goods, Smart Chart, Arrival Lot, Auction, Purchase & Sales Billing, Partner Ledger, Inventory, and Reporting SaaS Platform.

## Project Structure

- `backend/click-smart-chart-api`: Node.js + Express.js + TypeScript + Prisma ORM + MySQL 8+ REST API (`/api/v1` + Swagger `/api/docs`)
- `web/click-smart-chart-web`: Next.js App Router + TypeScript + Tailwind CSS (Public SaaS Website, Super Admin Portal, Business Admin & Employee Workspace)
- `mobile/click-smart-chart-mobile`: Flutter + Riverpod + Offline Sync Queue + PDF Printing App
- `docs/`: Complete architecture, database schema, API specification, deployment guide, and user manual

## Quick Start

1. **Database & Backend API**:
   ```bash
   cd backend/click-smart-chart-api
   cp .env.example .env
   npm install
   npx prisma generate
   npx prisma migrate deploy
   npm run prisma:seed
   npm run dev
   ```
2. **Next.js Web Application**:
   ```bash
   cd web/click-smart-chart-web
   cp .env.example .env.local
   npm install
   npm run dev
   ```
3. **Flutter Mobile Application**:
   ```bash
   cd mobile/click-smart-chart-mobile
   flutter pub get
   flutter run
   ```

## Seeded Demo Credentials

| Role | Username | Password | Redirect Target |
| :--- | :--- | :--- | :--- |
| **Super Admin** | `superadmin` | `Admin@123` | `/super-admin/dashboard` |
| **Business Admin** | `vinayaka_admin` | `Admin@123` | `/admin/dashboard` |
| **Business Employee** | `vinayaka_staff` | `Admin@123` | `/workspace/dashboard` |
| **Tenant 2 Admin** | `deccan_admin` | `Admin@123` | `/admin/dashboard` |
