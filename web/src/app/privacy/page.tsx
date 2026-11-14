import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";

export default function PrivacyPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <PublicNavbar />
      <main className="mx-auto max-w-4xl flex-1 px-6 py-16">
        <h1 className="text-3xl font-extrabold text-slate-900">Privacy Policy</h1>
        <p className="mt-4 text-sm leading-relaxed text-slate-600">
          All business partner, billing, and ledger records are strictly isolated per tenant. Passwords
          are hashed with bcrypt/Argon2id, and all sensitive administrative operations are recorded
          in immutable audit logs.
        </p>
      </main>
      <PublicFooter />
    </div>
  );
}
