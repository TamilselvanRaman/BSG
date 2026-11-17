"use client";

import { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { BsgLogo } from "@/components/BsgLogo";
import {
  ShieldCheck,
  ArrowRight,
  Menu,
  X,
  CheckCircle2,
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
    <header className="sticky top-0 z-50 w-full border-b border-[#CDE8D5] bg-white/95 backdrop-blur-md transition-all shadow-xs">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
        {/* Brand Logo */}
        <Link href="/" className="flex items-center group transition-opacity hover:opacity-95">
          <BsgLogo size="md" />
        </Link>

        {/* Desktop Navigation Capsule Island */}
        <nav className="hidden items-center rounded-full border border-[#D5E8DA] bg-[#EBF3ED] p-1 shadow-xs lg:flex">
          {NAV_LINKS.map((item) => {
            const active = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`rounded-full px-4 py-1.5 text-xs transition-all ${
                  active
                    ? "bg-white text-[#063D2E] font-bold shadow-xs"
                    : "text-[#47785C] hover:text-[#063D2E] hover:bg-white/60 font-semibold"
                }`}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>

        {/* Auth CTA */}
        <div className="hidden items-center gap-2.5 sm:flex">
          <Link
            href="/login"
            className="rounded-xl border border-[#D5E8DA] bg-white px-4 py-2 text-xs font-bold text-[#063D2E] hover:bg-[#E8F5EC] shadow-xs transition"
          >
            Sign In
          </Link>
          <Link
            href="/register"
            className="inline-flex items-center gap-1.5 rounded-xl bg-[#087A50] px-4 py-2 text-xs font-bold text-white shadow-sm hover:bg-[#063D2E] active:scale-[0.98] transition-all"
          >
            <span>Start Free Trial</span>
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>

        {/* Mobile Menu Button */}
        <button
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          className="rounded-xl p-2 text-[#063D2E] hover:bg-[#E8F5EC] lg:hidden transition"
          aria-label="Toggle Menu"
        >
          {mobileMenuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
        </button>
      </div>

      {/* Mobile Menu Dropdown */}
      {mobileMenuOpen && (
        <div className="border-b border-[#CDE8D5] bg-white px-6 py-4 shadow-xl backdrop-blur-md lg:hidden">
          <nav className="flex flex-col space-y-1.5">
            {NAV_LINKS.map((item) => {
              const active = pathname === item.href;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={() => setMobileMenuOpen(false)}
                  className={`rounded-xl px-3.5 py-2 text-sm font-bold transition ${
                    active
                      ? "bg-[#E8F5EC] text-[#063D2E]"
                      : "text-[#47785C] hover:bg-[#F4FAF5]"
                  }`}
                >
                  {item.label}
                </Link>
              );
            })}
            <div className="pt-3.5 border-t border-[#CDE8D5] flex flex-col gap-2">
              <Link
                href="/login"
                onClick={() => setMobileMenuOpen(false)}
                className="w-full text-center rounded-xl border border-[#D5E8DA] bg-white py-2.5 text-xs font-bold text-[#063D2E] hover:bg-[#E8F5EC] transition"
              >
                Sign In to Portal
              </Link>
              <Link
                href="/register"
                onClick={() => setMobileMenuOpen(false)}
                className="w-full text-center rounded-xl bg-[#087A50] py-2.5 text-xs font-bold text-white shadow hover:bg-[#063D2E] transition"
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
    <footer className="border-t-2 border-[#0D5C43] bg-[#021810] text-[#B8DFC6]">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-16">
        <div className="grid gap-10 md:grid-cols-2 lg:grid-cols-5">
          {/* Brand Col */}
          <div className="lg:col-span-2 space-y-4">
            <BsgLogo size="md" theme="dark" />
            <p className="text-xs text-[#A8D9B9] leading-relaxed max-w-sm">
              BSG (Buyer Seller Goods) is the dedicated Enterprise Mandi SaaS & Handheld Operating System for APMC Mandis, Wholesale Vegetable & Fruit Traders, Commission Agents, and Multi-Crop Agricultural Enterprises.
            </p>
            <div className="flex items-center gap-2 pt-2 text-xs font-semibold text-[#10A66A]">
              <CheckCircle2 className="h-4 w-4 shrink-0" />
              <span>Cryptographic Multi-Tenant Financial & Stock Isolation</span>
            </div>
          </div>

          {/* Col 2 */}
          <div>
            <h4 className="text-xs font-bold uppercase tracking-wider text-white">Product Capabilities</h4>
            <ul className="mt-3.5 space-y-2.5 text-xs">
              <li><Link href="/features" className="hover:text-white transition">Goods Inward & Lots</Link></li>
              <li><Link href="/features" className="hover:text-white transition">Bag-by-Bag Weighment</Link></li>
              <li><Link href="/features" className="hover:text-white transition">Smart Chart Auctions</Link></li>
              <li><Link href="/features" className="hover:text-white transition">Daily Cash Tally</Link></li>
              <li><Link href="/pricing" className="hover:text-white transition">SaaS Plans & Pricing</Link></li>
            </ul>
          </div>

          {/* Col 3 */}
          <div>
            <h4 className="text-xs font-bold uppercase tracking-wider text-white">Market Solutions</h4>
            <ul className="mt-3.5 space-y-2.5 text-xs">
              <li><Link href="/solutions" className="hover:text-white transition">APMC Commission Agents</Link></li>
              <li><Link href="/solutions" className="hover:text-white transition">Vegetable & Fruit Mandis</Link></li>
              <li><Link href="/solutions" className="hover:text-white transition">Wholesale Grain & Spices</Link></li>
              <li><Link href="/solutions" className="hover:text-white transition">Multi-Yard Mandi Enterprises</Link></li>
            </ul>
          </div>

          {/* Col 4 */}
          <div>
            <h4 className="text-xs font-bold uppercase tracking-wider text-white">Portals & Support</h4>
            <ul className="mt-3.5 space-y-2.5 text-xs">
              <li><Link href="/login" className="hover:text-white transition">Business Admin Portal</Link></li>
              <li><Link href="/login" className="hover:text-white transition">Staff Cashier Desk</Link></li>
              <li><Link href="/login" className="hover:text-white transition">Super Admin Governance</Link></li>
              <li><Link href="/contact" className="hover:text-white transition">Schedule Mandi Demo</Link></li>
            </ul>
          </div>
        </div>

        <div className="mt-14 flex flex-wrap items-center justify-between gap-4 border-t border-[#063423] pt-8 text-[11px] text-[#5C856C]">
          <p>© {new Date().getFullYear()} BSG Platform Technologies Pvt Ltd. All rights reserved.</p>
          <div className="flex items-center gap-6">
            <Link href="/privacy" className="hover:text-[#B8DFC6] transition">Privacy Policy</Link>
            <Link href="/terms" className="hover:text-[#B8DFC6] transition">Terms of Service</Link>
            <Link href="/contact" className="hover:text-[#B8DFC6] transition">Mandi Enquiry & Demo</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
