import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  Apple,
  ArrowRight,
  Boxes,
  CheckCircle2,
  Coins,
  Cpu,
  PackagePlus,
  Scale,
  ShieldCheck,
  Sparkles,
  Truck,
  Users,
  Utensils,
  Wheat,
  XCircle,
  Zap,
} from "lucide-react";

const SOLUTIONS = [
  {
    icon: Utensils,
    title: "Vegetable Mandis & Onion/Potato Merchants",
    tagline: "High-volume perishables with rapid bag weighment and daily evening cash tallying",
    challenges: [
      "Rapidly arriving farmer trucks with diverse grades (Tomato Hybrid, Country, Red Onion)",
      "Varying bag tare weights causing daily weight shrinkage and reconciliation disputes",
      "Fast counter cash sales needing thermal printed receipts in under 5 seconds",
    ],
    mandiOsSolution: [
      "Multi-product arrival entry capturing whole truck manifest in a single screen",
      "Bag-by-bag weighment scale table auto-calculating net commodity weight",
      "Instant thermal bill generation with coolie/labour and transport charges auto-added",
      "Closing currency denomination breakdown for accurate cash drawer balance",
    ],
  },
  {
    icon: Apple,
    title: "Fruit Commission Agents & Cold Storage",
    tagline: "Box and crate tracking with lot-wise profit margins and buyer credit controls",
    challenges: [
      "Grading and tracking fruit crates across multiple orchard arrivals and cold stores",
      "Long buyer credit cycles resulting in outstanding debt recovery risks",
      "Complex commission percentages and ripening/handling expense splits",
    ],
    mandiOsSolution: [
      "Support for Crate, Box, and Kg unit measures with lot-wise remaining quantity tracking",
      "Automated Buyer Credit Limit warnings and overdue payment aging timelines",
      "Customizable commission deduction rules and pre-season farmer advance tracking",
      "One-click WhatsApp statements with PDF balance sheets sent directly to buyers",
    ],
  },
  {
    icon: Wheat,
    title: "Grains, Oilseeds & Pulses Wholesale Mandis",
    tagline: "Weighbridge gross/tare entries, APMC market cess, and bulk buyer delivery manifests",
    challenges: [
      "Large quintal and metric ton shipments requiring weighbridge scale verification",
      "Strict statutory APMC cess and market committee compliance reporting",
      "Double-entry supplier settlements accounting for gunny bag charges and moisture loss",
    ],
    mandiOsSolution: [
      "Quintal-based pricing with gross weight, tare weight, and moisture cut deductions",
      "Built-in RMC Market Cess calculation and monthly tax compliance registers",
      "Immutable double-entry supplier ledgers showing gross value, cess, deductions, and net dues",
      "Comprehensive vehicle-wise arrival and dispatch registers for audit compliance",
    ],
  },
];

export default function SolutionsPage() {
  return (
    <div className="flex min-h-screen flex-col bg-slate-50">
      <PublicNavbar />

      {/* Header */}
      <section className="border-b border-slate-200/80 bg-white py-16 lg:py-24">
        <div className="mx-auto max-w-7xl px-6 text-center">
          <span className="inline-flex items-center gap-1.5 rounded-full bg-blue-50 border border-blue-200 px-3.5 py-1 text-xs font-bold text-blue-700">
            <Cpu className="h-3.5 w-3.5" />
            Specialized Agricultural Trade Solutions
          </span>
          <h1 className="mt-5 text-4xl font-black text-slate-900 sm:text-5xl lg:text-6xl tracking-tight">
            Built for Your Specific Commodity Workflow
          </h1>
          <p className="mt-4 text-base sm:text-lg text-slate-600 max-w-2xl mx-auto leading-relaxed">
            Whether you trade perishable vegetables, graded fruits, or bulk grains, CLICK Smart Chart adapts to your trade conventions, units, and credit cycles.
          </p>
        </div>
      </section>

      {/* Solutions Cards */}
      <section className="py-20">
        <div className="mx-auto max-w-7xl px-6">
          <div className="space-y-12">
            {SOLUTIONS.map((sol) => {
              const Icon = sol.icon;

              return (
                <div
                  key={sol.title}
                  className="rounded-3xl border border-slate-200 bg-white p-8 lg:p-12 shadow-sm hover:shadow-md transition"
                >
                  <div className="flex items-center gap-4">
                    <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-blue-100 text-blue-700">
                      <Icon className="h-7 w-7" />
                    </div>
                    <div>
                      <h2 className="text-2xl font-bold text-slate-900">{sol.title}</h2>
                      <p className="text-xs text-slate-500 mt-1">{sol.tagline}</p>
                    </div>
                  </div>

                  <div className="mt-8 grid gap-8 md:grid-cols-2 pt-4 border-t border-slate-100">
                    {/* The Problem */}
                    <div className="rounded-2xl border border-red-100 bg-red-50/50 p-6 space-y-3">
                      <span className="text-xs font-bold uppercase tracking-wider text-red-700 flex items-center gap-1.5">
                        <XCircle className="h-4 w-4 text-red-500" />
                        Common Industry Challenges
                      </span>
                      <div className="space-y-2.5 pt-1 text-xs text-red-900">
                        {sol.challenges.map((c) => (
                          <div key={c} className="flex items-start gap-2">
                            <span className="text-red-400 font-bold">•</span>
                            <span>{c}</span>
                          </div>
                        ))}
                      </div>
                    </div>

                    {/* Mandi OS Solution */}
                    <div className="rounded-2xl border border-emerald-100 bg-emerald-50/50 p-6 space-y-3">
                      <span className="text-xs font-bold uppercase tracking-wider text-emerald-800 flex items-center gap-1.5">
                        <CheckCircle2 className="h-4 w-4 text-emerald-600" />
                        Mandi OS Solves This With
                      </span>
                      <div className="space-y-2.5 pt-1 text-xs text-emerald-950 font-medium">
                        {sol.mandiOsSolution.map((s) => (
                          <div key={s} className="flex items-start gap-2">
                            <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600 shrink-0 mt-0.5" />
                            <span>{s}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Comparison: Traditional Paper Mandi vs Mandi OS */}
      <section className="py-20 bg-white border-t border-slate-200">
        <div className="mx-auto max-w-5xl px-6">
          <div className="text-center max-w-2xl mx-auto">
            <span className="text-xs font-bold uppercase tracking-widest text-blue-600">
              Operational Comparison
            </span>
            <h2 className="mt-2 text-3xl font-black text-slate-900">
              Manual Paper Bookkeeping vs Mandi OS Cloud
            </h2>
            <p className="mt-2 text-xs text-slate-500">
              Why leading commission shops across India are replacing paper diaries with Mandi OS.
            </p>
          </div>

          <div className="mt-12 overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="border-b border-slate-200 bg-slate-50 uppercase tracking-wider text-[11px] text-slate-600">
                <tr>
                  <th className="p-4 font-bold">Operational Aspect</th>
                  <th className="p-4 font-bold text-red-700">Old Manual Paper Bookkeeping</th>
                  <th className="p-4 font-bold text-blue-700">Mandi OS Cloud Platform</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-slate-700">
                <tr>
                  <td className="p-4 font-semibold text-slate-900">Bag Weighment Calculation</td>
                  <td className="p-4 text-red-600">Manual paper additions prone to math mistakes</td>
                  <td className="p-4 font-bold text-emerald-700">Digital scale table summing bags & weights instantly</td>
                </tr>
                <tr>
                  <td className="p-4 font-semibold text-slate-900">Day-End Cash Reconciliation</td>
                  <td className="p-4 text-red-600">1-2 hours of manual ledger counting with cash leaks</td>
                  <td className="p-4 font-bold text-emerald-700">3-minute currency denomination counter with audit log</td>
                </tr>
                <tr>
                  <td className="p-4 font-semibold text-slate-900">Buyer Bill Dispatch</td>
                  <td className="p-4 text-red-600">Handwritten slips easily lost or disputed</td>
                  <td className="p-4 font-bold text-emerald-700">1-click WhatsApp bill PDF & thermal printed receipt</td>
                </tr>
                <tr>
                  <td className="p-4 font-semibold text-slate-900">Multi-User Seat Security</td>
                  <td className="p-4 text-red-600">No audit trail of who modified rates or received cash</td>
                  <td className="p-4 font-bold text-emerald-700">Strict 3-seat quota with immutable operator audit trail</td>
                </tr>
                <tr>
                  <td className="p-4 font-semibold text-slate-900">Floor Mobility & Power Outage</td>
                  <td className="p-4 text-red-600">Tied to a bulky physical desk or unorganized paper slips</td>
                  <td className="p-4 font-bold text-emerald-700">Rugged Android handheld tablet with offline local sync</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-20 bg-slate-900 text-white text-center border-t border-slate-800">
        <div className="mx-auto max-w-4xl px-6 space-y-6">
          <h2 className="text-3xl font-black sm:text-4xl">
            Modernize Your Mandi Operations Today
          </h2>
          <p className="text-sm text-slate-400 max-w-xl mx-auto">
            Join hundreds of APMC commission agents and wholesale commodity merchants who save 2 hours every evening with Mandi OS.
          </p>
          <div className="pt-2">
            <Link
              href="/register"
              className="inline-flex items-center gap-2 rounded-xl bg-blue-600 px-7 py-3 text-sm font-bold text-white shadow-lg hover:bg-blue-700 transition"
            >
              <span>Start 30-Day Free Trial</span>
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </div>
      </section>

      <PublicFooter />
    </div>
  );
}
