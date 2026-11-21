"use client";

import { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { BsgLogo } from "@/components/BsgLogo";
import { useTheme } from "@/components/ThemeProvider";
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
  Sun,
  Moon,
  Zap,
  Sparkles,
  Store,
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
  const { theme, toggleTheme } = useTheme();
  const isDark = theme === "dark";

  return (
    <header
      className={`sticky top-0 z-50 w-full border-b backdrop-blur-xl transition-all duration-300 ${
        isDark
          ? "border-[#30264B] bg-[#080516]/90 shadow-glow-card"
          : "border-[#E9E3F4] bg-[#FFFFFF]/90 shadow-xs"
      }`}
    >
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
        {/* Brand Logo */}
        <Link href="/" className="flex items-center group transition-opacity hover:opacity-95">
          <BsgLogo size="md" />
        </Link>

        {/* Desktop Navigation Capsule Island */}
        <nav
          className={`hidden items-center rounded-full border p-1 shadow-xs lg:flex transition-colors ${
            isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-[#F2EEFA]"
          }`}
        >
          {NAV_LINKS.map((item) => {
            const active = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`rounded-full px-4 py-1.5 text-xs transition-all ${
                  active
                    ? isDark
                      ? "bg-[#9475F5] text-white font-bold shadow-glow"
                      : "bg-white text-[#7955DF] font-bold shadow-xs"
                    : isDark
                    ? "text-[#B7ADC9] hover:text-[#F8F5FF] hover:bg-[#1E173D] font-medium"
                    : "text-[#777086] hover:text-[#211936] hover:bg-white/60 font-medium"
                }`}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>

        {/* Auth CTA & Theme Switcher */}
        <div className="hidden items-center gap-3 sm:flex">
          {/* Theme Toggle Button */}
          <button
            onClick={toggleTheme}
            className={`flex items-center justify-center rounded-xl p-2 transition-all border ${
              isDark
                ? "border-[#30264B] bg-[#15102B] text-[#B49AFF] hover:border-[#9475F5]"
                : "border-[#E9E3F4] bg-white text-[#7955DF] hover:border-[#7955DF]"
            }`}
            title={`Switch to ${isDark ? "Light" : "Dark"} Mode`}
          >
            {isDark ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
          </button>

          <Link
            href="/workspace/dashboard"
            className={`rounded-xl border px-3.5 py-2 text-xs font-bold transition flex items-center gap-1.5 ${
              isDark
                ? "border-[#9475F5]/40 bg-[#9475F5]/10 text-[#9475F5] hover:bg-[#9475F5]/20"
                : "border-[#7955DF]/30 bg-[#7955DF]/10 text-[#7955DF] hover:bg-[#7955DF]/20"
            }`}
          >
            <Store className="h-3.5 w-3.5" />
            <span>Mandi Workspace</span>
          </Link>

          <Link
            href="/login"
            className={`rounded-xl border px-4 py-2 text-xs font-bold transition ${
              isDark
                ? "border-[#30264B] bg-[#15102B] text-[#F8F5FF] hover:border-[#9475F5]"
                : "border-[#E9E3F4] bg-white text-[#211936] hover:bg-[#F2EEFA]"
            }`}
          >
            Sign In
          </Link>

          <Link
            href="/register"
            className="inline-flex items-center gap-1.5 rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] px-4 py-2 text-xs font-bold text-white shadow-glow hover:brightness-110 active:scale-[0.98] transition-all"
          >
            <span>Start Free Trial</span>
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>

        {/* Mobile Menu Button */}
        <div className="flex items-center gap-2 lg:hidden">
          <button
            onClick={toggleTheme}
            className={`p-2 rounded-xl border ${
              isDark ? "border-[#30264B] bg-[#15102B] text-[#B49AFF]" : "border-[#E9E3F4] bg-white text-[#7955DF]"
            }`}
          >
            {isDark ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
          </button>
          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className={`rounded-xl p-2 transition ${
              isDark ? "hover:bg-[#15102B] text-[#F8F5FF]" : "hover:bg-[#F2EEFA] text-[#211936]"
            }`}
            aria-label="Toggle Menu"
          >
            {mobileMenuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
          </button>
        </div>
      </div>

      {/* Mobile Menu Dropdown */}
      {mobileMenuOpen && (
        <div
          className={`border-b px-6 py-4 shadow-xl backdrop-blur-md lg:hidden ${
            isDark ? "border-[#30264B] bg-[#080516]" : "border-[#E9E3F4] bg-white"
          }`}
        >
          <nav className="flex flex-col space-y-2">
            {NAV_LINKS.map((item) => {
              const active = pathname === item.href;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={() => setMobileMenuOpen(false)}
                  className={`rounded-xl px-4 py-2 text-xs font-semibold ${
                    active
                      ? "bg-[#9475F5] text-white"
                      : isDark
                      ? "text-[#B7ADC9] hover:bg-[#15102B]"
                      : "text-[#777086] hover:bg-[#F2EEFA]"
                  }`}
                >
                  {item.label}
                </Link>
              );
            })}
            <div className="pt-3 border-t border-opacity-30 border-[#30264B] flex flex-col gap-2">
              <Link
                href="/workspace/dashboard"
                onClick={() => setMobileMenuOpen(false)}
                className="w-full text-center rounded-xl bg-[#9475F5] py-2 text-xs font-bold text-white shadow-glow"
              >
                Open Mandi Workspace
              </Link>
              <Link
                href="/login"
                onClick={() => setMobileMenuOpen(false)}
                className={`w-full text-center rounded-xl border py-2 text-xs font-bold ${
                  isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-gray-100"
                }`}
              >
                Sign In
              </Link>
            </div>
          </nav>
        </div>
      )}
    </header>
  );
}

export function PublicFooter() {
  const { theme } = useTheme();
  const isDark = theme === "dark";

  return (
    <footer
      className={`border-t transition-colors duration-300 ${
        isDark
          ? "border-[#30264B] bg-[#0D0920] text-[#B7ADC9]"
          : "border-[#E9E3F4] bg-[#FFFFFF] text-[#777086]"
      }`}
    >
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-16">
        <div className="grid gap-10 md:grid-cols-2 lg:grid-cols-12">
          {/* Brand & Platform Architecture */}
          <div className="lg:col-span-4 space-y-4">
            <BsgLogo size="md" />
            <p className={`text-xs leading-relaxed max-w-sm ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
              Click Smart Chart is India&apos;s premier Mandi OS and Handheld Business Management Platform. Purpose-built with Nexi aesthetics for APMC commission agents, wholesale produce merchants, and agricultural corporations.
            </p>

            <div className="space-y-2 pt-2 text-[11px]">
              <div className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 shrink-0 text-[#9475F5]" />
                <span>PostgreSQL Schema-Level Tenant Isolation</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 shrink-0 text-[#9475F5]" />
                <span>Strict 3-User Concurrency Seat Enforcement</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 shrink-0 text-[#9475F5]" />
                <span>ACID Double-Entry Farmer & Buyer Ledgers</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 shrink-0 text-[#9475F5]" />
                <span>Offline-First Android Handheld Sync Architecture</span>
              </div>
            </div>
          </div>

          {/* Mandi Capabilities */}
          <div className="lg:col-span-2 space-y-3">
            <h4 className={`text-xs font-bold uppercase tracking-wider ${isDark ? "text-white" : "text-[#211936]"}`}>
              Mandi Operations
            </h4>
            <ul className="space-y-2.5 text-xs">
              <li><Link href="/features" className="hover:text-[#9475F5] transition">Goods Inward & Lots</Link></li>
              <li><Link href="/features" className="hover:text-[#9475F5] transition">Bag-by-Bag Weighment</Link></li>
              <li><Link href="/features" className="hover:text-[#9475F5] transition">Smart Chart Auctions</Link></li>
              <li><Link href="/features" className="hover:text-[#9475F5] transition">POS Cash & Credit Bills</Link></li>
              <li><Link href="/features" className="hover:text-[#9475F5] transition">Daily Cash Drawer Tally</Link></li>
              <li><Link href="/features" className="hover:text-[#9475F5] transition">Farmer Advance Deductions</Link></li>
              <li><Link href="/features" className="hover:text-[#9475F5] transition">WhatsApp PDF Dispatch</Link></li>
            </ul>
          </div>

          {/* Market Verticals */}
          <div className="lg:col-span-2 space-y-3">
            <h4 className={`text-xs font-bold uppercase tracking-wider ${isDark ? "text-white" : "text-[#211936]"}`}>
              Market Verticals
            </h4>
            <ul className="space-y-2.5 text-xs">
              <li><Link href="/solutions" className="hover:text-[#9475F5] transition">Vegetables & Perishables</Link></li>
              <li><Link href="/solutions" className="hover:text-[#9475F5] transition">Onion & Potato Merchants</Link></li>
              <li><Link href="/solutions" className="hover:text-[#9475F5] transition">Fruit Commission Agencies</Link></li>
              <li><Link href="/solutions" className="hover:text-[#9475F5] transition">Cold Storage & Crates</Link></li>
              <li><Link href="/solutions" className="hover:text-[#9475F5] transition">Grain & Spices Wholesale</Link></li>
              <li><Link href="/solutions" className="hover:text-[#9475F5] transition">APMC Statutory Cess</Link></li>
            </ul>
          </div>

          {/* Platform Portals */}
          <div className="lg:col-span-2 space-y-3">
            <h4 className={`text-xs font-bold uppercase tracking-wider ${isDark ? "text-white" : "text-[#211936]"}`}>
              Portals & SaaS
            </h4>
            <ul className="space-y-2.5 text-xs">
              <li><Link href="/workspace/dashboard" className="text-[#9475F5] font-bold hover:underline transition">Click Smart Chart App</Link></li>
              <li><Link href="/super-admin/dashboard" className="hover:text-[#9475F5] transition">Super Admin Governance</Link></li>
              <li><Link href="/login" className="hover:text-[#9475F5] transition">Store Admin Sign In</Link></li>
              <li><Link href="/pricing" className="hover:text-[#9475F5] transition">Subscription Plans</Link></li>
              <li><Link href="/about" className="hover:text-[#9475F5] transition">About Click Smart Chart</Link></li>
              <li><Link href="/register" className="hover:text-[#9475F5] transition">Register New Yard Shop</Link></li>
            </ul>
          </div>

          {/* Contact Desk */}
          <div className="lg:col-span-2 space-y-3">
            <h4 className={`text-xs font-bold uppercase tracking-wider ${isDark ? "text-white" : "text-[#211936]"}`}>
              Tech Desk
            </h4>
            <div className="space-y-2 text-xs">
              <div>
                <span className="text-[10px] uppercase font-bold text-[#9475F5]">Helpline Phone</span>
                <p className={`font-bold mt-0.5 ${isDark ? "text-white" : "text-[#211936]"}`}>
                  <a href="tel:+919841238910" className="hover:text-[#9475F5] transition">+91 98412 38910</a>
                </p>
              </div>
              <div>
                <span className="text-[10px] uppercase font-bold text-[#9475F5]">Official WhatsApp</span>
                <p className="font-bold text-[#10B981] mt-0.5">
                  <a href="https://wa.me/919841238910" target="_blank" rel="noopener noreferrer" className="hover:underline">
                    Chat on WhatsApp &rarr;
                  </a>
                </p>
              </div>
              <div>
                <span className="text-[10px] uppercase font-bold text-[#9475F5]">Support Email</span>
                <p className={`mt-0.5 ${isDark ? "text-white" : "text-[#211936]"}`}>support@bsgmandi.io</p>
              </div>
            </div>
          </div>
        </div>

        {/* Legal & Regulatory Bottom Bar */}
        <div
          className={`mt-14 flex flex-col gap-4 border-t pt-8 text-[11px] sm:flex-row sm:items-center sm:justify-between ${
            isDark ? "border-[#30264B] text-[#B7ADC9]" : "border-[#E9E3F4] text-[#777086]"
          }`}
        >
          <div className="space-y-1">
            <p>© {new Date().getFullYear()} Click Smart Chart Enterprise SaaS. All rights reserved.</p>
            <p className="text-[10px] opacity-70">
              Enterprise Agricultural Trading System • Protected by Multi-Tenant Cryptographic Isolation
            </p>
          </div>

          <div className="flex flex-wrap items-center gap-6">
            <Link href="/privacy" className="hover:text-[#9475F5] transition">Privacy Policy</Link>
            <Link href="/terms" className="hover:text-[#9475F5] transition">Terms of Service</Link>
            <Link href="/contact" className="hover:text-[#9475F5] transition">Mandi Consultation</Link>
            <Link href="/faq" className="hover:text-[#9475F5] transition">Help & FAQs</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
