"use client";

import { useState } from "react";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  CheckCircle2,
  Clock,
  Mail,
  MapPin,
  PhoneCall,
  Send,
  ShieldCheck,
} from "lucide-react";

export default function ContactPage() {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    businessName: "",
    businessType: "Vegetable & Fruit Mandi",
    location: "",
    usersCount: "3 Users (Standard License)",
    message: "",
  });
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    await new Promise((r) => setTimeout(r, 600));
    setSubmitting(false);
    setSubmitted(true);
  }

  return (
    <div className="flex min-h-screen flex-col bg-[#F4FAF5] text-[#123B29] font-sans">
      <PublicNavbar />

      <main className="flex-1 py-16 lg:py-24">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          {/* Header */}
          <div className="text-center max-w-2xl mx-auto">
            <span className="text-xs font-bold uppercase tracking-widest text-[#087A50]">
              Get In Touch With Specialists
            </span>
            <h1 className="mt-3 text-3xl font-black text-[#063D2E] sm:text-5xl">
              Connect with Our Mandi Architecture Team
            </h1>
            <p className="mt-3 text-sm sm:text-base text-[#47785C]">
              Have questions about multi-product lot arrivals, bag weighment scales, or custom APMC billing? We are here to help.
            </p>
          </div>

          <div className="mt-14 grid gap-10 lg:grid-cols-12 items-start">
            {/* Contact Info Cards */}
            <div className="lg:col-span-5 space-y-4">
              <div className="rounded-2xl border border-[#CDE8D5] bg-white p-6 shadow-xs">
                <div className="flex items-center gap-4">
                  <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-[#E8F5EC] text-[#087A50]">
                    <PhoneCall className="h-6 w-6" />
                  </div>
                  <div>
                    <h3 className="font-bold text-[#063D2E] text-sm">Direct Phone & WhatsApp</h3>
                    <p className="text-xs text-[#47785C] mt-0.5">Quick consultation & instant demo</p>
                    <p className="text-sm font-bold text-[#087A50] mt-1">+91 98412 38910</p>
                  </div>
                </div>
              </div>

              <div className="rounded-2xl border border-[#CDE8D5] bg-white p-6 shadow-xs">
                <div className="flex items-center gap-4">
                  <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-[#E8F5EC] text-[#087A50]">
                    <Mail className="h-6 w-6" />
                  </div>
                  <div>
                    <h3 className="font-bold text-[#063D2E] text-sm">Email Support</h3>
                    <p className="text-xs text-[#47785C] mt-0.5">Formal onboarding & technical queries</p>
                    <p className="text-sm font-bold text-[#123B29] mt-1">support@bsgmandi.io</p>
                  </div>
                </div>
              </div>

              <div className="rounded-2xl border border-[#CDE8D5] bg-white p-6 shadow-xs">
                <div className="flex items-center gap-4">
                  <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-[#E8F5EC] text-[#087A50]">
                    <Clock className="h-6 w-6" />
                  </div>
                  <div>
                    <h3 className="font-bold text-[#063D2E] text-sm">Mandi Working Support Hours</h3>
                    <p className="text-xs text-[#47785C] mt-0.5">Monday to Saturday</p>
                    <p className="text-xs font-semibold text-[#123B29] mt-1">5:30 AM – 9:00 PM IST</p>
                  </div>
                </div>
              </div>

              <div className="rounded-2xl border border-emerald-200 bg-[#E8F5EC]/70 p-6 space-y-2">
                <div className="flex items-center gap-2 font-bold text-[#063D2E] text-xs">
                  <ShieldCheck className="h-4 w-4 text-[#087A50]" />
                  <span>30-Day Full Feature Trial Guarantee</span>
                </div>
                <p className="text-xs text-[#47785C] leading-relaxed">
                  No credit card required. Experience live smart charts, digital bag scales, and cash drawer reconciliations right on your mandi floor.
                </p>
              </div>
            </div>

            {/* Lead Capture Form */}
            <div className="lg:col-span-7">
              <div className="rounded-3xl border border-[#CDE8D5] bg-white p-8 sm:p-10 shadow-sm">
                {submitted ? (
                  <div className="py-12 text-center space-y-3">
                    <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-[#E8F5EC] text-[#087A50]">
                      <CheckCircle2 className="h-8 w-8" />
                    </div>
                    <h3 className="text-xl font-bold text-[#063D2E]">Message Received Successfully</h3>
                    <p className="text-xs text-[#47785C] max-w-md mx-auto">
                      Thank you for contacting BSG. Our agricultural solution engineer will reach out to schedule your live walkthrough.
                    </p>
                  </div>
                ) : (
                  <form onSubmit={handleSubmit} className="space-y-4 text-xs">
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="block font-bold text-[#123B29] mb-1">Your Full Name *</label>
                        <input
                          type="text"
                          required
                          placeholder="e.g. Anand Sharma"
                          value={formData.name}
                          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                          className="w-full rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] p-2.5 text-sm text-[#123B29] focus:border-[#10A66A] focus:outline-none"
                        />
                      </div>
                      <div>
                        <label className="block font-bold text-[#123B29] mb-1">Mandi Business Name *</label>
                        <input
                          type="text"
                          required
                          placeholder="e.g. Sharma Agro Traders"
                          value={formData.businessName}
                          onChange={(e) => setFormData({ ...formData, businessName: e.target.value })}
                          className="w-full rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] p-2.5 text-sm text-[#123B29] focus:border-[#10A66A] focus:outline-none"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="block font-bold text-[#123B29] mb-1">Contact Phone Number *</label>
                        <input
                          type="tel"
                          required
                          placeholder="+91-9876543210"
                          value={formData.phone}
                          onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                          className="w-full rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] p-2.5 text-sm text-[#123B29] focus:border-[#10A66A] focus:outline-none"
                        />
                      </div>
                      <div>
                        <label className="block font-bold text-[#123B29] mb-1">Official Email Address *</label>
                        <input
                          type="email"
                          required
                          placeholder="anand@sharmaagro.in"
                          value={formData.email}
                          onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                          className="w-full rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] p-2.5 text-sm text-[#123B29] focus:border-[#10A66A] focus:outline-none"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="block font-bold text-[#123B29] mb-1">Business Domain</label>
                        <select
                          value={formData.businessType}
                          onChange={(e) => setFormData({ ...formData, businessType: e.target.value })}
                          className="w-full rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] p-2.5 text-sm text-[#123B29]"
                        >
                          <option value="Vegetable & Fruit Mandi">Vegetable & Fruit Mandi</option>
                          <option value="APMC Commission Agent">APMC Commission Agent</option>
                          <option value="Grain & Spices Wholesale">Grain & Spices Wholesale</option>
                          <option value="Multi-Yard Enterprise">Multi-Yard Enterprise</option>
                        </select>
                      </div>
                      <div>
                        <label className="block font-bold text-[#123B29] mb-1">Market Yard City / State *</label>
                        <input
                          type="text"
                          required
                          placeholder="e.g. Oddanchatram, Tamil Nadu"
                          value={formData.location}
                          onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                          className="w-full rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] p-2.5 text-sm text-[#123B29] focus:border-[#10A66A] focus:outline-none"
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block font-bold text-[#123B29] mb-1">Message or Specific Mandi Setup Details</label>
                      <textarea
                        rows={3}
                        placeholder="Tell us about your commodity volume, number of cashier desks, printer models..."
                        value={formData.message}
                        onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                        className="w-full rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] p-2.5 text-sm text-[#123B29] focus:border-[#10A66A] focus:outline-none"
                      />
                    </div>

                    <button
                      type="submit"
                      disabled={submitting}
                      className="w-full rounded-xl bg-[#087A50] hover:bg-[#063D2E] py-3.5 text-sm font-bold text-white shadow-md transition disabled:opacity-50 flex items-center justify-center gap-2"
                    >
                      <Send className="h-4 w-4" />
                      <span>{submitting ? "Sending Request..." : "Send Mandi Consultation Request"}</span>
                    </button>
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
