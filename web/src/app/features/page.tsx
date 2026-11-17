import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  ArrowRight,
  BarChart3,
  Boxes,
  CheckCircle2,
  Coins,
  Cpu,
  Database,
  FileSpreadsheet,
  FileText,
  Key,
  Layers,
  Lock,
  PackagePlus,
  Printer,
  Scale,
  ShieldCheck,
  Smartphone,
  Sparkles,
  Truck,
  UserCheck,
  Users,
  Wallet,
  Zap,
} from "lucide-react";

const FEATURE_PILLARS = [
  {
    id: "arrivals",
    icon: PackagePlus,
    title: "Multi-Product Arrival Lots",
    badge: "Inward Gate",
    summary:
      "Handle trucks carrying multiple crops from farmers in a single arrival entry with full gross, tare, and net weighment traceability.",
    details: [
      "Record multiple crops (e.g. Tomato Hybrid, Onion Red, Potato) in one arrival lot",
      "Assign vehicle number, driver phone, supplier/farmer name, and arrival gate time",
      "Auto-calculate tare weight of bags/crates and derive true net commodity weight",
      "Real-time lot status tracking: Open, Partially Sold, Closed, and Reconciled",
    ],
    metric: "100% Traceability from Farm to Mandi Gate",
  },
  {
    id: "scale",
    icon: Scale,
    title: "Bag-by-Bag Weighment Scale",
    badge: "Floor Weighment",
    summary:
      "Eliminate manual paper calculation slips with digital bag weight entry that sums individual bags and computes net totals instantly.",
    details: [
      "Direct numerical entry for individual bags (e.g., Bag 1: 52 kg, Bag 2: 53 kg, Bag 3: 53 kg)",
      "Instant sum of total bags, gross weight, tare deduction, and net saleable weight",
      "Fast keyboard numpad shortcuts designed for high-speed mandi auction environments",
      "Printed bag weighment table directly on the buyer invoice receipt",
    ],
    metric: "0 Math Errors • Instant Bag Totaling",
  },
  {
    id: "auction",
    icon: Layers,
    title: "Smart Chart & Live Lot Auctions",
    badge: "Mandi Floor",
    summary:
      "Digital auction blackboard for allotting arrival lots to multiple buyers at different strike rates with zero stock slippage.",
    details: [
      "Real-time lot split: sell 20 bags to Buyer A @ ₹35/kg and 30 bags to Buyer B @ ₹34/kg",
      "Live remaining stock counters updated instantly upon each auction allotment",
      "Weighted average selling rate computation across the entire lot",
      "Instant conversion of auction lots into confirmed purchase and sales bill drafts",
    ],
    metric: "Sub-Second Lot Allotment & Stock Deduction",
  },
  {
    id: "billing",
    icon: FileText,
    title: "High-Speed Cash & Credit Billing",
    badge: "Point of Sale",
    summary:
      "Issue GST and non-GST Mandi bills in seconds with automatic coolie/hamali, RMC market cess, and previous balance roll-forward.",
    details: [
      "Instant Cash Bills with immediate cash drawer receipt and register entry",
      "Credit Bills for registered buyers with credit limit warnings and payment terms",
      "Automated addition of labour/coolie charges, unloading fees, and transport costs",
      "One-click bill cancellation with automatic stock reversal and ledger rebalancing",
    ],
    metric: "< 5 Seconds Per Bill • Thermal & A4 Print Ready",
  },
  {
    id: "tally",
    icon: Coins,
    title: "Daily Cash Tally & Drawer Reconciliation",
    badge: "Cash Desk",
    summary:
      "Evening cash drawer audit featuring physical currency denomination breakdown, expected closing computation, and shortage tracking.",
    details: [
      "Yesterday's closing cash carried forward automatically as today's opening cash",
      "Live tally of cash sales, customer receipts, GPay 1, GPay 2, and petty cash expenses",
      "Physical currency counter for ₹2000, ₹500, ₹200, ₹100, ₹50, ₹20, ₹10, and coins",
      "Audit trail flagging cash surplus or shortage discrepancies with mandatory supervisor notes",
    ],
    metric: "Zero Cash Leakage at Day-End Closing",
  },
  {
    id: "ledgers",
    icon: Wallet,
    title: "Double-Entry Partner Ledgers & Advances",
    badge: "Financial Core",
    summary:
      "True double-entry running balance accounts for all buyers, suppliers, and transporters with automatic advance deductions.",
    details: [
      "Real-time debit/credit timeline tracking every bill, receipt, return, and discount",
      "Pre-season farmer advance disbursement and automatic settlement against crop arrivals",
      "One-click WhatsApp & SMS statement dispatch with PDF statement attached",
      "Credit aging analysis (0-15 days, 16-30 days, 30+ days overdue)",
    ],
    metric: "ACID Guaranteed Financial Ledger Integrity",
  },
  {
    id: "mobile",
    icon: Smartphone,
    title: "Offline Handheld Android Mobile Sync",
    badge: "Floor Mobility",
    summary:
      "Empower weighment operators on the mandi floor with rugged handheld Android tablets that work seamlessly without internet.",
    details: [
      "Offline-first local SQLite queue for arrivals, bag weighments, and sales bills",
      "Automatic background synchronization to the cloud database when Wi-Fi/4G connects",
      "Bluetooth thermal printer integration for printing spot receipts right on the floor",
      "Consistent UI and instant data mirroring between Mobile handhelds and Web store portal",
    ],
    metric: "100% Floor Uptime Even With Zero Internet",
  },
  {
    id: "licensing",
    icon: UserCheck,
    title: "Strict Multi-User Licensing (Max 3 Seats)",
    badge: "Enterprise Security",
    summary:
      "Enforce authorized seat quotas per shop (1 Store Admin + 2 Staff/Cashiers) with active concurrent session monitors and anti-theft controls.",
    details: [
      "Strict seat cap of 3 users per tenant ID enforced at database and API layers",
      "Concurrent active session monitor with 1-click 'Revoke Session / Free Seat' capability",
      "Role-Based Access Control: Operator staff cannot alter commission rates or delete logs",
      "Comprehensive immutable audit logging capturing IP address, device, and user actions",
    ],
    metric: "Zero Account Sharing • Enterprise RBAC Protection",
  },
];

export default function FeaturesPage() {
  return (
    <div className="flex min-h-screen flex-col bg-slate-50">
      <PublicNavbar />

      {/* Header */}
      <section className="border-b border-slate-200/80 bg-white py-16 lg:py-24">
        <div className="mx-auto max-w-7xl px-6 text-center">
          <span className="inline-flex items-center gap-1.5 rounded-full bg-blue-50 border border-blue-200 px-3.5 py-1 text-xs font-bold text-blue-700">
            <Cpu className="h-3.5 w-3.5" />
            Enterprise Architecture & Capabilities
          </span>
          <h1 className="mt-5 text-4xl font-black text-slate-900 sm:text-5xl lg:text-6xl tracking-tight">
            Engineered for High-Volume Mandis
          </h1>
          <p className="mt-4 text-base sm:text-lg text-slate-600 max-w-2xl mx-auto leading-relaxed">
            Every module in CLICK Smart Chart is purpose-built for the unique speed, weighment methods, and financial credit rituals of agricultural wholesale markets.
          </p>

          <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
            <Link
              href="/register"
              className="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-indigo-600 px-6 py-3.5 text-xs font-bold text-white shadow-md hover:from-blue-700 hover:to-indigo-700 transition"
            >
              <span>Start 30-Day Free Trial</span>
              <ArrowRight className="h-4 w-4" />
            </Link>
            <Link
              href="/pricing"
              className="inline-flex items-center gap-2 rounded-xl border border-slate-300 bg-white px-6 py-3.5 text-xs font-bold text-slate-700 shadow-sm hover:bg-slate-50"
            >
              <span>View Pricing Plans</span>
            </Link>
          </div>
        </div>
      </section>

      {/* Feature Deep Dive Grid */}
      <section className="py-20">
        <div className="mx-auto max-w-7xl px-6">
          <div className="space-y-12">
            {FEATURE_PILLARS.map((feat, idx) => {
              const Icon = feat.icon;
              const isEven = idx % 2 === 0;

              return (
                <div
                  key={feat.id}
                  id={feat.id}
                  className="rounded-3xl border border-slate-200 bg-white p-8 lg:p-12 shadow-sm hover:shadow-md transition"
                >
                  <div className="grid gap-8 lg:grid-cols-12 items-center">
                    {/* Left Info */}
                    <div className="lg:col-span-7 space-y-4">
                      <div className="flex items-center gap-3">
                        <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-100 text-blue-700">
                          <Icon className="h-6 w-6" />
                        </div>
                        <div>
                          <span className="rounded-full bg-slate-100 px-2.5 py-0.5 text-[10px] font-bold text-slate-600 uppercase tracking-wider">
                            {feat.badge}
                          </span>
                          <h2 className="text-2xl font-bold text-slate-900 mt-1">
                            {feat.title}
                          </h2>
                        </div>
                      </div>

                      <p className="text-sm text-slate-600 leading-relaxed pt-1">
                        {feat.summary}
                      </p>

                      <div className="space-y-2.5 pt-2">
                        {feat.details.map((point) => (
                          <div key={point} className="flex items-start gap-2.5 text-xs text-slate-700">
                            <CheckCircle2 className="h-4 w-4 text-emerald-600 shrink-0 mt-0.5" />
                            <span>{point}</span>
                          </div>
                        ))}
                      </div>

                      <div className="pt-3">
                        <span className="inline-flex items-center gap-2 rounded-lg bg-emerald-50 border border-emerald-200 px-3 py-1.5 text-xs font-bold text-emerald-800">
                          <Sparkles className="h-3.5 w-3.5 text-emerald-600" />
                          {feat.metric}
                        </span>
                      </div>
                    </div>

                    {/* Right Visual Card */}
                    <div className="lg:col-span-5">
                      <div className="rounded-2xl border border-slate-200 bg-slate-900 p-6 text-white shadow-inner">
                        <div className="flex items-center justify-between border-b border-slate-800 pb-3 text-xs">
                          <span className="font-mono text-blue-400">MANDI_OS::{feat.id.toUpperCase()}</span>
                          <span className="rounded bg-emerald-500/20 text-emerald-400 px-2 py-0.5 text-[10px] font-bold">
                            ONLINE / LIVE
                          </span>
                        </div>
                        <div className="py-6 space-y-3 font-mono text-xs">
                          <div className="flex justify-between text-slate-400">
                            <span>Processing Mode</span>
                            <span className="text-white">ACID Multi-Tenant</span>
                          </div>
                          <div className="flex justify-between text-slate-400">
                            <span>Hardware Hook</span>
                            <span className="text-white">Thermal & Weighbridge</span>
                          </div>
                          <div className="flex justify-between text-slate-400">
                            <span>Platform Security</span>
                            <span className="text-white">AES-256 / Max 3 Seats</span>
                          </div>
                          <div className="flex justify-between text-slate-400">
                            <span>Mobile Mirroring</span>
                            <span className="text-emerald-400 font-bold">Sync Enabled</span>
                          </div>
                        </div>
                        <div className="border-t border-slate-800 pt-3 flex justify-between text-[11px] text-slate-500">
                          <span>Audit Verified</span>
                          <span className="text-slate-400">APMC Mandi Standard</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-slate-900 text-white text-center border-t border-slate-800">
        <div className="mx-auto max-w-4xl px-6 space-y-6">
          <h2 className="text-3xl font-black sm:text-4xl">
            Experience the Complete Mandi OS Suite
          </h2>
          <p className="text-sm text-slate-400 max-w-xl mx-auto">
            Get instant access to all 8 modules for your shop. Provision your 30-day trial license in 60 seconds.
          </p>
          <div className="pt-2">
            <Link
              href="/register"
              className="inline-flex items-center gap-2 rounded-xl bg-blue-600 px-7 py-3 text-sm font-bold text-white shadow-lg hover:bg-blue-700 transition"
            >
              <span>Provision Shop License</span>
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </div>
      </section>

      <PublicFooter />
    </div>
  );
}
