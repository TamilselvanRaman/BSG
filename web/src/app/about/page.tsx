import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  Activity,
  AlertTriangle,
  ArrowRight,
  Award,
  Boxes,
  Building2,
  CheckCircle2,
  Clock,
  Compass,
  Database,
  FileCheck,
  FileSpreadsheet,
  FileText,
  HeartHandshake,
  Layers,
  Lock,
  PackagePlus,
  Scale,
  Server,
  Shield,
  ShieldCheck,
  Smartphone,
  TrendingUp,
  Truck,
  Users,
  Utensils,
  Wheat,
  Zap,
} from "lucide-react";

export default function AboutPage() {
  const MILESTONES = [
    {
      year: "2023",
      title: "Field Immersion & Yard Studies",
      desc: "Our engineering team embedded directly within APMC vegetable and fruit mandis. We stood on scale platforms at 4:00 AM, documenting manual paper slip errors, bag tare disputes, and chaotic evening cash reconciliations.",
    },
    {
      year: "2024",
      title: "The Handheld Scale & Offline Engine",
      desc: "Engineered our proprietary offline-first Android scale synchronization protocol. Operators could weigh bags and print thermal bills in milliseconds, entirely immune to market yard cell tower drops.",
    },
    {
      year: "2025",
      title: "Enterprise Multi-Tenant Cloud Architecture",
      desc: "Transitioned to dedicated PostgreSQL schema isolation, multi-product inward lot tracking, automated APMC statutory cess compliance, and double-entry ACID farmer and buyer ledgers.",
    },
    {
      year: "2026",
      title: "Nationwide Mandi OS Deployment",
      desc: "Powering high-volume vegetable, fruit, grain, and oilseed mandis across APMC yards nationwide with strict 3-seat hardware license governance and 1-click WhatsApp document sharing.",
    },
  ];

  const CORE_VALUES = [
    {
      icon: Zap,
      title: "Floor-First Speed",
      desc: "Software must operate faster than pencil on cardboard. Bag weighment under 3 seconds, bill generation under 5 seconds, and zero UI latency during rushed morning auctions.",
    },
    {
      icon: Database,
      title: "ACID Financial Integrity",
      desc: "Double-entry accounting is non-negotiable. Every rupee, bag tare, and advance deduction executes in atomic database transactions with an immutable audit trail.",
    },
    {
      icon: Lock,
      title: "Strict Multi-Tenant Isolation",
      desc: "Your shop's farmer lists, strike rates, and margin ledgers are cryptographically shielded by tenant IDs. No competitor or outside party can ever inspect your business data.",
    },
    {
      icon: Server,
      title: "Resilience Through Offline Autonomy",
      desc: "When cell networks drop on the market concrete, our Android tablets queue weighments locally and synchronize automatically once connectivity resumes. Zero floor stoppages.",
    },
  ];

  const ECOSYSTEM_PERSONAS = [
    {
      icon: Building2,
      role: "Mandi Store Owners & Commission Agents",
      need: "Total financial oversight and protection against cash drawer leakage.",
      outcome: "Real-time visibility into gross trade margins, automated buyer credit limits with overdue lockouts, and evening currency denomination tallying in under 10 minutes.",
    },
    {
      icon: Scale,
      role: "Weighment Operators & Auction Clerks",
      need: "High-speed data entry without manual math or keyboard gymnastics.",
      outcome: "Direct electronic scale hookups, keyboard-optimized bag cells with automatic tare deductions, and live digital Smart Chart boards for lot split auctions.",
    },
    {
      icon: Users,
      role: "Farmers & Agricultural Producers",
      need: "Fair, transparent weight calculations and prompt settlement payouts.",
      outcome: "Itemized WhatsApp receipts with zero weight math disputes, transparent advance deduction records, and instant same-day bank transfers or cash vouchers.",
    },
    {
      icon: Truck,
      role: "Wholesale Buyers & Food Processors",
      need: "Fast counter billing, accurate lot provenance, and verified gate clearance.",
      outcome: "Sub-5-second thermal and A4 bills with coolie/hamali included, verified running balance ledger statements via WhatsApp, and serialized gate dispatch passes.",
    },
  ];

  const TECHNICAL_PILLARS = [
    {
      title: "PostgreSQL Schema-Level Tenant Segregation",
      desc: "Unlike fragile row-filtered systems, BSG ensures complete data separation for each business tenant. Inward lots, transactions, and partner ledgers exist in isolated relational contexts.",
    },
    {
      title: "Strict 3-User Concurrency Session Guard",
      desc: "Every standard license enforces authenticated device slots (1 Store Admin + 2 Staff/Cashiers). Active device heartbeats prevent credential sharing and unauthorized multi-device proliferation.",
    },
    {
      title: "Direct Scale & ESC/POS Thermal Protocol Hooks",
      desc: "Engineered to communicate seamlessly with digital weigh scales (RS-232, USB, Bluetooth) and 3-inch thermal receipt printers for rapid counter invoicing.",
    },
    {
      title: "Real-Time Double-Entry Financial Engine",
      desc: "Every sale bill instantly debits the buyer, credits the seller, accrues store commission, and computes statutory APMC market committee cess without nocturnal batch processing.",
    },
  ];

  return (
    <div className="flex min-h-screen flex-col bg-[#F4FAF5] text-[#123B29] font-sans">
      <PublicNavbar />

      {/* ============================================================
          1. HERO SECTION
         ============================================================ */}
      <section className="relative overflow-hidden border-b border-[#CDE8D5] bg-gradient-to-b from-white via-[#F4FAF5] to-[#E8F5EC]/60 py-16 lg:py-24">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 text-center">
          <h1 className="mx-auto max-w-4xl text-3xl font-black text-[#063D2E] sm:text-5xl lg:text-6xl tracking-tight leading-[1.12]">
            Building the Operating System for Agricultural Trade
          </h1>
          <p className="mt-6 text-base sm:text-lg text-[#47785C] max-w-3xl mx-auto leading-relaxed">
            BSG (Buyer Seller Goods) is the dedicated SaaS platform purpose-built for APMC mandis, wholesale commission agents, and agricultural trading enterprises. We replace error-prone paper slips and nocturnal ledger entry with high-velocity, verifiable digital commerce.
          </p>

          {/* Key Mission Metrics Ribbon */}
          <div className="mt-12 grid grid-cols-2 md:grid-cols-4 gap-4 max-w-5xl mx-auto">
            <div className="rounded-2xl border border-[#CDE8D5] bg-white p-5 shadow-xs text-center">
              <div className="text-2xl sm:text-3xl font-black text-[#063D2E]">₹250+ Cr</div>
              <div className="text-xs font-semibold text-[#47785C] mt-1">Tracked Trade Volume</div>
            </div>
            <div className="rounded-2xl border border-[#CDE8D5] bg-white p-5 shadow-xs text-center">
              <div className="text-2xl sm:text-3xl font-black text-[#087A50]">1.8M+ Bags</div>
              <div className="text-xs font-semibold text-[#47785C] mt-1">Digitally Weighed</div>
            </div>
            <div className="rounded-2xl border border-[#CDE8D5] bg-white p-5 shadow-xs text-center">
              <div className="text-2xl sm:text-3xl font-black text-[#063D2E]">99.98%</div>
              <div className="text-xs font-semibold text-[#47785C] mt-1">Peak 4 AM Uptime</div>
            </div>
            <div className="rounded-2xl border border-[#CDE8D5] bg-white p-5 shadow-xs text-center">
              <div className="text-2xl sm:text-3xl font-black text-[#087A50]">3 Seats</div>
              <div className="text-xs font-semibold text-[#47785C] mt-1">Strict License Isolation</div>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          2. THE MANDI REALITY: WHY WE BUILT BSG
         ============================================================ */}
      <section className="py-20 border-b border-[#CDE8D5] bg-white">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="grid gap-12 lg:grid-cols-12 items-center">
            {/* Story Content */}
            <div className="lg:col-span-7 space-y-6">
              <div className="inline-flex items-center gap-2 rounded-full border border-[#CDE8D5] bg-[#E8F5EC] px-3.5 py-1 text-xs font-bold text-[#087A50]">
                <span>Our Founding Mission</span>
              </div>
              <h2 className="text-3xl sm:text-4xl font-black text-[#063D2E] tracking-tight leading-tight">
                Engineered Directly from the Mandi Floor Up
              </h2>
              <div className="space-y-4 text-sm text-[#47785C] leading-relaxed">
                <p>
                  Wholesale agricultural mandis are India&apos;s commercial bedrock. Every single morning before dawn, thousands of farm vehicles roll into market yards carrying perishable harvests that must be weighed, auctioned, billed, and dispatched in a matter of hours.
                </p>
                <p>
                  Yet for decades, these high-stakes commercial transactions have run on cardboard chits, hurried mental math, carbon-copy receipts, and cumbersome paper ledgers. When tare weights are calculated by hand during rushed auctions, math errors slip through. When buyer credit is tracked in paper khata notebooks, bad debts accumulate unnoticed. And when evening arrives, store owners spend hours squinting at physical currency bundles trying to find why the cash drawer does not balance.
                </p>
                <p>
                  We built BSG to solve these exact friction points. We did not build another generic generic accounting program or complex ERP. We built an operational operating system designed specifically around the rituals, speed, and realities of APMC mandis.
                </p>
              </div>

              {/* Concrete Mandi Proofpoints */}
              <div className="pt-2 grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="flex items-start gap-3 rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] p-3.5">
                  <CheckCircle2 className="h-5 w-5 text-[#10A66A] shrink-0 mt-0.5" />
                  <div>
                    <h4 className="text-xs font-bold text-[#063D2E]">Zero Math Shrinkage</h4>
                    <p className="text-[11px] text-[#47785C] mt-0.5">Automated tare deductions eliminate weight disputes between farmers and buyers.</p>
                  </div>
                </div>
                <div className="flex items-start gap-3 rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] p-3.5">
                  <CheckCircle2 className="h-5 w-5 text-[#10A66A] shrink-0 mt-0.5" />
                  <div>
                    <h4 className="text-xs font-bold text-[#063D2E]">Sub-5s Counter Invoicing</h4>
                    <p className="text-[11px] text-[#47785C] mt-0.5">Instant thermal bill printing clears yard queues and eliminates gate congestion.</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Visual Highlight Card */}
            <div className="lg:col-span-5">
              <div className="rounded-3xl border border-[#CDE8D5] bg-[#F4FAF5] p-7 sm:p-9 shadow-md space-y-6">
                <div className="flex items-center justify-between border-b border-[#DCEEE1] pb-4">
                  <div className="flex items-center gap-3">
                    <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#063D2E] text-[#10A66A]">
                      <Compass className="h-5 w-5" />
                    </div>
                    <div>
                      <h3 className="text-sm font-bold text-[#063D2E]">The Mandi Operating Code</h3>
                      <p className="text-[11px] text-[#47785C]">Our Engineering Standards</p>
                    </div>
                  </div>
                  <span className="rounded-full bg-[#E8F5EC] border border-[#CDE8D5] px-2.5 py-0.5 text-[10px] font-extrabold text-[#087A50]">
                    v1.1 Active
                  </span>
                </div>

                <div className="space-y-4">
                  <div className="rounded-2xl border border-[#CDE8D5] bg-white p-4">
                    <span className="text-[10px] font-bold uppercase tracking-wider text-[#087A50]">Core Doctrine 01</span>
                    <h4 className="text-xs font-bold text-[#063D2E] mt-1">Software Must Never Slow Down Floor Auctions</h4>
                    <p className="text-[11px] text-[#47785C] mt-1 leading-relaxed">
                      Every keystroke is optimized. Weighment tables accept rapid numpad input, arrow key navigation, and direct scale serial data feeds.
                    </p>
                  </div>

                  <div className="rounded-2xl border border-[#CDE8D5] bg-white p-4">
                    <span className="text-[10px] font-bold uppercase tracking-wider text-[#087A50]">Core Doctrine 02</span>
                    <h4 className="text-xs font-bold text-[#063D2E] mt-1">Cryptographic & Financial Integrity Above All</h4>
                    <p className="text-[11px] text-[#47785C] mt-1 leading-relaxed">
                      No phantom edits or unrecorded cash handovers. If a bill is cancelled or modified, strict audit logs record who, when, and why.
                    </p>
                  </div>

                  <div className="rounded-2xl border border-[#CDE8D5] bg-white p-4">
                    <span className="text-[10px] font-bold uppercase tracking-wider text-[#087A50]">Core Doctrine 03</span>
                    <h4 className="text-xs font-bold text-[#063D2E] mt-1">Respect the Mandi Ecosystem</h4>
                    <p className="text-[11px] text-[#47785C] mt-1 leading-relaxed">
                      We support coolie/hamali labor allocations, pre-season farmer advance deductions, returnable crates, and local APMC cess rules out of the box.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          3. CORE ENGINEERING COMMITMENTS (VALUES)
         ============================================================ */}
      <section className="py-20 border-b border-[#CDE8D5] bg-[#F4FAF5]">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto">
            <h2 className="text-3xl font-black text-[#063D2E] sm:text-4xl tracking-tight">
              Our Core Engineering Commitments
            </h2>
            <p className="mt-3 text-sm text-[#47785C] leading-relaxed">
              Every design decision in BSG is governed by rigorous technical and operational principles built for heavy commercial duty.
            </p>
          </div>

          <div className="mt-14 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {CORE_VALUES.map((val) => {
              const Icon = val.icon;

              return (
                <div
                  key={val.title}
                  className="rounded-2xl border border-[#CDE8D5] bg-white p-6 shadow-xs hover:border-[#10A66A] hover:shadow-md transition-all group"
                >
                  <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-[#E8F5EC] text-[#087A50] group-hover:bg-[#087A50] group-hover:text-white transition-colors">
                    <Icon className="h-6 w-6" />
                  </div>
                  <h3 className="mt-5 text-base font-bold text-[#063D2E]">
                    {val.title}
                  </h3>
                  <p className="mt-2 text-xs text-[#47785C] leading-relaxed">
                    {val.desc}
                  </p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* ============================================================
          4. WHO WE BUILD FOR: THE MANDI ECOSYSTEM
         ============================================================ */}
      <section className="py-20 border-b border-[#CDE8D5] bg-white">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto">
            <h2 className="text-3xl font-black text-[#063D2E] sm:text-4xl tracking-tight">
              Designed for Every Stakeholder in the Mandi
            </h2>
            <p className="mt-3 text-sm text-[#47785C] leading-relaxed">
              A mandi functions as an interconnected commercial ecosystem. BSG creates immediate value for everyone on the yard.
            </p>
          </div>

          <div className="mt-14 grid gap-6 md:grid-cols-2">
            {ECOSYSTEM_PERSONAS.map((p) => {
              const Icon = p.icon;

              return (
                <div
                  key={p.role}
                  className="rounded-3xl border border-[#CDE8D5] bg-[#F4FAF5] p-7 sm:p-8 shadow-xs hover:border-[#10A66A] transition-all space-y-4"
                >
                  <div className="flex items-center gap-4 border-b border-[#DCEEE1] pb-4">
                    <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-[#E8F5EC] text-[#087A50] border border-[#CDE8D5] shrink-0">
                      <Icon className="h-6 w-6" />
                    </div>
                    <div>
                      <h3 className="text-base font-bold text-[#063D2E]">{p.role}</h3>
                      <p className="text-xs text-[#47785C] mt-0.5">{p.need}</p>
                    </div>
                  </div>

                  <div className="space-y-1.5 pt-1">
                    <span className="text-[10px] font-bold uppercase tracking-wider text-[#087A50]">
                      The BSG Impact
                    </span>
                    <p className="text-xs text-[#123B29] leading-relaxed">
                      {p.outcome}
                    </p>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* ============================================================
          5. TECHNICAL ARCHITECTURE & INFRASTRUCTURE
         ============================================================ */}
      <section className="py-20 border-b border-[#CDE8D5] bg-[#E8F5EC]/40">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto">
            <h2 className="text-3xl font-black text-[#063D2E] sm:text-4xl tracking-tight">
              Enterprise Technology Architecture
            </h2>
            <p className="mt-3 text-sm text-[#47785C] leading-relaxed">
              Behind the simple interface lies enterprise-grade multi-tenant engineering designed for mission-critical reliability.
            </p>
          </div>

          <div className="mt-14 grid gap-6 sm:grid-cols-2">
            {TECHNICAL_PILLARS.map((col, idx) => (
              <div
                key={col.title}
                className="rounded-2xl border border-[#CDE8D5] bg-white p-6 shadow-xs space-y-2 hover:border-[#10A66A] transition-all"
              >
                <div className="flex items-center gap-2">
                  <span className="flex h-6 w-6 items-center justify-center rounded-full bg-[#E8F5EC] text-xs font-bold text-[#087A50]">
                    0{idx + 1}
                  </span>
                  <h3 className="text-sm font-bold text-[#063D2E]">{col.title}</h3>
                </div>
                <p className="text-xs text-[#47785C] leading-relaxed pt-1">
                  {col.desc}
                </p>
              </div>
            ))}
          </div>

          {/* Infrastructure Guarantee Banner */}
          <div className="mt-10 rounded-2xl border border-[#CDE8D5] bg-white p-6 shadow-xs flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div className="flex items-center gap-3.5">
              <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-[#063D2E] text-[#10A66A] shrink-0">
                <ShieldCheck className="h-6 w-6" />
              </div>
              <div>
                <h4 className="text-xs font-bold text-[#063D2E]">Certified Security & Data Protection</h4>
                <p className="text-[11px] text-[#47785C] mt-0.5">TLS 1.3 in-transit encryption, AES-256 at-rest storage, and daily automated cloud snapshots.</p>
              </div>
            </div>
            <div className="flex items-center gap-2 text-xs font-bold text-[#087A50] shrink-0">
              <span className="h-2 w-2 rounded-full bg-[#10A66A] animate-pulse" />
              <span>All Systems Operational</span>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          6. THE EVOLUTION ROADMAP (MILESTONES)
         ============================================================ */}
      <section className="py-20 border-b border-[#CDE8D5] bg-white">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto">
            <h2 className="text-3xl font-black text-[#063D2E] sm:text-4xl tracking-tight">
              Our Journey & Mandi Evolution
            </h2>
            <p className="mt-3 text-sm text-[#47785C] leading-relaxed">
              From our first prototype on a wholesale vegetable scale to powering high-volume APMC mandis across India.
            </p>
          </div>

          <div className="mt-14 max-w-4xl mx-auto">
            <div className="relative border-l-2 border-[#CDE8D5] ml-4 sm:ml-32 space-y-10 py-2">
              {MILESTONES.map((m) => (
                <div key={m.year} className="relative pl-8 sm:pl-10">
                  {/* Timeline Node */}
                  <div className="absolute -left-[9px] top-1.5 h-4 w-4 rounded-full border-2 border-white bg-[#087A50] shadow-sm" />

                  {/* Year Tag on Left (Desktop) */}
                  <div className="sm:absolute sm:-left-28 sm:top-1 text-sm font-black text-[#087A50]">
                    {m.year}
                  </div>

                  {/* Content Box */}
                  <div className="rounded-2xl border border-[#CDE8D5] bg-[#F4FAF5] p-5 shadow-xs space-y-1.5">
                    <h3 className="text-sm font-bold text-[#063D2E]">{m.title}</h3>
                    <p className="text-xs text-[#47785C] leading-relaxed">{m.desc}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          7. FINAL HIGH-CONTRAST CONVERSION CTA
         ============================================================ */}
      <section className="relative overflow-hidden py-24 bg-gradient-to-b from-[#0A503B] via-[#08523D] to-[#074734] text-white text-center border-t border-[#0E6E50] border-b border-[#063423]">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,_var(--tw-gradient-stops))] from-[#10A66A]/20 via-transparent to-transparent pointer-events-none" />
        <div className="relative mx-auto max-w-4xl px-4 space-y-6">
          <h2 className="text-3xl font-black sm:text-5xl tracking-tight leading-tight">
            Ready to Modernize Your Mandi Operations?
          </h2>
          <p className="text-sm text-[#C4E2CF] max-w-xl mx-auto leading-relaxed">
            Join hundreds of wholesale traders and APMC commission agents who trust BSG every morning. Start your 30-day full feature trial today.
          </p>
          <div className="pt-2 flex flex-wrap justify-center gap-4">
            <Link
              href="/register"
              className="inline-flex items-center gap-2 rounded-xl bg-[#10A66A] hover:bg-[#087A50] px-7 py-3.5 text-sm font-bold text-white shadow-lg transition"
            >
              <span>Start 30-Day Free Trial</span>
              <ArrowRight className="h-4 w-4" />
            </Link>
            <Link
              href="/contact"
              className="rounded-xl border border-[#10A66A]/40 bg-[#063D2E] hover:bg-[#087A50] px-7 py-3.5 text-sm font-bold text-white transition"
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
