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
  Clock,
  Lock,
  Mail,
  MapPin,
  MessageSquare,
  PhoneCall,
  Scale,
  Server,
  Smartphone,
  Zap,
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
      {/* Main Footer Content Grid */}
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-16">
        <div className="grid gap-10 md:grid-cols-2 lg:grid-cols-12">
          {/* Brand & Platform Architecture Column (Spans 4 cols on lg) */}
          <div className="lg:col-span-4 space-y-4">
            <BsgLogo size="md" theme="dark" />
            <p className="text-xs text-[#A8D9B9] leading-relaxed max-w-sm">
              BSG (Buyer Seller Goods) is India&apos;s dedicated Enterprise Mandi Operating System & Handheld Platform. Engineered directly from the market concrete for APMC commission agents, wholesale vegetable & fruit traders, and agricultural corporations.
            </p>

            {/* Architecture Badges */}
            <div className="space-y-2 pt-2 text-[11px] text-[#A8E2BD]">
              <div className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 shrink-0 text-[#10A66A]" />
                <span>Cryptographic PostgreSQL Schema-Level Tenant Isolation</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 shrink-0 text-[#10A66A]" />
                <span>Strict 3-User Concurrency Seat Enforcement</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 shrink-0 text-[#10A66A]" />
                <span>ACID Double-Entry Farmer & Buyer Ledgers</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 shrink-0 text-[#10A66A]" />
                <span>Offline-First Android Handheld Sync Architecture</span>
              </div>
            </div>
          </div>

          {/* Col 2: Mandi Capabilities (Spans 2 cols) */}
          <div className="lg:col-span-2 space-y-3">
            <h4 className="text-xs font-bold uppercase tracking-wider text-white">
              Mandi Operations
            </h4>
            <ul className="space-y-2.5 text-xs text-[#B8DFC6]">
              <li><Link href="/features" className="hover:text-white transition">Goods Inward & Lots</Link></li>
              <li><Link href="/features" className="hover:text-white transition">Bag-by-Bag Weighment</Link></li>
              <li><Link href="/features" className="hover:text-white transition">Smart Chart Auctions</Link></li>
              <li><Link href="/features" className="hover:text-white transition">POS Cash & Credit Bills</Link></li>
              <li><Link href="/features" className="hover:text-white transition">Daily Cash Drawer Tally</Link></li>
              <li><Link href="/features" className="hover:text-white transition">Farmer Advance Deductions</Link></li>
              <li><Link href="/features" className="hover:text-white transition">WhatsApp PDF Dispatch</Link></li>
            </ul>
          </div>

          {/* Col 3: Commodity Verticals (Spans 2 cols) */}
          <div className="lg:col-span-2 space-y-3">
            <h4 className="text-xs font-bold uppercase tracking-wider text-white">
              Market Verticals
            </h4>
            <ul className="space-y-2.5 text-xs text-[#B8DFC6]">
              <li><Link href="/solutions" className="hover:text-white transition">Vegetables & Perishables</Link></li>
              <li><Link href="/solutions" className="hover:text-white transition">Onion & Potato Merchants</Link></li>
              <li><Link href="/solutions" className="hover:text-white transition">Fruit Commission Agencies</Link></li>
              <li><Link href="/solutions" className="hover:text-white transition">Cold Storage & Crates</Link></li>
              <li><Link href="/solutions" className="hover:text-white transition">Grain & Spices Wholesale</Link></li>
              <li><Link href="/solutions" className="hover:text-white transition">Multi-Yard Mandi Enterprises</Link></li>
              <li><Link href="/solutions" className="hover:text-white transition">APMC Statutory Cess</Link></li>
            </ul>
          </div>

          {/* Col 4: Platform Portals & SaaS (Spans 2 cols) */}
          <div className="lg:col-span-2 space-y-3">
            <h4 className="text-xs font-bold uppercase tracking-wider text-white">
              Platform & Portals
            </h4>
            <ul className="space-y-2.5 text-xs text-[#B8DFC6]">
              <li><Link href="/super-admin/dashboard" className="hover:text-white transition">Super Admin Governance</Link></li>
              <li><Link href="/login" className="hover:text-white transition">Store Admin Workspace</Link></li>
              <li><Link href="/login" className="hover:text-white transition">Staff Cashier Desk</Link></li>
              <li><Link href="/pricing" className="hover:text-white transition">Subscription Plans</Link></li>
              <li><Link href="/about" className="hover:text-white transition">About BSG Platform</Link></li>
              <li><Link href="/faq" className="hover:text-white transition">Mandi Knowledge Base</Link></li>
              <li><Link href="/register" className="hover:text-white transition">Register New Shop</Link></li>
            </ul>
          </div>

          {/* Col 5: Mandi Desk & Contact (Spans 2 cols) */}
          <div className="lg:col-span-2 space-y-3">
            <h4 className="text-xs font-bold uppercase tracking-wider text-white">
              Mandi Tech Desk
            </h4>
            <div className="space-y-3 text-xs text-[#B8DFC6]">
              <div>
                <span className="text-[10px] uppercase font-bold text-[#A8E2BD]">Helpline Phone</span>
                <p className="font-bold text-white mt-0.5">
                  <a href="tel:+919841238910" className="hover:text-[#10A66A] transition">+91 98412 38910</a>
                </p>
              </div>

              <div>
                <span className="text-[10px] uppercase font-bold text-[#A8E2BD]">Official WhatsApp</span>
                <p className="font-bold text-[#10A66A] mt-0.5">
                  <a
                    href="https://wa.me/919841238910?text=Hello%20BSG%20Team%2C%20I%20have%20an%20inquiry%20regarding%20Mandi%20OS."
                    target="_blank"
                    rel="noopener noreferrer"
                    className="hover:underline"
                  >
                    Chat on WhatsApp &rarr;
                  </a>
                </p>
              </div>

              <div>
                <span className="text-[10px] uppercase font-bold text-[#A8E2BD]">Email Support</span>
                <p className="text-white mt-0.5 font-medium">support@bsgmandi.io</p>
              </div>

              <div>
                <span className="text-[10px] uppercase font-bold text-[#A8E2BD]">Mandi Hours</span>
                <p className="text-white mt-0.5">5:30 AM – 9:00 PM IST</p>
                <p className="text-[10px] text-[#A8D9B9]">Active during morning auctions</p>
              </div>
            </div>
          </div>
        </div>

        {/* Bottom Legal & Regulatory Compliance Bar */}
        <div className="mt-14 flex flex-col gap-4 border-t border-[#0A3D2A] pt-8 text-[11px] text-[#A8D9B9] sm:flex-row sm:items-center sm:justify-between">
          <div className="space-y-1">
            <p>© {new Date().getFullYear()} BSG Platform Technologies Pvt Ltd. All rights reserved.</p>
            <p className="text-[10px] text-[#47785C]">
              Enterprise Agricultural Trading System • Protected by Multi-Tenant Cryptographic Isolation
            </p>
          </div>

          <div className="flex flex-wrap items-center gap-6">
            <Link href="/privacy" className="hover:text-white transition">Privacy Policy</Link>
            <Link href="/terms" className="hover:text-white transition">Terms of Service</Link>
            <Link href="/contact" className="hover:text-white transition">Mandi Onboarding Consultation</Link>
            <Link href="/faq" className="hover:text-white transition">Help & FAQs</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
