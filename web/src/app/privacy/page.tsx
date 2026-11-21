import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";

export default function PrivacyPage() {
  return (
    <div className="flex min-h-screen flex-col bg-[#F4FAF5] text-[#123B29] font-sans">
      <PublicNavbar />
      <main className="mx-auto max-w-4xl flex-1 px-4 sm:px-6 py-16">
        <div className="rounded-3xl border border-[#CDE8D5] bg-white p-8 sm:p-12 shadow-xs space-y-6">
          <h1 className="text-3xl font-black text-[#063D2E]">BSG Platform Privacy Policy</h1>
          <div className="space-y-4 text-xs sm:text-sm leading-relaxed text-[#47785C]">
            <p>
              At BSG (Buyer Seller Goods Platform), we recognize the critical confidentiality of wholesale agricultural commodity pricing, farmer lists, buyer khata ledgers, and cash balances.
            </p>
            <h3 className="font-bold text-[#063D2E] text-base pt-2">1. Strict Tenant Data Isolation</h3>
            <p>
              All business partner, billing, and ledger records are strictly isolated per tenant using schema-isolated PostgreSQL storage. Your trade data, supplier contacts, and strike rates are never commingled or accessible to any outside merchant or third party.
            </p>
            <h3 className="font-bold text-[#063D2E] text-base pt-2">2. Authentication & Session Security</h3>
            <p>
              Store administrator and staff credentials are cryptographically secured using high-work-factor hashing algorithms. Active sessions are enforced with a strict 3-seat concurrency cap per shop license, preventing account theft or credential proliferation.
            </p>
            <h3 className="font-bold text-[#063D2E] text-base pt-2">3. Immutable Audit Trails</h3>
            <p>
              Administrative actions, bill reversals, price adjustments, and session revocations record immutable audit entries capturing timestamps, operator identifiers, and network IP addresses.
            </p>
          </div>
        </div>
      </main>
      <PublicFooter />
    </div>
  );
}
