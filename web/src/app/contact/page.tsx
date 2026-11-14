import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";

export default function ContactPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <PublicNavbar />
      <main className="mx-auto max-w-4xl flex-1 px-6 py-16">
        <h1 className="text-3xl font-extrabold text-slate-900">Contact Enterprise Support</h1>
        <p className="mt-2 text-slate-600">
          Reach our onboarding and technical architecture team for custom mandi workflows or bulk
          migration.
        </p>
        <div className="mt-6 rounded-xl border border-slate-200 bg-white p-6 text-sm text-slate-700">
          <p><strong>Email:</strong> support@clicksmartchart.io</p>
          <p className="mt-2"><strong>Helpline:</strong> +91-800-555-0199 (Mon–Sat, 8:00 AM – 8:00 PM IST)</p>
        </div>
      </main>
      <PublicFooter />
    </div>
  );
}
