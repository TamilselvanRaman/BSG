"use client";

import { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  BarChart3,
  ShieldCheck,
  ArrowRight,
  Menu,
  X,
  Sparkles,
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
    <header className="sticky top-0 z-50 border-b border-slate-200/80 bg-white/90 backdrop-blur-md transition-all">
      <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-3.5">
        {/* Brand Logo */}
        <Link href="/" className="flex items-center gap-3 group">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-blue-600 to-indigo-700 text-white shadow-md shadow-blue-500/20 group-hover:scale-105 transition-transform">
            <BarChart3 className="h-5 w-5" />
          </div>
          <div>
            <span className="block text-base font-extrabold tracking-tight text-slate-900 group-hover:text-blue-600 transition-colors">
              CLICK Smart Chart
            </span>
            <span className="block text-[11px] font-semibold text-slate-500 tracking-wide">
              Mandi OS • Multi-Tenant SaaS
            </span>
          </div>
        </Link>

        {/* Desktop Navigation */}
        <nav className="hidden items-center gap-1 lg:flex bg-slate-100/70 p-1.5 rounded-full border border-slate-200/60">
          {NAV_LINKS.map((item) => {
            const active = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`px-3.5 py-1.5 text-xs font-semibold rounded-full transition-all ${
                  active
                    ? "bg-white text-blue-600 shadow-sm"
                    : "text-slate-600 hover:text-slate-900 hover:bg-white/60"
                }`}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>

        {/* Auth CTA */}
        <div className="hidden items-center gap-3 sm:flex">
          <Link
            href="/login"
            className="rounded-lg border border-slate-300 px-4 py-2 text-xs font-bold text-slate-700 hover:bg-slate-100 hover:border-slate-400 transition"
          >
            Sign In
          </Link>
          <Link
            href="/register"
            className="inline-flex items-center gap-1.5 rounded-lg bg-gradient-to-r from-blue-600 to-indigo-600 px-4 py-2 text-xs font-bold text-white shadow-md shadow-blue-600/20 hover:from-blue-700 hover:to-indigo-700 transition hover:shadow-lg"
          >
            <span>Start Free Trial</span>
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>

        {/* Mobile Menu Button */}
        <button
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          className="rounded-lg p-2 text-slate-600 hover:bg-slate-100 lg:hidden"
          aria-label="Toggle Menu"
        >
          {mobileMenuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
        </button>
      </div>

      {/* Mobile Menu Dropdown */}
      {mobileMenuOpen && (
        <div className="border-b border-slate-200 bg-white px-6 py-4 shadow-xl lg:hidden">
          <nav className="flex flex-col space-y-2">
            {NAV_LINKS.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setMobileMenuOpen(false)}
                className={`rounded-lg px-3 py-2 text-sm font-semibold transition ${
                  pathname === item.href
                    ? "bg-blue-50 text-blue-600"
                    : "text-slate-700 hover:bg-slate-100"
                }`}
              >
                {item.label}
              </Link>
            ))}
            <div className="pt-3 border-t border-slate-100 flex flex-col gap-2">
              <Link
                href="/login"
                onClick={() => setMobileMenuOpen(false)}
                className="w-full text-center rounded-lg border border-slate-300 py-2.5 text-xs font-bold text-slate-700 hover:bg-slate-50"
              >
                Sign In to Portal
              </Link>
              <Link
                href="/register"
                onClick={() => setMobileMenuOpen(false)}
                className="w-full text-center rounded-lg bg-blue-600 py-2.5 text-xs font-bold text-white shadow hover:bg-blue-700"
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
            <div className="flex items-center gap-3 text-white">
              <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-blue-600 text-white">
                <BarChart3 className="h-5 w-5" />
              </div>
              <span className="text-lg font-extrabold tracking-tight">CLICK Smart Chart</span>
            </div>
            <p className="text-xs text-slate-400 leading-relaxed max-w-sm">
              The premier Cloud SaaS & Handheld Operating System for APMC Mandis, Wholesale Vegetable & Fruit Traders, Commission Agents, and Multi-Crop Enterprises.
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
          <p>© {new Date().getFullYear()} CLICK Smart Chart Corp. All rights reserved.</p>
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
