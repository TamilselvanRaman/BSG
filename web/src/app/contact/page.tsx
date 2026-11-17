"use client";

import { useState } from "react";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  CheckCircle2,
  Clock,
  HelpCircle,
  Mail,
  MapPin,
  MessageCircle,
  PhoneCall,
  Send,
  ShieldCheck,
} from "lucide-react";

export default function ContactPage() {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    shopName: "",
    marketLocation: "",
    subject: "New Shop License & Onboarding",
    message: "",
  });
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    await new Promise((r) => setTimeout(r, 700));
    setSubmitting(false);
    setSubmitted(true);
  }

  return (
    <div className="flex min-h-screen flex-col bg-slate-50">
      <PublicNavbar />

      <main className="flex-1 py-16 lg:py-24">
        <div className="mx-auto max-w-7xl px-6">
          {/* Header */}
          <div className="text-center max-w-2xl mx-auto">
            <h1 className="text-3xl font-black text-slate-900 sm:text-5xl">
              Get in Touch with Our Team
            </h1>
            <p className="mt-3 text-sm sm:text-base text-slate-600">
              Have questions about multi-product lot arrivals, bag-by-bag weighment scale, or custom APMC billing? We are here to help.
            </p>
          </div>

          <div className="mt-14 grid gap-10 lg:grid-cols-12 items-start">
            {/* Contact Info Cards */}
            <div className="lg:col-span-5 space-y-4">
              <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
                <div className="flex items-center gap-4">
                  <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-emerald-100 text-emerald-800">
                    <PhoneCall className="h-6 w-6" />
                  </div>
                  <div>
                    <h3 className="font-bold text-slate-900 text-sm">Direct Phone & WhatsApp</h3>
                    <p className="text-xs text-slate-500 mt-0.5">Quick consultation & instant demo</p>
                    <p className="text-sm font-bold text-blue-600 mt-1">+91 98412 38910</p>
                  </div>
                </div>
              </div>

              <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
                <div className="flex items-center gap-4">
                  <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-indigo-100 text-indigo-700">
                    <Mail className="h-6 w-6" />
                  </div>
                  <div>
                    <h3 className="font-bold text-slate-900 text-sm">Email Support</h3>
                    <p className="text-xs text-slate-500 mt-0.5">Formal onboarding & technical queries</p>
                    <p className="text-sm font-bold text-slate-800 mt-1">support@bsgmandi.io</p>
                  </div>
                </div>
              </div>

              <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
                <div className="flex items-center gap-4">
                  <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-emerald-100 text-emerald-700">
                    <Clock className="h-6 w-6" />
                  </div>
                  <div>
                    <h3 className="font-bold text-slate-900 text-sm">Support Hours</h3>
                    <p className="text-xs text-slate-500 mt-0.5">Monday to Saturday (Mandi Working Hours)</p>
                    <p className="text-xs font-semibold text-slate-800 mt-1">6:00 AM – 9:00 PM IST</p>
                  </div>
                </div>
              </div>

              <div className="rounded-2xl border border-blue-200 bg-blue-50/70 p-6 space-y-2">
                <div className="flex items-center gap-2 font-bold text-blue-900 text-xs">
                  <ShieldCheck className="h-4 w-4 text-blue-700" />
                  <span>30-Day Free Trial Guarantee</span>
                </div>
                <p className="text-[11px] text-blue-800 leading-relaxed">
                  No credit card required. Receive a fully activated shop license key with 3 login seats (1 Store Admin + 2 Staff Cashiers) and all 10 features unlocked.
                </p>
              </div>
            </div>

            {/* Main Interactive Contact Form */}
            <div className="lg:col-span-7">
              <div className="rounded-3xl border border-slate-200 bg-white p-8 shadow-xl shadow-slate-200/50">
                {submitted ? (
                  <div className="text-center py-10 space-y-4">
                    <div className="inline-flex h-16 w-16 items-center justify-center rounded-full bg-emerald-100 text-emerald-600">
                      <CheckCircle2 className="h-8 w-8" />
                    </div>
                    <h3 className="text-2xl font-bold text-slate-900">Message Delivered!</h3>
                    <p className="text-sm text-slate-600 max-w-md mx-auto">
                      Thank you, <strong>{formData.name}</strong>. Your enquiry regarding <strong>{formData.shopName || "your shop"}</strong> has been sent to our Mandi Support Desk. We will call you at <strong>{formData.phone}</strong> shortly.
                    </p>
                    <button
                      onClick={() => setSubmitted(false)}
                      className="mt-4 rounded-xl bg-slate-900 px-6 py-2.5 text-xs font-bold text-white hover:bg-slate-800 transition"
                    >
                      Send Another Message
                    </button>
                  </div>
                ) : (
                  <form onSubmit={handleSubmit} className="space-y-4 text-xs">
                    <div>
                      <h2 className="text-lg font-bold text-slate-900">
                        Send an Enquiry or Support Request
                      </h2>
                      <p className="text-slate-500 mt-0.5">
                        Our technical team responds to all mandi inquiries within 30 minutes.
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
                          value={formData.name}
                          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                          className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm focus:border-blue-600 focus:outline-none"
                        />
                      </div>
                      <div>
                        <label className="block font-bold text-slate-700 mb-1 uppercase tracking-wider text-[11px]">
                          Shop / Mandi Store Name
                        </label>
                        <input
                          type="text"
                          placeholder="e.g. Lakshmi Vegetable Mandi"
                          value={formData.shopName}
                          onChange={(e) => setFormData({ ...formData, shopName: e.target.value })}
                          className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm focus:border-blue-600 focus:outline-none"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                      <div>
                        <label className="block font-bold text-slate-700 mb-1 uppercase tracking-wider text-[11px]">
                          Phone / WhatsApp Number *
                        </label>
                        <input
                          type="tel"
                          required
                          placeholder="10-digit mobile number"
                          value={formData.phone}
                          onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                          className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm focus:border-blue-600 focus:outline-none"
                        />
                      </div>
                      <div>
                        <label className="block font-bold text-slate-700 mb-1 uppercase tracking-wider text-[11px]">
                          Email Address
                        </label>
                        <input
                          type="email"
                          placeholder="name@example.com"
                          value={formData.email}
                          onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                          className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm focus:border-blue-600 focus:outline-none"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                      <div>
                        <label className="block font-bold text-slate-700 mb-1 uppercase tracking-wider text-[11px]">
                          City / Market Location
                        </label>
                        <input
                          type="text"
                          placeholder="e.g. Coimbatore / Oddanchatram"
                          value={formData.marketLocation}
                          onChange={(e) => setFormData({ ...formData, marketLocation: e.target.value })}
                          className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none"
                        />
                      </div>
                      <div>
                        <label className="block font-bold text-slate-700 mb-1 uppercase tracking-wider text-[11px]">
                          Subject
                        </label>
                        <select
                          value={formData.subject}
                          onChange={(e) => setFormData({ ...formData, subject: e.target.value })}
                          className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none bg-white"
                        >
                          <option value="New Shop License & Onboarding">New Shop License & Onboarding</option>
                          <option value="Schedule Live Video Demo">Schedule Live Video Demo</option>
                          <option value="Weighment & Bill Customization">Weighment & Bill Customization</option>
                          <option value="Pricing & Enterprise Subscription">Pricing & Enterprise Subscription</option>
                          <option value="Technical Support">Technical Support</option>
                        </select>
                      </div>
                    </div>

                    <div>
                      <label className="block font-bold text-slate-700 mb-1 uppercase tracking-wider text-[11px]">
                        Message Details *
                      </label>
                      <textarea
                        required
                        rows={4}
                        placeholder="Tell us what commodities you trade, daily bag volume, or any custom questions..."
                        value={formData.message}
                        onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                        className="w-full rounded-xl border border-slate-300 p-3 text-sm focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none"
                      />
                    </div>

                    <button
                      type="submit"
                      disabled={submitting}
                      className="w-full flex items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-700 py-3.5 text-sm font-bold text-white shadow-md shadow-emerald-600/25 hover:from-emerald-700 hover:to-teal-800 transition disabled:opacity-50"
                    >
                      <Send className="h-4 w-4" />
                      <span>{submitting ? "Sending..." : "Submit Enquiry"}</span>
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
