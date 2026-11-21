"use client";

import { useState } from "react";
import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  ArrowRight,
  CheckCircle2,
  HelpCircle,
  PhoneCall,
  ShieldCheck,
  Zap,
} from "lucide-react";

export default function PricingPage() {
  const [annualBilling, setAnnualBilling] = useState(true);

  const PLANS = [
    {
      id: "STARTER",
      name: "Starter Mandi",
      tagline: "Essential digital scale billing & ledgers for single commission shops",
      monthlyPrice: 999,
      annualPrice: 9990,
      popular: false,
      features: [
        "Up to 2 User Seats (1 Admin + 1 Staff)",
        "Multi-Product Inward Lot Arrival",
        "Bag-by-Bag Weighment Scale Billing",
        "Instant Cash & Credit Sales Bills",
        "Daily Cash Tally & Drawer Balance",
        "Buyer & Seller Double-Entry Ledgers",
        "A4 & 3-Inch Thermal Receipt Printing",
        "WhatsApp Bill PDF Sharing",
        "Standard Email & Phone Support",
      ],
      buttonLabel: "Start 30-Day Free Trial",
    },
    {
      id: "PROFESSIONAL",
      name: "Professional Mandi Suite",
      tagline: "Full-speed auctions & offline handheld mobility for busy mandi merchants",
      monthlyPrice: 1999,
      annualPrice: 19990,
      popular: true,
      features: [
        "Up to 3 User Seats (1 Admin + 2 Staff)",
        "Everything in Starter Mandi, plus:",
        "Smart Chart Live Auction & Bidding Board",
        "Offline-First Android Handheld Sync",
        "Automatic Pre-Season Farmer Advance Deductions",
        "Currency Denomination Counter Breakdown",
        "Gross Profit & Margin Analysis by Lot",
        "APMC RMC Market Cess & Tax Reports",
        "Daily Truck Inward & Outward Summary",
        "Priority 30-Minute WhatsApp Helpline",
      ],
      buttonLabel: "Start 30-Day Free Trial",
    },
    {
      id: "ENTERPRISE",
      name: "Enterprise Multi-Branch",
      tagline: "Custom integrations, dedicated servers & high-volume mandi corporations",
      monthlyPrice: 4999,
      annualPrice: 49990,
      popular: false,
      features: [
        "Up to 10 Concurrent Device Seats",
        "Multi-Branch & Inter-Mandi Transfers",
        "Dedicated Database Schema & Custom Backups",
        "Weighbridge Digital Serial Port Integration",
        "Custom APMC Cess / Market Tax Templates",
        "Automated Daily Financial Audits",
        "Dedicated Account Manager & Onsite Training",
        "99.95% Guaranteed Uptime SLA",
      ],
      buttonLabel: "Contact Enterprise Sales",
    },
  ];

  return (
    <div className="flex min-h-screen flex-col bg-[var(--bg-main)] text-[var(--text-primary)] font-sans">
      <PublicNavbar />

      {/* Hero Header */}
      <section className="border-b border-[var(--border-color)] bg-gradient-to-b from-white via-[var(--bg-main)] to-[var(--bg-card-hover)]/60 py-16 lg:py-20">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 text-center">
          <h1 className="mx-auto max-w-3xl text-3xl font-black text-[var(--text-primary)] sm:text-4xl lg:text-5xl tracking-tight leading-tight">
            Simple, Predictable Plans for Every Mandi Business
          </h1>
          <p className="mt-4 text-sm sm:text-base text-[var(--text-secondary)] max-w-2xl mx-auto leading-relaxed">
            Every plan includes our strict multi-user license protection, digital bag weighment tables, and instant WhatsApp billing. Zero hidden commissions.
          </p>

          {/* Billing Cycle Segmented Control */}
          <div className="mt-8 flex flex-col items-center justify-center gap-4">
            <div className="inline-flex items-center rounded-full border border-[var(--border-color)] bg-white p-1.5 shadow-xs">
              <button
                type="button"
                onClick={() => setAnnualBilling(false)}
                className={`rounded-full px-5 py-2 text-xs font-bold transition-all ${
                  !annualBilling
                    ? "bg-[#9475F5] text-white shadow-xs"
                    : "text-[var(--text-secondary)] hover:text-[var(--text-primary)]"
                }`}
              >
                Monthly Billing
              </button>
              <button
                type="button"
                onClick={() => setAnnualBilling(true)}
                className={`rounded-full px-5 py-2 text-xs font-bold transition-all flex items-center gap-2 ${
                  annualBilling
                    ? "bg-[#9475F5] text-white shadow-xs"
                    : "text-[var(--text-secondary)] hover:text-[var(--text-primary)]"
                }`}
              >
                <span>Annual Billing</span>
                <span
                  className={`rounded-full px-2 py-0.5 text-[10px] font-extrabold tracking-wide ${
                    annualBilling
                      ? "bg-[var(--text-primary)] text-[var(--border-subtle)]"
                      : "bg-[var(--bg-card-hover)] text-[#9475F5]"
                  }`}
                >
                  Save 20%
                </span>
              </button>
            </div>

            <div className="flex flex-wrap items-center justify-center gap-5 text-xs font-semibold text-[var(--text-secondary)]">
              <span className="flex items-center gap-1.5">
                <CheckCircle2 className="h-3.5 w-3.5 text-[#B49AFF]" />
                30-Day Free Trial
              </span>
              <span className="flex items-center gap-1.5">
                <CheckCircle2 className="h-3.5 w-3.5 text-[#B49AFF]" />
                No Credit Card Required
              </span>
              <span className="flex items-center gap-1.5">
                <CheckCircle2 className="h-3.5 w-3.5 text-[#B49AFF]" />
                3-Seat License Included
              </span>
            </div>
          </div>
        </div>
      </section>

      {/* Pricing Cards */}
      <section className="py-20">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="grid gap-8 lg:grid-cols-3 max-w-6xl mx-auto">
            {PLANS.map((plan) => {
              const price = annualBilling ? Math.round(plan.annualPrice / 12) : plan.monthlyPrice;

              return (
                <div
                  key={plan.id}
                  className={`relative flex flex-col justify-between rounded-3xl p-8 sm:p-9 transition-all ${
                    plan.popular
                      ? "border-2 border-[#B49AFF] bg-white shadow-xl lg:-translate-y-2"
                      : "border border-[var(--border-color)] bg-[var(--bg-main)] shadow-xs hover:border-[#B49AFF]"
                  }`}
                >
                  {plan.popular && (
                    <div className="absolute -top-3.5 left-1/2 -translate-x-1/2 rounded-full bg-[#B49AFF] px-4 py-1 text-[11px] font-extrabold uppercase tracking-wider text-white shadow-sm">
                      Recommended for Mandis
                    </div>
                  )}

                  <div>
                    <div className="space-y-1">
                      <h3 className="text-xl font-bold text-[var(--text-primary)]">{plan.name}</h3>
                      <p className="text-xs text-[var(--text-secondary)] min-h-[32px]">{plan.tagline}</p>
                    </div>

                    <div className="mt-6 flex items-baseline gap-1">
                      <span className="text-4xl font-black text-[var(--text-primary)]">₹{price.toLocaleString("en-IN")}</span>
                      <span className="text-xs font-semibold text-[var(--text-secondary)]">/ month</span>
                    </div>
                    {annualBilling && (
                      <p className="mt-1 text-[11px] font-semibold text-[#9475F5]">
                        Billed annually at ₹{plan.annualPrice.toLocaleString("en-IN")} / year
                      </p>
                    )}

                    <div className="mt-8 space-y-3 border-t border-[#DCEEE1] pt-6">
                      <p className="text-xs font-bold uppercase tracking-wider text-[var(--text-secondary)]">
                        Included Features
                      </p>
                      <ul className="space-y-2.5 text-xs text-[var(--text-primary)]">
                        {plan.features.map((f) => (
                          <li key={f} className="flex items-start gap-2.5">
                            <CheckCircle2 className="h-4 w-4 text-[#B49AFF] shrink-0 mt-0.5" />
                            <span>{f}</span>
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>

                  <div className="mt-10 pt-6 border-t border-[#DCEEE1]">
                    <Link
                      href={plan.id === "ENTERPRISE" ? "/contact" : "/register"}
                      className={`block w-full text-center rounded-xl py-3 text-xs font-bold transition shadow-xs ${
                        plan.popular
                          ? "bg-[#9475F5] hover:bg-[var(--text-primary)] text-white"
                          : "border border-[var(--border-color)] bg-white hover:bg-[var(--bg-card-hover)] text-[var(--text-primary)]"
                      }`}
                    >
                      {plan.buttonLabel}
                    </Link>
                    <p className="mt-2 text-center text-[10px] text-[var(--text-secondary)]">
                      {plan.id === "ENTERPRISE" ? "Custom multi-branch quote" : "30-day free trial • No credit card required"}
                    </p>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Feature Comparison Matrix */}
      <section className="py-20 bg-white border-t border-[var(--border-color)]">
        <div className="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto mb-12">
            <h2 className="text-2xl sm:text-3xl font-bold text-[var(--text-primary)]">
              Detailed Plan Capabilities Comparison
            </h2>
            <p className="mt-2 text-xs sm:text-sm text-[var(--text-secondary)]">
              Compare all features and limits across the Starter, Professional, and Enterprise plans.
            </p>
          </div>

          <div className="overflow-x-auto rounded-2xl border border-[var(--border-color)]">
            <table className="w-full text-left text-xs">
              <thead className="bg-[var(--bg-card-hover)] text-[var(--text-primary)] font-bold border-b border-[var(--border-color)]">
                <tr>
                  <th className="px-4 py-3">Platform Capability</th>
                  <th className="px-4 py-3 text-center">Starter</th>
                  <th className="px-4 py-3 text-center bg-[var(--border-subtle)]">Professional</th>
                  <th className="px-4 py-3 text-center">Enterprise</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#DCEEE1] text-[var(--text-primary)]">
                {[
                  { name: "Concurrent User Seats", starter: "2 Seats", pro: "3 Seats", ent: "Up to 10 Seats" },
                  { name: "Multi-Product Inward Lots", starter: "Yes", pro: "Yes", ent: "Yes" },
                  { name: "Bag Weighment Digital Scale", starter: "Yes", pro: "Yes", ent: "Yes" },
                  { name: "POS Cash & Credit Bills", starter: "Yes", pro: "Yes", ent: "Yes" },
                  { name: "Daily Cash Tally & Drawer", starter: "Yes", pro: "Yes", ent: "Yes" },
                  { name: "Double-Entry ACID Ledgers", starter: "Yes", pro: "Yes", ent: "Yes" },
                  { name: "Smart Chart Live Auctions", starter: "—", pro: "Yes", ent: "Yes" },
                  { name: "Offline Android Mobile Sync", starter: "—", pro: "Yes", ent: "Yes" },
                  { name: "Farmer Pre-Season Advances", starter: "—", pro: "Yes", ent: "Yes" },
                  { name: "Weighbridge Serial Hook", starter: "—", pro: "—", ent: "Yes" },
                  { name: "Database Context", starter: "Schema Isolated", pro: "Schema Isolated", ent: "Dedicated Schema / DB" },
                ].map((row) => (
                  <tr key={row.name} className="hover:bg-[var(--bg-main)]">
                    <td className="px-4 py-3 font-semibold text-[var(--text-primary)]">{row.name}</td>
                    <td className="px-4 py-3 text-center text-[var(--text-secondary)]">{row.starter}</td>
                    <td className="px-4 py-3 text-center font-bold text-[#9475F5] bg-[var(--border-subtle)]/40">{row.pro}</td>
                    <td className="px-4 py-3 text-center font-bold text-[var(--text-primary)]">{row.ent}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="relative overflow-hidden py-24 bg-gradient-to-b from-[#15102B] via-[#08523D] to-[#074734] text-white border-t border-[#0E6E50] border-b border-[#063423]">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,_var(--tw-gradient-stops))] from-[#B49AFF]/20 via-transparent to-transparent pointer-events-none" />
        <div className="relative mx-auto max-w-4xl px-4 text-center space-y-6">
          <h2 className="text-3xl font-black sm:text-5xl">
            Test Drive BSG in Your Mandi for 30 Days
          </h2>
          <p className="text-sm text-[#C4E2CF] max-w-xl mx-auto">
            Experience the clarity of digital bag weighments, live smart charts, and daily cash tallies with full feature access.
          </p>
          <div className="pt-2">
            <Link
              href="/register"
              className="inline-flex items-center gap-2 rounded-xl bg-[#B49AFF] hover:bg-[#9475F5] px-7 py-3.5 text-sm font-bold text-white shadow-lg transition"
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
