# BSG — Buyer & Seller Goods Management Application (MVP)

A comprehensive, enterprise-grade mobile application prototype designed for agricultural mandis, commission mundies, and produce trading houses. Built under the **BSG** brand with a premium green-and-white Material 3 design system.

---

## 🌟 Key Highlights & Business Capabilities

1. **Strict Financial Accounting & Live Calculations**:
   - $\text{Line Amount} = \text{Weight (kg) or Quantity} \times \text{Selling Rate (₹)}$
   - $\text{Current Bill Total} = \text{Subtotal} + \text{Labour / Hamali Charge}$
   - $\text{Gross Amount Payable} = \text{Previous Outstanding Balance} + \text{Current Bill Total}$
   - $\text{Payments Applied} = \text{Eligible Initial Payment} + \text{Other Payments}$
   - $\text{Remaining Due} = \max(0, \text{Gross Payable} - \text{Payments Applied})$
   - $\text{Excess Customer Credit} = \max(0, \text{Payments Applied} - \text{Gross Payable})$
2. **Dedicated Initial Payment Engine**:
   - Initial advance payment received from the buyer at vehicle unloading / arrival.
   - Zero initial payment supported.
   - Deducted exactly once from the generated bill.
   - Retained as advance credit if unbilled, and preserved in audit trail even upon bill cancellation.
3. **Reconciled Buyer Account Ledger**:
   - Authoritative double-entry ledger with chronological Debit, Credit, and Running Balance.
   - Zero discrepancy between ledger running balance and buyer outstanding dues.
4. **Controlled Bill Cancellation**:
   - Auditable cancellation modal requiring reason and authorizing supervisor.
   - Never deletes bills; preserves history, reverses ledger debits, and excludes cancelled bills from active sales.
5. **WhatsApp Invoice Sharing**:
   - Generates beautifully formatted WhatsApp invoice summaries with one-tap copy and send.
6. **Daily Financial Summaries & 8 Core Reports**:
   - Date-aware navigation cleanly separating active sales from actual cash collections.
   - Reports: Daily Sales, Initial Payments, Collections, Outstanding Dues, Customer Ledger, Goods Entries, Lot Numbers, and Cancelled Bills.
7. **Safe Demo Mode**:
   - Pre-seeded with 8 buyers, 3 sellers/both, 12 goods entries, 10 bills, cancelled bills, and advances.
   - Safe **Reset Demo Data** option with confirmation dialog.

---

## 🏗️ Technology Stack

- **Framework**: Flutter 3.41+ (Dart 3.11+)
- **Design System**: Material 3 (BSG Green & White Theme: `#15803D`, `#16A34A`, `#F0FDF4`, `#F8FAFC`)
- **State Management**: Flutter Riverpod (`Notifier` & `Provider`)
- **Navigation**: GoRouter with ShellRoute Bottom Navigation
- **Charts & Animations**: `fl_chart`, `flutter_animate`
- **Formatting**: `intl` (Indian Currency `₹`, Indian date conventions)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.41 or higher installed and on your PATH.
- Google Chrome, Microsoft Edge, or Android Emulator.

### Installation & Run

1. Clone or navigate to the project directory:
   ```powershell
   cd s:\Project\BuyerSellerGoodsManagement
   ```

2. Fetch dependencies:
   ```powershell
   flutter pub get
   ```

3. Run automated tests (Unit & Widget verification):
   ```powershell
   flutter test
   ```

4. Run locally in Chrome / Web:
   ```powershell
   flutter run -d chrome
   ```

5. Or build the Web release bundle:
   ```powershell
   flutter build web --release
   ```

---

## 📋 Client Demonstration Script (5–10 Minutes)

1. **Dashboard Overview**:
   - Showcase Today's Sales, Initial Payments, Total Collections, and Outstanding Dues.
   - Highlight the Weekly Sales & Collections trend bar chart.
2. **Customer Management**:
   - Open **Customers** tab: filter by Buyers, Sellers, Both.
   - View customer profile (e.g. *Murugan Traders* or *Senthil Agro*).
   - Check the **Account Ledger** tab to show live Debit, Credit, and Running Balance reconciliation.
3. **Goods Entry with Initial Payment**:
   - Tap **New Goods Entry**.
   - Select buyer *Karthik & Sons*, enter Lot `LOT-SAL-15`, 40 bags, and add 2 product lines with weight and rates.
   - In the **Initial Payment Received** card, enter ₹5,000 via UPI.
   - Save entry: show that the ₹5,000 advance appears in the customer's payment history.
4. **Billing & Invoice Generation**:
   - Open the entry and tap **Generate Bill**.
   - Notice how the ₹5,000 initial payment is automatically deducted from the Gross Payable amount.
   - Save the bill to preview the branded BSG Invoice.
5. **WhatsApp Sharing**:
   - Tap **WhatsApp Share** to preview the formatted message and demonstrate the **Copy Message** feature.
6. **Recording Additional Payment**:
   - Tap **Record Payment** on an unpaid or partially paid bill.
   - Enter ₹3,000 and view the live "Balance before vs after payment" preview.
7. **Bill Cancellation with Audit**:
   - Open a bill and tap **Cancel Demo Bill**.
   - Enter reason (*"Weighbridge tare mismatch"*), authorize, and observe the red audit banner, ledger reversal, and updated dashboard sales.
8. **Daily Summary & Reports**:
   - Open **Daily Summary** and switch dates to view itemized transactions.
   - Switch to **Reports Hub** to examine the 8 specialized reports.
9. **Settings & Demo Reset**:
   - Open **Settings**, review company profile, and demonstrate the safe **Reset Demo Data** confirmation.
