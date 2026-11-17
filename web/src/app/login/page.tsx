"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import { apiFetch, saveStoredSession } from "@/lib/api";
import {
  ArrowRight,
  BarChart3,
  CheckCircle2,
  Eye,
  EyeOff,
  Lock,
  Scale,
  ShieldCheck,
  Sparkles,
  UserCheck,
  Zap,
} from "lucide-react";

export default function LoginPage() {
  const router = useRouter();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      const data = await apiFetch<{
        accessToken: string;
        refreshToken: string;
        redirectTo: string;
        user: any;
      }>("/auth/login", {
        method: "POST",
        body: JSON.stringify({ username, password, rememberMe }),
      });

      saveStoredSession(data.accessToken, data.refreshToken, data.user);
      router.push(data.redirectTo || "/admin/dashboard");
    } catch (err: any) {
      setError(err.message || "Authentication failed. Please check your credentials.");
    } finally {
      setLoading(false);
    }
  }

  function fillDemoCredentials(user: string, pass: string) {
    setUsername(user);
    setPassword(pass);
  }

  return (
    <div className="flex min-h-screen flex-col bg-slate-50">
      <PublicNavbar />

      <main className="flex flex-1 items-center justify-center py-12 px-6">
        <div className="w-full max-w-4xl overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-xl shadow-slate-200/50 grid lg:grid-cols-12">
          {/* Left: Brand showcase */}
          <div className="hidden lg:flex lg:col-span-5 flex-col justify-between bg-gradient-to-br from-slate-900 via-slate-900 to-blue-950 p-8 text-white">
            <div>
              <div className="flex items-center gap-2.5">
                <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-blue-600 text-white">
                  <BarChart3 className="h-5 w-5" />
                </div>
                <span className="font-extrabold text-base tracking-tight">CLICK Smart Chart</span>
              </div>

              <div className="mt-12 space-y-4">
                <span className="inline-flex items-center gap-1.5 rounded-full bg-blue-900/60 border border-blue-700/60 px-3 py-1 text-[11px] font-bold text-blue-300">
                  <Sparkles className="h-3 w-3" />
                  Mandi OS Cloud Portal
                </span>
                <h2 className="text-2xl font-bold leading-tight">
                  Single Sign-On for Your Entire Mandi Operations
                </h2>
                <p className="text-xs text-slate-300 leading-relaxed">
                  Log in as Store Admin, Cashier, or Super Admin. All sessions enforce strict 3-user license protection.
                </p>
              </div>

              <div className="mt-8 space-y-2.5 text-xs text-slate-300">
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="h-4 w-4 text-emerald-400 shrink-0" />
                  <span>Multi-Product Arrival Lots</span>
                </div>
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="h-4 w-4 text-emerald-400 shrink-0" />
                  <span>Digital Bag Weighment Table</span>
                </div>
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="h-4 w-4 text-emerald-400 shrink-0" />
                  <span>Live Smart Chart Auctions</span>
                </div>
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="h-4 w-4 text-emerald-400 shrink-0" />
                  <span>Evening Cash Drawer Tally</span>
                </div>
              </div>
            </div>

            <div className="pt-8 border-t border-slate-800 text-[11px] text-slate-400 flex items-center justify-between">
              <span>ACID Multi-Tenant</span>
              <span>AES-256 Encrypted</span>
            </div>
          </div>

          {/* Right: Login Form */}
          <div className="lg:col-span-7 p-8 sm:p-10 flex flex-col justify-center">
            <div className="space-y-1">
              <h1 className="text-2xl font-bold text-slate-900">Sign In to Workspace</h1>
              <p className="text-xs text-slate-500">
                Enter your registered store username and password to access your dashboard.
              </p>
            </div>

            {error && (
              <div className="mt-4 rounded-xl border border-red-200 bg-red-50 p-3.5 text-xs font-semibold text-red-700">
                {error}
              </div>
            )}

            <form onSubmit={handleSubmit} className="mt-6 space-y-4 text-xs">
              <div>
                <label className="block font-bold text-slate-700 uppercase tracking-wider mb-1 text-[11px]">
                  Username or Mobile Number *
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. kannan_admin or superadmin"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm focus:border-blue-600 focus:outline-none"
                />
              </div>

              <div>
                <div className="flex items-center justify-between mb-1">
                  <label className="font-bold text-slate-700 uppercase tracking-wider text-[11px]">
                    Password *
                  </label>
                  <Link
                    href="/forgot-password"
                    className="text-[11px] font-semibold text-blue-600 hover:text-blue-700"
                  >
                    Forgot Password?
                  </Link>
                </div>
                <div className="relative">
                  <input
                    type={showPassword ? "text" : "password"}
                    required
                    placeholder="Enter your password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm pr-10 focus:border-blue-600 focus:outline-none"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-2.5 text-slate-400 hover:text-slate-600"
                  >
                    {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
              </div>

              <div className="flex items-center justify-between pt-1">
                <label className="flex items-center gap-2 cursor-pointer font-medium text-slate-600">
                  <input
                    type="checkbox"
                    checked={rememberMe}
                    onChange={(e) => setRememberMe(e.target.checked)}
                    className="rounded border-slate-300 text-blue-600 focus:ring-blue-500 h-3.5 w-3.5"
                  />
                  <span>Keep me signed in</span>
                </label>
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full flex items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-indigo-600 py-3 text-sm font-bold text-white shadow-md shadow-blue-600/25 hover:from-blue-700 hover:to-indigo-700 transition disabled:opacity-50"
              >
                <span>{loading ? "Authenticating..." : "Sign In to Portal"}</span>
                <ArrowRight className="h-4 w-4" />
              </button>
            </form>

            {/* Quick Demo Fill Pills */}
            <div className="mt-8 rounded-2xl border border-slate-200 bg-slate-50 p-3.5">
              <span className="text-[10px] uppercase font-bold text-slate-500 block mb-2">
                1-Click Demo Accounts (Instant Testing)
              </span>
              <div className="flex flex-wrap gap-2">
                <button
                  type="button"
                  onClick={() => fillDemoCredentials("raman_admin", "Admin@1234")}
                  className="rounded-lg border border-slate-300 bg-white px-2.5 py-1 text-[11px] font-semibold text-slate-700 hover:bg-slate-100 transition shadow-sm"
                >
                  Store Admin
                </button>
                <button
                  type="button"
                  onClick={() => fillDemoCredentials("karthik_emp", "Emp@1234")}
                  className="rounded-lg border border-slate-300 bg-white px-2.5 py-1 text-[11px] font-semibold text-slate-700 hover:bg-slate-100 transition shadow-sm"
                >
                  Cashier / Staff
                </button>
                <button
                  type="button"
                  onClick={() => fillDemoCredentials("superadmin", "SuperAdmin@1234")}
                  className="rounded-lg border border-blue-200 bg-blue-50 px-2.5 py-1 text-[11px] font-semibold text-blue-700 hover:bg-blue-100 transition shadow-sm"
                >
                  Super Admin
                </button>
              </div>
            </div>

            <div className="mt-6 text-center text-xs text-slate-500">
              Need a new shop workspace?{" "}
              <Link href="/register" className="font-bold text-blue-600 hover:underline">
                Register with 30-Day Free Trial
              </Link>
            </div>
          </div>
        </div>
      </main>

      <PublicFooter />
    </div>
  );
}
