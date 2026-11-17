import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";

export default function TermsPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <PublicNavbar />
      <main className="mx-auto max-w-4xl flex-1 px-6 py-16">
        <h1 className="text-3xl font-extrabold text-slate-900">Terms & Conditions</h1>
        <p className="mt-4 text-sm leading-relaxed text-slate-600">
          By registering a business workspace on BSG SaaS, you agree to maintain
          accurate tax, weight, and billing records in compliance with applicable APMC and GST
          regulations. Subscription quotas and billing cycles are governed by your active plan.
        </p>
      </main>
      <PublicFooter />
    </div>
  );
}
