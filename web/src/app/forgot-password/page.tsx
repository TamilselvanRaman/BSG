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
    <div className="flex min-h-screen flex-col bg-[#F4FAF5] text-[#123B29] font-sans">
      <PublicNavbar />
      <main className="mx-auto flex w-full max-w-md flex-1 items-center px-4 sm:px-6 py-14">
        <div className="w-full rounded-3xl border border-[#CDE8D5] bg-white p-8 sm:p-9 shadow-xl shadow-[#063D2E]/5">
          <h1 className="text-xl font-bold text-[#063D2E]">Account Password Recovery</h1>
          <p className="mt-1 text-xs text-[#47785C]">
            Request a reset token or complete password recovery
          </p>

          {message && (
            <div className="mt-4 rounded-xl bg-[#E8F5EC] border border-[#CDE8D5] p-3 text-xs font-semibold text-[#087A50]">
              {message}
            </div>
          )}
          {error && (
            <div className="mt-4 rounded-xl bg-red-50 border border-red-200 p-3 text-xs font-semibold text-[#C2413B]">
              {error}
            </div>
          )}

          <form onSubmit={handleRequestReset} className="mt-5 space-y-3">
            <label className="block text-xs font-bold uppercase text-[#123B29]">
              Username or Registered Email
            </label>
            <input
              type="text"
              required
              value={usernameOrEmail}
              onChange={(e) => setUsernameOrEmail(e.target.value)}
              className="w-full rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] px-3.5 py-2.5 text-sm text-[#123B29] focus:border-[#10A66A] focus:outline-none"
            />
            <button
              type="submit"
              className="w-full rounded-xl bg-[#087A50] hover:bg-[#063D2E] py-2.5 text-xs font-bold text-white shadow-xs transition"
            >
              Request Password Reset Token
            </button>
          </form>

          <form onSubmit={handleResetPassword} className="mt-6 space-y-3 border-t border-[#DCEEE1] pt-6">
            <label className="block text-xs font-bold uppercase text-[#123B29]">
              Reset Token
            </label>
            <input
              type="text"
              required
              value={token}
              onChange={(e) => setToken(e.target.value)}
              placeholder="Paste generated token"
              className="w-full rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] px-3.5 py-2.5 text-sm font-mono text-[#123B29] focus:border-[#10A66A] focus:outline-none"
            />
            <label className="block text-xs font-bold uppercase text-[#123B29]">
              New Password
            </label>
            <input
              type="password"
              required
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              placeholder="At least 6 characters"
              className="w-full rounded-xl border border-[#CDE8D5] bg-[#F4FAF5] px-3.5 py-2.5 text-sm text-[#123B29] focus:border-[#10A66A] focus:outline-none"
            />
            <button
              type="submit"
              className="w-full rounded-xl bg-[#063D2E] hover:bg-[#0A503B] py-2.5 text-xs font-bold text-white shadow-xs transition"
            >
              Update Password
            </button>
          </form>

          <div className="mt-6 text-center text-xs text-[#47785C]">
            <Link href="/login" className="font-bold text-[#087A50] hover:text-[#063D2E] hover:underline">
              Return to Workspace Login
            </Link>
          </div>
        </div>
      </main>
      <PublicFooter />
    </div>
  );
}
