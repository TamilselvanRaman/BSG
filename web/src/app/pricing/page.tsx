"use client";

import { useState } from "react";
import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  ArrowRight,
  Check,
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
      monthlyPrice: 1499,
      annualPrice: 14990,
      popular: false,
      features: [
        "Up to 3 Login Users (1 Admin + 2 Staff)",
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
      monthlyPrice: 2999,
      annualPrice: 29990,
      popular: true,
      features: [
        "Up to 3 Login Users (1 Admin + 2 Staff)",
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
      monthlyPrice: 5999,
      annualPrice: 59990,
      popular: false,
      features: [
        "Custom User Seat Capacity (Multi-Staff)",
        "Multi-Branch & Inter-Mandi Transfers",
        "Dedicated Database Instance & Custom Backups",
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
    <div className="flex min-h-screen flex-col bg-slate-50">
      <PublicNavbar />

      {/* Hero Header */}
      <section className="border-b border-slate-200/80 bg-white py-16 lg:py-24">
        <div className="mx-auto max-w-7xl px-6 text-center">
          <h1 className="text-4xl font-black text-slate-900 sm:text-5xl lg:text-6xl tracking-tight">
            Simple, Predictable Plans for Every Mandi Shop
          </h1>
          <p className="mt-4 text-base sm:text-lg text-slate-600 max-w-2xl mx-auto leading-relaxed">
            Every plan includes our strict 3-user license protection, multi-product weighment tables, and instant WhatsApp billing. No surprise transaction fees.
          </p>

          {/* Billing Cycle Toggle */}
          <div className="mt-10 flex items-center justify-center gap-3">
            <span className={`text-xs font-bold ${!annualBilling ? "text-slate-900" : "text-slate-500"}`}>
              Monthly Billing
            </span>
            <button
              onClick={() => setAnnualBilling(!annualBilling)}
              className="relative inline-flex h-6 w-12 shrink-0 cursor-pointer rounded-full border-2 border-transparent bg-slate-900 transition-colors duration-200 ease-in-out"
            >
              <span
                className={`pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${
                  annualBilling ? "translate-x-6" : "translate-x-0"
                }`}
              />
            </button>
            <span className={`text-xs font-bold flex items-center gap-1.5 ${annualBilling ? "text-slate-900" : "text-slate-500"}`}>
              <span>Annual Billing</span>
              <span className="rounded-full bg-emerald-100 text-emerald-800 text-[10px] font-extrabold px-2 py-0.5">
                Save 20%
              </span>
            </span>
          </div>
        </div>
      </section>

      {/* Pricing Cards Grid */}
      <section className="py-20">
        <div className="mx-auto max-w-7xl px-6">
          <div className="grid gap-8 lg:grid-cols-3 items-stretch">
            {PLANS.map((plan) => {
              const price = annualBilling
                ? Math.round(plan.annualPrice / 12)
                : plan.monthlyPrice;

              return (
                <div
                  key={plan.id}
                  className={`relative flex flex-col justify-between rounded-3xl p-8 transition-all ${
                    plan.popular
                      ? "border-2 border-emerald-600 bg-white shadow-xl shadow-emerald-600/10 lg:-translate-y-2"
                      : "border border-slate-200 bg-white shadow-sm hover:shadow-md"
                  }`}
                >
                  {plan.popular && (
                    <div className="absolute -top-3.5 left-1/2 -translate-x-1/2 rounded-full bg-gradient-to-r from-emerald-600 to-teal-700 px-4 py-1 text-[11px] font-extrabold text-white shadow-md uppercase tracking-wider">
                      Most Popular in Mandis
                    </div>
                  )}

                  <div>
                    <h3 className="text-xl font-bold text-slate-900">{plan.name}</h3>
                    <p className="mt-2 text-xs text-slate-500 leading-relaxed min-h-[36px]">
                      {plan.tagline}
                    </p>

                    <div className="mt-6 flex items-baseline gap-1">
                      <span className="text-4xl font-black text-slate-900">
                        ₹{price.toLocaleString()}
                      </span>
                      <span className="text-xs font-semibold text-slate-500">/ month</span>
                    </div>
                    <p className="text-[11px] text-slate-400 mt-1">
                      {annualBilling
                        ? `Billed ₹${plan.annualPrice.toLocaleString()} annually`
                        : "Billed monthly"}
                    </p>

                    <div className="my-8 border-t border-slate-100" />

                    <div className="space-y-3 text-xs">
                      {plan.features.map((feat) => (
                        <div key={feat} className="flex items-start gap-2.5 text-slate-700">
                          <Check className="h-4 w-4 text-emerald-600 shrink-0 mt-0.5" />
                          <span>{feat}</span>
                        </div>
                      ))}
                    </div>
                  </div>

                  <div className="mt-8 pt-4">
                    {plan.id === "ENTERPRISE" ? (
                      <Link
                        href="/contact"
                        className="w-full flex items-center justify-center gap-2 rounded-xl border border-slate-300 py-3 text-xs font-bold text-slate-800 hover:bg-slate-50 transition"
                      >
                        <PhoneCall className="h-3.5 w-3.5 text-emerald-600" />
                        <span>{plan.buttonLabel}</span>
                      </Link>
                    ) : (
                      <Link
                        href="/register"
                        className={`w-full flex items-center justify-center gap-2 rounded-xl py-3 text-xs font-bold transition shadow-sm ${
                          plan.popular
                            ? "bg-gradient-to-r from-emerald-600 to-teal-700 text-white hover:from-emerald-700 hover:to-teal-800 shadow-emerald-600/20"
                            : "bg-slate-900 text-white hover:bg-slate-800"
                        }`}
                      >
                        <span>{plan.buttonLabel}</span>
                        <ArrowRight className="h-3.5 w-3.5" />
                      </Link>
                    )}
                  </div>
                </div>
              );
            })}
          </div>

          {/* Guarantee Pill */}
          <div className="mt-14 mx-auto max-w-xl rounded-2xl border border-slate-200 bg-white p-5 text-center shadow-sm">
            <div className="flex items-center justify-center gap-2 text-xs font-bold text-slate-800">
              <ShieldCheck className="h-4 w-4 text-emerald-600" />
              <span>30-Day Risk-Free Evaluation Period</span>
            </div>
            <p className="mt-1 text-xs text-slate-500">
              Try the full Mandi OS suite with your actual daily arrivals, weighments, and bills for 30 days. No credit card required to begin.
            </p>
          </div>
        </div>
      </section>

      {/* Comparison Matrix */}
      <section className="py-20 bg-white border-t border-slate-200">
        <div className="mx-auto max-w-5xl px-6">
          <div className="text-center max-w-2xl mx-auto">
            <h2 className="text-3xl font-black text-slate-900">Feature Comparison Matrix</h2>
            <p className="mt-2 text-sm text-slate-600">
              Compare capabilities across Starter, Professional, and Enterprise plans.
            </p>
          </div>

          <div className="mt-12 overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="border-b border-slate-200 bg-slate-50 uppercase tracking-wider text-[11px] text-slate-600">
                <tr>
                  <th className="p-4 font-bold">Feature Capability</th>
                  <th className="p-4 font-bold text-center">Starter</th>
                  <th className="p-4 font-bold text-center text-emerald-800">Professional</th>
                  <th className="p-4 font-bold text-center">Enterprise</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-slate-700">
                <tr>
                  <td className="p-4 font-semibold text-slate-900">User Login Seats Allowed</td>
                  <td className="p-4 text-center">3 Seats (1 Admin + 2 Staff)</td>
                  <td className="p-4 text-center font-bold text-emerald-800">3 Seats (1 Admin + 2 Staff)</td>
                  <td className="p-4 text-center">Custom / Unlimited</td>
                </tr>
                <tr>
                  <td className="p-4 font-semibold text-slate-900">Multi-Product Inward Lots</td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                </tr>
                <tr>
                  <td className="p-4 font-semibold text-slate-900">Bag-by-Bag Digital Weighment Scale</td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                </tr>
                <tr>
                  <td className="p-4 font-semibold text-slate-900">Smart Chart Live Lot Auctions</td>
                  <td className="p-4 text-center text-slate-400">—</td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                </tr>
                <tr>
                  <td className="p-4 font-semibold text-slate-900">Daily Cash Tally & Denominations Counter</td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                </tr>
                <tr>
                  <td className="p-4 font-semibold text-slate-900">Handheld Android Mobile Offline Sync</td>
                  <td className="p-4 text-center text-slate-400">—</td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                </tr>
                <tr>
                  <td className="p-4 font-semibold text-slate-900">WhatsApp 1-Click Bill Sharing</td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                </tr>
                <tr>
                  <td className="p-4 font-semibold text-slate-900">Dedicated Technical Account Manager</td>
                  <td className="p-4 text-center text-slate-400">—</td>
                  <td className="p-4 text-center text-slate-400">—</td>
                  <td className="p-4 text-center text-emerald-700 font-semibold"><span className="inline-flex items-center gap-1"><Check className="h-4 w-4 text-emerald-600 inline" /> Included</span></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </section>

      <PublicFooter />
    </div>
  );
}
