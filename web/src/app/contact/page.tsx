"use client";

import { useState } from "react";
import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  AlertTriangle,
  ArrowRight,
  Boxes,
  Building2,
  Check,
  CheckCircle2,
  Clock,
  Coins,
  FileSpreadsheet,
  FileText,
  Lock,
  Mail,
  MapPin,
  MessageSquare,
  PackagePlus,
  PhoneCall,
  Printer,
  Scale,
  Send,
  ShieldCheck,
  Smartphone,
  Utensils,
  Wheat,
  Zap,
} from "lucide-react";

interface DomainOption {
  id: string;
  name: string;
  desc: string;
  icon: any;
}

const DOMAIN_OPTIONS: DomainOption[] = [
  {
    id: "vegetables",
    name: "Vegetable & Fruit Mandi",
    desc: "Perishables, rapid bag weighment & daily cash tally",
    icon: Utensils,
  },
  {
    id: "apmc_agent",
    name: "APMC Commission Agent",
    desc: "Live auctions, lot splits & farmer khata advances",
    icon: Scale,
  },
  {
    id: "grains_wholesale",
    name: "Grain & Spices Wholesale",
    desc: "Weighbridge scales, quintals & APMC cess compliance",
    icon: Wheat,
  },
  {
    id: "enterprise",
    name: "Multi-Yard Enterprise",
    desc: "Multi-branch trading, dedicated schema & SLAs",
    icon: Building2,
  },
];

const REQUIREMENT_CHIPS = [
  "Bag-by-Bag Digital Scale",
  "3-Inch Bluetooth Thermal Printer",
  "Live Smart Chart Auctions",
  "Evening Cash Drawer Tally",
  "Farmer Advance Deductions",
  "Weighbridge Serial Scale",
  "WhatsApp PDF Ledger Dispatch",
  "Offline Android Mobile App",
];

export default function ContactPage() {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    businessName: "",
    businessDomain: "vegetables",
    location: "",
    selectedRequirements: ["Bag-by-Bag Digital Scale", "3-Inch Bluetooth Thermal Printer"],
    dailyVolume: "50 - 200 Bags / Day",
    message: "",
  });

  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  function toggleRequirement(req: string) {
    setFormData((prev) => {
      const exists = prev.selectedRequirements.includes(req);
      return {
        ...prev,
        selectedRequirements: exists
          ? prev.selectedRequirements.filter((r) => r !== req)
          : [...prev.selectedRequirements, req],
      };
    });
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    setErrorMessage("");

    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000/api/v1";
      const domainLabel =
        DOMAIN_OPTIONS.find((d) => d.id === formData.businessDomain)?.name || formData.businessDomain;
      const combinedNotes = [
        `Requirements: ${formData.selectedRequirements.join(", ")}`,
        `Daily Volume: ${formData.dailyVolume}`,
        formData.message ? `Notes: ${formData.message}` : null,
      ]
        .filter(Boolean)
        .join(" | ");

      const res = await fetch(`${apiUrl}/public/contact-inquiries`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          fullName: formData.name,
          businessName: formData.businessName,
          phone: formData.phone,
          email: formData.email,
          businessDomain: domainLabel,
          marketYardCity: formData.location || "Not specified",
          notes: combinedNotes,
        }),
      });

      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.message || "Failed to submit inquiry. Please check your inputs.");
      }

      setSubmitted(true);
    } catch (err: any) {
      setErrorMessage(err.message || "An error occurred while transmitting your request.");
    } finally {
      setSubmitting(false);
    }
  }

  const selectedDomainObj =
    DOMAIN_OPTIONS.find((d) => d.id === formData.businessDomain) || DOMAIN_OPTIONS[0];

  return (
    <div className="flex min-h-screen flex-col bg-[#F4FAF5] text-[#123B29] font-sans">
      <PublicNavbar />

      {/* ============================================================
          1. HERO SECTION
         ============================================================ */}
      <section className="relative overflow-hidden border-b border-[#CDE8D5] bg-gradient-to-b from-white via-[#F4FAF5] to-[#E8F5EC]/60 py-16 lg:py-20">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 text-center">
          <div className="inline-flex items-center gap-2 rounded-full border border-[#CDE8D5] bg-[#E8F5EC] px-3.5 py-1 text-xs font-bold text-[#087A50] mb-4">
            <span className="h-2 w-2 rounded-full bg-[#10A66A] animate-pulse" />
            <span>Mandi Onboarding Tech Desk Active • 5:30 AM – 9:00 PM IST</span>
          </div>
          <h1 className="mx-auto max-w-4xl text-3xl font-black text-[#063D2E] sm:text-4xl lg:text-5xl tracking-tight leading-tight">
            Consult with Our Mandi Architecture Team
          </h1>
          <p className="mt-4 text-sm sm:text-base text-[#47785C] max-w-2xl mx-auto leading-relaxed">
            Direct phone, WhatsApp, and remote setup guidance for wholesale commission agents, fruit and vegetable merchants, and agricultural yard enterprises.
          </p>

          {/* Quick Metrics Bar */}
          <div className="mt-8 flex flex-wrap items-center justify-center gap-6 text-xs font-bold text-[#47785C]">
            <span className="flex items-center gap-1.5">
              <CheckCircle2 className="h-4 w-4 text-[#10A66A]" />
              Response Time: &lt; 30 Minutes
            </span>
            <span className="flex items-center gap-1.5">
              <CheckCircle2 className="h-4 w-4 text-[#10A66A]" />
              Dedicated Mandi Specialist
            </span>
            <span className="flex items-center gap-1.5">
              <CheckCircle2 className="h-4 w-4 text-[#10A66A]" />
              Go-Live in Under 15 Minutes
            </span>
          </div>
        </div>
      </section>

      {/* ============================================================
          2. MAIN CONTENT (LEFT DESK + RIGHT CUSTOM FORM)
         ============================================================ */}
      <main className="flex-1 py-16 lg:py-20">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="grid gap-12 lg:grid-cols-12 items-start">
            {/* ============================================================
                LEFT COLUMN: MANDI TECH DESK CARDS
               ============================================================ */}
            <div className="lg:col-span-5 space-y-6">
              {/* Primary Direct Helpline Card */}
              <div className="rounded-3xl border border-[#CDE8D5] bg-white p-7 shadow-xs space-y-5">
                <div className="flex items-center justify-between border-b border-[#DCEEE1] pb-4">
                  <div className="flex items-center gap-3">
                    <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-[#087A50] text-white shadow-xs">
                      <PhoneCall className="h-5 w-5" />
                    </div>
                    <div>
                      <h3 className="text-sm font-bold text-[#063D2E]">Direct Phone & WhatsApp</h3>
                      <p className="text-[11px] text-[#47785C]">Instant morning auction support</p>
                    </div>
                  </div>
                  <span className="rounded-full bg-[#E8F5EC] border border-[#CDE8D5] px-2.5 py-0.5 text-[10px] font-extrabold text-[#087A50]">
                    Direct
                  </span>
                </div>

                <div className="space-y-3">
                  <a
                    href="tel:+919841238910"
                    className="flex items-center justify-between rounded-2xl border border-[#CDE8D5] bg-[#F4FAF5] p-4 hover:border-[#10A66A] hover:bg-[#E8F5EC]/40 transition group"
                  >
                    <div>
                      <span className="text-[10px] font-bold uppercase tracking-wider text-[#47785C]">Direct Telephone</span>
                      <p className="text-base font-black text-[#063D2E] group-hover:text-[#087A50] transition">+91 98412 38910</p>
                    </div>
                    <span className="rounded-xl bg-white border border-[#CDE8D5] px-3 py-1 text-xs font-bold text-[#087A50]">
                      Call Now
                    </span>
                  </a>

                  <a
                    href="https://wa.me/919841238910?text=Hello%20BSG%20Team%2C%20I%20would%20like%20to%20schedule%20a%20mandi%20consultation"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center justify-between rounded-2xl border border-[#CDE8D5] bg-[#F4FAF5] p-4 hover:border-[#10A66A] hover:bg-[#E8F5EC]/40 transition group"
                  >
                    <div>
                      <span className="text-[10px] font-bold uppercase tracking-wider text-[#47785C]">Official WhatsApp</span>
                      <p className="text-base font-black text-[#087A50]">+91 98412 38910</p>
                    </div>
                    <span className="rounded-xl bg-[#087A50] px-3 py-1 text-xs font-bold text-white shadow-xs">
                      Chat WhatsApp
                    </span>
                  </a>
                </div>
              </div>

              {/* Operating Hours & Location */}
              <div className="rounded-3xl border border-[#CDE8D5] bg-white p-7 shadow-xs space-y-4 text-xs">
                <div className="flex items-start gap-3.5">
                  <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#E8F5EC] text-[#087A50] shrink-0">
                    <Clock className="h-5 w-5" />
                  </div>
                  <div>
                    <h4 className="font-bold text-[#063D2E]">Mandi Working Hours</h4>
                    <p className="text-[#47785C] mt-0.5">Monday to Saturday: <strong className="text-[#063D2E]">5:30 AM – 9:00 PM IST</strong></p>
                    <p className="text-[11px] text-[#71917B] mt-0.5">Covers early morning farmer arrivals and evening drawer closing.</p>
                  </div>
                </div>

                <div className="border-t border-[#DCEEE1] pt-4 flex items-start gap-3.5">
                  <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#E8F5EC] text-[#087A50] shrink-0">
                    <Mail className="h-5 w-5" />
                  </div>
                  <div>
                    <h4 className="font-bold text-[#063D2E]">Email Desk</h4>
                    <p className="text-[#087A50] font-semibold mt-0.5">support@bsgmandi.io</p>
                    <p className="text-[11px] text-[#71917B] mt-0.5">For formal onboarding, SLA agreements & API integrations.</p>
                  </div>
                </div>

                <div className="border-t border-[#DCEEE1] pt-4 flex items-start gap-3.5">
                  <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#E8F5EC] text-[#087A50] shrink-0">
                    <MapPin className="h-5 w-5" />
                  </div>
                  <div>
                    <h4 className="font-bold text-[#063D2E]">Central Tech Operations Hub</h4>
                    <p className="text-[#47785C] mt-0.5">APMC Market Complex, Agro Trading Zone, Coimbatore, Tamil Nadu, India.</p>
                  </div>
                </div>
              </div>

              {/* Guarantees Box */}
              <div className="rounded-3xl border border-emerald-200 bg-[#E8F5EC]/70 p-6 space-y-3">
                <div className="flex items-center gap-2 font-bold text-[#063D2E] text-xs">
                  <ShieldCheck className="h-5 w-5 text-[#087A50]" />
                  <span>30-Day Full Feature Trial Guarantee</span>
                </div>
                <p className="text-xs text-[#47785C] leading-relaxed">
                  No credit card or upfront deposit required. Experience digital bag weighment scales, smart chart auctions, and evening cash drawer tallies right on your mandi floor with 3 user seats included.
                </p>
              </div>
            </div>

            {/* ============================================================
                RIGHT COLUMN: REDESIGNED ENTERPRISE CONSULTATION FORM
               ============================================================ */}
            <div className="lg:col-span-7">
              <div className="rounded-3xl border border-[#CDE8D5] bg-white p-7 sm:p-10 shadow-sm">
                {submitted ? (
                  /* Success Feedback */
                  <div className="py-12 text-center space-y-4">
                    <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-2xl bg-[#E8F5EC] text-[#087A50] border border-[#CDE8D5]">
                      <CheckCircle2 className="h-9 w-9" />
                    </div>
                    <h3 className="text-2xl font-black text-[#063D2E]">
                      Consultation Request Received
                    </h3>
                    <p className="text-xs sm:text-sm text-[#47785C] max-w-md mx-auto leading-relaxed">
                      Thank you, <strong className="text-[#063D2E]">{formData.name}</strong>. Our agricultural software specialist will call you at <strong className="text-[#063D2E]">{formData.phone}</strong> within 30 minutes to discuss setup for <strong className="text-[#063D2E]">{formData.businessName || "your mandi"}</strong>.
                    </p>

                    <div className="pt-4 flex flex-wrap items-center justify-center gap-3">
                      <a
                        href={`https://wa.me/919841238910?text=Hello%20BSG%2C%20I%20just%20submitted%20a%20request%20for%20${encodeURIComponent(formData.businessName || "our shop")}.`}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center gap-2 rounded-xl bg-[#087A50] px-5 py-2.5 text-xs font-bold text-white shadow-xs hover:bg-[#063D2E] transition"
                      >
                        <MessageSquare className="h-4 w-4" />
                        <span>Continue on WhatsApp</span>
                      </a>
                      <button
                        onClick={() => setSubmitted(false)}
                        className="rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] px-5 py-2.5 text-xs font-bold text-[#063D2E] hover:bg-[#E8F5EC] transition"
                      >
                        Submit Another Request
                      </button>
                    </div>
                  </div>
                ) : (
                  /* Form Body */
                  <form onSubmit={handleSubmit} className="space-y-6">
                    <div>
                      <h2 className="text-xl font-black text-[#063D2E] tracking-tight">
                        Schedule Your Guided Mandi Walkthrough
                      </h2>
                      <p className="text-xs text-[#47785C] mt-1">
                        Fill in your business parameters below. We will customize the demonstration to your crops and weighment hardware.
                      </p>
                    </div>

                    {/* Step 1: Contact Information */}
                    <div className="space-y-3 pt-2">
                      <span className="text-[11px] font-bold uppercase tracking-wider text-[#087A50]">
                        Step 1: Contact Information
                      </span>

                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                        <div>
                          <label className="block text-xs font-bold text-[#123B29] mb-1">
                            Your Full Name *
                          </label>
                          <input
                            type="text"
                            required
                            placeholder="e.g. Anand Sharma"
                            value={formData.name}
                            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                            className="w-full rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] px-3.5 py-2.5 text-sm text-[#063D2E] focus:border-[#087A50] focus:ring-1 focus:ring-[#087A50] focus:outline-none transition"
                          />
                        </div>

                        <div>
                          <label className="block text-xs font-bold text-[#123B29] mb-1">
                            Mandi Business Name *
                          </label>
                          <input
                            type="text"
                            required
                            placeholder="e.g. Sharma Agro Traders"
                            value={formData.businessName}
                            onChange={(e) => setFormData({ ...formData, businessName: e.target.value })}
                            className="w-full rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] px-3.5 py-2.5 text-sm text-[#063D2E] focus:border-[#087A50] focus:ring-1 focus:ring-[#087A50] focus:outline-none transition"
                          />
                        </div>
                      </div>

                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                        <div>
                          <label className="block text-xs font-bold text-[#123B29] mb-1">
                            Contact Phone (WhatsApp) *
                          </label>
                          <input
                            type="tel"
                            required
                            placeholder="e.g. +91 98412 38910"
                            value={formData.phone}
                            onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                            className="w-full rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] px-3.5 py-2.5 text-sm text-[#063D2E] focus:border-[#087A50] focus:ring-1 focus:ring-[#087A50] focus:outline-none transition"
                          />
                        </div>

                        <div>
                          <label className="block text-xs font-bold text-[#123B29] mb-1">
                            Official Email Address *
                          </label>
                          <input
                            type="email"
                            required
                            placeholder="e.g. anand@sharmaagro.in"
                            value={formData.email}
                            onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                            className="w-full rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] px-3.5 py-2.5 text-sm text-[#063D2E] focus:border-[#087A50] focus:ring-1 focus:ring-[#087A50] focus:outline-none transition"
                          />
                        </div>
                      </div>

                      <div>
                        <label className="block text-xs font-bold text-[#123B29] mb-1">
                          Market Yard / APMC City & State *
                        </label>
                        <input
                          type="text"
                          required
                          placeholder="e.g. Oddanchatram Mandi, Dindigul, Tamil Nadu"
                          value={formData.location}
                          onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                          className="w-full rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] px-3.5 py-2.5 text-sm text-[#063D2E] focus:border-[#087A50] focus:ring-1 focus:ring-[#087A50] focus:outline-none transition"
                        />
                      </div>
                    </div>

                    {/* ============================================================
                        Step 2: CUSTOM DESIGNED BUSINESS DOMAIN SELECTION CARDS
                        (REPLACING NATIVE BLUE SELECT)
                       ============================================================ */}
                    <div className="space-y-2.5 pt-2 border-t border-[#DCEEE1]">
                      <div className="flex items-center justify-between">
                        <span className="text-[11px] font-bold uppercase tracking-wider text-[#087A50]">
                          Step 2: Select Your Business Domain
                        </span>
                        <span className="text-[11px] font-semibold text-[#47785C]">
                          Selected: <strong className="text-[#063D2E]">{selectedDomainObj.name}</strong>
                        </span>
                      </div>

                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        {DOMAIN_OPTIONS.map((opt) => {
                          const Icon = opt.icon;
                          const active = formData.businessDomain === opt.id;

                          return (
                            <button
                              type="button"
                              key={opt.id}
                              onClick={() => setFormData({ ...formData, businessDomain: opt.id })}
                              className={`flex items-start gap-3 rounded-2xl p-3.5 text-left transition-all border ${
                                active
                                  ? "border-2 border-[#087A50] bg-[#E8F5EC] shadow-xs"
                                  : "border-[#CDE8D5] bg-[#F4FAF5] hover:border-[#10A66A] hover:bg-white"
                              }`}
                            >
                              <div
                                className={`flex h-9 w-9 items-center justify-center rounded-xl shrink-0 transition-colors ${
                                  active
                                    ? "bg-[#087A50] text-white shadow-xs"
                                    : "bg-white border border-[#CDE8D5] text-[#087A50]"
                                }`}
                              >
                                <Icon className="h-4 w-4" />
                              </div>
                              <div className="flex-1">
                                <div className="flex items-center justify-between">
                                  <h4 className="text-xs font-bold text-[#063D2E]">
                                    {opt.name}
                                  </h4>
                                  {active && (
                                    <span className="flex h-4 w-4 items-center justify-center rounded-full bg-[#087A50] text-white">
                                      <Check className="h-2.5 w-2.5" />
                                    </span>
                                  )}
                                </div>
                                <p className="text-[11px] text-[#47785C] mt-0.5 leading-snug">
                                  {opt.desc}
                                </p>
                              </div>
                            </button>
                          );
                        })}
                      </div>
                    </div>

                    {/* ============================================================
                        Step 3: INTERACTIVE REQUIREMENTS & HARDWARE CHIPS
                       ============================================================ */}
                    <div className="space-y-2.5 pt-2 border-t border-[#DCEEE1]">
                      <span className="text-[11px] font-bold uppercase tracking-wider text-[#087A50]">
                        Step 3: Mandi Hardware & Workflow Needs (Select All That Apply)
                      </span>

                      <div className="flex flex-wrap gap-2">
                        {REQUIREMENT_CHIPS.map((chip) => {
                          const isSelected = formData.selectedRequirements.includes(chip);

                          return (
                            <button
                              type="button"
                              key={chip}
                              onClick={() => toggleRequirement(chip)}
                              className={`inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-bold transition-all border ${
                                isSelected
                                  ? "bg-[#087A50] text-white border-[#087A50] shadow-xs"
                                  : "bg-[#F4FAF5] text-[#47785C] border-[#CDE8D5] hover:border-[#10A66A] hover:bg-white"
                              }`}
                            >
                              {isSelected ? (
                                <Check className="h-3.5 w-3.5" />
                              ) : (
                                <span className="h-1.5 w-1.5 rounded-full bg-[#71917B]" />
                              )}
                              <span>{chip}</span>
                            </button>
                          );
                        })}
                      </div>
                    </div>

                    {/* Step 4: Specific Mandi Setup Details */}
                    <div className="space-y-2 pt-2 border-t border-[#DCEEE1]">
                      <label className="block text-xs font-bold text-[#123B29]">
                        Step 4: Specific Mandi Details or Equipment Notes
                      </label>
                      <textarea
                        rows={3}
                        placeholder="Tell us about your daily bag volume, number of cashier desks, printer models (e.g. TVS 3-inch, Epson), or digital weighbridge..."
                        value={formData.message}
                        onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                        className="w-full rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] p-3 text-xs text-[#063D2E] focus:border-[#087A50] focus:ring-1 focus:ring-[#087A50] focus:outline-none transition leading-relaxed"
                      />
                    </div>

                    {/* Error Banner */}
                    {errorMessage && (
                      <div className="rounded-xl border border-red-200 bg-red-50 p-3 text-xs text-red-700 flex items-center gap-2">
                        <AlertTriangle className="h-4 w-4 shrink-0 text-red-500" />
                        <span>{errorMessage}</span>
                      </div>
                    )}

                    {/* Submit Action */}
                    <button
                      type="submit"
                      disabled={submitting}
                      className="w-full rounded-xl bg-[#087A50] hover:bg-[#063D2E] py-4 text-sm font-bold text-white shadow-md transition disabled:opacity-50 flex items-center justify-center gap-2 group"
                    >
                      <Send className="h-4 w-4 group-hover:translate-x-0.5 transition-transform" />
                      <span>{submitting ? "Transmitting Mandi Consultation..." : "Send Mandi Consultation Request"}</span>
                    </button>

                    <div className="text-center text-[11px] text-[#71917B] flex items-center justify-center gap-2">
                      <Lock className="h-3 w-3 text-[#087A50]" />
                      <span>Strict data privacy. We never share your phone number with outside vendors.</span>
                    </div>
                  </form>
                )}
              </div>
            </div>
          </div>
        </div>
      </main>

      <PublicFooter />
    </div>
  );
}
