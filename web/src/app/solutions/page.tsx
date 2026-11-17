import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  Apple,
  ArrowRight,
  Boxes,
  CheckCircle2,
  Coins,
  PackagePlus,
  Scale,
  ShieldCheck,
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
    <div className="flex min-h-screen flex-col bg-[#F4FAF5] text-[#123B29] font-sans">
      <PublicNavbar />

      {/* Header */}
      <section className="border-b border-[#CDE8D5] bg-gradient-to-b from-[#F4FAF5] to-[#E8F5EC] py-16 lg:py-24">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 text-center">
          <span className="text-xs font-bold uppercase tracking-widest text-[#087A50]">
            Agricultural Wholesale Verticals
          </span>
          <h1 className="mt-3 text-4xl font-black text-[#063D2E] sm:text-5xl lg:text-6xl tracking-tight">
            Built for Your Specific Commodity Workflow
          </h1>
          <p className="mt-4 text-base sm:text-lg text-[#47785C] max-w-2xl mx-auto leading-relaxed">
            Whether you trade perishable vegetables, graded fruits, or bulk grains, BSG adapts to your trade conventions, units, and credit cycles.
          </p>
        </div>
      </section>

      {/* Solutions Cards */}
      <section className="py-20">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="space-y-12">
            {SOLUTIONS.map((sol) => {
              const Icon = sol.icon;

              return (
                <div
                  key={sol.title}
                  className="rounded-3xl border border-[#CDE8D5] bg-white p-8 lg:p-12 shadow-xs hover:border-[#10A66A] transition-all"
                >
                  <div className="flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between border-b border-[#DCEEE1] pb-6">
                    <div className="flex items-center gap-4">
                      <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-[#E8F5EC] text-[#087A50]">
                        <Icon className="h-7 w-7" />
                      </div>
                      <div>
                        <h2 className="text-xl sm:text-2xl font-bold text-[#063D2E]">
                          {sol.title}
                        </h2>
                        <p className="text-xs sm:text-sm text-[#47785C] mt-1 font-medium">
                          {sol.tagline}
                        </p>
                      </div>
                    </div>
                    <Link
                      href="/register"
                      className="inline-flex items-center justify-center gap-2 rounded-xl bg-[#087A50] hover:bg-[#063D2E] px-5 py-2.5 text-xs font-bold text-white shadow-xs transition"
                    >
                      <span>Start 30-Day Free Trial</span>
                      <ArrowRight className="h-3.5 w-3.5" />
                    </Link>
                  </div>

                  <div className="mt-8 grid gap-8 lg:grid-cols-2">
                    {/* Traditional Inefficiencies */}
                    <div className="rounded-2xl border border-red-200 bg-red-50/40 p-6 space-y-3">
                      <h3 className="text-xs font-bold uppercase tracking-wider text-[#C2413B]">
                        Traditional Mandi Inefficiencies
                      </h3>
                      <ul className="space-y-2.5 text-xs text-[#123B29]">
                        {sol.challenges.map((c) => (
                          <li key={c} className="flex items-start gap-2">
                            <span className="text-[#C2413B] font-bold text-sm leading-none mt-0.5">•</span>
                            <span>{c}</span>
                          </li>
                        ))}
                      </ul>
                    </div>

                    {/* BSG Solution */}
                    <div className="rounded-2xl border border-emerald-200 bg-[#E8F5EC]/60 p-6 space-y-3">
                      <h3 className="text-xs font-bold uppercase tracking-wider text-[#087A50]">
                        BSG Enterprise Solution
                      </h3>
                      <ul className="space-y-2.5 text-xs text-[#123B29]">
                        {sol.mandiOsSolution.map((s) => (
                          <li key={s} className="flex items-start gap-2">
                            <CheckCircle2 className="h-4 w-4 text-[#10A66A] shrink-0 mt-0.5" />
                            <span>{s}</span>
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Conversion Banner */}
      <section className="py-20 bg-[#063D2E] text-white">
        <div className="mx-auto max-w-4xl px-4 text-center space-y-6">
          <span className="text-xs font-bold uppercase tracking-widest text-[#10A66A]">
            Tailored Industry Onboarding
          </span>
          <h2 className="text-3xl font-black sm:text-5xl">
            Modernize Your Mandi Workflow in 24 Hours
          </h2>
          <p className="text-sm text-[#C4E2CF] max-w-xl mx-auto">
            Get your shop setup with commodity masters, electronic scale hooks, and mobile tablets.
          </p>
          <div className="pt-2 flex flex-wrap justify-center gap-4">
            <Link
              href="/register"
              className="rounded-xl bg-[#10A66A] hover:bg-[#087A50] px-7 py-3.5 text-sm font-bold text-white shadow-lg transition"
            >
              Start 30-Day Free Trial
            </Link>
            <Link
              href="/contact"
              className="rounded-xl border border-[#0A503B] bg-[#0A503B] hover:bg-[#0E664C] px-7 py-3.5 text-sm font-bold text-white transition"
            >
              Schedule Mandi Consultation
            </Link>
          </div>
        </div>
      </section>

      <PublicFooter />
    </div>
  );
}
