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
      setError(err.message || "Failed to generate reset token.");
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
      setError(err.message || "Password reset failed.");
    }
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--bg-main)] text-[var(--text-primary)] font-sans">
      <PublicNavbar />
      <main className="mx-auto flex w-full max-w-md flex-1 items-center px-4 sm:px-6 py-14">
        <div className="w-full rounded-3xl border border-[var(--border-color)] bg-white p-8 sm:p-9 shadow-xl shadow-[var(--text-primary)]/5">
          <h1 className="text-xl font-bold text-[var(--text-primary)]">Account Password Recovery</h1>
          <p className="mt-1 text-xs text-[var(--text-secondary)]">
            Request a reset token or complete password recovery
          </p>

          {message && (
            <div className="mt-4 rounded-xl bg-[var(--bg-card-hover)] border border-[var(--border-color)] p-3 text-xs font-semibold text-[#9475F5]">
              {message}
            </div>
          )}
          {error && (
            <div className="mt-4 rounded-xl bg-red-50 border border-red-200 p-3 text-xs font-semibold text-[#C2413B]">
              {error}
            </div>
          )}

          <form onSubmit={handleRequestReset} className="mt-5 space-y-3">
            <label className="block text-xs font-bold uppercase text-[var(--text-primary)]">
              Username or Registered Email
            </label>
            <input
              type="text"
              required
              value={usernameOrEmail}
              onChange={(e) => setUsernameOrEmail(e.target.value)}
              className="w-full rounded-xl border border-[var(--border-color)] bg-[var(--bg-main)] px-3.5 py-2.5 text-sm text-[var(--text-primary)] focus:border-[#B49AFF] focus:outline-none"
            />
            <button
              type="submit"
              className="w-full rounded-xl bg-[#9475F5] hover:bg-[var(--text-primary)] py-2.5 text-xs font-bold text-white shadow-xs transition"
            >
              Request Password Reset Token
            </button>
          </form>

          <form onSubmit={handleResetPassword} className="mt-6 space-y-3 border-t border-[#DCEEE1] pt-6">
            <label className="block text-xs font-bold uppercase text-[var(--text-primary)]">
              Reset Token
            </label>
            <input
              type="text"
              required
              value={token}
              onChange={(e) => setToken(e.target.value)}
              placeholder="Paste generated token"
              className="w-full rounded-xl border border-[var(--border-color)] bg-[var(--bg-main)] px-3.5 py-2.5 text-sm font-mono text-[var(--text-primary)] focus:border-[#B49AFF] focus:outline-none"
            />
            <label className="block text-xs font-bold uppercase text-[var(--text-primary)]">
              New Password
            </label>
            <input
              type="password"
              required
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              placeholder="At least 6 characters"
              className="w-full rounded-xl border border-[var(--border-color)] bg-[var(--bg-main)] px-3.5 py-2.5 text-sm text-[var(--text-primary)] focus:border-[#B49AFF] focus:outline-none"
            />
            <button
              type="submit"
              className="w-full rounded-xl bg-[var(--text-primary)] hover:bg-[#15102B] py-2.5 text-xs font-bold text-white shadow-xs transition"
            >
              Update Password
            </button>
          </form>

          <div className="mt-6 text-center text-xs text-[var(--text-secondary)]">
            <Link href="/login" className="font-bold text-[#9475F5] hover:text-[var(--text-primary)] hover:underline">
              Return to Workspace Login
            </Link>
          </div>
        </div>
      </main>
      <PublicFooter />
    </div>
  );
}
