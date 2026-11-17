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
    <div className="flex min-h-screen flex-col bg-[#F4FAF5] text-[#123B29] font-sans">
      <PublicNavbar />

      {/* Hero Header */}
      <section className="border-b border-[#CDE8D5] bg-gradient-to-b from-[#F4FAF5] to-[#E8F5EC] py-16 lg:py-24">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 text-center">
          <span className="text-xs font-bold uppercase tracking-widest text-[#087A50]">
            Transparent Subscriptions
          </span>
          <h1 className="mt-3 text-4xl font-black text-[#063D2E] sm:text-5xl lg:text-6xl tracking-tight">
            Simple, Predictable Plans for Every Mandi Shop
          </h1>
          <p className="mt-4 text-base sm:text-lg text-[#47785C] max-w-2xl mx-auto leading-relaxed">
            Every plan includes our strict multi-user license protection, digital bag weighment tables, and instant WhatsApp billing. Zero hidden commissions.
          </p>

          {/* Billing Cycle Toggle */}
          <div className="mt-10 flex items-center justify-center gap-3">
            <span className={`text-xs font-bold ${!annualBilling ? "text-[#063D2E]" : "text-[#71917B]"}`}>
              Monthly Billing
            </span>
            <button
              onClick={() => setAnnualBilling(!annualBilling)}
              className="relative h-7 w-12 rounded-full bg-[#087A50] transition-colors focus:outline-none"
              aria-label="Toggle annual billing"
            >
              <span
                className={`inline-block h-5 w-5 transform rounded-full bg-white transition-transform ${
                  annualBilling ? "translate-x-6" : "translate-x-1"
                }`}
              />
            </button>
            <span className={`text-xs font-bold ${annualBilling ? "text-[#063D2E]" : "text-[#71917B]"}`}>
              Annual Billing
            </span>
            <span className="rounded-full bg-[#DDF2E4] border border-[#CDE8D5] px-2.5 py-0.5 text-[10px] font-bold text-[#087A50]">
              Save 2 Months Free
            </span>
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
                      ? "border-2 border-[#10A66A] bg-white shadow-xl lg:-translate-y-2"
                      : "border border-[#CDE8D5] bg-[#F4FAF5] shadow-xs hover:border-[#10A66A]"
                  }`}
                >
                  {plan.popular && (
                    <div className="absolute -top-3.5 left-1/2 -translate-x-1/2 rounded-full bg-[#10A66A] px-4 py-1 text-[11px] font-extrabold uppercase tracking-wider text-white shadow-sm">
                      Recommended for Mandis
                    </div>
                  )}

                  <div>
                    <div className="space-y-1">
                      <h3 className="text-xl font-bold text-[#063D2E]">{plan.name}</h3>
                      <p className="text-xs text-[#47785C] min-h-[32px]">{plan.tagline}</p>
                    </div>

                    <div className="mt-6 flex items-baseline gap-1">
                      <span className="text-4xl font-black text-[#063D2E]">₹{price.toLocaleString("en-IN")}</span>
                      <span className="text-xs font-semibold text-[#71917B]">/ month</span>
                    </div>
                    {annualBilling && (
                      <p className="mt-1 text-[11px] font-semibold text-[#087A50]">
                        Billed annually at ₹{plan.annualPrice.toLocaleString("en-IN")} / year
                      </p>
                    )}

                    <div className="mt-8 space-y-3 border-t border-[#DCEEE1] pt-6">
                      <p className="text-xs font-bold uppercase tracking-wider text-[#47785C]">
                        Included Features
                      </p>
                      <ul className="space-y-2.5 text-xs text-[#123B29]">
                        {plan.features.map((f) => (
                          <li key={f} className="flex items-start gap-2.5">
                            <CheckCircle2 className="h-4 w-4 text-[#10A66A] shrink-0 mt-0.5" />
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
                          ? "bg-[#087A50] hover:bg-[#063D2E] text-white"
                          : "border border-[#CDE8D5] bg-white hover:bg-[#E8F5EC] text-[#063D2E]"
                      }`}
                    >
                      {plan.buttonLabel}
                    </Link>
                    <p className="mt-2 text-center text-[10px] text-[#71917B]">
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
      <section className="py-20 bg-white border-t border-[#CDE8D5]">
        <div className="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto mb-12">
            <h2 className="text-2xl sm:text-3xl font-bold text-[#063D2E]">
              Detailed Plan Capabilities Comparison
            </h2>
            <p className="mt-2 text-xs sm:text-sm text-[#47785C]">
              Compare all features and limits across the Starter, Professional, and Enterprise plans.
            </p>
          </div>

          <div className="overflow-x-auto rounded-2xl border border-[#CDE8D5]">
            <table className="w-full text-left text-xs">
              <thead className="bg-[#E8F5EC] text-[#063D2E] font-bold border-b border-[#CDE8D5]">
                <tr>
                  <th className="px-4 py-3">Platform Capability</th>
                  <th className="px-4 py-3 text-center">Starter</th>
                  <th className="px-4 py-3 text-center bg-[#DDF2E4]">Professional</th>
                  <th className="px-4 py-3 text-center">Enterprise</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#DCEEE1] text-[#123B29]">
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
                  <tr key={row.name} className="hover:bg-[#F4FAF5]">
                    <td className="px-4 py-3 font-semibold text-[#063D2E]">{row.name}</td>
                    <td className="px-4 py-3 text-center text-[#47785C]">{row.starter}</td>
                    <td className="px-4 py-3 text-center font-bold text-[#087A50] bg-[#DDF2E4]/40">{row.pro}</td>
                    <td className="px-4 py-3 text-center font-bold text-[#063D2E]">{row.ent}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="relative overflow-hidden py-24 bg-gradient-to-b from-[#0A503B] via-[#08523D] to-[#074734] text-white border-t border-[#0E6E50] border-b border-[#063423]">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,_var(--tw-gradient-stops))] from-[#10A66A]/20 via-transparent to-transparent pointer-events-none" />
        <div className="relative mx-auto max-w-4xl px-4 text-center space-y-6">
          <span className="text-xs font-bold uppercase tracking-widest text-[#10A66A]">
            Risk-Free Guarantee
          </span>
          <h2 className="text-3xl font-black sm:text-5xl">
            Test Drive BSG in Your Mandi for 30 Days
          </h2>
          <p className="text-sm text-[#C4E2CF] max-w-xl mx-auto">
            Experience the clarity of digital bag weighments, live smart charts, and daily cash tallies with full feature access.
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
