import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";

export default function SolutionsPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <PublicNavbar />
      <main className="mx-auto max-w-5xl flex-1 px-6 py-16">
        <h1 className="text-3xl font-extrabold text-slate-900">Industry Solutions</h1>
        <p className="mt-2 text-slate-600">
          Configured for wholesale commodity mandis, commission agents, and multi-branch traders.
        </p>
        <div className="mt-8 grid gap-6 md:grid-cols-3">
          {[
            {
              title: "APMC & Mandi Commission Agents",
              desc: "Manage farmer arrivals, auction lots, labour/hamali deductions, RMC market cess, and instant patti / purchase bills.",
            },
            {
              title: "Wholesale Goods Distributors",
              desc: "Multi-item sales billing, buyer credit limits, running ledger statements, and product-wise gross profit tracking.",
            },
            {
              title: "Multi-Branch Trading Enterprises",
              desc: "Isolated tenant workspaces, role-based employee permissions, and centralized SaaS governance.",
            },
          ].map((s) => (
            <div key={s.title} className="rounded-xl border border-slate-200 bg-white p-6">
              <h3 className="font-bold text-slate-900">{s.title}</h3>
              <p className="mt-2 text-sm text-slate-600">{s.desc}</p>
            </div>
          ))}
        </div>
      </main>
      <PublicFooter />
    </div>
  );
}
