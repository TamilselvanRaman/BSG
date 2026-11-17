import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";

export default function TermsPage() {
  return (
    <div className="flex min-h-screen flex-col bg-[#F4FAF5] text-[#123B29] font-sans">
      <PublicNavbar />
      <main className="mx-auto max-w-4xl flex-1 px-4 sm:px-6 py-16">
        <div className="rounded-3xl border border-[#CDE8D5] bg-white p-8 sm:p-12 shadow-xs space-y-6">
          <span className="text-xs font-bold uppercase tracking-widest text-[#087A50]">
            Service Agreement & Terms
          </span>
          <h1 className="text-3xl font-black text-[#063D2E]">Terms and Conditions of Service</h1>
          <div className="space-y-4 text-xs sm:text-sm leading-relaxed text-[#47785C]">
            <p>
              By registering a business workspace on the BSG Mandi Platform, you agree to these Terms of Service governing multi-tenant access, license quotas, and data governance.
            </p>
            <h3 className="font-bold text-[#063D2E] text-base pt-2">1. License & Seat Enforcement</h3>
            <p>
              Standard shop licenses grant up to 3 authorized concurrent seats (1 Store Administrator + 2 Staff/Cashiers). Sharing credentials outside your authorized shop organization or attempting to bypass license concurrency limits is prohibited.
            </p>
            <h3 className="font-bold text-[#063D2E] text-base pt-2">2. Regulatory & APMC Compliance</h3>
            <p>
              Users are responsible for ensuring trade records, bag tare calibrations, and statutory APMC market cess calculations comply with local agricultural market committee regulations.
            </p>
            <h3 className="font-bold text-[#063D2E] text-base pt-2">3. Subscription & Billing Cycles</h3>
            <p>
              Subscriptions renew on a monthly or annual basis as configured. The 30-Day Free Trial period provides full unrestricted access to all 10 platform modules.
            </p>
          </div>
        </div>
      </main>
      <PublicFooter />
    </div>
  );
}
