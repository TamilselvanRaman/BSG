# User Manual — CLICK Smart Chart SaaS

## 1. Logging In
Navigate to `/login` on Web or open the Flutter Mobile App. Enter your username and password. The platform automatically redirects you based on your role:
- **Super Admin** → `/super-admin/dashboard`
- **Business Admin** → `/admin/dashboard`
- **Business User / Employee** → `/workspace/dashboard`

## 2. Recording Arrival Goods & Lots
Open **C. Goods & Lot Entries**, select the Seller/Farmer, Goods item, Vehicle Number, Bags count, Gross Weight, Tare Deduction, and Cost/Sell rates. Saving creates both the Goods Entry and an open `GoodsLot`.

## 3. Creating Purchase & Sales Bills (3-Step Wizard)
Open **D. Purchase & Sales Bills**:
1. **Step 1 (Party Details)**: Choose the Buyer or Seller, enter Vehicle Number, and toggle RMC Market Cess if applicable.
2. **Step 2 (Goods & Weight)**: Add one or more Goods lines with Bags count, Gross Weight, Tare Weight, and Rate.
3. **Step 3 (Charges & Payment)**: Enter Labour/Hamali charges, Discount, and On-Spot Paid/Received amount. Confirming atomically updates stock and the partner's running ledger balance.

## 4. Cancelling a Bill
Click **Cancel** on any confirmed bill in the Bill Book and enter the cancellation reason. The bill is marked `CANCELLED` (never deleted) and stock/ledger balances are reversed automatically.
