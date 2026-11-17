import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  ArrowRight,
  Boxes,
  CheckCircle2,
  Coins,
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
    <div className="flex min-h-screen flex-col bg-[#F4FAF5] text-[#123B29] font-sans">
      <PublicNavbar />

      {/* Header */}
      <section className="border-b border-[#CDE8D5] bg-gradient-to-b from-[#F4FAF5] to-[#E8F5EC] py-16 lg:py-24">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 text-center">
          <span className="text-xs font-bold uppercase tracking-widest text-[#087A50]">
            Enterprise Architecture & Capabilities
          </span>
          <h1 className="mt-3 text-4xl font-black text-[#063D2E] sm:text-5xl lg:text-6xl tracking-tight">
            Engineered for High-Volume Mandis
          </h1>
          <p className="mx-auto mt-6 max-w-3xl text-base sm:text-lg text-[#47785C] leading-relaxed">
            Every module in BSG is purpose-built for the unique speed, weighment methods, and financial credit rituals of agricultural wholesale markets.
          </p>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
            <Link
              href="/register"
              className="rounded-xl bg-[#087A50] hover:bg-[#063D2E] px-7 py-3.5 text-sm font-bold text-white shadow-md transition"
            >
              Start 30-Day Free Trial
            </Link>
            <Link
              href="/pricing"
              className="rounded-xl border border-[#CDE8D5] bg-white hover:bg-[#E8F5EC] px-7 py-3.5 text-sm font-bold text-[#063D2E] transition"
            >
              View Pricing Plans
            </Link>
          </div>
        </div>
      </section>

      {/* Deep-Dive Alternating Modules */}
      <section className="py-20 space-y-16">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 space-y-12">
          {FEATURE_PILLARS.map((feat, idx) => {
            const Icon = feat.icon;
            const isEven = idx % 2 === 0;
            return (
              <div
                key={feat.id}
                className={`grid gap-8 lg:grid-cols-12 items-center rounded-3xl border border-[#CDE8D5] p-8 sm:p-10 shadow-xs transition ${
                  isEven ? "bg-white" : "bg-[#E8F5EC]/50"
                }`}
              >
                {/* Content */}
                <div className={`space-y-4 lg:col-span-7 ${isEven ? "" : "lg:order-2"}`}>
                  <div className="flex items-center gap-2.5">
                    <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#DDF2E4] text-[#087A50]">
                      <Icon className="h-5 w-5" />
                    </div>
                    <span className="rounded-full bg-[#E8F5EC] border border-[#CDE8D5] px-3 py-0.5 text-[11px] font-bold text-[#063D2E] uppercase tracking-wider">
                      {feat.badge}
                    </span>
                  </div>

                  <h2 className="text-2xl sm:text-3xl font-bold text-[#063D2E]">
                    {feat.title}
                  </h2>
                  <p className="text-sm text-[#47785C] leading-relaxed">
                    {feat.summary}
                  </p>

                  <div className="pt-2 grid gap-2.5 sm:grid-cols-2">
                    {feat.details.map((d) => (
                      <div key={d} className="flex items-start gap-2 text-xs text-[#123B29]">
                        <CheckCircle2 className="h-4 w-4 text-[#10A66A] shrink-0 mt-0.5" />
                        <span>{d}</span>
                      </div>
                    ))}
                  </div>

                  <div className="pt-4 flex items-center justify-between border-t border-[#DCEEE1]">
                    <span className="font-bold text-xs text-[#087A50]">
                      {feat.metric}
                    </span>
                    <Link
                      href="/contact"
                      className="inline-flex items-center gap-1 text-xs font-bold text-[#063D2E] hover:text-[#087A50] transition"
                    >
                      <span>Request Live Walkthrough</span>
                      <ArrowRight className="h-3.5 w-3.5" />
                    </Link>
                  </div>
                </div>

                {/* Right Interactive Mock Display */}
                <div className={`lg:col-span-5 ${isEven ? "" : "lg:order-1"}`}>
                  <div className="rounded-2xl border border-[#0A503B] bg-[#063D2E] p-6 text-[#C4E2CF] font-mono text-xs shadow-xl space-y-3">
                    <div className="flex items-center justify-between border-b border-[#0A503B] pb-2 text-[10px] text-[#71917B]">
                      <span>MANDI OS :: {feat.badge.toUpperCase()}</span>
                      <span className="text-[#10A66A] font-bold">ONLINE / LIVE</span>
                    </div>
                    <div className="space-y-1.5 font-sans">
                      <div className="text-white font-bold text-sm">{feat.title}</div>
                      <p className="text-[11px] text-[#C4E2CF] leading-relaxed">
                        Continuous ACID transactional integrity with automated tare verification and receipt generation.
                      </p>
                    </div>
                    <div className="pt-3 border-t border-[#0A503B] flex justify-between text-[11px]">
                      <span>Telemetry Health:</span>
                      <span className="text-[#10A66A] font-bold">SHA256:VERIFIED</span>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </section>

      {/* CTA Box */}
      <section className="relative overflow-hidden py-24 bg-gradient-to-b from-[#0A503B] via-[#08523D] to-[#074734] text-white border-t border-[#0E6E50] border-b border-[#063423]">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,_var(--tw-gradient-stops))] from-[#10A66A]/20 via-transparent to-transparent pointer-events-none" />
        <div className="relative mx-auto max-w-4xl px-4 text-center space-y-6">
          <span className="text-xs font-bold uppercase tracking-widest text-[#10A66A]">
            Deploy to Your Market Yard
          </span>
          <h2 className="text-3xl font-black sm:text-5xl">
            Upgrade Your Mandi with Enterprise Software Today
          </h2>
          <p className="text-sm text-[#C4E2CF] max-w-2xl mx-auto">
            Get instant access for 1 Store Admin and 2 Staff Cashiers with our 30-day full feature trial.
          </p>
          <div className="pt-3 flex flex-wrap items-center justify-center gap-4">
            <Link
              href="/register"
              className="rounded-xl bg-[#10A66A] hover:bg-[#087A50] px-7 py-3.5 text-sm font-bold text-white shadow-lg transition"
            >
              Start 30-Day Free Trial
            </Link>
            <Link
              href="/contact"
              className="rounded-xl border border-[#10A66A]/40 bg-[#063D2E] hover:bg-[#087A50] px-7 py-3.5 text-sm font-bold text-white transition"
            >
              Schedule Guided Demo
            </Link>
          </div>
        </div>
      </section>

      <PublicFooter />
    </div>
  );
}
