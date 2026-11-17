"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import { apiFetch } from "@/lib/api";
import {
  ArrowRight,
  BarChart3,
  Building2,
  CheckCircle2,
  ShieldCheck,
  Sparkles,
} from "lucide-react";

export default function RegisterBusinessPage() {
  const router = useRouter();
  const [form, setForm] = useState({
    businessName: "",
    ownerFullName: "",
    username: "",
    password: "",
    email: "",
    phone: "",
    city: "Tamil Nadu",
    gstNumber: "",
    planCode: "PROFESSIONAL_SAAS",
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [successData, setSuccessData] = useState<any | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      const res = await apiFetch("/auth/register-business", {
        method: "POST",
        body: JSON.stringify(form),
      });
      setSuccessData(res);
    } catch (err: any) {
      setError(err.message || "Registration failed.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex min-h-screen flex-col bg-slate-50">
      <PublicNavbar />

      <main className="mx-auto flex w-full max-w-2xl flex-1 items-center px-6 py-14">
        <div className="w-full rounded-3xl border border-slate-200 bg-white p-8 sm:p-10 shadow-xl shadow-slate-200/50">
          {successData ? (
            <div className="space-y-6 text-center py-6">
              <div className="inline-flex h-16 w-16 items-center justify-center rounded-full bg-emerald-100 text-emerald-600">
                <CheckCircle2 className="h-8 w-8" />
              </div>
              <div>
                <h2 className="text-2xl font-bold text-slate-900">
                  Shop Provisioned Successfully!
                </h2>
                <p className="mt-1 text-xs text-slate-500">
                  Your tenant workspace, Store Admin credentials, and 30-Day Free Trial License are ready.
                </p>
              </div>

              <div className="rounded-2xl border border-slate-200 bg-slate-50 p-4 text-left font-mono text-xs space-y-1.5">
                <p><strong>Shop Code:</strong> {successData.tenant?.code}</p>
                <p><strong>Business:</strong> {successData.tenant?.name}</p>
                <p><strong>Admin Login:</strong> {successData.admin?.username}</p>
                <p><strong>License Limit:</strong> Max 3 Users (1 Admin + 2 Staff)</p>
                <p className="text-emerald-700"><strong>Status:</strong> 30-Day Free Trial Active (All Features)</p>
              </div>

              <Link
                href="/login"
                className="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-700 px-6 py-3 text-xs font-bold text-white shadow hover:from-emerald-700 hover:to-teal-800 transition"
              >
                <span>Proceed to Sign In</span>
                <ArrowRight className="h-4 w-4" />
              </Link>
            </div>
          ) : (
            <div>
              <div className="flex items-center gap-3">
                <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-emerald-600 text-white shadow-md shadow-emerald-500/20">
                  <Building2 className="h-5 w-5" />
                </div>
                <div>
                  <h1 className="text-xl font-bold text-slate-900">
                    Register Mandi Shop Workspace
                  </h1>
                  <p className="text-xs text-slate-500">
                    Instant tenant provisioning with 30-day trial and 3-seat license
                  </p>
                </div>
              </div>

              {error && (
                <div className="mt-4 rounded-xl border border-red-200 bg-red-50 p-3.5 text-xs font-semibold text-red-700">
                  {error}
                </div>
              )}

              <form onSubmit={handleSubmit} className="mt-6 space-y-4 text-xs">
                <div>
                  <label className="block font-bold text-slate-700 uppercase tracking-wider mb-1 text-[11px]">
                    Shop / Store Name *
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. BSG Trading Corp / Lakshmi Vegetable Mandi"
                    value={form.businessName}
                    onChange={(e) => setForm({ ...form, businessName: e.target.value })}
                    className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm focus:border-blue-600 focus:outline-none"
                  />
                </div>

                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  <div>
                    <label className="block font-bold text-slate-700 uppercase tracking-wider mb-1 text-[11px]">
                      Owner Full Name *
                    </label>
                    <input
                      type="text"
                      required
                      placeholder="e.g. Ramanathan Kannan"
                      value={form.ownerFullName}
                      onChange={(e) => setForm({ ...form, ownerFullName: e.target.value })}
                      className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm focus:border-blue-600 focus:outline-none"
                    />
                  </div>
                  <div>
                    <label className="block font-bold text-slate-700 uppercase tracking-wider mb-1 text-[11px]">
                      City / Mandi Location *
                    </label>
                    <input
                      type="text"
                      required
                      placeholder="e.g. Coimbatore / Oddanchatram"
                      value={form.city}
                      onChange={(e) => setForm({ ...form, city: e.target.value })}
                      className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm focus:border-blue-600 focus:outline-none"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  <div>
                    <label className="block font-bold text-slate-700 uppercase tracking-wider mb-1 text-[11px]">
                      Owner Phone *
                    </label>
                    <input
                      type="tel"
                      required
                      placeholder="10-digit mobile number"
                      value={form.phone}
                      onChange={(e) => setForm({ ...form, phone: e.target.value })}
                      className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm focus:border-blue-600 focus:outline-none"
                    />
                  </div>
                  <div>
                    <label className="block font-bold text-slate-700 uppercase tracking-wider mb-1 text-[11px]">
                      Owner Email *
                    </label>
                    <input
                      type="email"
                      required
                      placeholder="owner@bsg.com"
                      value={form.email}
                      onChange={(e) => setForm({ ...form, email: e.target.value })}
                      className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm focus:border-blue-600 focus:outline-none"
                    />
                  </div>
                </div>

                <div className="rounded-2xl border border-slate-200 bg-slate-50/70 p-4 space-y-3">
                  <span className="font-bold text-slate-800 uppercase tracking-wider text-[11px] block">
                    Store Admin Credentials
                  </span>
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                    <div>
                      <label className="block font-semibold text-slate-600 mb-1 text-[11px]">
                        Admin Username *
                      </label>
                      <input
                        type="text"
                        required
                        placeholder="e.g. raman_admin"
                        value={form.username}
                        onChange={(e) => setForm({ ...form, username: e.target.value })}
                        className="w-full rounded-xl border border-slate-300 bg-white px-3.5 py-2 text-sm focus:border-blue-600 focus:outline-none"
                      />
                    </div>
                    <div>
                      <label className="block font-semibold text-slate-600 mb-1 text-[11px]">
                        Initial Password *
                      </label>
                      <input
                        type="password"
                        required
                        placeholder="At least 6 characters"
                        value={form.password}
                        onChange={(e) => setForm({ ...form, password: e.target.value })}
                        className="w-full rounded-xl border border-slate-300 bg-white px-3.5 py-2 text-sm focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none"
                      />
                    </div>
                  </div>
                </div>

                <div className="rounded-xl border border-emerald-200 bg-emerald-50/60 p-3 flex items-start gap-2.5 text-xs text-emerald-950">
                  <ShieldCheck className="h-4 w-4 text-emerald-700 shrink-0 mt-0.5" />
                  <span>
                    Includes 30-Day Free Trial with 3 Authorized Login Seats (1 Store Admin + 2 Staff/Cashiers) and all 10 Mandi features unlocked.
                  </span>
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  className="w-full flex items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-700 py-3 text-sm font-bold text-white shadow-md shadow-emerald-600/25 hover:from-emerald-700 hover:to-teal-800 transition disabled:opacity-50"
                >
                  <span>{loading ? "Provisioning Shop..." : "Create Shop Workspace"}</span>
                  <ArrowRight className="h-4 w-4" />
                </button>
              </form>

              <div className="mt-6 text-center text-xs text-slate-500">
                Already registered?{" "}
                <Link href="/login" className="font-bold text-emerald-700 hover:underline">
                  Sign In to Workspace
                </Link>
              </div>
            </div>
          )}
        </div>
      </main>

      <PublicFooter />
    </div>
  );
}
