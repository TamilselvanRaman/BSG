"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import { apiFetch } from "@/lib/api";
import { Building2, CheckCircle2 } from "lucide-react";

export default function RegisterBusinessPage() {
  const router = useRouter();
  const [form, setForm] = useState({
    businessName: "",
    ownerFullName: "",
    username: "",
    password: "",
    email: "",
    phone: "",
    city: "",
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
    <div className="flex min-h-screen flex-col">
      <PublicNavbar />

      <main className="mx-auto flex w-full max-w-2xl flex-1 items-center px-6 py-12">
        <div className="w-full rounded-2xl border border-slate-200 bg-white p-8 shadow-sm">
          <div className="flex items-center gap-3">
            <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-blue-600 text-white">
              <Building2 className="h-5 w-5" />
            </div>
            <div>
              <h1 className="text-xl font-bold text-slate-900">
                Register Multi-Tenant Business Workspace
              </h1>
              <p className="text-xs text-slate-500">
                Instant tenant provisioning with 14-day trial subscription
              </p>
            </div>
          </div>

          {error && (
            <div className="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-xs font-medium text-red-700">
              {error}
            </div>
          )}

          {successData ? (
            <div className="mt-6 rounded-xl border border-emerald-200 bg-emerald-50 p-6 text-emerald-950">
              <div className="flex items-center gap-2 font-bold text-emerald-800">
                <CheckCircle2 className="h-5 w-5" />
                Workspace Provisioned Successfully!
              </div>
              <p className="mt-2 text-sm">
                Tenant Code: <strong>{successData.tenantCode}</strong> ({successData.businessName})
              </p>
              <p className="mt-1 text-sm">
                Admin Username: <strong>{successData.username}</strong>
              </p>
              <button
                onClick={() => router.push("/login")}
                className="mt-5 rounded-lg bg-slate-900 px-5 py-2.5 text-xs font-semibold text-white hover:bg-slate-800"
              >
                Proceed to Admin Login
              </button>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="mt-6 grid gap-4 sm:grid-cols-2">
              <div className="sm:col-span-2">
                <label className="block text-xs font-semibold uppercase text-slate-700">
                  Business / Trading Firm Name *
                </label>
                <input
                  type="text"
                  required
                  value={form.businessName}
                  onChange={(e) => setForm({ ...form, businessName: e.target.value })}
                  placeholder="e.g., Sri Lakshmi Commodity Traders"
                  className="mt-1 w-full rounded-lg border border-slate-300 px-3.5 py-2 text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase text-slate-700">
                  Owner / Admin Full Name *
                </label>
                <input
                  type="text"
                  required
                  value={form.ownerFullName}
                  onChange={(e) => setForm({ ...form, ownerFullName: e.target.value })}
                  className="mt-1 w-full rounded-lg border border-slate-300 px-3.5 py-2 text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase text-slate-700">
                  Admin Login Username *
                </label>
                <input
                  type="text"
                  required
                  value={form.username}
                  onChange={(e) => setForm({ ...form, username: e.target.value })}
                  placeholder="lakshmi_admin"
                  className="mt-1 w-full rounded-lg border border-slate-300 px-3.5 py-2 text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase text-slate-700">
                  Password *
                </label>
                <input
                  type="password"
                  required
                  minLength={6}
                  value={form.password}
                  onChange={(e) => setForm({ ...form, password: e.target.value })}
                  className="mt-1 w-full rounded-lg border border-slate-300 px-3.5 py-2 text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase text-slate-700">
                  Mobile / WhatsApp Number *
                </label>
                <input
                  type="text"
                  required
                  value={form.phone}
                  onChange={(e) => setForm({ ...form, phone: e.target.value })}
                  placeholder="+91 98450 00000"
                  className="mt-1 w-full rounded-lg border border-slate-300 px-3.5 py-2 text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase text-slate-700">
                  Business Email *
                </label>
                <input
                  type="email"
                  required
                  value={form.email}
                  onChange={(e) => setForm({ ...form, email: e.target.value })}
                  className="mt-1 w-full rounded-lg border border-slate-300 px-3.5 py-2 text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase text-slate-700">
                  Market Yard / City
                </label>
                <input
                  type="text"
                  value={form.city}
                  onChange={(e) => setForm({ ...form, city: e.target.value })}
                  placeholder="Yeshwanthpur APMC"
                  className="mt-1 w-full rounded-lg border border-slate-300 px-3.5 py-2 text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase text-slate-700">
                  GSTIN (Optional)
                </label>
                <input
                  type="text"
                  value={form.gstNumber}
                  onChange={(e) => setForm({ ...form, gstNumber: e.target.value })}
                  className="mt-1 w-full rounded-lg border border-slate-300 px-3.5 py-2 text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase text-slate-700">
                  Subscription Plan
                </label>
                <select
                  value={form.planCode}
                  onChange={(e) => setForm({ ...form, planCode: e.target.value })}
                  className="mt-1 w-full rounded-lg border border-slate-300 px-3.5 py-2 text-sm"
                >
                  <option value="STARTER_MANDI">Starter Mandi Plan (₹1,499/mo)</option>
                  <option value="PROFESSIONAL_SAAS">Professional Smart Chart Suite (₹2,999/mo)</option>
                  <option value="ENTERPRISE_MULTI">Enterprise Trade Network (₹5,999/mo)</option>
                </select>
              </div>

              <div className="sm:col-span-2 pt-2">
                <button
                  type="submit"
                  disabled={loading}
                  className="w-full rounded-lg bg-blue-600 py-3 text-sm font-semibold text-white hover:bg-blue-700 disabled:opacity-50"
                >
                  {loading ? "Provisioning Tenant Workspace..." : "Create Business Workspace"}
                </button>
              </div>
            </form>
          )}
        </div>
      </main>

      <PublicFooter />
    </div>
  );
}
