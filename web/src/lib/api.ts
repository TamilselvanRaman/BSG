import { AuthUser } from "@/types";

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:4000/api/v1";

const TOKEN_KEY = "csc_access_token";
const REFRESH_KEY = "csc_refresh_token";
const USER_KEY = "csc_auth_user";

export function getStoredSession(): {
  accessToken: string | null;
  refreshToken: string | null;
  user: AuthUser | null;
} {
  if (typeof window === "undefined") {
    return { accessToken: null, refreshToken: null, user: null };
  }
  const accessToken = localStorage.getItem(TOKEN_KEY);
  const refreshToken = localStorage.getItem(REFRESH_KEY);
  const rawUser = localStorage.getItem(USER_KEY);
  const user = rawUser ? (JSON.parse(rawUser) as AuthUser) : null;
  return { accessToken, refreshToken, user };
}

export function saveStoredSession(
  accessToken: string,
  refreshToken: string,
  user: AuthUser
) {
  if (typeof window === "undefined") return;
  localStorage.setItem(TOKEN_KEY, accessToken);
  localStorage.setItem(REFRESH_KEY, refreshToken);
  localStorage.setItem(USER_KEY, JSON.stringify(user));
}

export function clearStoredSession() {
  if (typeof window === "undefined") return;
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(REFRESH_KEY);
  localStorage.removeItem(USER_KEY);
}

export async function apiFetch<T = any>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const { accessToken, refreshToken } = getStoredSession();

  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...(options.headers as Record<string, string>),
  };

  if (accessToken) {
    headers["Authorization"] = `Bearer ${accessToken}`;
  }

  let res = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...options,
    headers,
  });

  // Transparently attempt refresh token rotation on 401
  if (res.status === 401 && refreshToken && !endpoint.startsWith("/auth/")) {
    const refreshRes = await fetch(`${API_BASE_URL}/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken }),
    });

    if (refreshRes.ok) {
      const refreshJson = await refreshRes.json();
      const { user } = getStoredSession();
      if (user && refreshJson.data?.accessToken) {
        saveStoredSession(
          refreshJson.data.accessToken,
          refreshJson.data.refreshToken,
          user
        );
        headers["Authorization"] = `Bearer ${refreshJson.data.accessToken}`;
        res = await fetch(`${API_BASE_URL}${endpoint}`, {
          ...options,
          headers,
        });
      }
    }
  }

  const payload = await res.json().catch(() => null);
  if (!res.ok || !payload?.success) {
    throw new Error(
      payload?.error?.message || `API request failed (${res.status})`
    );
  }

  return payload.data as T;
}

export function formatINR(value: number | string | undefined | null): string {
  const num = Number(value ?? 0);
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 2,
  }).format(Number.isFinite(num) ? num : 0);
}

export function exportRowsToCsv(filename: string, rows: Record<string, unknown>[]) {
  if (typeof window === "undefined" || rows.length === 0) return;
  const headers = Object.keys(rows[0]);
  const csvLines = [
    headers.join(","),
    ...rows.map((r) =>
      headers
        .map((h) => `"${String(r[h] ?? "").replace(/"/g, '""')}"`)
        .join(",")
    ),
  ];
  const blob = new Blob([csvLines.join("\n")], { type: "text/csv;charset=utf-8;" });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.setAttribute("download", filename);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}
