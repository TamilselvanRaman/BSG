import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  ArrowRight,
  CheckCircle2,
  Cpu,
  Database,
  Lock,
  Scale,
  Server,
  ShieldCheck,
  Sparkles,
  Users,
  Zap,
} from "lucide-react";

export default function AboutPage() {
  return (
    <div className="flex min-h-screen flex-col bg-slate-50">
      <PublicNavbar />

      {/* Header */}
      <section className="border-b border-slate-200/80 bg-white py-16 lg:py-24">
        <div className="mx-auto max-w-7xl px-6 text-center">
          <span className="inline-flex items-center gap-1.5 rounded-full bg-blue-50 border border-blue-200 px-3.5 py-1 text-xs font-bold text-blue-700">
            <Sparkles className="h-3.5 w-3.5" />
            Engineering Mission & Mandi Architecture
          </span>
          <h1 className="mt-5 text-4xl font-black text-slate-900 sm:text-5xl lg:text-6xl tracking-tight">
            Building the Operating System for Agricultural Trade
          </h1>
          <p className="mt-4 text-base sm:text-lg text-slate-600 max-w-2xl mx-auto leading-relaxed">
            BSG (Buyer Seller Goods) transforms traditional mandi chaos into high-speed, verifiable digital commerce with zero math errors and complete financial audit integrity.
          </p>
        </div>
      </section>

      {/* Main Content */}
      <section className="py-20">
        <div className="mx-auto max-w-5xl px-6 space-y-16">
          {/* Story & Background */}
          <div className="rounded-3xl border border-slate-200 bg-white p-8 lg:p-12 shadow-sm space-y-4">
            <h2 className="text-2xl font-bold text-slate-900">
              Why We Built BSG
            </h2>
            <p className="text-sm text-slate-600 leading-relaxed">
              Wholesale agricultural mandis are India's economic lifeblood. Yet every day, commission agents and traders juggle hundreds of handwritten slips, complex bag tare deductions, fast auctions, and cash reconciliations late into the night.
            </p>
            <p className="text-sm text-slate-600 leading-relaxed">
              We engineered BSG from the mandi floor up. We observed how weighment operators write bag weights on pieces of cardboard, how auctioneers call out bids, and how cashiers balance physical notes against sales registers. Every feature in our software mirrors these exact rituals while automating the math, ledger balances, and WhatsApp dispatch.
            </p>
          </div>

          {/* 4 Core Engineering Principles */}
          <div>
            <h2 className="text-2xl font-black text-slate-900 text-center mb-8">
              Our Core Engineering Commitments
            </h2>
            <div className="grid gap-6 sm:grid-cols-2">
              <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm space-y-3">
                <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-blue-100 text-blue-700">
                  <Database className="h-6 w-6" />
                </div>
                <h3 className="text-lg font-bold text-slate-900">ACID Financial Isolation</h3>
                <p className="text-xs text-slate-600 leading-relaxed">
                  Every bill, payment, and inventory deduction runs in strict atomic database transactions. If a bill is cancelled, stock and ledger balances revert automatically with zero residue.
                </p>
              </div>

              <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm space-y-3">
                <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-indigo-100 text-indigo-700">
                  <Lock className="h-6 w-6" />
                </div>
                <h3 className="text-lg font-bold text-slate-900">Multi-Tenant Zero-Leakage</h3>
                <p className="text-xs text-slate-600 leading-relaxed">
                  Your shop's farmer lists, pricing rates, and profit ledgers are cryptographically shielded by unique tenant IDs. No competitor or outside party can ever view your trade data.
                </p>
              </div>

              <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm space-y-3">
                <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-emerald-100 text-emerald-700">
                  <Zap className="h-6 w-6" />
                </div>
                <h3 className="text-lg font-bold text-slate-900">Zero Floor Downtime</h3>
                <p className="text-xs text-slate-600 leading-relaxed">
                  Mandi auctions happen in seconds. Our mobile handhelds operate on local offline queues, ensuring you never halt weighment even when cell reception drops on the market floor.
                </p>
              </div>

              <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm space-y-3">
                <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-amber-100 text-amber-700">
                  <ShieldCheck className="h-6 w-6" />
                </div>
                <h3 className="text-lg font-bold text-slate-900">Strict 3-User Seat Governance</h3>
                <p className="text-xs text-slate-600 leading-relaxed">
                  Enforces authenticated operator seats (1 Store Admin + 2 Staff/Cashiers) with active concurrent session monitors to protect store owners from unauthorized access or password sharing.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-20 bg-slate-900 text-white text-center border-t border-slate-800">
        <div className="mx-auto max-w-4xl px-6 space-y-6">
          <h2 className="text-3xl font-black sm:text-4xl">
            Partner With India's Leading Mandi OS
          </h2>
          <p className="text-sm text-slate-400 max-w-xl mx-auto">
            Experience our 30-day free trial on Web and Android mobile handhelds.
          </p>
          <div className="pt-2">
            <Link
              href="/register"
              className="inline-flex items-center gap-2 rounded-xl bg-blue-600 px-7 py-3 text-sm font-bold text-white shadow-lg hover:bg-blue-700 transition"
            >
              <span>Start Free Trial</span>
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </div>
      </section>

      <PublicFooter />
    </div>
  );
}
