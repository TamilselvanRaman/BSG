"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import { apiFetch, saveStoredSession } from "@/lib/api";
import { Eye, EyeOff, Lock, UserCheck } from "lucide-react";

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
    <div className="flex min-h-screen flex-col">
      <PublicNavbar />

      <main className="flex flex-1 items-center justify-center px-6 py-12">
        <div className="w-full max-w-md rounded-2xl border border-slate-200 bg-white p-8 shadow-sm">
          <div className="flex items-center gap-3">
            <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-slate-900 text-white">
              <Lock className="h-5 w-5 text-blue-400" />
            </div>
            <div>
              <h1 className="text-xl font-bold text-slate-900">Sign In to Workspace</h1>
              <p className="text-xs text-slate-500">
                Role-aware routing for Super Admin, Business Admin & Staff
              </p>
            </div>
          </div>

          {error && (
            <div className="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-xs font-medium text-red-700">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="mt-6 space-y-4">
            <div>
              <label className="block text-xs font-semibold uppercase text-slate-700">
                Username
              </label>
              <input
                type="text"
                required
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                placeholder="Enter your assigned username"
                className="mt-1.5 w-full rounded-lg border border-slate-300 px-3.5 py-2.5 text-sm focus:border-blue-600 focus:outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold uppercase text-slate-700">
                Password
              </label>
              <div className="relative mt-1.5">
                <input
                  type={showPassword ? "text" : "password"}
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full rounded-lg border border-slate-300 px-3.5 py-2.5 pr-10 text-sm focus:border-blue-600 focus:outline-none"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((v) => !v)}
                  className="absolute right-3 top-2.5 text-slate-400 hover:text-slate-600"
                >
                  {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              </div>
            </div>

            <div className="flex items-center justify-between text-xs">
              <label className="flex items-center gap-2 text-slate-600">
                <input
                  type="checkbox"
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  className="rounded border-slate-300"
                />
                Remember me for 30 days
              </label>
              <Link href="/forgot-password" className="font-semibold text-blue-600 hover:underline">
                Forgot password?
              </Link>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full rounded-lg bg-slate-900 py-2.5 text-sm font-semibold text-white hover:bg-slate-800 disabled:opacity-50"
            >
              {loading ? "Validating Credentials..." : "Sign In"}
            </button>
          </form>

          {/* Quick Demo Role Switcher */}
          <div className="mt-6 rounded-xl border border-slate-200 bg-slate-50 p-4">
            <div className="flex items-center gap-1.5 text-xs font-semibold text-slate-700">
              <UserCheck className="h-4 w-4 text-blue-600" />
              Quick Seeded Role Credentials (Click to Autofill)
            </div>
            <div className="mt-2.5 grid grid-cols-3 gap-2">
              <button
                type="button"
                onClick={() => fillDemoCredentials("superadmin", "Admin@123")}
                className="rounded border border-slate-300 bg-white px-2 py-1.5 text-xs font-medium text-slate-700 hover:bg-blue-50"
              >
                Super Admin
              </button>
              <button
                type="button"
                onClick={() => fillDemoCredentials("vinayaka_admin", "Admin@123")}
                className="rounded border border-slate-300 bg-white px-2 py-1.5 text-xs font-medium text-slate-700 hover:bg-blue-50"
              >
                Business Admin
              </button>
              <button
                type="button"
                onClick={() => fillDemoCredentials("vinayaka_staff", "Admin@123")}
                className="rounded border border-slate-300 bg-white px-2 py-1.5 text-xs font-medium text-slate-700 hover:bg-blue-50"
              >
                Employee Staff
              </button>
            </div>
          </div>

          <p className="mt-6 text-center text-xs text-slate-500">
            New business organization?{" "}
            <Link href="/register" className="font-semibold text-blue-600 hover:underline">
              Register your business workspace
            </Link>
          </p>
        </div>
      </main>

      <PublicFooter />
    </div>
  );
}
