"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { BarChart3, ShieldCheck, ArrowRight } from "lucide-react";

const NAV_LINKS = [
  { href: "/", label: "Home" },
  { href: "/features", label: "Features" },
  { href: "/solutions", label: "Solutions" },
  { href: "/pricing", label: "Pricing" },
  { href: "/about", label: "About Us" },
  { href: "/faq", label: "FAQ" },
  { href: "/contact", label: "Contact" },
];

export function PublicNavbar() {
  const pathname = usePathname();
  return (
    <header className="sticky top-0 z-40 border-b border-slate-200 bg-white/95 backdrop-blur">
      <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4">
        <Link href="/" className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-slate-900 text-white">
            <BarChart3 className="h-5 w-5 text-blue-400" />
          </div>
          <div>
            <span className="block text-base font-bold tracking-tight text-slate-900">
              CLICK Smart Chart
            </span>
            <span className="block text-xs font-medium text-slate-500">
              Multi-Tenant Goods & Billing SaaS
            </span>
          </div>
        </Link>

        <nav className="hidden items-center gap-6 md:flex">
          {NAV_LINKS.map((item) => {
            const active = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`text-sm font-medium transition ${
                  active ? "text-blue-600" : "text-slate-600 hover:text-slate-900"
                }`}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>

        <div className="flex items-center gap-3">
          <Link
            href="/login"
            className="rounded-lg border border-slate-300 px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-100"
          >
            Sign In
          </Link>
          <Link
            href="/register"
            className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-blue-700"
          >
            Register Business
            <ArrowRight className="h-4 w-4" />
          </Link>
        </div>
      </div>
    </header>
  );
}

export function PublicFooter() {
  return (
    <footer className="border-t border-slate-200 bg-slate-900 text-slate-300">
      <div className="mx-auto grid max-w-7xl gap-8 px-6 py-12 md:grid-cols-4">
        <div>
          <div className="flex items-center gap-2 text-white">
            <ShieldCheck className="h-5 w-5 text-blue-400" />
            <span className="text-lg font-bold">CLICK Smart Chart SaaS</span>
          </div>
          <p className="mt-3 text-sm text-slate-400">
            Enterprise-grade Goods Arrival, Smart Chart, Auction, Purchase & Sales Bill Books,
            Partner Ledgers, and Offline Mobile SaaS Platform.
          </p>
        </div>
        <div>
          <h4 className="text-sm font-semibold uppercase tracking-wider text-white">Platform</h4>
          <ul className="mt-3 space-y-2 text-sm">
            <li><Link href="/features" className="hover:text-white">Core Modules</Link></li>
            <li><Link href="/solutions" className="hover:text-white">APMC & Wholesale Solutions</Link></li>
            <li><Link href="/pricing" className="hover:text-white">SaaS Pricing Plans</Link></li>
          </ul>
        </div>
        <div>
          <h4 className="text-sm font-semibold uppercase tracking-wider text-white">Access Portals</h4>
          <ul className="mt-3 space-y-2 text-sm">
            <li><Link href="/login" className="hover:text-white">Business Admin Login</Link></li>
            <li><Link href="/login" className="hover:text-white">Employee Workspace Login</Link></li>
            <li><Link href="/login" className="hover:text-white">Super Admin Governance</Link></li>
          </ul>
        </div>
        <div>
          <h4 className="text-sm font-semibold uppercase tracking-wider text-white">Legal & Support</h4>
          <ul className="mt-3 space-y-2 text-sm">
            <li><Link href="/terms" className="hover:text-white">Terms & Conditions</Link></li>
            <li><Link href="/privacy" className="hover:text-white">Privacy Policy</Link></li>
            <li><Link href="/contact" className="hover:text-white">24/7 Enterprise Support</Link></li>
          </ul>
        </div>
      </div>
      <div className="border-t border-slate-800 py-5 text-center text-xs text-slate-500">
        © {new Date().getFullYear()} CLICK Smart Chart SaaS Platform. All rights reserved.
      </div>
    </footer>
  );
}
