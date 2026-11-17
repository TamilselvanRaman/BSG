"use client";

import { useState } from "react";
import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  ArrowRight,
  BarChart3,
  Boxes,
  Calculator,
  Check,
  CheckCircle2,
  Clock,
  Coins,
  FileSpreadsheet,
  FileText,
  Key,
  Layers,
  Lock,
  MessageSquare,
  PackagePlus,
  PhoneCall,
  Printer,
  Scale,
  Send,
  ShieldCheck,
  Smartphone,
  Truck,
  UserCheck,
  Users,
  Wallet,
  Zap,
} from "lucide-react";

const MANDI_FEATURES = [
  {
    icon: PackagePlus,
    title: "Multi-Product Inward Lots",
    desc: "Record arrivals of multiple crops (tomatoes, onions, potatoes) in a single vehicle entry with distinct bags and weights.",
    badge: "Arrival",
  },
  {
    icon: Scale,
    title: "Bag-by-Bag Weighment Scale",
    desc: "Digital scale entry summing individual bag weights (e.g., 52, 53, 53 kg) with automatic gross, tare, and net total calculation.",
    badge: "Billing",
  },
  {
    icon: Layers,
    title: "Smart Chart & Live Auctions",
    desc: "Real-time lot bidding, buyer allotment, automatic average rate computation, and zero-loss inventory tracking.",
    badge: "Auction",
  },
  {
    icon: FileText,
    title: "Cash & Credit Billing",
    desc: "Instant counter sales settlement or registered buyer credit invoicing with previous balance carry-forward and cooling charges.",
    badge: "Invoicing",
  },
  {
    icon: Coins,
    title: "Daily Cash Tally & Drawer",
    desc: "Closing cash reconciliation with full physical currency denomination counter (₹2000, ₹500, ₹200, ₹100, ₹50, coins).",
    badge: "Accounts",
  },
  {
    icon: Wallet,
    title: "Double-Entry Partner Ledgers",
    desc: "Real-time buyer and seller running statements with automated advance deductions and 1-click WhatsApp PDF share.",
    badge: "Ledgers",
  },
  {
    icon: Boxes,
    title: "Stock & Inventory Control",
    desc: "Opening + Inward − Sales = Closing stock with low-stock alerts, shrinkage logs, and lot profit margin audits.",
    badge: "Stock",
  },
  {
    icon: Smartphone,
    title: "Offline-First Mobile Handheld",
    desc: "Record weight on handheld mobile tablets right on the mandi auction floor. Automatic cloud sync when network is restored.",
    badge: "Mobile App",
  },
  {
    icon: UserCheck,
    title: "Multi-User License (Max 3 Users)",
    desc: "1 Store Admin + 2 Staff/Cashier seats per tenant ID with active concurrent session tracking and anti-theft session controls.",
    badge: "Security",
  },
];

const WORKFLOW_STEPS = [
  {
    step: "01",
    title: "Inward Lot Arrival",
    desc: "Enter farmer/supplier details, vehicle number, and multiple commodities with gross & tare weight.",
    tag: "Farmer Inward",
  },
  {
    step: "02",
    title: "Smart Chart Auction",
    desc: "Auction lots on the mandi floor, allocate bags to buyers, and set final strike prices.",
    tag: "Allotment",
  },
  {
    step: "03",
    title: "Bag-Scale Sales Bill",
    desc: "Weigh individual bags (52kg, 53kg...), calculate coolie/labour, and issue thermal/A4 cash or credit receipts.",
    tag: "Weighment",
  },
  {
    step: "04",
    title: "Daily Cash Tally",
    desc: "Count physical cash denominations, verify expected system closing, and record verified balance.",
    tag: "Settlement",
  },
];

const FAQS = [
  {
    q: "Can multiple operators and cashiers log in simultaneously?",
    a: "Yes. Every registered shop gets an authorized license allowing up to 3 concurrent users (1 Store Admin/Owner + 2 Staff/Cashier operators) on Web and Android mobile handhelds.",
  },
  {
    q: "How does the bag-by-bag weighment scale work?",
    a: "Operators enter each bag's weight on their mobile or web screen (e.g., Bag 1: 52 kg, Bag 2: 53 kg). The system automatically computes total bags, net weight, average weight, and gross amounts instantly.",
  },
  {
    q: "Does the mobile app function without continuous internet?",
    a: "Yes! The Flutter mobile handheld app features offline-first local queueing. You can record arrivals and weigh bills on the mandi floor, and records sync to the cloud once connectivity resumes.",
  },
  {
    q: "Can bills and ledger statements be shared directly via WhatsApp?",
    a: "Yes. With 1 click, you can generate formatted bill PDFs and ledger balance statements and send them directly to the buyer or seller's WhatsApp number.",
  },
];

export default function HomePage() {
  // Interactive Enquiry Form State
  const [enquiryForm, setEnquiryForm] = useState({
    fullName: "",
    shopName: "",
    phone: "",
    city: "",
    marketLocation: "",
    businessType: "Vegetable Mandi",
    dailyBags: "500 - 2000 Bags",
    message: "",
  });
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  async function handleEnquirySubmit(e: React.FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    // Simulate fast reliable lead capture
    await new Promise((resolve) => setTimeout(resolve, 800));
    setSubmitting(false);
    setSubmitted(true);
  }

  return (
    <div className="flex min-h-screen flex-col bg-slate-50">
      <PublicNavbar />

      {/* ============================================================
          HERO SECTION
         ============================================================ */}
      <section className="relative overflow-hidden border-b border-slate-200/80 bg-gradient-to-b from-white via-slate-50 to-emerald-50/25 pt-16 pb-20 lg:pt-24 lg:pb-32">
        {/* Glow circles */}
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[650px] h-[350px] bg-gradient-to-tr from-emerald-400/15 via-teal-500/15 to-green-400/10 blur-3xl pointer-events-none rounded-full" />

        <div className="relative mx-auto max-w-7xl px-6">
          <div className="mx-auto max-w-3xl text-center">
            {/* Headline */}
            <h1 className="text-4xl font-black tracking-tight text-slate-900 sm:text-5xl lg:text-6xl leading-[1.12]">
              Run Your Entire Goods Inward, Mandi Trade & Billing in{" "}
              <span className="bg-gradient-to-r from-emerald-600 via-teal-600 to-green-700 bg-clip-text text-transparent">
                One BSG Platform
              </span>
            </h1>

            {/* Subheading */}
            <p className="mt-6 text-base sm:text-lg text-slate-600 leading-relaxed max-w-2xl mx-auto">
              The high-speed cloud platform designed specifically for wholesale agricultural traders, APMC commission agents, and fruit & vegetable mandis.
              Supports multi-crop arrivals, bag weighment tables, daily cash tallies, and max 3-user license controls.
            </p>

            {/* CTAs */}
            <div className="mt-9 flex flex-wrap items-center justify-center gap-4">
              <Link
                href="/register"
                className="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-700 px-6 py-3.5 text-sm font-bold text-white shadow-lg shadow-emerald-600/25 hover:from-emerald-700 hover:to-teal-800 transition hover:shadow-xl hover:-translate-y-0.5"
              >
                <span>Start 30-Day Free Trial</span>
                <ArrowRight className="h-4 w-4" />
              </Link>
              <a
                href="#enquiry-section"
                className="inline-flex items-center gap-2 rounded-xl border border-slate-300 bg-white px-6 py-3.5 text-sm font-bold text-slate-700 shadow-sm hover:bg-slate-50 hover:border-slate-400 transition hover:-translate-y-0.5"
              >
                <PhoneCall className="h-4 w-4 text-emerald-600" />
                <span>Request Mandi Demo</span>
              </a>
            </div>

            {/* Micro assurances */}
            <div className="mt-6 flex flex-wrap items-center justify-center gap-6 text-xs font-semibold text-slate-500">
              <span className="flex items-center gap-1.5">
                <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600" />
                30 Days Full Access
              </span>
              <span className="flex items-center gap-1.5">
                <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600" />
                Max 3 Login Seats Included
              </span>
              <span className="flex items-center gap-1.5">
                <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600" />
                Zero Setup Fee
              </span>
            </div>
          </div>

          {/* Interactive Metric Cards */}
          <div className="mt-16 grid grid-cols-2 gap-4 sm:grid-cols-4">
            <div className="rounded-2xl border border-slate-200/80 bg-white p-5 text-center shadow-sm hover:shadow-md transition">
              <p className="text-3xl font-black text-slate-900">50K+</p>
              <p className="text-xs font-semibold text-slate-500 mt-1 uppercase tracking-wider">
                Bags Weighed Daily
              </p>
            </div>
            <div className="rounded-2xl border border-slate-200/80 bg-white p-5 text-center shadow-sm hover:shadow-md transition">
              <p className="text-3xl font-black text-emerald-800">₹150Cr+</p>
              <p className="text-xs font-semibold text-slate-500 mt-1 uppercase tracking-wider">
                Mandi Turnover Processed
              </p>
            </div>
            <div className="rounded-2xl border border-slate-200/80 bg-white p-5 text-center shadow-sm hover:shadow-md transition">
              <p className="text-3xl font-black text-slate-900">100%</p>
              <p className="text-xs font-semibold text-slate-500 mt-1 uppercase tracking-wider">
                ACID Financial Balance
              </p>
            </div>
            <div className="rounded-2xl border border-slate-200/80 bg-white p-5 text-center shadow-sm hover:shadow-md transition">
              <p className="text-3xl font-black text-emerald-600">0 sec</p>
              <p className="text-xs font-semibold text-slate-500 mt-1 uppercase tracking-wider">
                Offline Floor Downtime
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          WORKFLOW STEPS (4-STEP MANDI PIPELINE)
         ============================================================ */}
      <section className="py-20 bg-slate-900 text-white border-b border-slate-800">
        <div className="mx-auto max-w-7xl px-6">
          <div className="text-center max-w-2xl mx-auto">
            <span className="text-xs font-bold uppercase tracking-widest text-emerald-400">
              End-to-End Workflow
            </span>
            <h2 className="mt-2 text-3xl font-black sm:text-4xl">
              From Inward Truck to Evening Cash Tally
            </h2>
            <p className="mt-3 text-sm text-slate-400">
              Engineered specifically for the fast-paced, high-volume environment of agricultural markets.
            </p>
          </div>

          <div className="mt-14 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {WORKFLOW_STEPS.map((s) => (
              <div
                key={s.step}
                className="relative rounded-2xl border border-slate-800 bg-slate-800/60 p-6 backdrop-blur hover:border-emerald-500/50 hover:bg-slate-800 transition group"
              >
                <div className="flex items-center justify-between">
                  <span className="text-2xl font-black text-emerald-400 group-hover:scale-110 transition-transform">
                    {s.step}
                  </span>
                  <span className="rounded-full bg-emerald-950/60 border border-emerald-700/50 px-2.5 py-0.5 text-[10px] font-bold text-emerald-300">
                    {s.tag}
                  </span>
                </div>
                <h3 className="mt-4 text-base font-bold text-white group-hover:text-emerald-300 transition-colors">
                  {s.title}
                </h3>
                <p className="mt-2 text-xs text-slate-300 leading-relaxed">
                  {s.desc}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ============================================================
          MANDI CORE FEATURES (10 CAPABILITIES)
         ============================================================ */}
      <section className="py-20 bg-white border-b border-slate-200">
        <div className="mx-auto max-w-7xl px-6">
          <div className="text-center max-w-2xl mx-auto">
            <span className="text-xs font-bold uppercase tracking-widest text-emerald-700">
              Complete Mandi Suite
            </span>
            <h2 className="mt-2 text-3xl font-black text-slate-900 sm:text-4xl">
              Everything Your Shop Needs Under One License
            </h2>
            <p className="mt-3 text-sm text-slate-600">
              All 10 modules enabled out-of-the-box with 1-click activation from Super Admin.
            </p>
          </div>

          <div className="mt-14 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {MANDI_FEATURES.map((item) => {
              const Icon = item.icon;
              return (
                <div
                  key={item.title}
                  className="rounded-2xl border border-slate-200 bg-slate-50/50 p-6 hover:bg-white hover:border-emerald-300 hover:shadow-lg transition-all group"
                >
                  <div className="flex items-center justify-between">
                    <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-emerald-100/80 text-emerald-800 group-hover:bg-emerald-600 group-hover:text-white transition-colors">
                      <Icon className="h-6 w-6" />
                    </div>
                    <span className="rounded-full bg-slate-100 border border-slate-200 px-2.5 py-0.5 text-[10px] font-bold text-slate-600 uppercase tracking-wider">
                      {item.badge}
                    </span>
                  </div>
                  <h3 className="mt-5 text-base font-bold text-slate-900 group-hover:text-emerald-700 transition-colors">
                    {item.title}
                  </h3>
                  <p className="mt-2 text-xs text-slate-600 leading-relaxed">
                    {item.desc}
                  </p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* ============================================================
          ENQUIRY & DEMO CONTACT FORM
         ============================================================ */}
      <section id="enquiry-section" className="py-20 bg-gradient-to-b from-slate-50 to-emerald-50/30">
        <div className="mx-auto max-w-7xl px-6">
          <div className="grid gap-12 lg:grid-cols-12 items-center">
            {/* Left pitch */}
            <div className="lg:col-span-5 space-y-6">
              <p className="text-xs font-bold uppercase tracking-widest text-emerald-700">
                Direct Onboarding & Deployment
              </p>
              <h2 className="text-3xl font-black text-slate-900 sm:text-4xl">
                Ready to Upgrade Your Mandi Shop Operations?
              </h2>
              <p className="text-sm text-slate-600 leading-relaxed">
                Fill out the quick enquiry form. Our Mandi deployment team will set up your shop's Tenant ID, provision your 30-Day Free Trial License (Max 3 Users), and guide you through first bill generation in 15 minutes.
              </p>

              <div className="space-y-3.5 pt-2">
                <div className="flex items-start gap-3">
                  <div className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-emerald-100 text-emerald-700">
                    <Check className="h-3.5 w-3.5" />
                  </div>
                  <p className="text-xs text-slate-700">
                    <strong>100% Tailored for Mandis:</strong> Handles KG, Quintal, Bags, Crates, Coolie & RMC Cess automatically.
                  </p>
                </div>
                <div className="flex items-start gap-3">
                  <div className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-emerald-100 text-emerald-700">
                    <Check className="h-3.5 w-3.5" />
                  </div>
                  <p className="text-xs text-slate-700">
                    <strong>Multi-Device Access:</strong> 1 Shop Admin on Web + 2 Handheld Mobile Cashiers simultaneously.
                  </p>
                </div>
                <div className="flex items-start gap-3">
                  <div className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-emerald-100 text-emerald-700">
                    <Check className="h-3.5 w-3.5" />
                  </div>
                  <p className="text-xs text-slate-700">
                    <strong>Instant Thermal & WhatsApp Receipts:</strong> Send bills to farmers and buyers in 1 second.
                  </p>
                </div>
              </div>
            </div>

            {/* Right Form Card */}
            <div className="lg:col-span-7">
              <div className="rounded-3xl border border-slate-200/90 bg-white p-8 shadow-xl shadow-slate-200/50">
                {submitted ? (
                  <div className="text-center py-10 space-y-4">
                    <div className="inline-flex h-16 w-16 items-center justify-center rounded-full bg-emerald-100 text-emerald-600">
                      <CheckCircle2 className="h-8 w-8" />
                    </div>
                    <h3 className="text-2xl font-bold text-slate-900">Enquiry Received!</h3>
                    <p className="text-sm text-slate-600 max-w-md mx-auto">
                      Thank you, <strong>{enquiryForm.fullName}</strong>. Your shop details for <strong>{enquiryForm.shopName}</strong> have been recorded.
                      Our Mandi Specialist will call/WhatsApp you at <strong>{enquiryForm.phone}</strong> within 30 minutes with your 30-Day Free Trial License Key.
                    </p>
                    <button
                      onClick={() => setSubmitted(false)}
                      className="mt-4 rounded-xl bg-slate-900 px-6 py-2.5 text-xs font-bold text-white hover:bg-slate-800 transition"
                    >
                      Submit Another Enquiry
                    </button>
                  </div>
                ) : (
                  <form onSubmit={handleEnquirySubmit} className="space-y-4 text-xs">
                    <div>
                      <h3 className="text-lg font-bold text-slate-900">
                        Request a Free 30-Day Trial & Demo
                      </h3>
                      <p className="text-slate-500 mt-0.5">
                        Tell us about your mandi shop to get an instant tailored demo.
                      </p>
                    </div>

                    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 pt-2">
                      <div>
                        <label className="block font-bold text-slate-700 mb-1 uppercase tracking-wider text-[11px]">
                          Your Name *
                        </label>
                        <input
                          type="text"
                          required
                          placeholder="e.g. Kannan Murugan"
                          value={enquiryForm.fullName}
                          onChange={(e) => setEnquiryForm({ ...enquiryForm, fullName: e.target.value })}
                          className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none"
                        />
                      </div>
                      <div>
                        <label className="block font-bold text-slate-700 mb-1 uppercase tracking-wider text-[11px]">
                          Shop / Store Name *
                        </label>
                        <input
                          type="text"
                          required
                          placeholder="e.g. BSG Trading Corp"
                          value={enquiryForm.shopName}
                          onChange={(e) => setEnquiryForm({ ...enquiryForm, shopName: e.target.value })}
                          className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                      <div>
                        <label className="block font-bold text-slate-700 mb-1 uppercase tracking-wider text-[11px]">
                          WhatsApp / Mobile Phone *
                        </label>
                        <input
                          type="tel"
                          required
                          placeholder="10-digit mobile number"
                          value={enquiryForm.phone}
                          onChange={(e) => setEnquiryForm({ ...enquiryForm, phone: e.target.value })}
                          className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none"
                        />
                      </div>
                      <div>
                        <label className="block font-bold text-slate-700 mb-1 uppercase tracking-wider text-[11px]">
                          City / Market Location *
                        </label>
                        <input
                          type="text"
                          required
                          placeholder="e.g. Coimbatore / Oddanchatram"
                          value={enquiryForm.city}
                          onChange={(e) => setEnquiryForm({ ...enquiryForm, city: e.target.value })}
                          className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                      <div>
                        <label className="block font-bold text-slate-700 mb-1 uppercase tracking-wider text-[11px]">
                          Primary Business Type
                        </label>
                        <select
                          value={enquiryForm.businessType}
                          onChange={(e) => setEnquiryForm({ ...enquiryForm, businessType: e.target.value })}
                          className="w-full rounded-xl border border-slate-300 px-3 py-2.5 text-sm focus:border-emerald-600 focus:outline-none bg-white"
                        >
                          <option value="Vegetable Mandi">Vegetable Mandi Trader</option>
                          <option value="Fruit Commission Agent">Fruit Commission Agent</option>
                          <option value="Onion & Potato Trader">Onion & Potato Merchant</option>
                          <option value="Grains & Pulses">Grains & Pulses Merchant</option>
                          <option value="Multi-Commodity Wholesaler">Multi-Commodity Wholesaler</option>
                        </select>
                      </div>
                      <div>
                        <label className="block font-bold text-slate-700 mb-1 uppercase tracking-wider text-[11px]">
                          Estimated Daily Bags Volume
                        </label>
                        <select
                          value={enquiryForm.dailyBags}
                          onChange={(e) => setEnquiryForm({ ...enquiryForm, dailyBags: e.target.value })}
                          className="w-full rounded-xl border border-slate-300 px-3 py-2.5 text-sm focus:border-emerald-600 focus:outline-none bg-white"
                        >
                          <option value="Under 500 Bags">Under 500 Bags / Day</option>
                          <option value="500 - 2000 Bags">500 - 2,000 Bags / Day</option>
                          <option value="2000+ Bags">2,000+ Bags / Day (High Volume)</option>
                        </select>
                      </div>
                    </div>

                    <div>
                      <label className="block font-bold text-slate-700 mb-1 uppercase tracking-wider text-[11px]">
                        Any Specific Requirements or Questions
                      </label>
                      <textarea
                        rows={3}
                        placeholder="Tell us about your weighment flow, printers, or custom commission rate needs..."
                        value={enquiryForm.message}
                        onChange={(e) => setEnquiryForm({ ...enquiryForm, message: e.target.value })}
                        className="w-full rounded-xl border border-slate-300 p-3 text-sm focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none"
                      />
                    </div>

                    <button
                      type="submit"
                      disabled={submitting}
                      className="w-full flex items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-700 py-3.5 text-sm font-bold text-white shadow-md shadow-emerald-600/25 hover:from-emerald-700 hover:to-teal-800 transition disabled:opacity-50"
                    >
                      <Send className="h-4 w-4" />
                      <span>{submitting ? "Sending Enquiry..." : "Submit Enquiry & Get Free Trial Key"}</span>
                    </button>
                    <p className="text-[11px] text-center text-slate-400">
                      No spam. Your phone number is kept confidential for demo onboarding only.
                    </p>
                  </form>
                )}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          FAQS SECTION
         ============================================================ */}
      <section className="py-20 bg-white border-t border-slate-200">
        <div className="mx-auto max-w-4xl px-6">
          <div className="text-center">
            <span className="text-xs font-bold uppercase tracking-widest text-emerald-700">
              Frequently Asked Questions
            </span>
            <h2 className="mt-2 text-3xl font-black text-slate-900 sm:text-4xl">
              Common Questions from Mandi Traders
            </h2>
          </div>

          <div className="mt-12 space-y-4">
            {FAQS.map((faq) => (
              <div
                key={faq.q}
                className="rounded-2xl border border-slate-200 bg-slate-50/60 p-6 hover:bg-slate-50 transition"
              >
                <h3 className="font-bold text-slate-900 text-base">{faq.q}</h3>
                <p className="mt-2 text-xs sm:text-sm text-slate-600 leading-relaxed">{faq.a}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ============================================================
          BOTTOM CTA BAR
         ============================================================ */}
      <section className="py-16 bg-gradient-to-r from-emerald-700 via-teal-700 to-green-800 text-white text-center">
        <div className="mx-auto max-w-4xl px-6 space-y-6">
          <h2 className="text-3xl font-black sm:text-4xl tracking-tight">
            Start Your Shop's 30-Day Free Trial Today
          </h2>
          <p className="text-sm text-emerald-100 max-w-xl mx-auto">
            Experience the speed of digital bag weighment, live smart charts, and daily cash tallies.
          </p>
          <div className="flex flex-wrap items-center justify-center gap-4 pt-2">
            <Link
              href="/register"
              className="rounded-xl bg-white px-7 py-3 text-sm font-bold text-emerald-800 shadow-md hover:bg-emerald-50 transition"
            >
              Register Shop Now
            </Link>
            <Link
              href="/login"
              className="rounded-xl border border-white/40 bg-white/10 px-7 py-3 text-sm font-bold text-white hover:bg-white/20 transition backdrop-blur-sm"
            >
              Sign In to Workspace
            </Link>
          </div>
        </div>
      </section>

      <PublicFooter />
    </div>
  );
}
