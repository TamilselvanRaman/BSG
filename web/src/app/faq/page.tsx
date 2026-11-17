import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  ArrowRight,
  CheckCircle2,
  Coins,
  FileText,
  HelpCircle,
  PhoneCall,
  Printer,
  Scale,
  ShieldCheck,
  Smartphone,
  UserCheck,
} from "lucide-react";

const FAQ_SECTIONS = [
  {
    category: "Licensing & User Access",
    icon: UserCheck,
    items: [
      {
        q: "How many users can log in per shop license?",
        a: "Every registered shop is provisioned with a strict 3-user license: 1 Store Admin / Owner seat + 2 Staff / Cashier operator seats. All 3 accounts can be active simultaneously across Desktop Web and Android Mobile handhelds.",
      },
      {
        q: "What happens if a 4th user tries to log in?",
        a: "The system enforces concurrent seat quotas at the API layer. If 3 active sessions are currently occupied, a 4th login attempt receives a license limit notification. The store owner can view active logged-in devices and click 'Revoke / Free Seat' to disconnect inactive sessions.",
      },
      {
        q: "Is there a free trial period?",
        a: "Yes. Every newly provisioned shop receives a 30-Day Free Trial License with all 10 Mandi capabilities enabled by default and zero payment required upfront.",
      },
    ],
  },
  {
    category: "Weighment Scale & Billing",
    icon: Scale,
    items: [
      {
        q: "How does the bag-by-bag digital weighment scale operate?",
        a: "Operators enter individual bag weights as they come off the scale (e.g., 52, 53, 53, 54 kg). Mandi OS auto-sums the total bags count, computes gross weight, deducts tare weight, and derives the net chargeable weight instantly with zero paper math errors.",
      },
      {
        q: "Can I bill multiple commodities in a single sales bill?",
        a: "Yes. You can add multiple commodities (e.g., 10 bags of Tomato Hybrid + 5 bags of Country Tomato + 8 bags of Onions) in a single Cash or Credit bill. Each item maintains its own bag weighment breakdown.",
      },
      {
        q: "What happens when a bill is cancelled?",
        a: "Bills are never silently purged. Cancelling a bill requires an audit reason, marks the bill as CANCELLED, and atomically rolls back the sold stock into the arrival lot and reverses the buyer's running ledger debit.",
      },
    ],
  },
  {
    category: "Mobile Handhelds & Offline Sync",
    icon: Smartphone,
    items: [
      {
        q: "Can our weighment staff record bills on the mandi auction floor without Wi-Fi?",
        a: "Yes. The Android mobile app uses an offline-first local queue. Staff can weigh bags, print thermal receipts via Bluetooth, and save bills on the floor. All entries sync to the cloud database when Wi-Fi or 4G connectivity resumes.",
      },
      {
        q: "What printers and hardware are supported?",
        a: "BSG supports all standard ESC/POS 3-inch (80mm) and 2-inch (58mm) Bluetooth and USB thermal printers, standard A4/A5 laser office printers, and digital serial weighbridges.",
      },
    ],
  },
  {
    category: "Cash Drawer & Daily Tally",
    icon: Coins,
    items: [
      {
        q: "How does the daily cash tally prevent cash leakage?",
        a: "At closing time, the cashier inputs the physical currency denomination counts (number of ₹2000, ₹500, ₹200, ₹100, ₹50, ₹20, ₹10 notes and coins). The system compares physical cash against expected closing cash (Opening Cash + Cash Sales + Receipts − Cash Expenses − Bank Deposits) and flags any surplus or shortage discrepancy.",
      },
      {
        q: "Can I track GPay and UPI payments separately from cash?",
        a: "Yes. The daily tally distinctly records Cash Sales, GPay 1, GPay 2, and direct bank transfers so your physical cash drawer tally matches your physical currency notes.",
      },
    ],
  },
];

export default function FaqPage() {
  return (
    <div className="flex min-h-screen flex-col bg-[#F4FAF5] text-[#123B29] font-sans">
      <PublicNavbar />

      {/* Header */}
      <section className="border-b border-[#CDE8D5] bg-gradient-to-b from-[#F4FAF5] to-[#E8F5EC] py-16 lg:py-24">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 text-center">
          <span className="text-xs font-bold uppercase tracking-widest text-[#087A50]">
            Mandi Help & Knowledge Base
          </span>
          <h1 className="mt-3 text-4xl font-black text-[#063D2E] sm:text-5xl lg:text-6xl tracking-tight">
            Frequently Asked Questions
          </h1>
          <p className="mt-4 text-base sm:text-lg text-[#47785C] max-w-2xl mx-auto leading-relaxed">
            Detailed answers regarding multi-user licensing, bag-by-bag weighment tables, offline floor mobility, and daily cash reconciliations.
          </p>
        </div>
      </section>

      {/* FAQ Sections */}
      <section className="py-20">
        <div className="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8 space-y-16">
          {FAQ_SECTIONS.map((sec) => {
            const Icon = sec.icon;

            return (
              <div key={sec.category} className="space-y-6">
                <div className="flex items-center gap-3 border-b border-[#CDE8D5] pb-3">
                  <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-[#E8F5EC] text-[#087A50]">
                    <Icon className="h-5 w-5" />
                  </div>
                  <h2 className="text-xl font-bold text-[#063D2E]">
                    {sec.category}
                  </h2>
                </div>

                <div className="space-y-4">
                  {sec.items.map((item) => (
                    <div
                      key={item.q}
                      className="rounded-2xl border border-[#CDE8D5] bg-white p-6 shadow-xs space-y-2 hover:border-[#10A66A] transition-all"
                    >
                      <h3 className="text-base font-bold text-[#063D2E]">
                        {item.q}
                      </h3>
                      <p className="text-xs text-[#47785C] leading-relaxed">
                        {item.a}
                      </p>
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      </section>

      {/* Still Have Questions */}
      <section className="py-20 bg-[#063D2E] text-white text-center">
        <div className="mx-auto max-w-3xl px-4 space-y-4">
          <span className="text-xs font-bold uppercase tracking-widest text-[#10A66A]">
            Direct Mandi Support
          </span>
          <h2 className="text-2xl sm:text-4xl font-bold">
            Still Have Questions About Mandi Operations?
          </h2>
          <p className="text-xs sm:text-sm text-[#C4E2CF] max-w-xl mx-auto">
            Our solution specialists can walk you through live weighment scales, bill printing, and cash tally setups.
          </p>
          <div className="pt-2 flex flex-wrap items-center justify-center gap-4">
            <Link
              href="/contact"
              className="rounded-xl bg-[#10A66A] hover:bg-[#087A50] px-6 py-3 text-xs font-bold text-white shadow transition"
            >
              Contact Specialist
            </Link>
            <Link
              href="/register"
              className="rounded-xl border border-[#0A503B] bg-[#0A503B] hover:bg-[#0E664C] px-6 py-3 text-xs font-bold text-white transition"
            >
              Start 30-Day Free Trial
            </Link>
          </div>
        </div>
      </section>

      <PublicFooter />
    </div>
  );
}
