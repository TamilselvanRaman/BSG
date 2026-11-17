import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  ArrowRight,
  CheckCircle2,
  Database,
  Lock,
  Scale,
  ShieldCheck,
  Users,
  Zap,
} from "lucide-react";

export default function AboutPage() {
  return (
    <div className="flex min-h-screen flex-col bg-[#F4FAF5] text-[#123B29] font-sans">
      <PublicNavbar />

      {/* Header */}
      <section className="border-b border-[#CDE8D5] bg-gradient-to-b from-white via-[#F4FAF5] to-[#E8F5EC]/60 py-16 lg:py-20">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 text-center">
          <h1 className="mx-auto max-w-3xl text-3xl font-black text-[#063D2E] sm:text-4xl lg:text-5xl tracking-tight leading-tight">
            Building the Operating System for Agricultural Trade
          </h1>
          <p className="mt-4 text-sm sm:text-base text-[#47785C] max-w-2xl mx-auto leading-relaxed">
            BSG (Buyer Seller Goods) transforms traditional mandi operations into high-speed, verifiable digital commerce with zero math errors and complete financial audit integrity.
          </p>
        </div>
      </section>

      {/* Main Content */}
      <section className="py-20">
        <div className="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8 space-y-16">
          {/* Story & Background */}
          <div className="rounded-3xl border border-[#CDE8D5] bg-white p-8 lg:p-12 shadow-xs space-y-4">
            <h2 className="text-2xl font-bold text-[#063D2E]">
              Why We Built BSG
            </h2>
            <p className="text-sm text-[#47785C] leading-relaxed">
              Wholesale agricultural mandis are India's commercial lifeblood. Yet every day, commission agents and traders handle hundreds of handwritten slips, complex bag tare deductions, fast-paced auctions, and cash reconciliations late into the evening.
            </p>
            <p className="text-sm text-[#47785C] leading-relaxed">
              We engineered BSG directly from the mandi floor up. We studied how weighment operators write individual bag weights on cardboard, how auctioneers call out bids, and how cashiers balance physical notes against sales registers. Every feature in our software mirrors these operational conventions while automating the math, ledger balances, and WhatsApp dispatches.
            </p>
          </div>

          {/* 4 Core Engineering Principles */}
          <div>
            <h2 className="text-2xl font-black text-[#063D2E] text-center mb-8">
              Our Core Engineering Commitments
            </h2>
            <div className="grid gap-6 sm:grid-cols-2">
              <div className="rounded-2xl border border-[#CDE8D5] bg-white p-6 shadow-xs space-y-3">
                <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-[#E8F5EC] text-[#087A50]">
                  <Database className="h-5 w-5" />
                </div>
                <h3 className="text-lg font-bold text-[#063D2E]">ACID Financial Isolation</h3>
                <p className="text-xs text-[#47785C] leading-relaxed">
                  Every bill, payment, and inventory deduction executes within strict atomic database transactions. If a bill is cancelled, stock and ledger balances revert automatically with zero residue.
                </p>
              </div>

              <div className="rounded-2xl border border-[#CDE8D5] bg-white p-6 shadow-xs space-y-3">
                <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-[#E8F5EC] text-[#087A50]">
                  <Lock className="h-5 w-5" />
                </div>
                <h3 className="text-lg font-bold text-[#063D2E]">Multi-Tenant Zero-Leakage</h3>
                <p className="text-xs text-[#47785C] leading-relaxed">
                  Your shop's farmer lists, pricing rates, and profit ledgers are cryptographically shielded by unique tenant IDs. No competitor or outside party can ever view your trade data.
                </p>
              </div>

              <div className="rounded-2xl border border-[#CDE8D5] bg-white p-6 shadow-xs space-y-3">
                <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-[#E8F5EC] text-[#087A50]">
                  <Zap className="h-5 w-5" />
                </div>
                <h3 className="text-lg font-bold text-[#063D2E]">Zero Floor Downtime</h3>
                <p className="text-xs text-[#47785C] leading-relaxed">
                  Mandi auctions happen in seconds. Our mobile handhelds operate on local offline queues, ensuring you never halt weighment even when cell reception drops on the market floor.
                </p>
              </div>

              <div className="rounded-2xl border border-[#CDE8D5] bg-white p-6 shadow-xs space-y-3">
                <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-[#E8F5EC] text-[#087A50]">
                  <ShieldCheck className="h-5 w-5" />
                </div>
                <h3 className="text-lg font-bold text-[#063D2E]">Strict 3-User Seat Governance</h3>
                <p className="text-xs text-[#47785C] leading-relaxed">
                  Enforces authenticated operator seats (1 Store Admin + 2 Staff/Cashiers) with active concurrent session monitors to protect store owners from unauthorized access or password sharing.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="relative overflow-hidden py-24 bg-gradient-to-b from-[#0A503B] via-[#08523D] to-[#074734] text-white text-center border-t border-[#0E6E50] border-b border-[#063423]">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,_var(--tw-gradient-stops))] from-[#10A66A]/20 via-transparent to-transparent pointer-events-none" />
        <div className="relative mx-auto max-w-4xl px-4 space-y-6">
          <h2 className="text-3xl font-black sm:text-5xl">
            Ready to Digitize Your Mandi Operations?
          </h2>
          <p className="text-sm text-[#C4E2CF] max-w-xl mx-auto">
            Join hundreds of wholesale traders and APMC commission agents who trust BSG every morning.
          </p>
          <div className="pt-2">
            <Link
              href="/register"
              className="inline-flex items-center gap-2 rounded-xl bg-[#10A66A] hover:bg-[#087A50] px-7 py-3.5 text-sm font-bold text-white shadow-lg transition"
            >
              <span>Start 30-Day Free Trial</span>
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </div>
      </section>

      <PublicFooter />
    </div>
  );
}
