"use client";

import { useState } from "react";
import Link from "next/link";
import { PublicNavbar, PublicFooter } from "@/components/PublicLayout";
import { apiFetch } from "@/lib/api";

export default function ForgotPasswordPage() {
  const [usernameOrEmail, setUsernameOrEmail] = useState("");
  const [token, setToken] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function handleRequestReset(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    try {
      const res = await apiFetch<{ resetTokenPreview?: string }>("/auth/forgot-password", {
        method: "POST",
        body: JSON.stringify({ usernameOrEmail }),
      });
      if (res.resetTokenPreview) {
        setToken(res.resetTokenPreview);
      }
      setMessage("Reset token generated. Enter the reset token and your new password below.");
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleResetPassword(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    try {
      await apiFetch("/auth/reset-password", {
        method: "POST",
        body: JSON.stringify({ token, newPassword }),
      });
      setMessage("Password reset complete! You may now sign in.");
    } catch (err: any) {
      setError(err.message);
    }
  }

  return (
    <div className="flex min-h-screen flex-col">
      <PublicNavbar />
      <main className="mx-auto flex w-full max-w-md flex-1 items-center px-6 py-12">
        <div className="w-full rounded-2xl border border-slate-200 bg-white p-8 shadow-sm">
          <h1 className="text-xl font-bold text-slate-900">Account Password Recovery</h1>
          <p className="mt-1 text-xs text-slate-500">
            Request a reset token or complete password recovery
          </p>

          {message && (
            <div className="mt-4 rounded-lg bg-emerald-50 border border-emerald-200 p-3 text-xs font-medium text-emerald-800">
              {message}
            </div>
          )}
          {error && (
            <div className="mt-4 rounded-lg bg-red-50 p-3 text-xs font-medium text-red-700">
              {error}
            </div>
          )}

          <form onSubmit={handleRequestReset} className="mt-5 space-y-3">
            <label className="block text-xs font-semibold uppercase text-slate-700">
              Username or Registered Email
            </label>
            <input
              type="text"
              required
              value={usernameOrEmail}
              onChange={(e) => setUsernameOrEmail(e.target.value)}
              className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none"
            />
            <button
              type="submit"
              className="w-full rounded-lg bg-slate-900 py-2.5 text-xs font-semibold text-white hover:bg-slate-800 transition"
            >
              Generate Reset Token
            </button>
          </form>

          <hr className="my-6 border-slate-200" />

          <form onSubmit={handleResetPassword} className="space-y-3">
            <div>
              <label className="block text-xs font-semibold uppercase text-slate-700">
                Reset Token
              </label>
              <input
                type="text"
                required
                value={token}
                onChange={(e) => setToken(e.target.value)}
                className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-semibold uppercase text-slate-700">
                New Password
              </label>
              <input
                type="password"
                required
                minLength={6}
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none"
              />
            </div>
            <button
              type="submit"
              className="w-full rounded-lg bg-emerald-700 py-2.5 text-xs font-semibold text-white hover:bg-emerald-800 transition"
            >
              Confirm New Password
            </button>
          </form>

          <div className="mt-5 text-center">
            <Link href="/login" className="text-xs font-semibold text-emerald-700 hover:underline">
              Back to Sign In
            </Link>
          </div>
        </div>
      </main>
      <PublicFooter />
    </div>
  );
}
