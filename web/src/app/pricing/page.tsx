import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";

export default function PricingPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <PublicNavbar />
      <main className="mx-auto max-w-6xl flex-1 px-6 py-16">
        <h1 className="text-3xl font-extrabold text-slate-900">SaaS Subscription Plans</h1>
        <p className="mt-2 text-slate-600">
          Enforced server-side quotas for users, goods records, partners, reports, and PDF exports.
        </p>
        <div className="mt-8 grid gap-6 md:grid-cols-3">
          {[
            {
              code: "STARTER_MANDI",
              name: "Starter Mandi Plan",
              monthly: "₹1,499/mo",
              annual: "₹14,990/yr",
              limits: "3 Users • 250 Goods • 500 Partners",
            },
            {
              code: "PROFESSIONAL_SAAS",
              name: "Professional Smart Chart Suite",
              monthly: "₹2,999/mo",
              annual: "₹29,990/yr",
              limits: "15 Users • 5,000 Goods • 10,000 Partners • RMC & Gross Profit Reports",
            },
            {
              code: "ENTERPRISE_MULTI",
              name: "Enterprise Trade Network",
              monthly: "₹5,999/mo",
              annual: "₹59,990/yr",
              limits: "100 Users • 100k Goods • Automated Backups & API Access",
            },
          ].map((p) => (
            <div key={p.code} className="rounded-xl border border-slate-200 bg-white p-6">
              <h3 className="text-lg font-bold text-slate-900">{p.name}</h3>
              <p className="mt-3 text-2xl font-extrabold text-blue-600">{p.monthly}</p>
              <p className="text-xs text-slate-500">or {p.annual} billed annually</p>
              <p className="mt-4 text-sm text-slate-700">{p.limits}</p>
              <Link
                href="/register"
                className="mt-6 block rounded-lg bg-slate-900 py-2.5 text-center text-xs font-semibold text-white"
              >
                Start 14-Day Trial
              </Link>
            </div>
          ))}
        </div>
      </main>
      <PublicFooter />
    </div>
  );
}
