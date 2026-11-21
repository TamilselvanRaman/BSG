import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  AlertTriangle,
  Apple,
  ArrowRight,
  Boxes,
  CheckCircle2,
  Clock,
  FileSpreadsheet,
  FileText,
  Layers,
  PackagePlus,
  Scale,
  ShieldCheck,
  Smartphone,
  TrendingUp,
  Truck,
  Users,
  Utensils,
  Wheat,
  Zap,
} from "lucide-react";

interface ComparisonRow {
  workflow: string;
  workflowIcon?: any;
  problemTitle: string;
  problemDesc: string;
  problemTag?: string;
  outcomeTitle: string;
  outcomeDesc: string;
  impactBadge: string;
}

interface SolutionVertical {
  id: string;
  icon: any;
  title: string;
  subtitle: string;
  tagline: string;
  metrics: { label: string; value: string }[];
  comparisons: ComparisonRow[];
}

const SOLUTIONS: SolutionVertical[] = [
  {
    id: "vegetables",
    icon: Utensils,
    title: "Vegetable Mandis & Onion/Potato Merchants",
    subtitle: "High-Volume APMC Commission Agents & Perishable Traders",
    tagline: "High-volume perishables with rapid bag weighment and daily evening cash tallying",
    metrics: [
      { label: "Weighment Speed", value: "< 3s per Bag" },
      { label: "Tare Discrepancy", value: "0% Math Loss" },
      { label: "Evening Closing", value: "100% Reconciled" },
    ],
    comparisons: [
      {
        workflow: "Multi-Crop Truck Inward",
        workflowIcon: Truck,
        problemTitle: "Paper Gate Passes & Multi-Crop Confusion",
        problemDesc: "Arriving farm vehicles carry multiple grades (Tomato, Country Onion, Chilli) requiring separate paper chits. Mixed-crop weights get confused at the gate, delaying unloading during rushed morning arrivals.",
        problemTag: "15-20 Min Gate Delay",
        outcomeTitle: "Single-Screen Multi-Crop Inward Manifest",
        outcomeDesc: "Captures the entire vehicle manifest, farmer details, gross truck weighment, and driver contact on a single screen with automatic tare deduction by packaging type.",
        impactBadge: "< 2 Min Clearance",
      },
      {
        workflow: "Bag-by-Bag Scale Weighment",
        workflowIcon: Scale,
        problemTitle: "Manual Chit Math & Weight Shrinkage Disputes",
        problemDesc: "Weighment laborers scribble 40-60 individual bag weights on paper scraps. Mental math tare deductions lead to calculation mistakes, buyer disputes, and untracked weight shrinkage.",
        problemTag: "Shrinkage & Math Risk",
        outcomeTitle: "Direct Electronic Scale Auto-Summing",
        outcomeDesc: "Connects directly to digital scales. Individual bag weights sum in real time, auto-subtracts bag tare according to commodity standard, and cryptographically locks billable net weight.",
        impactBadge: "100% Verified Weight",
      },
      {
        workflow: "Live Lot Split Auctions",
        workflowIcon: Layers,
        problemTitle: "Chalkboard Bidding & Inventory Overselling",
        problemDesc: "Splitting a single incoming lot across multiple wholesale buyers at varying strike rates is tracked on floor chalkboards, causing oversold stock, missing crates, and dispute arguments.",
        problemTag: "Inventory Leaks",
        outcomeTitle: "Digital Smart Chart Live Allocation",
        outcomeDesc: "Digital auction blackboard allocates precise bag quantities and strike rates across multiple buyers simultaneously with live remaining inventory counters and zero slippage.",
        impactBadge: "Zero Stock Slippage",
      },
      {
        workflow: "High-Speed Counter POS",
        workflowIcon: Zap,
        problemTitle: "Handwritten Bills & Yard Exit Congestion",
        problemDesc: "Buyers waiting 15+ minutes at the counter for handwritten carbon-copy receipts causes severe mandi exit gridlock, delayed cash collections, and human billing errors.",
        problemTag: "15+ Min Counter Wait",
        outcomeTitle: "Sub-5 Second Thermal & A4 Invoicing",
        outcomeDesc: "Generates GST-compliant itemized cash and credit bills in under 5 seconds with coolie/hamali, transport charges, APMC cess, and previous credit balances auto-computed.",
        impactBadge: "< 5s Instant Invoicing",
      },
      {
        workflow: "Evening Cash Drawer Tally",
        workflowIcon: Clock,
        problemTitle: "Unbalanced Drawer & Unidentified Cash Shortages",
        problemDesc: "Store owners spend hours after sunset manually counting currency bundles, unable to verify whether cash shortages stem from counter theft or unrecorded cash expenses.",
        problemTag: "Cash Shortage Risk",
        outcomeTitle: "Currency Denomination Breakdown & Audit",
        outcomeDesc: "Physical denomination counter (₹500, ₹200, ₹100, ₹50, coins) reconciles against system expected closing cash balance with permanent audit trail and discrepancy logs.",
        impactBadge: "Closing in < 10 Mins",
      },
    ],
  },
  {
    id: "fruits",
    icon: Apple,
    title: "Fruit Commission Agents & Cold Storage",
    subtitle: "Orchard Procurement, Crate Distribution & Credit Management",
    tagline: "Box and crate tracking with lot-wise profit margins and buyer credit controls",
    metrics: [
      { label: "Packaging Units", value: "Crate, Box & Kg" },
      { label: "Credit Control", value: "Automated Credit Cap" },
      { label: "Ledger Dispatch", value: "1-Click WhatsApp PDF" },
    ],
    comparisons: [
      {
        workflow: "Crate & Box Unit Tracking",
        workflowIcon: Boxes,
        problemTitle: "Mismatched Box Counts & Lost Orchard Crates",
        problemDesc: "High-value fruit arrivals come in diverse crates and cartons (Wooden Crates, Corrugated Boxes, Plastic Crates). Paper registers lose track of empty returnable crates and cold-room bay locations.",
        problemTag: "High Container Loss",
        outcomeTitle: "Native Multi-Unit Packaging & Cold Store Master",
        outcomeDesc: "Tracks stock natively across Box, Crate, and Kg units. Serialized lot codes link fruit arrivals to grower orchards, cold storage bays, and empty returnable crate ledgers.",
        impactBadge: "100% Crate Traceability",
      },
      {
        workflow: "Wholesale Buyer Credit Control",
        workflowIcon: ShieldCheck,
        problemTitle: "Unchecked Informal Credit & Severe Bad Debts",
        problemDesc: "Wholesale fruit buyers accumulate large informal credit balances across multiple weeks. Without automated credit enforcement, merchants suffer severe cash-flow crunches and bad debt.",
        problemTag: "Severe Bad Debt Risk",
        outcomeTitle: "Automated Credit Limit & Overdue Lock",
        outcomeDesc: "Enforces strict customizable buyer credit caps and overdue payment aging timelines. Automatically blocks new credit dispatch when credit thresholds are breached until dues are settled.",
        impactBadge: "92% Faster Debt Recovery",
      },
      {
        workflow: "Farmer Advance Deductions",
        workflowIcon: FileSpreadsheet,
        problemTitle: "Forgotten Pre-Season Cash Advance Khata",
        problemDesc: "Advances paid to orchard growers months before harvest are logged in paper notebooks. During rapid harvest settlements, advances are frequently omitted, causing irreversible store losses.",
        problemTag: "Uncollected Capital",
        outcomeTitle: "Automated Advance Recovery on Settlement",
        outcomeDesc: "Pre-season advances auto-deduct from grower auction payouts with itemized transparent statements showing commission percentages, storage fees, and net bank payout.",
        impactBadge: "Zero Missed Deductions",
      },
      {
        workflow: "Partner Double-Entry Ledgers",
        workflowIcon: FileText,
        problemTitle: "Disputed Paper Statements & Delayed Audits",
        problemDesc: "Orchard growers and wholesale buyers frequently dispute paper khata figures weeks later, requiring days of manual receipt digging and painful balance reconciliations.",
        problemTag: "Dispute Delays",
        outcomeTitle: "Instant 1-Click WhatsApp PDF Ledgers",
        outcomeDesc: "Dispatches verifiable double-entry running balance statements directly to partner WhatsApp numbers with complete itemized transaction history and verified payment receipts.",
        impactBadge: "Instant Verification",
      },
    ],
  },
  {
    id: "grains",
    icon: Wheat,
    title: "Grains, Oilseeds & Pulses Wholesale Mandis",
    subtitle: "Heavy Commodity Trading, Weighbridge Integration & APMC Compliance",
    tagline: "Weighbridge gross/tare entries, APMC market cess, and bulk buyer delivery manifests",
    metrics: [
      { label: "Trade Scale", value: "Quintal & MT Capacity" },
      { label: "APMC Compliance", value: "100% Cess Calculation" },
      { label: "Settlement Speed", value: "Same-Day Grower Payout" },
    ],
    comparisons: [
      {
        workflow: "Weighbridge Truck Weighment",
        workflowIcon: Scale,
        problemTitle: "Manual Weighbridge Re-Entry Clerical Errors",
        problemDesc: "Heavy grain trucks weighed on weighbridge scales require staff to manually re-type weigh slips into office PCs, introducing clerical tonnage discrepancies and inventory imbalances.",
        problemTag: "Tonnage Discrepancies",
        outcomeTitle: "Direct Gross & Tare Quintal Capture",
        outcomeDesc: "Directly records truck Gross, Tare, and Net weight in Quintals or Metric Tons with configurable moisture cut percentages, gunny bag tare allowances, and truck license plate logging.",
        impactBadge: "Zero Clerical Loss",
      },
      {
        workflow: "Statutory APMC Market Cess",
        workflowIcon: FileText,
        problemTitle: "Complex Cess Formulas & Regulatory Penalties",
        problemDesc: "Calculating statutory agricultural market committee fees, rural development funds, and mandi cess manually across hundreds of transactions risks tax audit fines and license suspension.",
        problemTag: "Audit & Penalty Risk",
        outcomeTitle: "Automated Mandi Cess Engine & Tax Registers",
        outcomeDesc: "Calculates statutory APMC market cess and statutory fees automatically based on local market committee regulations and generates monthly statutory compliance registers.",
        impactBadge: "100% Tax Compliant",
      },
      {
        workflow: "Outward Delivery Gate Passes",
        workflowIcon: Truck,
        problemTitle: "Unverified Gate Departures & Dispatch Chaos",
        problemDesc: "Bulk truck dispatches to flour and oil mills rely on paper chits without payment verification, leading to yard gate congestion, unrecorded trucks, and dispatch reconciliation disputes.",
        problemTag: "Yard Security Risk",
        outcomeTitle: "Serialized Cryptographic Gate Manifests",
        outcomeDesc: "Generates secure serialized outward gate passes only after cashier payment verification or verified credit authorization, validating truck driver identity and bill manifest before exit.",
        impactBadge: "Tamper-Proof Dispatch",
      },
      {
        workflow: "Farmer Payout Settlements",
        workflowIcon: Smartphone,
        problemTitle: "Week-Long Farmer Payment Delays",
        problemDesc: "Compiling truck weights, quality deductions, and mandi fees takes days, frustrating farmers and prompting growers to take their future harvest to competitor commission shops.",
        problemTag: "Loss of Grower Loyalty",
        outcomeTitle: "Instant Double-Entry Farmer Vouchers",
        outcomeDesc: "Computes gross value, statutory deductions, gunny bag allowances, and net payable in seconds, enabling prompt same-day farmer bank transfers or cash payouts at the counter.",
        impactBadge: "Same-Day Settlements",
      },
    ],
  },
];

export default function SolutionsPage() {
  return (
    <div className="flex min-h-screen flex-col bg-[var(--bg-main)] text-[var(--text-primary)] font-sans">
      <PublicNavbar />

      {/* Hero Header */}
      <section className="border-b border-[var(--border-color)] bg-gradient-to-b from-white via-[var(--bg-main)] to-[var(--bg-card-hover)]/60 py-16 lg:py-20">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 text-center">
          <h1 className="mx-auto max-w-3xl text-3xl font-black text-[var(--text-primary)] sm:text-4xl lg:text-5xl tracking-tight leading-tight">
            Built for Your Specific Commodity Workflow
          </h1>
          <p className="mt-4 text-sm sm:text-base text-[var(--text-secondary)] max-w-2xl mx-auto leading-relaxed">
            Whether you trade perishable vegetables, graded fruits, or bulk grains, BSG adapts to your trade conventions, units, and credit cycles.
          </p>
        </div>
      </section>

      {/* Solutions Cards with Detailed Table Comparisons */}
      <section className="py-16 lg:py-20">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="space-y-16">
            {SOLUTIONS.map((sol) => {
              const Icon = sol.icon;

              return (
                <div
                  key={sol.id}
                  className="rounded-3xl border border-[var(--border-color)] bg-white p-6 sm:p-8 lg:p-10 shadow-xs hover:border-[#B49AFF] transition-all"
                >
                  {/* Card Header & Key Vertical Metrics */}
                  <div className="flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between border-b border-[#DCEEE1] pb-6">
                    <div className="flex items-start sm:items-center gap-4">
                      <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-[var(--bg-card-hover)] text-[#9475F5] border border-[var(--border-color)] shrink-0">
                        <Icon className="h-7 w-7" />
                      </div>
                      <div>
                        <div className="flex flex-wrap items-center gap-2">
                          <h2 className="text-xl sm:text-2xl font-black text-[var(--text-primary)] tracking-tight">
                            {sol.title}
                          </h2>
                        </div>
                        <p className="text-xs sm:text-sm text-[var(--text-secondary)] mt-1 font-medium">
                          {sol.tagline}
                        </p>
                      </div>
                    </div>

                    <div className="flex flex-wrap items-center gap-3">
                      <Link
                        href="/register"
                        className="inline-flex items-center justify-center gap-2 rounded-xl bg-[#9475F5] hover:bg-[var(--text-primary)] px-5 py-2.5 text-xs font-bold text-white shadow-xs transition"
                      >
                        <span>Start 30-Day Free Trial</span>
                        <ArrowRight className="h-3.5 w-3.5" />
                      </Link>
                    </div>
                  </div>

                  {/* Vertical Quick Metric Strip */}
                  <div className="mt-5 grid grid-cols-1 sm:grid-cols-3 gap-3">
                    {sol.metrics.map((m) => (
                      <div
                        key={m.label}
                        className="rounded-xl border border-[var(--border-color)] bg-[var(--bg-main)] p-3 flex items-center justify-between"
                      >
                        <span className="text-[11px] font-bold text-[var(--text-secondary)]">{m.label}</span>
                        <span className="text-xs font-black text-[var(--text-primary)]">{m.value}</span>
                      </div>
                    ))}
                  </div>

                  {/* ============================================================
                      COMPARISON TABLE: PROBLEM VS OUTCOME MATRIX
                     ============================================================ */}
                  <div className="mt-8 overflow-hidden rounded-2xl border border-[var(--border-color)] bg-white shadow-xs">
                    <div className="overflow-x-auto">
                      <table className="w-full text-left border-collapse min-w-[780px]">
                        <thead>
                          <tr className="border-b border-[var(--border-color)] bg-[var(--bg-main)]">
                            {/* Column 1: Workflow */}
                            <th className="w-1/4 px-5 py-3.5 text-[11px] font-bold uppercase tracking-wider text-[var(--text-secondary)]">
                              Mandi Workflow Area
                            </th>

                            {/* Column 2: Problem (Subtle Red Tint Header) */}
                            <th className="w-[38%] px-5 py-3.5 text-[11px] font-bold uppercase tracking-wider text-[#C2413B] bg-red-50/60 border-l border-r border-[#F0D0CB]">
                              <div className="flex items-center gap-2">
                                <span className="h-2 w-2 rounded-full bg-[#C2413B]" />
                                <span>Traditional Mandi Problem</span>
                              </div>
                            </th>

                            {/* Column 3: Outcome (Subtle Emerald Tint Header) */}
                            <th className="w-[37%] px-5 py-3.5 text-[11px] font-bold uppercase tracking-wider text-[#9475F5] bg-[var(--bg-card-hover)]/70">
                              <div className="flex items-center gap-2">
                                <span className="h-2 w-2 rounded-full bg-[#B49AFF]" />
                                <span>BSG Platform Enterprise Outcome</span>
                              </div>
                            </th>
                          </tr>
                        </thead>

                        <tbody className="divide-y divide-[#DCEEE1]">
                          {sol.comparisons.map((row) => {
                            const RowIcon = row.workflowIcon || Layers;

                            return (
                              <tr key={row.workflow} className="hover:bg-[#F9FCFA] transition-colors">
                                {/* Workflow Cell */}
                                <td className="px-5 py-4 align-top">
                                  <div className="flex items-center gap-2.5">
                                    <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-[var(--bg-card-hover)] text-[#9475F5] shrink-0">
                                      <RowIcon className="h-3.5 w-3.5" />
                                    </div>
                                    <span className="font-bold text-xs text-[var(--text-primary)]">
                                      {row.workflow}
                                    </span>
                                  </div>
                                </td>

                                {/* Traditional Problem Cell (Distinct Red/Coral Styling) */}
                                <td className="px-5 py-4 align-top bg-red-50/20 border-l border-r border-[#F0D0CB]/60">
                                  <div className="space-y-1.5">
                                    <div className="flex items-center justify-between gap-2">
                                      <div className="flex items-center gap-1.5 text-xs font-bold text-[#A82822]">
                                        <AlertTriangle className="h-3.5 w-3.5 text-[#C2413B] shrink-0" />
                                        <span>{row.problemTitle}</span>
                                      </div>
                                      <span className="shrink-0 rounded-md bg-red-100/70 border border-red-200 px-2 py-0.5 text-[10px] font-bold text-[#A82822]">
                                        {row.problemTag}
                                      </span>
                                    </div>
                                    <p className="text-xs text-[#7A271A]/90 leading-relaxed">
                                      {row.problemDesc}
                                    </p>
                                  </div>
                                </td>

                                {/* BSG Enterprise Outcome Cell (Distinct Green Styling) */}
                                <td className="px-5 py-4 align-top bg-[var(--bg-card-hover)]/20">
                                  <div className="space-y-1.5">
                                    <div className="flex items-center justify-between gap-2">
                                      <div className="flex items-center gap-1.5 text-xs font-bold text-[var(--text-primary)]">
                                        <CheckCircle2 className="h-3.5 w-3.5 text-[#B49AFF] shrink-0" />
                                        <span>{row.outcomeTitle}</span>
                                      </div>
                                      <span className="shrink-0 rounded-full bg-[var(--border-subtle)] border border-[var(--border-color)] px-2.5 py-0.5 text-[10px] font-extrabold text-[#9475F5]">
                                        {row.impactBadge}
                                      </span>
                                    </div>
                                    <p className="text-xs text-[var(--text-primary)] leading-relaxed">
                                      {row.outcomeDesc}
                                    </p>
                                  </div>
                                </td>
                              </tr>
                            );
                          })}
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Conversion Banner */}
      <section className="relative overflow-hidden py-24 bg-gradient-to-b from-[#15102B] via-[#08523D] to-[#074734] text-white border-t border-[#0E6E50] border-b border-[#063423]">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,_var(--tw-gradient-stops))] from-[#B49AFF]/20 via-transparent to-transparent pointer-events-none" />
        <div className="relative mx-auto max-w-4xl px-4 text-center space-y-6">
          <h2 className="text-3xl font-black sm:text-5xl">
            Modernize Your Mandi Workflow in 24 Hours
          </h2>
          <p className="text-sm text-[#C4E2CF] max-w-xl mx-auto">
            Get your shop setup with commodity masters, electronic scale hooks, and mobile tablets.
          </p>
          <div className="pt-2 flex flex-wrap justify-center gap-4">
            <Link
              href="/register"
              className="rounded-xl bg-[#B49AFF] hover:bg-[#9475F5] px-7 py-3.5 text-sm font-bold text-white shadow-lg transition"
            >
              Start 30-Day Free Trial
            </Link>
            <Link
              href="/contact"
              className="rounded-xl border border-[#B49AFF]/40 bg-[var(--text-primary)] hover:bg-[#9475F5] px-7 py-3.5 text-sm font-bold text-white transition"
            >
              Schedule Mandi Consultation
            </Link>
          </div>
        </div>
      </section>

      <PublicFooter />
    </div>
  );
}
