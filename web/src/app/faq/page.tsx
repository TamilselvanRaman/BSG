"use client";

import { useState, useMemo } from "react";
import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import {
  AlertTriangle,
  ArrowRight,
  Boxes,
  Building2,
  CheckCircle2,
  ChevronDown,
  Clock,
  Coins,
  CreditCard,
  Database,
  FileSpreadsheet,
  FileText,
  HelpCircle,
  Layers,
  Lock,
  MessageSquare,
  PackagePlus,
  PhoneCall,
  Printer,
  Scale,
  Search,
  Server,
  ShieldCheck,
  Smartphone,
  UserCheck,
  Users,
  Utensils,
  Wheat,
  X,
  Zap,
} from "lucide-react";

interface FaqItem {
  id: string;
  category: string;
  question: string;
  answer: string;
  highlights?: string[];
  tags: string[];
}

const FAQ_CATEGORIES = [
  { id: "ALL", label: "All Questions", icon: HelpCircle },
  { id: "LICENSING", label: "Shop Licensing & Seats", icon: UserCheck },
  { id: "WEIGHMENT", label: "Scale Weighment & POS", icon: Scale },
  { id: "OFFLINE", label: "Mobile & Offline Sync", icon: Smartphone },
  { id: "LEDGERS", label: "Ledgers & Advances", icon: FileText },
  { id: "CASH_TALLY", label: "Cash Drawer & Day Closing", icon: Coins },
  { id: "COMPLIANCE", label: "APMC Cess & Taxes", icon: ShieldCheck },
];

const FAQS: FaqItem[] = [
  // 1. Licensing & User Access
  {
    id: "lic-1",
    category: "LICENSING",
    question: "How many concurrent users can operate per mandi shop license?",
    answer:
      "Every registered shop is provisioned with a strict 3-user license: 1 Store Admin/Owner seat + 2 Staff/Cashier operator seats. All 3 accounts can be active simultaneously across Desktop Web and Android Mobile handhelds on the mandi floor.",
    highlights: [
      "1 Store Administrator (Full Owner Rights & Financial Governance)",
      "2 Staff / Cashier Operators (Weighment & POS Billing Rights)",
      "Simultaneous Desktop & Mobile Tablet access",
    ],
    tags: ["seats", "users", "quota", "license", "admin", "staff"],
  },
  {
    id: "lic-2",
    category: "LICENSING",
    question: "What occurs if a 4th user attempts to log in simultaneously?",
    answer:
      "The system enforces concurrent seat quotas at the session and API layer. If 3 active sessions are currently occupied, a 4th login attempt is immediately prevented with an active seat quota notice. The store owner can view all active devices from the dashboard and revoke idle sessions with one click to free up a slot.",
    highlights: [
      "Hardware-enforced API concurrency limiter",
      "Store owner can remotely revoke inactive sessions",
      "Protects store credentials against unauthorized credential sharing",
    ],
    tags: ["4th user", "limit", "revoke", "concurrency", "security"],
  },
  {
    id: "lic-3",
    category: "LICENSING",
    question: "Can multi-branch or high-volume mandi enterprises add extra seats?",
    answer:
      "Yes. While standard shops operate with the 3-seat quota, multi-yard agricultural corporations and multi-branch enterprises can upgrade to Enterprise Multi-Branch plans with up to 10+ concurrent seats, dedicated database schemas, and inter-mandi inventory transfers.",
    highlights: [
      "Scalable seat tiers for large APMC commission agencies",
      "Inter-mandi transfer support across separate yards",
      "Dedicated database schema on Enterprise tier",
    ],
    tags: ["upgrade", "enterprise", "multi-branch", "extra seats"],
  },
  {
    id: "lic-4",
    category: "LICENSING",
    question: "Is the 30-Day Free Trial fully unlocked with real features?",
    answer:
      "Yes. Every newly provisioned shop receives a 30-Day Free Trial License with all 10 core mandi capabilities enabled by default — including bag weighment scales, smart chart auctions, partner ledgers, and WhatsApp PDF dispatch — with zero payment card required upfront.",
    highlights: [
      "30 Days of complete unrestricted platform access",
      "No credit card or upfront deposit required",
      "Seamless 1-click continuation without data loss upon subscription",
    ],
    tags: ["free trial", "cost", "30 days", "pricing", "setup"],
  },

  // 2. Scale Weighment & POS
  {
    id: "weigh-1",
    category: "WEIGHMENT",
    question: "How does the bag-by-bag digital weighment scale table operate?",
    answer:
      "Operators enter individual bag weights as bags come off the floor scale (e.g. 52, 53, 51.5, 54 kg) using rapid numeric keypad shortcuts. The system automatically computes total bag count, gross weight, subtracts standardized tare per bag type (gunny, plastic crate, net sack), and locks net billable weight cryptographically.",
    highlights: [
      "Keyboard-optimized cells with numpad enter progression",
      "Automatic tare deduction by commodity container standard",
      "Direct scale hookup via RS-232, USB, or Bluetooth",
    ],
    tags: ["scale", "bag", "weighment", "tare", "gross", "math errors"],
  },
  {
    id: "weigh-2",
    category: "WEIGHMENT",
    question: "Can I bill multiple commodities and inward lots on a single invoice?",
    answer:
      "Yes. Mandi OS supports composite multi-product sales bills. A buyer can purchase 10 bags of Tomato Hybrid, 5 bags of Country Tomato, and 8 bags of Bellary Onion in a single Cash or Credit transaction. Each commodity maintains its separate bag weighment table and lot traceability.",
    highlights: [
      "Composite billing for wholesale buyers purchasing diverse produce",
      "Item-wise gross weight, tare deduction, and strike price",
      "Automatic coolie/hamali labor and APMC cess itemization",
    ],
    tags: ["multi-product", "multiple commodities", "invoice", "cash bill"],
  },
  {
    id: "weigh-3",
    category: "WEIGHMENT",
    question: "What happens when a bill is cancelled or modified?",
    answer:
      "Bills are never silently purged or deleted. Cancelling an invoice requires a mandatory operator audit reason. The system marks the transaction as CANCELLED, atomically rolls back the sold stock into the arrival lot inventory, and reverses the buyer's running double-entry ledger balance instantly.",
    highlights: [
      "Atomic ACID database rollback with zero stock residue",
      "Automatic reversal of buyer credit ledger balance",
      "Immutable audit record tracking operator, time, and reason",
    ],
    tags: ["cancel", "delete bill", "rollback", "audit trail", "void"],
  },
  {
    id: "weigh-4",
    category: "WEIGHMENT",
    question: "How does the Smart Chart live auction bidding board operate?",
    answer:
      "The Smart Chart digital blackboard allows an auctioneer to split a single incoming lot (e.g. 50 bags of Tomato) across multiple wholesale buyers at different strike rates (e.g. 20 bags @ ₹44/kg to Buyer A, 30 bags @ ₹43.50/kg to Buyer B). Remaining stock is decremented live with zero inventory overselling.",
    highlights: [
      "Multi-buyer lot split auctions in real time",
      "Live counter showing remaining bags and clearance progress",
      "Direct automated bill creation from auction strikes",
    ],
    tags: ["auction", "smart chart", "bidding", "lot split", "allotment"],
  },

  // 3. Mobile & Offline Sync
  {
    id: "off-1",
    category: "OFFLINE",
    question: "Can weighment staff record bills on the market floor without Wi-Fi?",
    answer:
      "Yes. The Android mobile application uses an offline-first local queue architecture. Operators can capture bag weighments, conduct auction splits, and print Bluetooth thermal receipts on the yard floor even if cell reception drops completely. All queued records synchronize automatically once connectivity resumes.",
    highlights: [
      "Offline-first local database queue on Android tablets and phones",
      "Bluetooth receipt printing operates 100% offline",
      "Automatic background conflict-free sync when internet reconnects",
    ],
    tags: ["offline", "no internet", "wifi", "mobile app", "android", "floor"],
  },
  {
    id: "off-2",
    category: "OFFLINE",
    question: "Which thermal printers, weigh scales, and hardware devices are supported?",
    answer:
      "BSG supports all standard ESC/POS 3-inch (80mm) and 2-inch (58mm) Bluetooth and USB thermal printers, standard A4/A5 laser office printers, barcode/QR scanners, and electronic weighbridge indicators via RS-232 serial communication.",
    highlights: [
      "Bluetooth 3-Inch thermal printers (TVS, Epson, Everycom, NGX)",
      "Standard office laser printers for A4 formal invoices",
      "Direct serial port hookup for digital weighbridge scales",
    ],
    tags: ["thermal printer", "hardware", "bluetooth", "esc/pos", "weighbridge"],
  },

  // 4. Partner Ledgers & Advances
  {
    id: "ledg-1",
    category: "LEDGERS",
    question: "How does BSG manage pre-season farmer advances and deductions?",
    answer:
      "Cash advances given to growers months before harvest are recorded directly in the farmer's double-entry ledger. When the farmer brings their harvest to auction, the system automatically detects outstanding advance balances and applies configurable deductions on payout vouchers with complete itemized transparency.",
    highlights: [
      "Pre-season cash advance tracking with date and voucher records",
      "Automated deduction from harvest auction payout proceeds",
      "Itemized statement showing gross sale, commissions, and net payout",
    ],
    tags: ["farmer advance", "deduction", "khata", "payout", "settlement"],
  },
  {
    id: "ledg-2",
    category: "LEDGERS",
    question: "Can we enforce wholesale buyer credit limits and aging lockouts?",
    answer:
      "Yes. Store owners can configure maximum credit caps (e.g. ₹2,00,000) and credit aging grace periods (e.g. 7 or 15 days) per wholesale buyer. If a buyer exceeds their credit threshold or holds overdue unpaid bills, the system blocks new credit billing until dues are settled.",
    highlights: [
      "Configurable credit limits per wholesale buyer organization",
      "Automatic block on credit dispatch when overdue thresholds breached",
      "Drastically reduces bad debts and shortens cash collection cycles",
    ],
    tags: ["credit limit", "buyer credit", "aging", "overdue", "bad debt"],
  },
  {
    id: "ledg-3",
    category: "LEDGERS",
    question: "How are double-entry ledger statements sent to farmers and buyers?",
    answer:
      "With a single click, store operators can dispatch verified double-entry PDF ledger statements directly to the partner's WhatsApp number. Statements include opening balance, chronological bill debits, payment receipts, and current closing balance with zero manual paper mailing.",
    highlights: [
      "1-Click WhatsApp PDF balance sheet and invoice delivery",
      "Cryptographically verified double-entry running balance",
      "Eliminates end-of-month reconciliation arguments and delays",
    ],
    tags: ["whatsapp", "pdf statement", "ledger dispatch", "balance sheet"],
  },

  // 5. Cash Drawer & Day Closing
  {
    id: "cash-1",
    category: "CASH_TALLY",
    question: "How does the evening cash tally prevent cash leakage and counter theft?",
    answer:
      "At day-end closing, the cashier inputs the physical currency denomination counts (number of ₹2000, ₹500, ₹200, ₹100, ₹50, ₹20, ₹10 notes and coins). The system compares physical counted currency against system expected cash (Opening Cash + Cash Sales + Receipts − Cash Expenses − Bank Deposits) and records permanent audit logs.",
    highlights: [
      "Full denomination breakdown counter (₹500, ₹200, ₹100, etc.)",
      "Instant discrepancy flag for cash surplus or shortage",
      "Day-end lock prevents unauthorized retrospective ledger tampering",
    ],
    tags: ["cash tally", "cash drawer", "denomination", "closing", "shortage"],
  },
  {
    id: "cash-2",
    category: "CASH_TALLY",
    question: "Can we track UPI and GPay collections separately from physical cash?",
    answer:
      "Yes. The daily tally distinctly separates physical Cash Sales, GPay 1, GPay 2, and direct RTGS/NEFT bank transfers. This ensures that only physical currency is expected in the cash drawer while digital UPI collections reconcile directly with your bank statements.",
    highlights: [
      "Separate channels for Cash, GPay, PhonePe, and Bank Transfers",
      "Zero confusion between physical drawer currency and digital funds",
      "Real-time daily collection breakdown by payment mode",
    ],
    tags: ["upi", "gpay", "digital payment", "bank transfer", "qr code"],
  },

  // 6. APMC Cess & Taxes
  {
    id: "comp-1",
    category: "COMPLIANCE",
    question: "How does BSG calculate statutory APMC Market Committee Cess?",
    answer:
      "BSG includes a configurable statutory market fee engine. Depending on your state and market committee rules, you can set the exact APMC cess percentage (e.g. 1.0%, 1.5%, or 2.0%) and rural development fees. The system auto-calculates cess on eligible taxable commodities and produces monthly APMC compliance reports.",
    highlights: [
      "Configurable APMC market cess percentage per commodity vertical",
      "Itemized statutory tax breakdown on wholesale invoices",
      "Automated monthly tax compliance registers for committee audits",
    ],
    tags: ["apmc cess", "market fee", "tax", "compliance", "government"],
  },
  {
    id: "comp-2",
    category: "COMPLIANCE",
    question: "Can labor charges (Coolie/Hamali) be configured by bag or weight?",
    answer:
      "Yes. You can configure labor and coolie charges either as a flat fee per bag (e.g. ₹10 per bag) or as a percentage of gross commodity value. The system adds coolie charges to the bill and tracks daily hamali payout accounts for labor crews.",
    highlights: [
      "Flexible rules: Flat per-bag fee or percentage of gross value",
      "Auto-split between buyer-payable or farmer-deductible charges",
      "Daily labor ledger for fair crew payout settlements",
    ],
    tags: ["coolie", "hamali", "labor charges", "handling fee"],
  },
];

export default function FaqPage() {
  const [selectedCategory, setSelectedCategory] = useState("ALL");
  const [searchQuery, setSearchQuery] = useState("");
  const [openFaqId, setOpenFaqId] = useState<string | null>("lic-1");

  // Filtered FAQs based on category and search query
  const filteredFaqs = useMemo(() => {
    return FAQS.filter((faq) => {
      const matchCategory =
        selectedCategory === "ALL" || faq.category === selectedCategory;

      if (!matchCategory) return false;

      if (!searchQuery.trim()) return true;

      const q = searchQuery.toLowerCase();
      return (
        faq.question.toLowerCase().includes(q) ||
        faq.answer.toLowerCase().includes(q) ||
        faq.tags.some((t) => t.toLowerCase().includes(q))
      );
    });
  }, [selectedCategory, searchQuery]);

  function toggleFaq(id: string) {
    setOpenFaqId(openFaqId === id ? null : id);
  }

  return (
    <div className="flex min-h-screen flex-col bg-[#F4FAF5] text-[#123B29] font-sans">
      <PublicNavbar />

      {/* ============================================================
          1. HERO SECTION WITH INSTANT SEARCH
         ============================================================ */}
      <section className="relative overflow-hidden border-b border-[#CDE8D5] bg-gradient-to-b from-white via-[#F4FAF5] to-[#E8F5EC]/60 py-16 lg:py-20">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 text-center">
          <h1 className="mx-auto max-w-3xl text-3xl font-black text-[#063D2E] sm:text-4xl lg:text-5xl tracking-tight leading-tight">
            Frequently Asked Questions
          </h1>
          <p className="mt-4 text-sm sm:text-base text-[#47785C] max-w-2xl mx-auto leading-relaxed">
            Detailed operational answers regarding multi-user licensing, bag-by-bag scale weighments, offline mobile sync, double-entry ledgers, and APMC statutory compliance.
          </p>

          {/* Interactive Search Bar */}
          <div className="mt-8 mx-auto max-w-2xl">
            <div className="relative flex items-center">
              <div className="absolute left-4 text-[#087A50]">
                <Search className="h-5 w-5" />
              </div>
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search questions (e.g., 3 seats, scale weighment, thermal printer, cash tally)..."
                className="w-full rounded-2xl border-2 border-[#CDE8D5] bg-white py-3.5 pl-12 pr-10 text-sm font-medium text-[#063D2E] placeholder-[#71917B] shadow-sm transition focus:border-[#087A50] focus:ring-2 focus:ring-[#087A50]/20 focus:outline-none"
              />
              {searchQuery && (
                <button
                  onClick={() => setSearchQuery("")}
                  className="absolute right-4 rounded-full p-1 text-[#71917B] hover:text-[#063D2E] transition"
                  aria-label="Clear search"
                >
                  <X className="h-4 w-4" />
                </button>
              )}
            </div>

            {/* Quick search keywords */}
            <div className="mt-3 flex flex-wrap items-center justify-center gap-2 text-xs text-[#47785C]">
              <span className="font-semibold">Common topics:</span>
              {["3 Seats Limit", "Digital Scale", "Offline Sync", "WhatsApp PDF", "APMC Cess"].map((term) => (
                <button
                  key={term}
                  onClick={() => setSearchQuery(term)}
                  className="rounded-full bg-white border border-[#CDE8D5] px-2.5 py-0.5 text-[11px] font-bold text-[#087A50] hover:bg-[#E8F5EC] transition"
                >
                  {term}
                </button>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          2. MAIN CONTENT: 2-COLUMN LAYOUT (SIDEBAR + ACCORDIONS)
         ============================================================ */}
      <section className="py-16 lg:py-20 flex-1">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="grid gap-10 lg:grid-cols-12 items-start">
            {/* Left Sidebar: Categories & Support Desk Card */}
            <div className="lg:col-span-4 space-y-6 lg:sticky lg:top-24">
              {/* Category Pills Navigation */}
              <div className="rounded-3xl border border-[#CDE8D5] bg-white p-5 shadow-xs space-y-1.5">
                <h3 className="px-3 pb-2 text-[11px] font-bold uppercase tracking-wider text-[#47785C]">
                  Topic Categories
                </h3>
                {FAQ_CATEGORIES.map((cat) => {
                  const Icon = cat.icon;
                  const active = selectedCategory === cat.id;
                  const count =
                    cat.id === "ALL"
                      ? FAQS.length
                      : FAQS.filter((f) => f.category === cat.id).length;

                  return (
                    <button
                      key={cat.id}
                      onClick={() => setSelectedCategory(cat.id)}
                      className={`flex w-full items-center justify-between rounded-xl px-3.5 py-2.5 text-xs font-bold transition-all text-left ${
                        active
                          ? "bg-[#087A50] text-white shadow-xs"
                          : "text-[#47785C] hover:bg-[#E8F5EC] hover:text-[#063D2E]"
                      }`}
                    >
                      <div className="flex items-center gap-2.5">
                        <Icon className={`h-4 w-4 shrink-0 ${active ? "text-white" : "text-[#087A50]"}`} />
                        <span>{cat.label}</span>
                      </div>
                      <span
                        className={`rounded-full px-2 py-0.5 text-[10px] font-mono font-bold ${
                          active
                            ? "bg-[#063D2E] text-white"
                            : "bg-[#F4FAF5] border border-[#CDE8D5] text-[#087A50]"
                        }`}
                      >
                        {count}
                      </span>
                    </button>
                  );
                })}
              </div>

              {/* Direct Mandi Help Desk Card */}
              <div className="rounded-3xl border border-[#CDE8D5] bg-[#E8F5EC]/60 p-6 shadow-xs space-y-4">
                <div className="flex items-center gap-3">
                  <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#087A50] text-white shrink-0">
                    <PhoneCall className="h-5 w-5" />
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-[#063D2E]">Mandi Floor Help Desk</h4>
                    <p className="text-[11px] text-[#47785C]">Active 4:00 AM – 8:00 PM IST</p>
                  </div>
                </div>
                <p className="text-xs text-[#123B29] leading-relaxed">
                  Have an urgent question during morning auction hours or setting up a new digital scale? Our specialists are available directly.
                </p>
                <div className="pt-1 space-y-2">
                  <a
                    href="tel:+919876543210"
                    className="flex items-center justify-center gap-2 w-full rounded-xl bg-[#087A50] hover:bg-[#063D2E] px-4 py-2.5 text-xs font-bold text-white shadow-xs transition"
                  >
                    <PhoneCall className="h-3.5 w-3.5" />
                    <span>Call Mandi Helpline</span>
                  </a>
                  <Link
                    href="/contact"
                    className="flex items-center justify-center gap-2 w-full rounded-xl border border-[#CDE8D5] bg-white hover:bg-[#F4FAF5] px-4 py-2.5 text-xs font-bold text-[#063D2E] transition"
                  >
                    <MessageSquare className="h-3.5 w-3.5 text-[#087A50]" />
                    <span>Request Callback</span>
                  </Link>
                </div>
              </div>

              {/* Strict License Reminder Card */}
              <div className="rounded-3xl border border-[#CDE8D5] bg-white p-5 shadow-xs space-y-2 text-xs">
                <div className="flex items-center gap-2 text-[#087A50] font-bold">
                  <ShieldCheck className="h-4 w-4" />
                  <span>Strict 3-Seat Standard</span>
                </div>
                <p className="text-[#47785C] text-[11px] leading-relaxed">
                  Every shop workspace includes 1 Store Admin + 2 Staff Cashier accounts. Need more seats? Contact enterprise sales.
                </p>
              </div>
            </div>

            {/* Right Column: Accordion Questions */}
            <div className="lg:col-span-8 space-y-4">
              {/* Active Filter Header */}
              <div className="flex items-center justify-between border-b border-[#DCEEE1] pb-3">
                <div className="flex items-center gap-2">
                  <span className="text-xs font-bold text-[#063D2E]">
                    {selectedCategory === "ALL"
                      ? "All Operational Questions"
                      : FAQ_CATEGORIES.find((c) => c.id === selectedCategory)?.label}
                  </span>
                  {searchQuery && (
                    <span className="text-xs text-[#47785C]">
                      matching &ldquo;{searchQuery}&rdquo;
                    </span>
                  )}
                </div>
                <span className="text-xs font-bold text-[#087A50]">
                  {filteredFaqs.length} {filteredFaqs.length === 1 ? "Result" : "Results"}
                </span>
              </div>

              {/* Empty Search State */}
              {filteredFaqs.length === 0 ? (
                <div className="rounded-3xl border border-[#CDE8D5] bg-white p-12 text-center space-y-4">
                  <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-[#E8F5EC] text-[#087A50]">
                    <Search className="h-6 w-6" />
                  </div>
                  <h3 className="text-base font-bold text-[#063D2E]">
                    No questions found matching your search
                  </h3>
                  <p className="text-xs text-[#47785C] max-w-sm mx-auto">
                    Try searching for common keywords like &ldquo;scale&rdquo;, &ldquo;license&rdquo;, &ldquo;seats&rdquo;, &ldquo;printer&rdquo;, or reset your filters.
                  </p>
                  <button
                    onClick={() => {
                      setSearchQuery("");
                      setSelectedCategory("ALL");
                    }}
                    className="inline-flex items-center gap-1.5 rounded-xl bg-[#087A50] px-4 py-2 text-xs font-bold text-white hover:bg-[#063D2E] transition"
                  >
                    <span>Reset All Filters</span>
                  </button>
                </div>
              ) : (
                /* Accordion List */
                <div className="space-y-3">
                  {filteredFaqs.map((faq) => {
                    const isOpen = openFaqId === faq.id;

                    return (
                      <div
                        key={faq.id}
                        className={`rounded-2xl border transition-all overflow-hidden ${
                          isOpen
                            ? "border-[#087A50] bg-white shadow-md"
                            : "border-[#CDE8D5] bg-white hover:border-[#10A66A] shadow-xs"
                        }`}
                      >
                        {/* Question Header (Toggle Button) */}
                        <button
                          onClick={() => toggleFaq(faq.id)}
                          className="w-full flex items-center justify-between p-5 text-left transition focus:outline-none"
                        >
                          <div className="flex items-center gap-3 pr-4">
                            <div
                              className={`flex h-7 w-7 items-center justify-center rounded-lg text-xs font-bold shrink-0 transition-colors ${
                                isOpen
                                  ? "bg-[#087A50] text-white"
                                  : "bg-[#E8F5EC] text-[#087A50]"
                              }`}
                            >
                              ?
                            </div>
                            <h3 className="text-sm font-bold text-[#063D2E]">
                              {faq.question}
                            </h3>
                          </div>
                          <div
                            className={`flex h-7 w-7 items-center justify-center rounded-lg transition-transform shrink-0 ${
                              isOpen
                                ? "rotate-180 bg-[#E8F5EC] text-[#087A50]"
                                : "text-[#71917B] hover:text-[#063D2E]"
                            }`}
                          >
                            <ChevronDown className="h-4 w-4" />
                          </div>
                        </button>

                        {/* Expandable Answer */}
                        {isOpen && (
                          <div className="px-5 pb-6 pt-1 text-xs text-[#47785C] leading-relaxed border-t border-[#DCEEE1]/60 space-y-4">
                            <p className="text-xs text-[#123B29] leading-relaxed">
                              {faq.answer}
                            </p>

                            {/* Structured Highlights */}
                            {faq.highlights && (
                              <div className="rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] p-3.5 space-y-2">
                                <span className="text-[10px] font-bold uppercase tracking-wider text-[#087A50]">
                                  Key Operational Takeaways
                                </span>
                                <ul className="space-y-1.5 text-xs text-[#123B29]">
                                  {faq.highlights.map((h, i) => (
                                    <li key={i} className="flex items-start gap-2">
                                      <CheckCircle2 className="h-3.5 w-3.5 text-[#10A66A] shrink-0 mt-0.5" />
                                      <span>{h}</span>
                                    </li>
                                  ))}
                                </ul>
                              </div>
                            )}

                            {/* Tags */}
                            <div className="flex flex-wrap items-center gap-1.5 pt-1">
                              {faq.tags.map((tag) => (
                                <span
                                  key={tag}
                                  className="rounded-md bg-[#E8F5EC] px-2 py-0.5 text-[10px] font-medium text-[#47785C]"
                                >
                                  #{tag}
                                </span>
                              ))}
                            </div>
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================
          3. STILL HAVE QUESTIONS (CONVERSION CTA)
         ============================================================ */}
      <section className="relative overflow-hidden py-24 bg-gradient-to-b from-[#0A503B] via-[#08523D] to-[#074734] text-white text-center border-t border-[#0E6E50] border-b border-[#063423]">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,_var(--tw-gradient-stops))] from-[#10A66A]/20 via-transparent to-transparent pointer-events-none" />
        <div className="relative mx-auto max-w-3xl px-4 space-y-6">
          <h2 className="text-3xl font-black sm:text-5xl tracking-tight leading-tight">
            Still Have Questions About Mandi Operations?
          </h2>
          <p className="text-sm text-[#C4E2CF] max-w-xl mx-auto leading-relaxed">
            Our solution specialists can walk you through live digital weighment scales, bill printing, and daily cash drawer tally setups in your market yard.
          </p>
          <div className="pt-2 flex flex-wrap items-center justify-center gap-4">
            <Link
              href="/contact"
              className="inline-flex items-center gap-2 rounded-xl bg-[#10A66A] hover:bg-[#087A50] px-7 py-3.5 text-sm font-bold text-white shadow-lg transition"
            >
              <span>Connect with a Specialist</span>
              <ArrowRight className="h-4 w-4" />
            </Link>
            <Link
              href="/register"
              className="rounded-xl border border-[#10A66A]/40 bg-[#063D2E] hover:bg-[#087A50] px-7 py-3.5 text-sm font-bold text-white transition"
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
