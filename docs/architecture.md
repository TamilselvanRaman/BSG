# Architecture Specification & Future Backend Upgrade Path

## 1. Domain Architecture
The application is structured following clean architecture principles with feature-first organization:

```
lib/
├── app/
│   ├── app.dart                    # Root application widget
│   ├── router.dart                 # GoRouter with ShellRoute navigation
│   └── theme/                      # BSG Green & White tokens and typography
├── core/
│   ├── formatters/                 # Indian Currency (₹) and Date formatters
│   └── widgets/                    # Reusable KPI cards, buttons, badges, fields
├── data/
│   ├── models/                     # Strongly-typed domain models
│   ├── demo_data.dart              # Seed data generator (8 buyers, 12 entries, 10 bills)
│   ├── mock_repository.dart        # Local in-memory repository & accounting calculation engine
│   └── app_state.dart              # Riverpod State Notifiers and reactive providers
└── features/
    ├── splash/
    ├── dashboard/
    ├── customers/
    ├── goods_entries/
    ├── billing/
    ├── payments/
    ├── reports/
    ├── sharing/
    └── settings/
```

## 2. In-Memory State & Calculation Engine
The `MockRepository` enforces strict business rules:
- **Zero Double-Counting**: An advance payment received with a goods entry is tagged as an initial advance and deducted once when the entry is billed.
- **Credit Balance Handling**: If payments exceed total payable, the difference is preserved as unapplied customer credit.
- **Authoritative Ledger Reconciliation**:
  $$\text{Net Balance} = \text{Opening Balance} + \sum \text{Active Bills} - \sum \text{Payments}$$
  Every ledger line calculates the running balance so the ledger matches the customer dues exactly.
- **Audit-Safe Bill Cancellation**: Bills are never deleted; an auditable cancellation record and reversal credit ledger entry are appended.

## 3. Seamless Production Upgrade Path (Backend-Connected Mode)
All UI screens interact with `ref.watch(customersProvider)`, `ref.watch(billsProvider)`, and dispatch actions through `appStateProvider.notifier`.

To connect to a Node.js / Express / Prisma / PostgreSQL backend in production:
1. Define abstract repository interfaces (`ICustomerRepository`, `IBillRepository`, `IPaymentRepository`).
2. Implement `ApiCustomerRepository`, `ApiBillRepository`, `ApiPaymentRepository` using `Dio`.
3. In `app_state.dart`, conditionally inject `ApiRepository` when `isDemoMode == false`.
4. No UI widgets or screens need to be rewritten.
