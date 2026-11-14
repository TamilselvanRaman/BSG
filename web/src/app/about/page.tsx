import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";

export default function AboutPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <PublicNavbar />
      <main className="mx-auto max-w-4xl flex-1 px-6 py-16">
        <h1 className="text-3xl font-extrabold text-slate-900">About CLICK Smart Chart SaaS</h1>
        <p className="mt-4 leading-relaxed text-slate-600">
          CLICK Smart Chart SaaS modernizes traditional commodity, mandi, and wholesale goods
          accounting into a multi-tenant cloud and offline-capable mobile platform. We combine
          high-speed arrival lot charting, 3-step billing, and double-verified partner ledgers with
          strict tenant data isolation.
        </p>
      </main>
      <PublicFooter />
    </div>
  );
}
