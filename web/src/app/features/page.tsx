import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";

export default function FeaturesPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <PublicNavbar />
      <main className="mx-auto max-w-6xl flex-1 px-6 py-16">
        <h1 className="text-3xl font-extrabold text-slate-900">
          Complete Feature Inventory — CLICK Smart Chart SaaS
        </h1>
        <p className="mt-2 text-slate-600">
          Every module is backed by tenant-scoped MySQL tables, RBAC guards, and real-time API
          integration.
        </p>

        <div className="mt-10 grid gap-6 md:grid-cols-2">
          {[
            {
              title: "A. Smart Chart & On-Arrival Auctions",
              items: [
                "Record incoming goods by seller, vehicle number, bags count, gross/tare/net weight",
                "Create unique Goods Lots and monitor Open, Partial, and Sold-Out status",
                "Smart Chart & Live Auction item allocation with instant party/product filtering",
              ],
            },
            {
              title: "B. 3-Step Purchase & Sales Bill Books",
              items: [
                "Step 1: Party selection with instant village/phone lookup and previous balance display",
                "Step 2: Multi-item Goods, Bags, Gross/Tare/Net Weight & Rate calculation",
                "Step 3: Labour/Hamali charges, RMC Cess, On-Spot Payment, and traceable Bill Cancellation",
              ],
            },
            {
              title: "C. Partners, Ledgers & Advances",
              items: [
                "Buyer, Seller & Transporter directories with custom categories and Excel/CSV import",
                "Automated Buyer & Seller Running Balance Ledgers with date range filters",
                "Issue/receive partner advances and allocate remaining balances to bills",
              ],
            },
            {
              title: "D. Inventory, Reports & PDF Engine",
              items: [
                "Opening + Purchases − Sales = Closing stock table with low-stock alerts",
                "Daily Summary (with Vehicle #), Gross Profit Report, and RMC Sales Report",
                "Branded A4 & Thermal PDF receipts, ledger statements, and CSV/Excel exports",
              ],
            },
          ].map((sec) => (
            <div key={sec.title} className="rounded-xl border border-slate-200 bg-white p-6">
              <h2 className="text-lg font-bold text-slate-900">{sec.title}</h2>
              <ul className="mt-4 list-disc space-y-2 pl-5 text-sm text-slate-600">
                {sec.items.map((i) => (
                  <li key={i}>{i}</li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="mt-10">
          <Link
            href="/register"
            className="inline-block rounded-lg bg-blue-600 px-6 py-3 text-sm font-semibold text-white"
          >
            Start Free Trial
          </Link>
        </div>
      </main>
      <PublicFooter />
    </div>
  );
}
