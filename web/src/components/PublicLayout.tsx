"use client";

import { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { BsgLogo } from "@/components/BsgLogo";
import {
  BarChart3,
  ShieldCheck,
  ArrowRight,
  Menu,
  X,
  PhoneCall,
  CheckCircle,
} from "lucide-react";

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
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <header className="sticky top-0 z-50 w-full border-b border-slate-200/80 bg-white/95 backdrop-blur-md transition-all shadow-xs">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
        {/* Brand Logo */}
        <Link href="/" className="flex items-center group transition-opacity hover:opacity-95">
          <BsgLogo size="md" />
        </Link>

        {/* Desktop Navigation */}
        <nav className="hidden items-center gap-1 lg:flex">
          {NAV_LINKS.map((item) => {
            const active = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`relative px-3.5 py-2 text-sm font-medium transition-all rounded-lg ${
                  active
                    ? "text-emerald-800 font-semibold bg-emerald-50/80"
                    : "text-slate-600 hover:text-slate-900 hover:bg-slate-100/70"
                }`}
              >
                {item.label}
                {active && (
                  <span className="absolute bottom-1 left-3.5 right-3.5 h-0.5 bg-emerald-600 rounded-full" />
                )}
              </Link>
            );
          })}
        </nav>

        {/* Auth CTA */}
        <div className="hidden items-center gap-2.5 sm:flex">
          <Link
            href="/login"
            className="rounded-lg px-3.5 py-2 text-sm font-semibold text-slate-700 hover:text-slate-900 hover:bg-slate-100/80 transition"
          >
            Sign In
          </Link>
          <Link
            href="/register"
            className="inline-flex items-center gap-2 rounded-xl bg-emerald-700 px-4 py-2.5 text-xs font-bold text-white shadow-sm shadow-emerald-900/10 hover:bg-emerald-800 active:scale-[0.98] transition-all"
          >
            <span>Start Free Trial</span>
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>

        {/* Mobile Menu Button */}
        <button
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          className="rounded-lg p-2 text-slate-600 hover:bg-slate-100 hover:text-slate-900 lg:hidden"
          aria-label="Toggle Menu"
        >
          {mobileMenuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
        </button>
      </div>

      {/* Mobile Menu Dropdown */}
      {mobileMenuOpen && (
        <div className="border-b border-slate-200 bg-white/95 px-6 py-4 shadow-xl backdrop-blur-md lg:hidden">
          <nav className="flex flex-col space-y-1.5">
            {NAV_LINKS.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setMobileMenuOpen(false)}
                className={`rounded-lg px-3.5 py-2 text-sm font-semibold transition ${
                  pathname === item.href
                    ? "bg-emerald-50 text-emerald-800 font-bold"
                    : "text-slate-700 hover:bg-slate-100"
                }`}
              >
                {item.label}
              </Link>
            ))}
            <div className="pt-3.5 border-t border-slate-100 flex flex-col gap-2">
              <Link
                href="/login"
                onClick={() => setMobileMenuOpen(false)}
                className="w-full text-center rounded-lg border border-slate-300 py-2.5 text-xs font-bold text-slate-700 hover:bg-slate-50 transition"
              >
                Sign In to Portal
              </Link>
              <Link
                href="/register"
                onClick={() => setMobileMenuOpen(false)}
                className="w-full text-center rounded-xl bg-emerald-700 py-2.5 text-xs font-bold text-white shadow hover:bg-emerald-800 transition"
              >
                Register New Business
              </Link>
            </div>
          </nav>
        </div>
      )}
    </header>
  );
}

export function PublicFooter() {
  return (
    <footer className="border-t border-slate-800 bg-slate-950 text-slate-400">
      <div className="mx-auto max-w-7xl px-6 py-14">
        <div className="grid gap-10 md:grid-cols-2 lg:grid-cols-5">
          {/* Brand Col */}
          <div className="lg:col-span-2 space-y-4">
            <BsgLogo size="md" theme="dark" />
            <p className="text-xs text-slate-400 leading-relaxed max-w-sm">
              BSG (Buyer Seller Goods) is the premier Cloud Mandi SaaS & Handheld Operating System for APMC Mandis, Wholesale Vegetable & Fruit Traders, Commission Agents, and Multi-Crop Enterprises.
            </p>
            <div className="flex items-center gap-2 pt-2 text-xs font-semibold text-emerald-400">
              <CheckCircle className="h-4 w-4" />
              <span>ACID Multi-Tenant Financial & Stock Isolation</span>
            </div>
          </div>

          {/* Col 2 */}
          <div>
            <h4 className="text-xs font-bold uppercase tracking-wider text-white">Product</h4>
            <ul className="mt-3.5 space-y-2.5 text-xs">
              <li><Link href="/features" className="hover:text-white transition">Multi-Product Lots</Link></li>
              <li><Link href="/features" className="hover:text-white transition">Bag Weighment Scale</Link></li>
              <li><Link href="/features" className="hover:text-white transition">Smart Chart & Auction</Link></li>
              <li><Link href="/features" className="hover:text-white transition">Daily Cash Tally</Link></li>
              <li><Link href="/pricing" className="hover:text-white transition">SaaS Plans & Pricing</Link></li>
            </ul>
          </div>

          {/* Col 3 */}
          <div>
            <h4 className="text-xs font-bold uppercase tracking-wider text-white">Solutions</h4>
            <ul className="mt-3.5 space-y-2.5 text-xs">
              <li><Link href="/solutions" className="hover:text-white transition">APMC Commission Agents</Link></li>
              <li><Link href="/solutions" className="hover:text-white transition">Vegetable & Fruit Mandis</Link></li>
              <li><Link href="/solutions" className="hover:text-white transition">Wholesale Grain & Spices</Link></li>
              <li><Link href="/solutions" className="hover:text-white transition">Multi-Branch Enterprises</Link></li>
            </ul>
          </div>

          {/* Col 4 */}
          <div>
            <h4 className="text-xs font-bold uppercase tracking-wider text-white">Quick Portals</h4>
            <ul className="mt-3.5 space-y-2.5 text-xs">
              <li><Link href="/login" className="hover:text-white transition">Business Admin Login</Link></li>
              <li><Link href="/login" className="hover:text-white transition">Staff Cashier Login</Link></li>
              <li><Link href="/login" className="hover:text-white transition">Super Admin Governance</Link></li>
              <li><Link href="/contact" className="hover:text-white transition">Contact Support & Sales</Link></li>
            </ul>
          </div>
        </div>

        <div className="mt-12 flex flex-wrap items-center justify-between gap-4 border-t border-slate-900 pt-8 text-[11px] text-slate-500">
          <p>© {new Date().getFullYear()} BSG Platform Technologies Pvt Ltd. All rights reserved.</p>
          <div className="flex items-center gap-6">
            <Link href="/privacy" className="hover:text-slate-300">Privacy Policy</Link>
            <Link href="/terms" className="hover:text-slate-300">Terms of Service</Link>
            <Link href="/contact" className="hover:text-slate-300">Enquiry & Demo</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
