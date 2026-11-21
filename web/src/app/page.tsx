"use client";

import { useState } from "react";
import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  AlertTriangle,
  ArrowRight,
  Boxes,
  CheckCircle2,
  ChevronDown,
  Coins,
  Database,
  FileSpreadsheet,
  FileText,
  Key,
  Layers,
  Lock,
  PackagePlus,
  PhoneCall,
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

const PRODUCT_SHOWCASE_TABS = [
  {
    id: "inward",
    name: "Goods Inward",
    title: "Multi-Product Arrival Lots",
    desc: "Record farm vehicles arriving with multiple crops in a single entry with vehicle tracking, driver phone, and automated tare deduction.",
    preview: {
      lotCode: "LOT-CBE-2026-089",
      supplier: "Murugan Agro Farms (Pollachi)",
      vehicle: "TN 38 BK 9021 • Tata 407",
      items: [
        { crop: "Tomato Hybrid (Grade A)", gross: "2,450 kg", tare: "250 kg", net: "2,200 kg", bags: "44 Bags" },
        { crop: "Small Onion (Bellary Red)", gross: "1,890 kg", tare: "190 kg", net: "1,700 kg", bags: "34 Bags" },
        { crop: "Green Chilli (G4 Hot)", gross: "840 kg", tare: "80 kg", net: "760 kg", bags: "16 Bags" },
      ],
      totalGross: "5,180 kg",
      totalNet: "4,660 kg",
      status: "VERIFIED & UNLOADED",
    },
  },
  {
    id: "weighment",
    name: "Bag Weighment",
    title: "Bag-by-Bag Digital Scale",
    desc: "Direct electronic scale capture summing individual bag weights with numpad shortcuts, removing paper calculation slips entirely.",
    preview: {
      lotCode: "SCALE-WEIGH-042",
      buyer: "Sri Selvam Wholesale (Coimbatore)",
      rate: "₹42.50 / kg",
      bagsSample: [
        { b: "Bag #1", wt: "52.4 kg" },
        { b: "Bag #2", wt: "53.1 kg" },
        { b: "Bag #3", wt: "51.8 kg" },
        { b: "Bag #4", wt: "52.9 kg" },
        { b: "Bag #5", wt: "53.0 kg" },
        { b: "Bag #6", wt: "52.6 kg" },
      ],
      totalBags: "48 Bags",
      grossWeight: "2,532.0 kg",
      tareDeducted: "48.0 kg",
      billableNet: "2,484.0 kg",
      netValue: "₹1,05,570.00",
    },
  },
  {
    id: "auction",
    name: "Smart Chart",
    title: "Live Lot Split Auctions",
    desc: "Allot incoming lots across multiple wholesale buyers at different strike rates with zero stock slippage and live remaining counters.",
    preview: {
      commodity: "Tomato Hybrid • Lot #089",
      totalAvailable: "2,200 kg (44 Bags)",
      allotments: [
        { buyer: "K.R. Traders", bags: "16 Bags", rate: "₹44.00/kg", value: "₹35,200" },
        { buyer: "Velan Vegetables", bags: "18 Bags", rate: "₹43.50/kg", value: "₹39,150" },
        { buyer: "Star Fresh Retail", bags: "10 Bags", rate: "₹45.00/kg", value: "₹22,500" },
      ],
      balanceStock: "0 Bags (100% Cleared)",
      averageRate: "₹44.02 / kg",
    },
  },
  {
    id: "billing",
    name: "POS Billing",
    title: "High-Speed Cash & Credit Billing",
    desc: "Issue GST and Mandi bills in under 5 seconds with automatic coolie/hamali, RMC market cess, and previous balance carry-forward.",
    preview: {
      billNo: "INV-2026-1104",
      customer: "Balaji Fresh Mart • GSTIN: 33AAAAA9999Z1",
      goodsTotal: "₹48,920.00",
      coolieLabor: "+ ₹480.00 (₹10/bag)",
      mandiCess: "+ ₹489.20 (1.0% APMC)",
      previousBalance: "₹12,450.00",
      netPayable: "₹62,339.20",
      paymentMode: "CASH (₹50,000) + CREDIT (₹12,339.20)",
    },
  },
  {
    id: "cash",
    name: "Cash Drawer",
    title: "Daily Cash Tally & Drawer Balance",
    desc: "Evening currency counter with denomination verification (₹2000, ₹500, ₹200, ₹100, ₹50, coins) against system expected closing.",
    preview: {
      openingBalance: "₹25,000.00",
      todayCashSales: "₹1,84,500.00",
      customerReceipts: "₹45,000.00",
      pettyExpenses: "− ₹3,200.00",
      expectedClosing: "₹2,51,300.00",
      physicalCounted: "₹2,51,300.00",
      status: "PERFECT RECONCILIATION • ZERO SHORTAGE",
    },
  },
];

const WORKFLOW_STEPS = [
  {
    step: "01",
    title: "Register Your Mandi",
    desc: "Set up your market yard, business GSTIN, commission rates, and initial store administrator credentials in under 2 minutes.",
    tag: "Onboarding",
  },
  {
    step: "02",
    title: "Configure Your Business",
    desc: "Customize commodities, bag tare standards, labour/hamali charges, and local APMC market cess rules.",
    tag: "Configuration",
  },
  {
    step: "03",
    title: "Record Incoming Goods",
    desc: "Log farmer vehicle arrivals with multi-crop lots, gross weighment, and driver dispatch details at the gate.",
    tag: "Inward Gate",
  },
  {
    step: "04",
    title: "Manage Weighment",
    desc: "Capture bag-by-bag weights on electronic scales with instant sum, tare deduction, and floor operator verification.",
    tag: "Scale Weighment",
  },
  {
    step: "05",
    title: "Complete Trading & Billing",
    desc: "Conduct live auction splits, allot lots to buyers, and issue thermal or A4 cash and credit invoices instantly.",
    tag: "Auction & POS",
  },
  {
    step: "06",
    title: "Review Daily Performance",
    desc: "Tally physical cash drawer denominations, inspect buyer credit aging, and review gross commission profits.",
    tag: "Day-End Closing",
  },
];

const CHALLENGES_AND_SOLUTIONS = [
  {
    challenge: "Manual Paper Slips & Double Entry",
    pain: "Floor weighment scribbled on paper slips leads to calculation errors, misplaced records, and hours of night-time computer re-entry.",
    solution: "Instant Digital Multi-Product Lots",
    benefit: "Operators enter weights directly on handheld tablets or PC desks; inventory and bills generate instantaneously.",
    impact: "Zero Re-Entry Lag",
  },
  {
    challenge: "Bag Weight Sum & Tare Math Errors",
    pain: "Adding 50 individual bag weights manually during rushed morning auctions produces math discrepancies and buyer disputes.",
    solution: "Bag-by-Bag Digital Scale Calculator",
    benefit: "Enter bag weights into dedicated keyboard-friendly cells. Total bags, tare deductions, and net weight compute in milliseconds.",
    impact: "100% Scale Accuracy",
  },
  {
    challenge: "Paper Ledgers & Unsettled Advances",
    pain: "Tracking farmer advance deductions and wholesale buyer credits in traditional khata books leads to bad debts and delayed settlements.",
    solution: "ACID Double-Entry Partner Ledgers",
    benefit: "Real-time running balances for all farmers, buyers, and transporters with 1-click WhatsApp PDF statement dispatch.",
    impact: "Real-Time Balances",
  },
  {
    challenge: "Long Billing Queues at Yard Exit",
    pain: "Buyers waiting 20+ minutes at the counter for hand-written bills causes yard congestion and vehicle blockages.",
    solution: "High-Speed Cash & Credit POS Billing",
    benefit: "Generate itemized bills with Hamali, Coolie, and APMC cess in under 5 seconds with instant thermal receipt print.",
    impact: "< 5s Thermal Bills",
  },
  {
    challenge: "Evening Cash Drawer Discrepancies",
    pain: "Uncertainty whether actual physical currency matches sales receipts, UPI collections, and cash expenses at day end.",
    solution: "Evening Denomination Cash Tally",
    benefit: "Physical currency counter (₹500, ₹200, ₹100, ₹50, coins) reconciles against expected drawer balance with discrepancy audit logs.",
    impact: "Zero Cash Shortage",
  },
];

const CORE_MODULES = [
  {
    icon: PackagePlus,
    title: "1. Goods Inward Management",
    desc: "Single-entry capture for multi-commodity truck arrivals from farmers with gross, tare, and net traceability.",
  },
  {
    icon: Scale,
    title: "2. Weighment Management",
    desc: "Digital bag-by-bag weighment scale with auto-deductions, electronic scale hooks, and thermal print receipts.",
  },
  {
    icon: Layers,
    title: "3. Mandi Trading Operations",
    desc: "Smart Chart digital auction blackboard for allocating lots across multiple buyers at distinct strike prices.",
  },
  {
    icon: Boxes,
    title: "4. Inventory Management",
    desc: "Real-time stock balance tracking: Opening + Inward − Sales = Closing stock with shrinkage and lot margin analytics.",
  },
  {
    icon: FileText,
    title: "5. Billing & Invoicing",
    desc: "High-speed cash and credit bill generation with automatic cooling, coolie charges, and previous khata carry-over.",
  },
  {
    icon: Coins,
    title: "6. Cash & Financial Management",
    desc: "Daily cash drawer tally with currency denomination audit, GPay/UPI splits, and petty expense controls.",
  },
  {
    icon: FileSpreadsheet,
    title: "7. Reports & Analytics",
    desc: "Comprehensive APMC market fee returns, commodity price trends, commission ledger audits, and profit statements.",
  },
  {
    icon: UserCheck,
    title: "8. User & Device Management",
    desc: "Strict 3-seat license quota (1 Store Admin + 2 Staff/Cashiers) with active device session revocation controls.",
  },
];

const AUDIENCE_SOLUTIONS = [
  {
    title: "Agricultural Wholesale Traders",
    desc: "High-volume commodity merchants handling multiple truckloads of onions, potatoes, grains, and spices every morning.",
    highlights: ["Truckload multi-product entries", "Bulk weighbridge & bag scale hooks", "Instant credit ledger balances"],
  },
  {
    title: "APMC Commission Agents",
    desc: "Licensed mandi commission agents mediating sales between farmers and wholesale buyers under APMC regulations.",
    highlights: ["Automated APMC cess & commission", "Farmer advance deduction ledgers", "1-click WhatsApp bill dispatches"],
  },
  {
    title: "Fruit & Vegetable Mandis",
    desc: "High-speed morning vegetable and fruit auctions where perishability requires sub-second allotment and fast checkout.",
    highlights: ["Smart Chart live lot split auctions", "Individual bag tare calibration", "Evening cash drawer reconciliation"],
  },
  {
    title: "Mandi Enterprise Administrators",
    desc: "Business owners overseeing multi-operator yards, cashier desks, and weighment stations with zero tolerance for leakage.",
    highlights: ["Max 3 concurrent user enforcement", "Immutable audit trail logs", "Cloud & offline mobile handheld sync"],
  },
];

const FAQS = [
  {
    q: "How does the bag-by-bag weighment scale work?",
    a: "Operators enter each bag's weight directly into clean numerical cells (e.g. 52 kg, 53 kg, 51.5 kg). The platform sums total bags, calculates tare deductions, and produces net saleable weight in milliseconds.",
  },
  {
    q: "Can multiple cashiers and weighment operators log in simultaneously?",
    a: "Yes. Every BSG store workspace includes 3 authorized seats (1 Store Admin/Owner + 2 Staff/Cashier operators). The system enforces this at the session layer with active device monitors.",
  },
  {
    q: "Does the mobile application function when internet connection drops?",
    a: "Yes. The handheld Android application features offline-first local queueing. Operators can weigh bags and record arrivals continuously on the mandi floor, and records synchronize automatically once connectivity resumes.",
  },
  {
    q: "Can bills and ledger statements be shared directly via WhatsApp?",
    a: "Yes. With a single click, you can generate formatted bill PDFs and ledger balance statements and send them directly to the farmer or wholesale buyer's WhatsApp number.",
  },
  {
    q: "How does tenant data isolation work in BSG?",
    a: "Every mandi business operates within a dedicated, schema-isolated PostgreSQL database context. Business ledgers, pricing rates, and transaction records are cryptographically separated from other tenants.",
  },
];

export default function HomePage() {
  const [activeShowcase, setActiveShowcase] = useState("inward");
  const [openFaq, setOpenFaq] = useState<number | null>(0);

  const currentShowcase = PRODUCT_SHOWCASE_TABS.find((t) => t.id === activeShowcase) || PRODUCT_SHOWCASE_TABS[0];

  return (
    <div className="flex min-h-screen flex-col bg-[var(--bg-main)] text-[var(--text-primary)] font-sans">
      <PublicNavbar />

      {/* ============================================================
          1. HERO SECTION
         ============================================================ */}
      <section className="relative overflow-hidden border-b border-[var(--border-color)] bg-gradient-to-b from-[var(--bg-main)] via-[var(--bg-card-hover)]/60 to-[var(--border-subtle)]/40 pt-16 pb-20 lg:pt-24 lg:pb-28">
        <div className="relative mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="mx-auto max-w-3xl text-center">
            {/* Headline */}
            <h1 className="text-4xl font-black tracking-tight text-[var(--text-primary)] sm:text-5xl lg:text-6xl leading-[1.12]">
              Run Your Entire Goods Inward, Mandi Trade & Billing in{" "}
              <span className="text-[#B49AFF]">
                One BSG Platform
              </span>
            </h1>

            {/* Supporting Content */}
            <p className="mt-6 text-base sm:text-lg text-[var(--text-secondary)] leading-relaxed max-w-2xl mx-auto">
              The high-speed cloud platform designed specifically for wholesale agricultural traders, APMC commission agents, and fruit and vegetable mandis.
              Supports multi-crop arrivals, bag weighment tables, live auctions, and strict 3-user license controls.
            </p>

            {/* Primary & Secondary CTAs */}
            <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
              <Link
                href="/register"
                className="inline-flex items-center gap-2 rounded-xl bg-[#9475F5] hover:bg-[var(--text-primary)] px-6 py-3.5 text-sm font-bold text-white shadow-md hover:shadow-lg transition-all"
              >
                <span>Start 30-Day Free Trial</span>
                <ArrowRight className="h-4 w-4" />
              </Link>
              <Link
                href="/contact"
                className="inline-flex items-center gap-2 rounded-xl border border-[var(--border-color)] bg-[var(--bg-card-hover)] hover:bg-[var(--border-subtle)] px-6 py-3.5 text-sm font-bold text-[var(--text-primary)] transition-all"
              >
                <PhoneCall className="h-4 w-4 text-[#9475F5]" />
                <span>Request Mandi Demo</span>
              </Link>
            </div>

            {/* Trust Indicators */}
            <div className="mt-7 flex flex-wrap items-center justify-center gap-6 text-xs font-bold text-[var(--text-secondary)]">
              <span className="flex items-center gap-1.5">
                <CheckCircle2 className="h-4 w-4 text-[#B49AFF]" />
                30 Days Full Access
              </span>
              <span className="flex items-center gap-1.5">
                <CheckCircle2 className="h-4 w-4 text-[#B49AFF]" />
                Maximum 3 Login Seats
              </span>
              <span className="flex items-center gap-1.5">
                <CheckCircle2 className="h-4 w-4 text-[#B49AFF]" />
                Zero Setup Fee
              </span>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          2. REAL-TIME PLATFORM SCALE & OPERATIONAL BENCHMARKS (ANIMATED)
         ============================================================ */}
      <section className="relative py-20 bg-gradient-to-b from-white via-[var(--bg-main)]/80 to-white border-b border-[var(--border-color)] overflow-hidden">
        {/* Ambient Glowing Animated Background Orbs */}
        <div className="absolute top-12 left-10 w-96 h-96 bg-[#B49AFF]/10 rounded-full blur-3xl pointer-events-none animate-gentle-pulse" />
        <div className="absolute bottom-10 right-10 w-96 h-96 bg-[var(--border-color)]/40 rounded-full blur-3xl pointer-events-none animate-gentle-pulse" style={{ animationDelay: "2s" }} />

        <div className="relative mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          {/* Section Header */}
          <div className="text-center max-w-3xl mx-auto">
            <div className="inline-flex items-center gap-2 rounded-full border border-[var(--border-color)] bg-[var(--bg-card-hover)] px-3.5 py-1 text-xs font-bold text-[#9475F5] mb-4">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#B49AFF] opacity-75" />
                <span className="relative inline-flex rounded-full h-2 w-2 bg-[#B49AFF]" />
              </span>
              <span>LIVE MANDI OPERATIONAL TELEMETRY</span>
            </div>
            <h2 className="text-3xl font-black text-[var(--text-primary)] sm:text-4xl tracking-tight">
              Enterprise Scale Tested on Active Mandi Floors
            </h2>
            <p className="mt-3 text-sm text-[var(--text-secondary)] leading-relaxed">
              Handling intense 4:00 AM auction rush hours, bag-by-bag digital scale weighments, and millisecond ledger reconciliation with zero downtime.
            </p>
          </div>

          {/* Animated 4-Card Benchmark Grid */}
          <div className="mt-14 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {/* Card 1: Bags Weighed */}
            <div className="group relative rounded-2xl border border-[var(--border-color)] bg-white p-6 shadow-sm hover:shadow-xl hover:border-[#B49AFF] hover:-translate-y-2 transition-all duration-300 animate-subtle-float">
              <div className="flex items-center justify-between">
                <div className="h-11 w-11 rounded-xl bg-[var(--bg-card-hover)] text-[#9475F5] flex items-center justify-center group-hover:bg-[#B49AFF] group-hover:text-white transition-colors duration-300">
                  <Scale className="h-5 w-5" />
                </div>
                <span className="inline-flex items-center gap-1 rounded-full bg-[var(--bg-card-hover)] px-2.5 py-0.5 text-[10px] font-bold text-[#9475F5]">
                  <span className="h-1.5 w-1.5 rounded-full bg-[#B49AFF] animate-pulse" />
                  Live Weighment
                </span>
              </div>
              <div className="mt-5">
                <p className="text-4xl font-black text-[var(--text-primary)] tracking-tight group-hover:text-[#9475F5] transition-colors">
                  50K+
                </p>
                <p className="mt-1 text-sm font-bold text-[var(--text-primary)]">
                  Bags Weighed Daily
                </p>
                <p className="mt-2 text-xs text-[var(--text-secondary)] leading-relaxed">
                  Sub-second electronic scales sync individual bag weights directly to customer bills with auto-tare.
                </p>
              </div>
              <div className="mt-5 pt-4 border-t border-[#F0F7F2] flex items-center justify-between text-[11px] font-mono text-[#9475F5]">
                <span>Speed: &lt;1.2s / bag</span>
                <span className="font-bold">100% Verified</span>
              </div>
            </div>

            {/* Card 2: Mandi Turnover */}
            <div className="group relative rounded-2xl border border-[var(--border-color)] bg-white p-6 shadow-sm hover:shadow-xl hover:border-[#B49AFF] hover:-translate-y-2 transition-all duration-300 animate-subtle-float" style={{ animationDelay: "0.8s" }}>
              <div className="flex items-center justify-between">
                <div className="h-11 w-11 rounded-xl bg-[var(--bg-card-hover)] text-[#9475F5] flex items-center justify-center group-hover:bg-[#B49AFF] group-hover:text-white transition-colors duration-300">
                  <Coins className="h-5 w-5" />
                </div>
                <span className="inline-flex items-center gap-1 rounded-full bg-[var(--bg-card-hover)] px-2.5 py-0.5 text-[10px] font-bold text-[#9475F5]">
                  <span className="h-1.5 w-1.5 rounded-full bg-[#B49AFF] animate-pulse" />
                  Processed
                </span>
              </div>
              <div className="mt-5">
                <p className="text-4xl font-black text-[#9475F5] tracking-tight">
                  ₹150Cr+
                </p>
                <p className="mt-1 text-sm font-bold text-[var(--text-primary)]">
                  Mandi Turnover Processed
                </p>
                <p className="mt-2 text-xs text-[var(--text-secondary)] leading-relaxed">
                  Automated APMC commission, market yard cess, and coolie hamali calculated without manual calculation errors.
                </p>
              </div>
              <div className="mt-5 pt-4 border-t border-[#F0F7F2] flex items-center justify-between text-[11px] font-mono text-[#9475F5]">
                <span>Settlements: Same-day</span>
                <span className="font-bold">APMC Audited</span>
              </div>
            </div>

            {/* Card 3: ACID Ledger */}
            <div className="group relative rounded-2xl border border-[var(--border-color)] bg-white p-6 shadow-sm hover:shadow-xl hover:border-[#B49AFF] hover:-translate-y-2 transition-all duration-300 animate-subtle-float" style={{ animationDelay: "1.6s" }}>
              <div className="flex items-center justify-between">
                <div className="h-11 w-11 rounded-xl bg-[var(--bg-card-hover)] text-[#9475F5] flex items-center justify-center group-hover:bg-[#B49AFF] group-hover:text-white transition-colors duration-300">
                  <ShieldCheck className="h-5 w-5" />
                </div>
                <span className="inline-flex items-center gap-1 rounded-full bg-[var(--bg-card-hover)] px-2.5 py-0.5 text-[10px] font-bold text-[#9475F5]">
                  <span className="h-1.5 w-1.5 rounded-full bg-[#B49AFF] animate-pulse" />
                  Zero Discrepancy
                </span>
              </div>
              <div className="mt-5">
                <p className="text-4xl font-black text-[var(--text-primary)] tracking-tight group-hover:text-[#9475F5] transition-colors">
                  100%
                </p>
                <p className="mt-1 text-sm font-bold text-[var(--text-primary)]">
                  ACID Ledger Balance
                </p>
                <p className="mt-2 text-xs text-[var(--text-secondary)] leading-relaxed">
                  Cryptographic double-entry buyer/farmer khata balancing ensures every single rupee of credit is strictly accounted for.
                </p>
              </div>
              <div className="mt-5 pt-4 border-t border-[#F0F7F2] flex items-center justify-between text-[11px] font-mono text-[#9475F5]">
                <span>Khata: Cryptographic</span>
                <span className="font-bold">PostgreSQL ACID</span>
              </div>
            </div>

            {/* Card 4: Offline Floor Downtime */}
            <div className="group relative rounded-2xl border border-[var(--border-color)] bg-white p-6 shadow-sm hover:shadow-xl hover:border-[#B49AFF] hover:-translate-y-2 transition-all duration-300 animate-subtle-float" style={{ animationDelay: "2.4s" }}>
              <div className="flex items-center justify-between">
                <div className="h-11 w-11 rounded-xl bg-[var(--bg-card-hover)] text-[#B49AFF] flex items-center justify-center group-hover:bg-[#B49AFF] group-hover:text-white transition-colors duration-300">
                  <Zap className="h-5 w-5" />
                </div>
                <span className="inline-flex items-center gap-1 rounded-full bg-[var(--bg-card-hover)] px-2.5 py-0.5 text-[10px] font-bold text-[#B49AFF]">
                  <span className="h-1.5 w-1.5 rounded-full bg-[#B49AFF] animate-pulse" />
                  Local-First Engine
                </span>
              </div>
              <div className="mt-5">
                <p className="text-4xl font-black text-[#B49AFF] tracking-tight">
                  0 sec
                </p>
                <p className="mt-1 text-sm font-bold text-[var(--text-primary)]">
                  Offline Floor Downtime
                </p>
                <p className="mt-2 text-xs text-[var(--text-secondary)] leading-relaxed">
                  Android handhelds keep recording weights and printing Bluetooth bills even during complete internet or power outages.
                </p>
              </div>
              <div className="mt-5 pt-4 border-t border-[#F0F7F2] flex items-center justify-between text-[11px] font-mono text-[#B49AFF]">
                <span>Sync: Automatic</span>
                <span className="font-bold">Zero Data Loss</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          3. PRODUCT SHOWCASE (DEEP GREEN SECTION)
         ============================================================ */}
      <section className="py-20 bg-[var(--text-primary)] text-white border-b border-[#15102B]">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto">
            <h2 className="text-3xl font-black sm:text-4xl text-white">
              Purpose-Built for Mandi Floor Operations
            </h2>
            <p className="mt-3 text-sm text-[#C4E2CF]">
              Explore the exact workflows that power goods inward, electronic scale weighment, auction allotments, and counter billing.
            </p>
          </div>

          {/* Feature Switcher Tabs */}
          <div className="mt-10 flex flex-wrap items-center justify-center gap-2">
            {PRODUCT_SHOWCASE_TABS.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveShowcase(tab.id)}
                className={`rounded-xl px-4 py-2.5 text-xs font-bold transition-all ${
                  activeShowcase === tab.id
                    ? "bg-[#B49AFF] text-white shadow-md"
                    : "bg-[#15102B] text-[#C4E2CF] hover:bg-[#0E664C] hover:text-white"
                }`}
              >
                {tab.name}
              </button>
            ))}
          </div>

          {/* Interactive Screen Preview Box */}
          <div className="mt-8 rounded-3xl border border-[#0E664C] bg-[#15102B]/90 p-6 sm:p-8 shadow-2xl">
            <div className="grid gap-8 lg:grid-cols-12 items-center">
              <div className="lg:col-span-5 space-y-4">
                <span className="inline-block rounded-lg bg-[#B49AFF]/20 border border-[#B49AFF]/40 px-3 py-1 text-xs font-bold text-[#B49AFF]">
                  Active Module • {currentShowcase.name}
                </span>
                <h3 className="text-2xl font-bold text-white leading-snug">
                  {currentShowcase.title}
                </h3>
                <p className="text-xs text-[#C4E2CF] leading-relaxed">
                  {currentShowcase.desc}
                </p>
                <div className="pt-2">
                  <Link
                    href="/register"
                    className="inline-flex items-center gap-2 rounded-xl bg-[#B49AFF] px-4 py-2 text-xs font-bold text-white hover:bg-[#9475F5] transition"
                  >
                    <span>Try This in 30-Day Trial</span>
                    <ArrowRight className="h-3.5 w-3.5" />
                  </Link>
                </div>
              </div>

              {/* Data Representation Mockup */}
              <div className="lg:col-span-7 rounded-2xl border border-[#0E664C] bg-[var(--text-primary)] p-5 font-mono text-xs text-[#C4E2CF] shadow-inner space-y-3">
                <div className="flex items-center justify-between border-b border-[#15102B] pb-2 text-[11px] text-[var(--text-secondary)]">
                  <span>BSG MANDI OS • v1.1 TELEMETRY</span>
                  <span className="text-[#B49AFF] font-bold">LIVE PRODUCTION READY</span>
                </div>

                {activeShowcase === "inward" && (
                  <div className="space-y-2">
                    <div className="flex justify-between font-sans">
                      <span className="font-bold text-white">{currentShowcase.preview.lotCode}</span>
                      <span className="text-[#B49AFF] font-bold">{currentShowcase.preview.status}</span>
                    </div>
                    <p className="text-[11px] text-[#C4E2CF] font-sans">
                      Supplier: <strong className="text-white">{currentShowcase.preview.supplier}</strong> • {currentShowcase.preview.vehicle}
                    </p>
                    <div className="mt-3 divide-y divide-[#15102B] text-[11px]">
                      {(currentShowcase.preview as any).items?.map((it: any) => (
                        <div key={it.crop} className="py-1.5 flex justify-between">
                          <span className="text-white">{it.crop}</span>
                          <span>Gross: {it.gross} | Tare: {it.tare} | <strong>Net: {it.net} ({it.bags})</strong></span>
                        </div>
                      ))}
                    </div>
                    <div className="pt-2 flex justify-between font-bold text-white border-t border-[#15102B]">
                      <span>Total Truck Inward Net:</span>
                      <span className="text-[#B49AFF]">{currentShowcase.preview.totalNet}</span>
                    </div>
                  </div>
                )}

                {activeShowcase === "weighment" && (
                  <div className="space-y-2">
                    <div className="flex justify-between font-sans">
                      <span className="font-bold text-white">{currentShowcase.preview.lotCode}</span>
                      <span className="text-[#B49AFF] font-bold">Rate: {currentShowcase.preview.rate}</span>
                    </div>
                    <p className="text-[11px] text-[#C4E2CF] font-sans">
                      Buyer: <strong className="text-white">{currentShowcase.preview.buyer}</strong>
                    </p>
                    <div className="grid grid-cols-3 gap-2 my-2">
                      {(currentShowcase.preview as any).bagsSample?.map((bg: any) => (
                        <div key={bg.b} className="p-1.5 bg-[#15102B] rounded text-center">
                          <div className="text-[10px] text-[var(--text-secondary)]">{bg.b}</div>
                          <div className="font-bold text-white">{bg.wt}</div>
                        </div>
                      ))}
                    </div>
                    <div className="pt-2 flex justify-between text-[11px] border-t border-[#15102B]">
                      <span>Total: {currentShowcase.preview.totalBags} • Net: {currentShowcase.preview.billableNet}</span>
                      <span className="font-bold text-white">{currentShowcase.preview.netValue}</span>
                    </div>
                  </div>
                )}

                {activeShowcase === "auction" && (
                  <div className="space-y-2">
                    <div className="flex justify-between font-sans">
                      <span className="font-bold text-white">{currentShowcase.preview.commodity}</span>
                      <span className="text-[#B49AFF] font-bold">Avg: {currentShowcase.preview.averageRate}</span>
                    </div>
                    <div className="divide-y divide-[#15102B] text-[11px]">
                      {(currentShowcase.preview as any).allotments?.map((a: any) => (
                        <div key={a.buyer} className="py-1.5 flex justify-between">
                          <span className="text-white">{a.buyer}</span>
                          <span>{a.bags} @ {a.rate} = <strong className="text-white">{a.value}</strong></span>
                        </div>
                      ))}
                    </div>
                    <div className="pt-2 flex justify-between font-bold text-[#B49AFF] border-t border-[#15102B]">
                      <span>Remaining Stock:</span>
                      <span>{currentShowcase.preview.balanceStock}</span>
                    </div>
                  </div>
                )}

                {activeShowcase === "billing" && (
                  <div className="space-y-2">
                    <div className="flex justify-between font-sans">
                      <span className="font-bold text-white">{currentShowcase.preview.billNo}</span>
                      <span className="text-[#C4E2CF]">{currentShowcase.preview.customer}</span>
                    </div>
                    <div className="space-y-1 text-[11px] text-[#C4E2CF]">
                      <div className="flex justify-between"><span>Goods Sale Value:</span><span>{currentShowcase.preview.goodsTotal}</span></div>
                      <div className="flex justify-between"><span>Hamali / Coolie Labour:</span><span>{currentShowcase.preview.coolieLabor}</span></div>
                      <div className="flex justify-between"><span>APMC Mandi Cess:</span><span>{currentShowcase.preview.mandiCess}</span></div>
                      <div className="flex justify-between"><span>Previous Khata Balance:</span><span>{currentShowcase.preview.previousBalance}</span></div>
                    </div>
                    <div className="pt-2 flex justify-between font-bold text-white border-t border-[#15102B]">
                      <span>Net Settlement Payable:</span>
                      <span className="text-[#B49AFF]">{currentShowcase.preview.netPayable}</span>
                    </div>
                  </div>
                )}

                {activeShowcase === "cash" && (
                  <div className="space-y-2">
                    <div className="flex justify-between font-sans">
                      <span className="font-bold text-white">Evening Cash Drawer Audit</span>
                      <span className="text-[#B49AFF] font-bold">MATCHED</span>
                    </div>
                    <div className="space-y-1 text-[11px] text-[#C4E2CF]">
                      <div className="flex justify-between"><span>Opening Float:</span><span>{currentShowcase.preview.openingBalance}</span></div>
                      <div className="flex justify-between"><span>Today Counter Sales:</span><span>{currentShowcase.preview.todayCashSales}</span></div>
                      <div className="flex justify-between"><span>Credit Customer Collections:</span><span>{currentShowcase.preview.customerReceipts}</span></div>
                      <div className="flex justify-between"><span>Petty Yard Expenses:</span><span>{currentShowcase.preview.pettyExpenses}</span></div>
                    </div>
                    <div className="pt-2 flex justify-between font-bold text-white border-t border-[#15102B]">
                      <span>Physical Cash in Hand:</span>
                      <span className="text-[#B49AFF]">{currentShowcase.preview.physicalCounted}</span>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          3. BUSINESS CHALLENGES & SOLUTIONS
         ============================================================ */}
      <section className="py-20 bg-[var(--bg-main)] border-b border-[var(--border-color)]">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto">
            <h2 className="text-3xl font-black text-[var(--text-primary)] sm:text-4xl">
              Eliminate Mandi Inefficiencies with Real Technology
            </h2>
            <p className="mt-3 text-sm text-[var(--text-secondary)]">
              Compare common manual mandi friction points against verified BSG software capabilities.
            </p>
          </div>

          {/* Comparison Table: Problem vs Outcome */}
          <div className="mt-12 overflow-hidden rounded-2xl border border-[var(--border-color)] bg-white shadow-xs">
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse min-w-[720px]">
                <thead>
                  <tr className="border-b border-[var(--border-color)] bg-[var(--bg-main)]">
                    <th className="w-1/2 px-6 py-4 text-[11px] font-bold uppercase tracking-wider text-[#C2413B] bg-red-50/60 border-r border-[#F0D0CB]">
                      <div className="flex items-center gap-2">
                        <span className="h-2 w-2 rounded-full bg-[#C2413B]" />
                        <span>Traditional Mandi Bottleneck</span>
                      </div>
                    </th>
                    <th className="w-1/2 px-6 py-4 text-[11px] font-bold uppercase tracking-wider text-[#9475F5] bg-[var(--bg-card-hover)]/70">
                      <div className="flex items-center gap-2">
                        <span className="h-2 w-2 rounded-full bg-[#B49AFF]" />
                        <span>BSG Platform Verified Outcome</span>
                      </div>
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#DCEEE1]">
                  {CHALLENGES_AND_SOLUTIONS.map((row) => (
                    <tr key={row.challenge} className="hover:bg-[#F9FCFA] transition-colors">
                      {/* Left: Traditional Problem (Red/Coral Tint) */}
                      <td className="w-1/2 px-6 py-4 align-top bg-red-50/20 border-r border-[#F0D0CB]/60">
                        <div className="space-y-1.5">
                          <div className="flex items-center gap-1.5 text-xs font-bold text-[#A82822]">
                            <AlertTriangle className="h-3.5 w-3.5 text-[#C2413B] shrink-0" />
                            <span>{row.challenge}</span>
                          </div>
                          <p className="text-xs text-[#7A271A]/90 leading-relaxed">
                            {row.pain}
                          </p>
                        </div>
                      </td>

                      {/* Right: BSG Outcome (Emerald Green Tint) */}
                      <td className="w-1/2 px-6 py-4 align-top bg-[var(--bg-card-hover)]/20">
                        <div className="space-y-1.5">
                          <div className="flex items-center justify-between gap-2">
                            <div className="flex items-center gap-1.5 text-xs font-bold text-[var(--text-primary)]">
                              <CheckCircle2 className="h-3.5 w-3.5 text-[#B49AFF] shrink-0" />
                              <span>{row.solution}</span>
                            </div>
                            <span className="shrink-0 rounded-full bg-[var(--border-subtle)] border border-[var(--border-color)] px-2.5 py-0.5 text-[10px] font-extrabold text-[#9475F5]">
                              {row.impact}
                            </span>
                          </div>
                          <p className="text-xs text-[var(--text-primary)] leading-relaxed">
                            {row.benefit}
                          </p>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          4. CORE FEATURES (8 IMPLEMENTED CAPABILITIES)
         ============================================================ */}
      <section className="py-20 bg-[var(--bg-card-hover)]/50 border-b border-[var(--border-color)]">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto">
            <h2 className="text-3xl font-black text-[var(--text-primary)] sm:text-4xl">
              8 Core Mandi Management Modules
            </h2>
            <p className="mt-3 text-sm text-[var(--text-secondary)]">
              Every capability is integrated end-to-end with real database schemas and instant synchronization.
            </p>
          </div>

          <div className="mt-14 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {CORE_MODULES.map((m) => {
              const Icon = m.icon;
              return (
                <div
                  key={m.title}
                  className="rounded-2xl border border-[var(--border-color)] bg-white p-6 shadow-xs hover:border-[#B49AFF] hover:shadow-md transition-all group"
                >
                  <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-[var(--bg-card-hover)] text-[#9475F5] group-hover:bg-[#9475F5] group-hover:text-white transition-colors">
                    <Icon className="h-5 w-5" />
                  </div>
                  <h3 className="mt-4 text-base font-bold text-[var(--text-primary)]">
                    {m.title}
                  </h3>
                  <p className="mt-2 text-xs text-[var(--text-secondary)] leading-relaxed">
                    {m.desc}
                  </p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* ============================================================
          5. HOW BSG WORKS (6-STEP WORKFLOW)
         ============================================================ */}
      <section className="py-20 bg-white border-b border-[var(--border-color)]">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto">
            <h2 className="text-3xl font-black text-[var(--text-primary)] sm:text-4xl">
              From Shop Registration to Daily Closing
            </h2>
            <p className="mt-3 text-sm text-[var(--text-secondary)]">
              Six straightforward operational steps that bring complete transparency to wholesale market trading.
            </p>
          </div>

          <div className="mt-14 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {WORKFLOW_STEPS.map((s) => (
              <div
                key={s.step}
                className="rounded-2xl border border-[var(--border-color)] bg-[var(--bg-main)] p-6 space-y-3 relative hover:border-[#B49AFF] transition-all"
              >
                <div className="flex items-center justify-between">
                  <span className="text-3xl font-black text-[#9475F5]">
                    {s.step}
                  </span>
                  <span className="rounded-full bg-[var(--bg-card-hover)] border border-[var(--border-color)] px-2.5 py-0.5 text-[10px] font-bold text-[var(--text-primary)]">
                    {s.tag}
                  </span>
                </div>
                <h3 className="text-base font-bold text-[var(--text-primary)]">
                  {s.title}
                </h3>
                <p className="text-xs text-[var(--text-secondary)] leading-relaxed">
                  {s.desc}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ============================================================
          6. SOLUTIONS SECTION
         ============================================================ */}
      <section className="py-20 bg-[var(--bg-main)] border-b border-[var(--border-color)]">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto">
            <h2 className="text-3xl font-black text-[var(--text-primary)] sm:text-4xl">
              Tailored for Agricultural Wholesale Trades
            </h2>
            <p className="mt-3 text-sm text-[var(--text-secondary)]">
              Engineered to match the specific operating rituals of APMC mandis and private commodity yards.
            </p>
          </div>

          <div className="mt-14 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {AUDIENCE_SOLUTIONS.map((aud) => (
              <div
                key={aud.title}
                className="rounded-2xl border border-[var(--border-color)] bg-white p-6 shadow-xs flex flex-col justify-between hover:border-[#B49AFF] transition-all"
              >
                <div>
                  <h3 className="text-base font-bold text-[var(--text-primary)]">{aud.title}</h3>
                  <p className="mt-2 text-xs text-[var(--text-secondary)] leading-relaxed">{aud.desc}</p>
                  <ul className="mt-4 space-y-2 text-xs text-[var(--text-primary)]">
                    {aud.highlights.map((h) => (
                      <li key={h} className="flex items-center gap-2">
                        <CheckCircle2 className="h-3.5 w-3.5 text-[#B49AFF] shrink-0" />
                        <span>{h}</span>
                      </li>
                    ))}
                  </ul>
                </div>
                <div className="pt-6">
                  <Link
                    href="/solutions"
                    className="inline-flex items-center gap-1.5 text-xs font-bold text-[#9475F5] hover:text-[var(--text-primary)] transition"
                  >
                    <span>View Full Solution</span>
                    <ArrowRight className="h-3.5 w-3.5" />
                  </Link>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ============================================================
          7. SECURITY & RELIABILITY (DEEP FOREST GREEN)
         ============================================================ */}
      <section className="py-20 bg-[var(--text-primary)] text-white border-b border-[#15102B]">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto">
            <h2 className="text-3xl font-black sm:text-4xl text-white">
              Zero Compromise on Data Isolation & Security
            </h2>
            <p className="mt-3 text-sm text-[#C4E2CF]">
              Built with PostgreSQL schema-level isolation, strict device concurrency enforcement, and cryptographic licensing.
            </p>
          </div>

          <div className="mt-14 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {[
              {
                icon: Database,
                title: "PostgreSQL Schema Isolation",
                desc: "Every tenant shop operates in a separate database schema. Your sales bills, profit margins, and buyer ledgers are inaccessible to any other business.",
              },
              {
                icon: UserCheck,
                title: "Strict 3-Seat Concurrency",
                desc: "1 Store Admin + 2 Staff Cashier devices per shop license. Anti-credential sharing protection enforced at the backend session layer.",
              },
              {
                icon: ShieldCheck,
                title: "Cryptographic Licensing",
                desc: "SHA-256 verified digital certificates for each registered shop, preventing unlicensed runtime execution or seat spoofing.",
              },
              {
                icon: Lock,
                title: "Role-Based Access Control",
                desc: "Cashiers cannot alter historical commission rates or delete closed ledgers. Granular permission boundary checks protect owner profits.",
              },
              {
                icon: FileSpreadsheet,
                title: "Immutable Security Audit Logs",
                desc: "Every login, bill cancellation, session revocation, and price override records IP addresses, device names, and actor IDs permanently.",
              },
              {
                icon: Zap,
                title: "Automated Daily Backups",
                desc: "Nightly automated encrypted snapshots stored offsite with zero data loss recovery objectives for continuous business continuity.",
              },
            ].map((sec) => {
              const Icon = sec.icon;
              return (
                <div
                  key={sec.title}
                  className="rounded-2xl border border-[#15102B] bg-[#15102B]/70 p-6 space-y-3"
                >
                  <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[var(--text-primary)] text-[#B49AFF]">
                    <Icon className="h-5 w-5" />
                  </div>
                  <h3 className="text-base font-bold text-white">{sec.title}</h3>
                  <p className="text-xs text-[#C4E2CF] leading-relaxed">{sec.desc}</p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* ============================================================
          8. PRICING PREVIEW
         ============================================================ */}
      <section className="py-20 bg-white border-b border-[var(--border-color)]">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto">
            <h2 className="text-3xl font-black text-[var(--text-primary)] sm:text-4xl">
              Simple, Predictable Mandi Subscription Plans
            </h2>
            <p className="mt-3 text-sm text-[var(--text-secondary)]">
              30-day risk-free trial included with every plan. No hidden charges or commission cuts.
            </p>
          </div>

          <div className="mt-14 grid gap-6 md:grid-cols-3 max-w-5xl mx-auto">
            {/* Starter */}
            <div className="rounded-3xl border border-[var(--border-color)] bg-[var(--bg-main)] p-7 flex flex-col justify-between">
              <div>
                <span className="text-xs font-bold uppercase tracking-wider text-[var(--text-secondary)]">Starter Mandi</span>
                <div className="mt-3 text-3xl font-black text-[var(--text-primary)]">₹999 <span className="text-xs text-[var(--text-secondary)] font-normal">/ month</span></div>
                <p className="mt-2 text-xs text-[var(--text-secondary)]">Ideal for single-counter retail and small mandi traders.</p>
                <ul className="mt-6 space-y-2.5 text-xs text-[var(--text-primary)]">
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-4 w-4 text-[#B49AFF]" /> Up to 2 User Seats</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-4 w-4 text-[#B49AFF]" /> Multi-Product Inward Lots</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-4 w-4 text-[#B49AFF]" /> Digital Bag Weighment</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-4 w-4 text-[#B49AFF]" /> POS Cash & Credit Billing</li>
                </ul>
              </div>
              <div className="pt-8">
                <Link
                  href="/register"
                  className="block w-full text-center rounded-xl border border-[var(--border-color)] bg-white py-3 text-xs font-bold text-[var(--text-primary)] hover:bg-[var(--bg-card-hover)] transition"
                >
                  Start 30-Day Trial
                </Link>
              </div>
            </div>

            {/* Professional (Highlighted) */}
            <div className="rounded-3xl border-2 border-[#B49AFF] bg-white p-7 shadow-lg relative flex flex-col justify-between">
              <span className="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full bg-[#B49AFF] px-3 py-0.5 text-[10px] font-bold text-white uppercase tracking-wider">
                Most Popular
              </span>
              <div>
                <span className="text-xs font-bold uppercase tracking-wider text-[#9475F5]">Professional Mandi</span>
                <div className="mt-3 text-3xl font-black text-[var(--text-primary)]">₹1,999 <span className="text-xs text-[var(--text-secondary)] font-normal">/ month</span></div>
                <p className="mt-2 text-xs text-[var(--text-secondary)]">For established commission agents and high-volume mandis.</p>
                <ul className="mt-6 space-y-2.5 text-xs text-[var(--text-primary)]">
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-4 w-4 text-[#B49AFF]" /> Up to 3 User Seats (Admin + 2 Staff)</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-4 w-4 text-[#B49AFF]" /> Smart Chart Live Lot Auctions</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-4 w-4 text-[#B49AFF]" /> Evening Cash Drawer Tally</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-4 w-4 text-[#B49AFF]" /> Offline Android Mobile Sync</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-4 w-4 text-[#B49AFF]" /> WhatsApp 1-Click Statement Share</li>
                </ul>
              </div>
              <div className="pt-8">
                <Link
                  href="/register"
                  className="block w-full text-center rounded-xl bg-[#9475F5] hover:bg-[var(--text-primary)] py-3 text-xs font-bold text-white shadow transition"
                >
                  Start 30-Day Trial
                </Link>
              </div>
            </div>

            {/* Enterprise */}
            <div className="rounded-3xl border border-[var(--border-color)] bg-[var(--bg-main)] p-7 flex flex-col justify-between">
              <div>
                <span className="text-xs font-bold uppercase tracking-wider text-[var(--text-secondary)]">Enterprise Mandi</span>
                <div className="mt-3 text-3xl font-black text-[var(--text-primary)]">₹4,999 <span className="text-xs text-[var(--text-secondary)] font-normal">/ month</span></div>
                <p className="mt-2 text-xs text-[var(--text-secondary)]">For multi-floor mandi enterprises with custom seat needs.</p>
                <ul className="mt-6 space-y-2.5 text-xs text-[var(--text-primary)]">
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-4 w-4 text-[#B49AFF]" /> Up to 10 Concurrent Device Seats</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-4 w-4 text-[#B49AFF]" /> Dedicated APMC Cess Customization</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-4 w-4 text-[#B49AFF]" /> Priority Dedicated Support Engineer</li>
                  <li className="flex items-center gap-2"><CheckCircle2 className="h-4 w-4 text-[#B49AFF]" /> Custom Electronic Weighbridge Hooks</li>
                </ul>
              </div>
              <div className="pt-8">
                <Link
                  href="/contact"
                  className="block w-full text-center rounded-xl border border-[var(--border-color)] bg-white py-3 text-xs font-bold text-[var(--text-primary)] hover:bg-[var(--bg-card-hover)] transition"
                >
                  Contact Enterprise Sales
                </Link>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          9. FAQ ACCORDIONS
         ============================================================ */}
      <section className="py-20 bg-[var(--bg-main)] border-b border-[var(--border-color)]">
        <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto">
            <h2 className="text-3xl font-black text-[var(--text-primary)] sm:text-4xl">
              Everything You Need to Know
            </h2>
          </div>

          <div className="mt-12 space-y-3">
            {FAQS.map((faq, idx) => {
              const isOpen = openFaq === idx;
              return (
                <div
                  key={faq.q}
                  className="rounded-2xl border border-[var(--border-color)] bg-white overflow-hidden transition-all"
                >
                  <button
                    onClick={() => setOpenFaq(isOpen ? null : idx)}
                    className="w-full flex items-center justify-between p-5 text-left text-sm font-bold text-[var(--text-primary)] hover:bg-[var(--bg-card-hover)]/50 transition"
                  >
                    <span>{faq.q}</span>
                    <ChevronDown className={`h-4 w-4 text-[#9475F5] transition-transform ${isOpen ? "rotate-180" : ""}`} />
                  </button>
                  {isOpen && (
                    <div className="px-5 pb-5 text-xs text-[var(--text-secondary)] leading-relaxed border-t border-[#DCEEE1] pt-3">
                      {faq.a}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* ============================================================
          10. FINAL CTA (RICH FOREST-EMERALD GRADIENT SECTION)
         ============================================================ */}
      <section className="relative overflow-hidden py-24 bg-gradient-to-b from-[#15102B] via-[#08523D] to-[#074734] text-white border-t border-[#0E6E50] border-b border-[#063423]">
        {/* Subtle radial emerald glow */}
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,_var(--tw-gradient-stops))] from-[#B49AFF]/20 via-transparent to-transparent pointer-events-none" />
        <div className="relative mx-auto max-w-4xl px-4 text-center space-y-6">
          <h2 className="text-3xl font-black sm:text-5xl leading-tight">
            Bring Your Entire Mandi Operation Into One Platform.
          </h2>
          <p className="text-sm text-[#C4E2CF] max-w-2xl mx-auto leading-relaxed">
            Experience digital bag weighment, live smart chart auctions, and evening cash drawer tallies with strict cryptographic multi-tenant isolation.
          </p>
          <div className="pt-2 flex flex-wrap items-center justify-center gap-4">
            <Link
              href="/register"
              className="inline-flex items-center gap-2 rounded-xl bg-[#B49AFF] hover:bg-[#9475F5] px-7 py-3.5 text-sm font-bold text-white shadow-lg transition"
            >
              <span>Start 30-Day Free Trial</span>
              <ArrowRight className="h-4 w-4" />
            </Link>
            <Link
              href="/login"
              className="inline-flex items-center gap-2 rounded-xl border border-[#B49AFF]/40 bg-[var(--text-primary)] hover:bg-[#9475F5] px-7 py-3.5 text-sm font-bold text-white transition"
            >
              <span>Sign In to Workspace</span>
            </Link>
          </div>
        </div>
      </section>

      <PublicFooter />
    </div>
  );
}
