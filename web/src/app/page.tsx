import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  BarChart3,
  CheckCircle2,
  FileSpreadsheet,
  Layers,
  Lock,
  Smartphone,
  Truck,
  Users,
  Wallet,
} from "lucide-react";

const FEATURE_BLOCKS = [
  {
    icon: Layers,
    title: "Smart Chart & Arrival / Auction",
    desc: "Record incoming goods on arrival, assign unique lot numbers, track bags/weights, conduct live auctions, and view instant sales summaries.",
  },
  {
    icon: FileSpreadsheet,
    title: "3-Step Purchase & Sales Bill Books",
    desc: "Guided Party → Goods/Weight/Tare → Labour, RMC Cess & On-Spot Payment billing with previous/due balance carry-forward and branded PDF receipts.",
  },
  {
    icon: Users,
    title: "Buyers, Sellers & Transporters",
    desc: "Dedicated partner directories with village/phone search, custom categories, credit limits, and Excel/CSV bulk upload templates.",
  },
  {
    icon: Wallet,
    title: "Automated Ledgers & Advances",
    desc: "Real-time debit/credit running balance statements, buyer/seller advance tracking, and one-click adjustment against future bills.",
  },
  {
    icon: Truck,
    title: "Inventory & Daily Stock Summary",
    desc: "Opening + Approved Purchases − Approved Sales = Closing stock table with low-stock alerts, lot-wise tracking, and damage/wastage adjustments.",
  },
  {
    icon: Smartphone,
    title: "Offline-Ready Flutter Mobile App",
    desc: "Continue recording arrivals and bills even without internet. Local SQLite queue syncs conflict-free when connectivity returns.",
  },
];

export default function HomePage() {
  return (
    <div className="flex min-h-screen flex-col">
      <PublicNavbar />

      {/* Hero Section */}
      <section className="border-b border-slate-200 bg-white py-20">
        <div className="mx-auto max-w-7xl px-6">
          <div className="mx-auto max-w-3xl text-center">
            <span className="inline-flex items-center gap-2 rounded-full border border-blue-200 bg-blue-50 px-3.5 py-1 text-xs font-semibold text-blue-700">
              <Lock className="h-3.5 w-3.5" />
              Multi-Tenant Goods & Commodity Management SaaS
            </span>
            <h1 className="mt-6 text-4xl font-extrabold tracking-tight text-slate-900 sm:text-5xl">
              Run Your Entire Goods, Smart Chart, Billing & Ledger Operations in One Platform
            </h1>
            <p className="mt-5 text-lg text-slate-600">
              Purpose-built for wholesale traders, commission agents, APMC mandis, and multi-branch
              enterprises. Complete tenant isolation, ACID financial integrity, and seamless Web +
              Flutter mobile workflows.
            </p>
            <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
              <Link
                href="/register"
                className="rounded-lg bg-slate-900 px-6 py-3.5 text-sm font-semibold text-white shadow hover:bg-slate-800"
              >
                Start 14-Day Free Business Trial
              </Link>
              <Link
                href="/login"
                className="rounded-lg border border-slate-300 bg-white px-6 py-3.5 text-sm font-semibold text-slate-800 hover:bg-slate-50"
              >
                Launch Live Portal Demo
              </Link>
            </div>
          </div>

          {/* Workflow Preview Bar */}
          <div className="mt-14 grid gap-4 rounded-2xl border border-slate-200 bg-slate-900 p-6 text-white sm:grid-cols-4">
            <div className="rounded-xl bg-slate-800/80 p-4">
              <span className="text-xs font-semibold uppercase text-blue-400">Step 01</span>
              <h3 className="mt-1 font-bold">On-Arrival & Goods Entry</h3>
              <p className="mt-1 text-xs text-slate-300">
                Assign Entry #, Seller, Vehicle #, Lot #, Bags, Gross/Tare/Net Weight & Rates.
              </p>
            </div>
            <div className="rounded-xl bg-slate-800/80 p-4">
              <span className="text-xs font-semibold uppercase text-blue-400">Step 02</span>
              <h3 className="mt-1 font-bold">Smart Chart & Auctions</h3>
              <p className="mt-1 text-xs text-slate-300">
                Allocate lots to buyers, record bid prices, and track sold vs remaining lot stock.
              </p>
            </div>
            <div className="rounded-xl bg-slate-800/80 p-4">
              <span className="text-xs font-semibold uppercase text-blue-400">Step 03</span>
              <h3 className="mt-1 font-bold">Purchase & Sales Bills</h3>
              <p className="mt-1 text-xs text-slate-300">
                Auto-compute Labour, RMC Cess, On-Spot Payment, and Previous/Closing Balance.
              </p>
            </div>
            <div className="rounded-xl bg-slate-800/80 p-4">
              <span className="text-xs font-semibold uppercase text-blue-400">Step 04</span>
              <h3 className="mt-1 font-bold">Ledgers, PDF & Reports</h3>
              <p className="mt-1 text-xs text-slate-300">
                Instant Buyer/Seller Ledgers, Daily Summary, Gross Profit, and WhatsApp/PDF share.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Core Platform Capabilities */}
      <section className="py-20">
        <div className="mx-auto max-w-7xl px-6">
          <div className="max-w-2xl">
            <h2 className="text-3xl font-bold text-slate-900">
              Engineered for High-Volume Goods & Billing Accuracy
            </h2>
            <p className="mt-3 text-slate-600">
              Every calculation—from tare deduction to running partner ledgers—is validated on the
              backend inside ACID database transactions.
            </p>
          </div>

          <div className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {FEATURE_BLOCKS.map((f) => {
              const Icon = f.icon;
              return (
                <div
                  key={f.title}
                  className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm"
                >
                  <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-blue-50 text-blue-600">
                    <Icon className="h-5 w-5" />
                  </div>
                  <h3 className="mt-4 text-lg font-bold text-slate-900">{f.title}</h3>
                  <p className="mt-2 text-sm leading-relaxed text-slate-600">{f.desc}</p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Pricing Preview */}
      <section className="border-t border-slate-200 bg-white py-20">
        <div className="mx-auto max-w-7xl px-6">
          <div className="text-center">
            <h2 className="text-3xl font-bold text-slate-900">Transparent SaaS Subscription Plans</h2>
            <p className="mt-2 text-slate-600">
              Start with a 14-day free trial. Upgrade anytime as your trade volume grows.
            </p>
          </div>

          <div className="mt-12 grid gap-8 md:grid-cols-3">
            {[
              {
                name: "Starter Mandi Plan",
                price: "₹1,499",
                period: "/month",
                desc: "For single-counter goods traders and commission agents.",
                features: [
                  "Up to 3 Business Users",
                  "250 Goods & Lot Catalog Items",
                  "500 Buyers & Sellers",
                  "Purchase & Sales Bill Books",
                  "Branded PDF Receipts",
                ],
              },
              {
                name: "Professional Smart Chart Suite",
                price: "₹2,999",
                period: "/month",
                badge: "Most Popular",
                desc: "Complete multi-user wholesale & APMC management suite.",
                features: [
                  "Up to 15 Business Users with Granular RBAC",
                  "5,000 Goods & Active Lot Records",
                  "10,000 Buyers, Sellers & Transporters",
                  "Smart Chart, Auctions & RMC Cess Reports",
                  "Gross Profit Report & Offline Mobile App",
                ],
              },
              {
                name: "Enterprise Trade Network",
                price: "₹5,999",
                period: "/month",
                desc: "High-capacity multi-branch trading houses.",
                features: [
                  "Up to 100 Users & Custom Roles",
                  "100,000+ Goods & Partner Records",
                  "Automated Cloud Backups & API Access",
                  "WhatsApp Template Triggers",
                  "Dedicated Account Support",
                ],
              },
            ].map((plan) => (
              <div
                key={plan.name}
                className={`flex flex-col justify-between rounded-2xl border p-8 ${
                  plan.badge
                    ? "border-blue-600 bg-slate-900 text-white shadow-lg"
                    : "border-slate-200 bg-white text-slate-900"
                }`}
              >
                <div>
                  {plan.badge && (
                    <span className="inline-block rounded-full bg-blue-600 px-3 py-1 text-xs font-semibold text-white">
                      {plan.badge}
                    </span>
                  )}
                  <h3 className="mt-3 text-xl font-bold">{plan.name}</h3>
                  <p className={`mt-2 text-sm ${plan.badge ? "text-slate-300" : "text-slate-500"}`}>
                    {plan.desc}
                  </p>
                  <div className="mt-6 flex items-baseline gap-1">
                    <span className="text-4xl font-extrabold">{plan.price}</span>
                    <span className={`text-sm ${plan.badge ? "text-slate-300" : "text-slate-500"}`}>
                      {plan.period}
                    </span>
                  </div>
                  <ul className="mt-6 space-y-3 text-sm">
                    {plan.features.map((feat) => (
                      <li key={feat} className="flex items-center gap-2.5">
                        <CheckCircle2
                          className={`h-4 w-4 shrink-0 ${
                            plan.badge ? "text-blue-400" : "text-blue-600"
                          }`}
                        />
                        <span>{feat}</span>
                      </li>
                    ))}
                  </ul>
                </div>

                <Link
                  href="/register"
                  className={`mt-8 block rounded-lg px-4 py-3 text-center text-sm font-semibold ${
                    plan.badge
                      ? "bg-blue-600 text-white hover:bg-blue-500"
                      : "bg-slate-900 text-white hover:bg-slate-800"
                  }`}
                >
                  Choose {plan.name}
                </Link>
              </div>
            ))}
          </div>
        </div>
      </section>

      <PublicFooter />
    </div>
  );
}
