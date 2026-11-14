import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";

export default function FaqPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <PublicNavbar />
      <main className="mx-auto max-w-4xl flex-1 px-6 py-16">
        <h1 className="text-3xl font-extrabold text-slate-900">Frequently Asked Questions</h1>
        <div className="mt-8 space-y-4">
          {[
            {
              q: "Is each business's data completely isolated?",
              a: "Yes. Every database table is scoped by tenantId and enforced by backend JWT middleware. Business A can never view or modify Business B records.",
            },
            {
              q: "Does the Flutter mobile app work without internet?",
              a: "Yes. The mobile app caches goods and partners locally in SQLite and queues offline entries for safe synchronization when connectivity returns.",
            },
            {
              q: "What happens when a bill is cancelled?",
              a: "Bills are never silently deleted. Cancelling a bill requires a reason, marks the bill CANCELLED, and atomically reverses stock and partner ledger balances.",
            },
          ].map((item) => (
            <div key={item.q} className="rounded-xl border border-slate-200 bg-white p-5">
              <h3 className="font-bold text-slate-900">{item.q}</h3>
              <p className="mt-2 text-sm text-slate-600">{item.a}</p>
            </div>
          ))}
        </div>
      </main>
      <PublicFooter />
    </div>
  );
}
