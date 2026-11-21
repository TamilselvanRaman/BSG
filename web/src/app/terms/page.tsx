import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";

export default function TermsPage() {
  return (
    <div className="flex min-h-screen flex-col bg-[var(--bg-main)] text-[var(--text-primary)] font-sans">
      <PublicNavbar />
      <main className="mx-auto max-w-4xl flex-1 px-4 sm:px-6 py-16">
        <div className="rounded-3xl border border-[var(--border-color)] bg-white p-8 sm:p-12 shadow-xs space-y-6">
          <h1 className="text-3xl font-black text-[var(--text-primary)]">Terms and Conditions of Service</h1>
          <div className="space-y-4 text-xs sm:text-sm leading-relaxed text-[var(--text-secondary)]">
            <p>
              By registering a business workspace on the BSG Mandi Platform, you agree to these Terms of Service governing multi-tenant access, license quotas, and data governance.
            </p>
            <h3 className="font-bold text-[var(--text-primary)] text-base pt-2">1. License & Seat Enforcement</h3>
            <p>
              Standard shop licenses grant up to 3 authorized concurrent seats (1 Store Administrator + 2 Staff/Cashiers). Sharing credentials outside your authorized shop organization or attempting to bypass license concurrency limits is prohibited.
            </p>
            <h3 className="font-bold text-[var(--text-primary)] text-base pt-2">2. Regulatory & APMC Compliance</h3>
            <p>
              Users are responsible for ensuring trade records, bag tare calibrations, and statutory APMC market cess calculations comply with local agricultural market committee regulations.
            </p>
            <h3 className="font-bold text-[var(--text-primary)] text-base pt-2">3. Subscription & Billing Cycles</h3>
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
