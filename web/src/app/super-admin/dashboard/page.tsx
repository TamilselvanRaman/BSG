"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { apiFetch, clearStoredSession, formatINR, getStoredSession } from "@/lib/api";
import {
  Activity,
  AlertTriangle,
  Building2,
  Check,
  CheckCircle2,
  Clock,
  Copy,
  CreditCard,
  ExternalLink,
  Key,
  Layers,
  LogOut,
  Plus,
  Printer,
  QrCode,
  RefreshCw,
  Settings,
  Shield,
  ShieldCheck,
  Sliders,
  Sparkles,
  UserCheck,
  Users,
  X,
  XCircle,
  Zap,
} from "lucide-react";

const MANDI_FEATURES = [
  { key: "MULTI_PRODUCT_LOTS", name: "Multi-Product Inward Lots", desc: "Store multiple crops/products in a single inward lot" },
  { key: "MULTI_PRODUCT_BILLING", name: "Multi-Product Cash & Credit Bills", desc: "Add multiple goods items to cash/credit sales bills" },
  { key: "BAG_WEIGHMENT_SCALE", name: "Bag-by-Bag Weighment Table", desc: "Auto-sum individual bag weights (e.g. 52, 53, 53 kg)" },
  { key: "DAILY_CASH_TALLY", name: "Daily Cash Tally Counter", desc: "Denomination breakdown and cash drawer closing balance" },
  { key: "SMART_CHART_AUCTION", name: "Smart Chart Auction Board", desc: "Real-time lot bidding, buyer allotment, and rates" },
  { key: "PARTNER_LEDGERS", name: "Buyer & Seller Double-Entry Ledgers", desc: "Running account statements, debit/credit history" },
  { key: "CUSTOMER_ADVANCES", name: "Customer Advances & Settlements", desc: "Pre-season cash advance deduction and tracking" },
  { key: "FINANCIAL_REPORTS", name: "Financial & Tax Audit Reports", desc: "GST summary, profit & loss, sales & purchase journals" },
  { key: "WHATSAPP_INVOICES", name: "WhatsApp & SMS Invoices", desc: "One-click bill PDF dispatch to buyer/seller mobile" },
  { key: "MOBILE_APP_SYNC", name: "Android App Cloud Sync", desc: "Real-time offline-first sync with mobile handheld devices" },
];

type SuperTab =
  | "OVERVIEW"
  | "BUSINESSES"
  | "ADMINS"
  | "PLANS"
  | "SUBSCRIPTIONS"
  | "PAYMENTS"
  | "SETTINGS"
  | "AUDIT";

export default function SuperAdminDashboardPage() {
  const router = useRouter();
  const [activeTab, setActiveTab] = useState<SuperTab>("OVERVIEW");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [toast, setToast] = useState<string | null>(null);

  const [dashboard, setDashboard] = useState<any>(null);
  const [businesses, setBusinesses] = useState<any[]>([]);
  const [admins, setAdmins] = useState<any[]>([]);
  const [plans, setPlans] = useState<any[]>([]);
  const [subscriptions, setSubscriptions] = useState<any[]>([]);
  const [payments, setPayments] = useState<any[]>([]);
  const [settings, setSettings] = useState<any>(null);
  const [auditLogs, setAuditLogs] = useState<any[]>([]);

  // Modal state for creating a new Business + Admin
  const [showNewBizModal, setShowNewBizModal] = useState(false);
  const [newBizForm, setNewBizForm] = useState({
    name: "",
    city: "Tamil Nadu",
    marketLocation: "Mandi Market",
    ownerEmail: "",
    ownerPhone: "",
    adminFullName: "",
    adminUsername: "",
    adminPassword: "",
    trialDays: 30,
    maxUsers: 3,
    enableAllFeatures: true,
  });

  // Modal state for managing license & features
  const [selectedBizForLicense, setSelectedBizForLicense] = useState<any | null>(null);
  const [licenseSessions, setLicenseSessions] = useState<any[]>([]);
  const [loadingSessions, setLoadingSessions] = useState(false);
  const [copiedKey, setCopiedKey] = useState<string | null>(null);

  // Modal state for license certificate
  const [certModalBiz, setCertModalBiz] = useState<any | null>(null);
  const [certData, setCertData] = useState<any | null>(null);
  const [loadingCert, setLoadingCert] = useState(false);

  // Modal state for creating a new Subscription Plan
  const [showNewPlanModal, setShowNewPlanModal] = useState(false);
  const [newPlanForm, setNewPlanForm] = useState({
    code: "",
    name: "",
    description: "",
    monthlyPrice: 1999,
    annualPrice: 19990,
    maxUsers: 3,
    maxGoodsRecords: 5000,
    maxBuyersAndSellers: 5000,
  });

  async function loadAllData() {
    setLoading(true);
    setError(null);
    try {
      const [dashData, bizData, admData, planData, subData, payData, setData, audData] =
        await Promise.all([
          apiFetch("/super-admin/dashboard"),
          apiFetch("/super-admin/businesses"),
          apiFetch("/super-admin/admins"),
          apiFetch("/super-admin/plans"),
          apiFetch("/super-admin/subscriptions"),
          apiFetch("/super-admin/payments"),
          apiFetch("/super-admin/settings"),
          apiFetch("/super-admin/audit-logs"),
        ]);
      setDashboard(dashData);
      setBusinesses(bizData);
      setAdmins(admData);
      setPlans(planData);
      setSubscriptions(subData);
      setPayments(payData);
      setSettings(setData);
      setAuditLogs(audData);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    const { user } = getStoredSession();
    if (!user || user.role !== "SUPER_ADMIN") {
      router.push("/login");
      return;
    }
    loadAllData();
  }, [router]);

  function notify(msg: string) {
    setToast(msg);
    setTimeout(() => setToast(null), 3500);
  }

  function copyToClipboard(text: string) {
    if (typeof navigator !== "undefined" && navigator.clipboard) {
      navigator.clipboard.writeText(text);
      setCopiedKey(text);
      setTimeout(() => setCopiedKey(null), 2500);
      notify("Copied to clipboard!");
    }
  }

  async function handleOpenLicenseModal(biz: any) {
    setSelectedBizForLicense(biz);
    setLoadingSessions(true);
    try {
      const res = await apiFetch(`/super-admin/businesses/${biz.id}/active-sessions`);
      setLicenseSessions(res.sessions || []);
    } catch {
      setLicenseSessions([]);
    } finally {
      setLoadingSessions(false);
    }
  }

  async function handleToggleFeature(bizId: string, featureKey: string) {
    if (!selectedBizForLicense) return;
    const current = (selectedBizForLicense.enabledFeatures as string[]) || MANDI_FEATURES.map((f) => f.key);
    const updated = current.includes(featureKey)
      ? current.filter((k) => k !== featureKey)
      : [...current, featureKey];

    try {
      await apiFetch(`/super-admin/businesses/${bizId}/features`, {
        method: "POST",
        body: JSON.stringify({ features: updated }),
      });
      setSelectedBizForLicense({ ...selectedBizForLicense, enabledFeatures: updated });
      notify("Feature access updated.");
      loadAllData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleEnableAllFeatures(bizId: string) {
    try {
      await apiFetch(`/super-admin/businesses/${bizId}/features`, {
        method: "POST",
        body: JSON.stringify({ enableAll: true }),
      });
      const allKeys = MANDI_FEATURES.map((f) => f.key);
      if (selectedBizForLicense) {
        setSelectedBizForLicense({ ...selectedBizForLicense, enabledFeatures: allKeys });
      }
      notify("All 10 Mandi features enabled for this shop!");
      loadAllData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleExtendTrial(bizId: string, days: number) {
    try {
      const res = await apiFetch(`/super-admin/businesses/${bizId}/license/extend-trial`, {
        method: "POST",
        body: JSON.stringify({ days }),
      });
      if (selectedBizForLicense) {
        setSelectedBizForLicense({
          ...selectedBizForLicense,
          status: "TRIAL",
          trialEndsAt: res.trialEndsAt,
        });
      }
      notify(`Free trial extended by ${days} days.`);
      loadAllData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleActivateSubscription(bizId: string, durationMonths: number) {
    try {
      const res = await apiFetch(`/super-admin/businesses/${bizId}/license/activate-subscription`, {
        method: "POST",
        body: JSON.stringify({ durationMonths, maxUsers: 3 }),
      });
      if (selectedBizForLicense) {
        setSelectedBizForLicense({
          ...selectedBizForLicense,
          status: "ACTIVE",
          subscriptionEndsAt: res.subscriptionEndsAt,
        });
      }
      notify(`Subscription activated for ${durationMonths} months (Max 3 Users).`);
      loadAllData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleRegenerateKey(bizId: string) {
    if (!confirm("Are you sure you want to regenerate this shop's license key? Existing activation will be updated.")) return;
    try {
      const res = await apiFetch(`/super-admin/businesses/${bizId}/license/regenerate-key`, {
        method: "POST",
      });
      if (selectedBizForLicense) {
        setSelectedBizForLicense({
          ...selectedBizForLicense,
          licenseKey: res.licenseKey,
        });
      }
      notify("New license key generated successfully.");
      loadAllData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleRevokeSession(bizId: string, userId: string) {
    try {
      await apiFetch(`/super-admin/businesses/${bizId}/active-sessions/${userId}`, {
        method: "DELETE",
      });
      setLicenseSessions((prev) => prev.filter((s) => s.userId !== userId));
      notify("User session revoked. Seat freed up!");
      loadAllData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleOpenCertificate(biz: any) {
    setCertModalBiz(biz);
    setLoadingCert(true);
    try {
      const res = await apiFetch(`/super-admin/businesses/${biz.id}/license/certificate`);
      setCertData(res);
    } catch (err: any) {
      setError(err.message);
      setCertModalBiz(null);
    } finally {
      setLoadingCert(false);
    }
  }

  async function handleToggleBusinessStatus(id: string, action: "activate" | "suspend") {
    try {
      await apiFetch(`/super-admin/businesses/${id}/${action}`, { method: "POST" });
      notify(`Business ${action}d successfully.`);
      loadAllData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleCreateBusiness(e: React.FormEvent) {
    e.preventDefault();
    try {
      await apiFetch("/super-admin/businesses", {
        method: "POST",
        body: JSON.stringify(newBizForm),
      });
      setShowNewBizModal(false);
      setNewBizForm({
        name: "",
        city: "Tamil Nadu",
        marketLocation: "Mandi Market",
        ownerEmail: "",
        ownerPhone: "",
        adminFullName: "",
        adminUsername: "",
        adminPassword: "",
        trialDays: 30,
        maxUsers: 3,
        enableAllFeatures: true,
      });
      notify("New tenant business, Admin, and 30-Day License provisioned.");
      loadAllData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleCreatePlan(e: React.FormEvent) {
    e.preventDefault();
    try {
      await apiFetch("/super-admin/plans", {
        method: "POST",
        body: JSON.stringify(newPlanForm),
      });
      setShowNewPlanModal(false);
      notify("Subscription plan created.");
      loadAllData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleSaveSettings(e: React.FormEvent) {
    e.preventDefault();
    try {
      await apiFetch("/super-admin/settings", {
        method: "PATCH",
        body: JSON.stringify(settings),
      });
      notify("Platform settings saved.");
    } catch (err: any) {
      setError(err.message);
    }
  }

  function handleLogout() {
    clearStoredSession();
    router.push("/login");
  }

  const m = dashboard?.metrics || {};

  return (
    <div className="flex min-h-screen bg-slate-100">
      {/* Sidebar */}
      <aside className="flex w-64 flex-col bg-slate-900 text-slate-200">
        <div className="border-b border-slate-800 px-6 py-5">
          <div className="flex items-center gap-2.5 text-white">
            <Shield className="h-6 w-6 text-blue-400" />
            <div>
              <span className="block text-sm font-bold">CLICK Smart Chart</span>
              <span className="block text-[11px] text-blue-400">Super Admin Control Plane</span>
            </div>
          </div>
        </div>

        <nav className="flex-1 space-y-1 p-4 text-sm">
          {[
            { id: "OVERVIEW", label: "Platform Overview", icon: Activity },
            { id: "BUSINESSES", label: "Registered Businesses", icon: Building2 },
            { id: "ADMINS", label: "Admin Accounts", icon: Users },
            { id: "PLANS", label: "Subscription Plans", icon: Layers },
            { id: "SUBSCRIPTIONS", label: "Active Subscriptions", icon: RefreshCw },
            { id: "PAYMENTS", label: "SaaS Revenue & Payments", icon: CreditCard },
            { id: "SETTINGS", label: "Platform Settings", icon: Settings },
            { id: "AUDIT", label: "Security Audit Logs", icon: Shield },
          ].map((item) => {
            const Icon = item.icon;
            const active = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id as SuperTab)}
                className={`flex w-full items-center gap-3 rounded-lg px-3.5 py-2.5 font-medium transition ${
                  active
                    ? "bg-blue-600 text-white"
                    : "text-slate-300 hover:bg-slate-800 hover:text-white"
                }`}
              >
                <Icon className="h-4 w-4" />
                {item.label}
              </button>
            );
          })}
        </nav>

        <div className="border-t border-slate-800 p-4">
          <button
            onClick={handleLogout}
            className="flex w-full items-center justify-center gap-2 rounded-lg bg-slate-800 px-4 py-2 text-xs font-semibold text-slate-200 hover:bg-red-600 hover:text-white"
          >
            <LogOut className="h-4 w-4" />
            Sign Out
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <div className="flex flex-1 flex-col">
        <header className="flex items-center justify-between border-b border-slate-200 bg-white px-8 py-4">
          <div>
            <h1 className="text-lg font-bold text-slate-900">
              SaaS Super Admin Governance — {activeTab}
            </h1>
            <p className="text-xs text-slate-500">
              Multi-tenant business lifecycle, pricing quotas, and platform security telemetry
            </p>
          </div>
          <div className="flex items-center gap-3">
            <button
              onClick={loadAllData}
              className=" inline-flex items-center gap-1.5 rounded-lg border border-slate-300 bg-white px-3 py-1.5 text-xs font-semibold text-slate-700 hover:bg-slate-50"
            >
              <RefreshCw className="h-3.5 w-3.5" />
              Refresh Data
            </button>
            <button
              onClick={() => setShowNewBizModal(true)}
              className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-3.5 py-1.5 text-xs font-semibold text-white hover:bg-blue-700"
            >
              <Plus className="h-3.5 w-3.5" />
              New Tenant Business
            </button>
          </div>
        </header>

        {toast && (
          <div className="mx-8 mt-4 rounded-lg bg-emerald-600 px-4 py-2.5 text-xs font-semibold text-white shadow">
            {toast}
          </div>
        )}
        {error && (
          <div className="mx-8 mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-2.5 text-xs font-medium text-red-700">
            {error}
          </div>
        )}

        <main className="flex-1 p-8">
          {loading ? (
            <div className="rounded-xl border border-slate-200 bg-white p-12 text-center text-sm text-slate-500">
              Loading platform telemetry...
            </div>
          ) : (
            <>
              {/* TAB 1: OVERVIEW */}
              {activeTab === "OVERVIEW" && (
                <div className="space-y-6">
                  <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <span className="text-xs font-semibold uppercase text-slate-500">
                        Total Registered Businesses
                      </span>
                      <p className="mt-2 text-2xl font-extrabold text-slate-900">
                        {m.totalBusinesses ?? 0}
                      </p>
                      <span className="mt-1 block text-xs text-emerald-600">
                        {m.activeBusinesses ?? 0} Active • {m.suspendedBusinesses ?? 0} Suspended
                      </span>
                    </div>

                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <span className="text-xs font-semibold uppercase text-slate-500">
                        Monthly Recurring Revenue (MRR)
                      </span>
                      <p className="mt-2 text-2xl font-extrabold text-blue-600">
                        {formatINR(m.monthlyRecurringRevenue)}
                      </p>
                      <span className="mt-1 block text-xs text-slate-500">
                        Total SaaS Collected: {formatINR(m.totalSaasRevenue)}
                      </span>
                    </div>

                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <span className="text-xs font-semibold uppercase text-slate-500">
                        Subscriptions Breakdown
                      </span>
                      <p className="mt-2 text-2xl font-extrabold text-slate-900">
                        {m.activeSubscriptions ?? 0} Active
                      </p>
                      <span className="mt-1 block text-xs text-slate-500">
                        {m.trialSubscriptions ?? 0} Trial • {m.expiredSubscriptions ?? 0} Expired
                      </span>
                    </div>

                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <span className="text-xs font-semibold uppercase text-slate-500">
                        Conversion & Platform Users
                      </span>
                      <p className="mt-2 text-2xl font-extrabold text-slate-900">
                        {m.subscriptionConversionRate ?? 0}%
                      </p>
                      <span className="mt-1 block text-xs text-slate-500">
                        Total Users Across Tenants: {m.totalUsers ?? 0}
                      </span>
                    </div>
                  </div>

                  <div className="grid gap-6 lg:grid-cols-2">
                    <div className="rounded-xl border border-slate-200 bg-white p-6">
                      <h3 className="text-sm font-bold text-slate-900">
                        Recent Tenant Registrations
                      </h3>
                      <div className="mt-4 divide-y divide-slate-100 text-sm">
                        {(dashboard?.recentRegistrations || []).map((biz: any) => (
                          <div key={biz.id} className="flex items-center justify-between py-3">
                            <div>
                              <p className="font-semibold text-slate-900">{biz.name}</p>
                              <p className="text-xs text-slate-500">
                                {biz.code} • {biz.ownerEmail}
                              </p>
                            </div>
                            <span className="rounded-full bg-blue-50 px-2.5 py-1 text-xs font-semibold text-blue-700">
                              {biz.status}
                            </span>
                          </div>
                        ))}
                      </div>
                    </div>

                    <div className="rounded-xl border border-slate-200 bg-white p-6">
                      <h3 className="text-sm font-bold text-slate-900">
                        Recent SaaS Payment Transactions
                      </h3>
                      <div className="mt-4 divide-y divide-slate-100 text-sm">
                        {(dashboard?.recentTransactions || []).map((t: any) => (
                          <div key={t.id} className="flex items-center justify-between py-3">
                            <div>
                              <p className="font-semibold text-slate-900">
                                {t.tenant?.name ?? "Tenant"}
                              </p>
                              <p className="text-xs text-slate-500">
                                {t.gateway} • Ref: {t.transactionRef || t.gatewayPaymentId || "-"}
                              </p>
                            </div>
                            <div className="text-right">
                              <p className="font-bold text-emerald-700">{formatINR(t.amount)}</p>
                              <span className="text-[11px] font-semibold text-slate-500">
                                {t.status}
                              </span>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* TAB 2: BUSINESSES */}
              {activeTab === "BUSINESSES" && (
                <div className="rounded-xl border border-slate-200 bg-white p-6">
                  <div className="flex flex-wrap items-center justify-between gap-4">
                    <div>
                      <h2 className="text-base font-bold text-slate-900">
                        All Registered Tenant Businesses ({businesses.length})
                      </h2>
                      <p className="text-xs text-slate-500">
                        Multi-tenant governance: License keys, trial status, max 3 users limit, and 1-click feature access
                      </p>
                    </div>
                    <button
                      onClick={() => setShowNewBizModal(true)}
                      className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-3.5 py-1.5 text-xs font-semibold text-white hover:bg-blue-700 shadow-sm"
                    >
                      <Plus className="h-3.5 w-3.5" />
                      Provision New Shop
                    </button>
                  </div>
                  <div className="mt-5 overflow-x-auto">
                    <table className="w-full text-left text-sm">
                      <thead className="border-b border-slate-200 bg-slate-50 text-xs font-semibold uppercase text-slate-600">
                        <tr>
                          <th className="px-4 py-3">Shop / Business</th>
                          <th className="px-4 py-3">Owner Contact</th>
                          <th className="px-4 py-3">License Key</th>
                          <th className="px-4 py-3">Status & Validity</th>
                          <th className="px-4 py-3">Seat Quota</th>
                          <th className="px-4 py-3">Mandi Features</th>
                          <th className="px-4 py-3 text-right">License Controls</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-100">
                        {businesses.map((b) => {
                          const maxUsers = b.maxUsers ?? 3;
                          const userCount = b._count?.users ?? 0;
                          const activeSessions = b._count?.activeSessions ?? 0;
                          const enabledFeatures = Array.isArray(b.enabledFeatures)
                            ? b.enabledFeatures
                            : MANDI_FEATURES.map((f) => f.key);
                          const isTrial = b.status === "TRIAL";
                          const trialDaysLeft = b.trialEndsAt
                            ? Math.max(0, Math.ceil((new Date(b.trialEndsAt).getTime() - Date.now()) / (1000 * 60 * 60 * 24)))
                            : null;

                          return (
                            <tr key={b.id} className="hover:bg-slate-50/70 transition">
                              <td className="px-4 py-3.5">
                                <div className="font-semibold text-slate-900">{b.name}</div>
                                <div className="flex items-center gap-1.5 mt-0.5">
                                  <span className="font-mono text-[11px] font-semibold text-slate-500">
                                    {b.code}
                                  </span>
                                  <span className="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] text-slate-600">
                                    {b.city || "Tamil Nadu"} • {b.marketLocation || "Mandi"}
                                  </span>
                                </div>
                              </td>

                              <td className="px-4 py-3.5 text-xs text-slate-600">
                                <div className="font-medium text-slate-800">{b.ownerPhone}</div>
                                <div className="text-[11px] text-slate-400">{b.ownerEmail}</div>
                              </td>

                              <td className="px-4 py-3.5 text-xs">
                                {b.licenseKey ? (
                                  <div className="flex items-center gap-1.5">
                                    <span className="font-mono font-semibold text-slate-700 bg-slate-100 px-2 py-0.5 rounded text-[11px]">
                                      {b.licenseKey.slice(0, 14)}...
                                    </span>
                                    <button
                                      onClick={() => copyToClipboard(b.licenseKey)}
                                      title="Copy full license key"
                                      className="rounded p-1 text-slate-400 hover:text-blue-600 hover:bg-slate-100"
                                    >
                                      {copiedKey === b.licenseKey ? (
                                        <Check className="h-3.5 w-3.5 text-emerald-600" />
                                      ) : (
                                        <Copy className="h-3.5 w-3.5" />
                                      )}
                                    </button>
                                  </div>
                                ) : (
                                  <span className="text-[11px] text-slate-400 italic">None</span>
                                )}
                              </td>

                              <td className="px-4 py-3.5 text-xs">
                                {b.status === "ACTIVE" ? (
                                  <div>
                                    <span className="inline-flex items-center gap-1 rounded-full bg-emerald-50 px-2.5 py-0.5 text-[11px] font-semibold text-emerald-700">
                                      <CheckCircle2 className="h-3 w-3" />
                                      Active Plan
                                    </span>
                                    {b.subscriptionEndsAt && (
                                      <div className="text-[10px] text-slate-500 mt-0.5">
                                        Exp: {new Date(b.subscriptionEndsAt).toLocaleDateString()}
                                      </div>
                                    )}
                                  </div>
                                ) : isTrial ? (
                                  <div>
                                    <span className="inline-flex items-center gap-1 rounded-full bg-amber-50 px-2.5 py-0.5 text-[11px] font-semibold text-amber-700">
                                      <Clock className="h-3 w-3" />
                                      Free Trial ({trialDaysLeft ?? 0}d left)
                                    </span>
                                  </div>
                                ) : (
                                  <span className="rounded-full bg-red-50 px-2.5 py-0.5 text-[11px] font-semibold text-red-700">
                                    {b.status}
                                  </span>
                                )}
                              </td>

                              <td className="px-4 py-3.5 text-xs">
                                <div className="flex items-center gap-1.5 font-medium text-slate-800">
                                  <Users className="h-3.5 w-3.5 text-slate-500" />
                                  <span>{userCount} / {maxUsers} Users</span>
                                </div>
                                <div className="text-[11px] text-slate-500 mt-0.5">
                                  {activeSessions} active session{activeSessions === 1 ? "" : "s"}
                                  {userCount >= maxUsers && (
                                    <span className="ml-1 font-bold text-amber-600">(Limit reached)</span>
                                  )}
                                </div>
                              </td>

                              <td className="px-4 py-3.5 text-xs">
                                <span className="inline-flex items-center gap-1 rounded-full bg-blue-50 px-2.5 py-0.5 text-[11px] font-semibold text-blue-700">
                                  <Sparkles className="h-3 w-3 text-blue-600" />
                                  {enabledFeatures.length}/10 Features
                                </span>
                              </td>

                              <td className="px-4 py-3.5 text-right">
                                <div className="flex items-center justify-end gap-1.5">
                                  <button
                                    onClick={() => handleOpenLicenseModal(b)}
                                    title="Manage License, Max 3 Users & Features"
                                    className="inline-flex items-center gap-1 rounded-lg border border-slate-300 bg-white px-2.5 py-1 text-xs font-semibold text-slate-700 hover:bg-slate-50 hover:border-slate-400"
                                  >
                                    <Sliders className="h-3 w-3 text-blue-600" />
                                    Manage
                                  </button>
                                  <button
                                    onClick={() => handleOpenCertificate(b)}
                                    title="View Printable License Certificate"
                                    className="inline-flex items-center gap-1 rounded-lg border border-slate-200 bg-slate-100 px-2 py-1 text-xs font-semibold text-slate-700 hover:bg-slate-200"
                                  >
                                    <Printer className="h-3 w-3" />
                                  </button>
                                  {b.status === "SUSPENDED" ? (
                                    <button
                                      onClick={() => handleToggleBusinessStatus(b.id, "activate")}
                                      className="rounded bg-emerald-600 px-2.5 py-1 text-xs font-semibold text-white hover:bg-emerald-700"
                                    >
                                      Activate
                                    </button>
                                  ) : (
                                    <button
                                      onClick={() => handleToggleBusinessStatus(b.id, "suspend")}
                                      className="rounded bg-amber-600 px-2.5 py-1 text-xs font-semibold text-white hover:bg-amber-700"
                                    >
                                      Suspend
                                    </button>
                                  )}
                                </div>
                              </td>
                            </tr>
                          );
                        })}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* TAB 3: ADMINS */}
              {activeTab === "ADMINS" && (
                <div className="rounded-xl border border-slate-200 bg-white p-6">
                  <h2 className="text-base font-bold text-slate-900">
                    Business Admin Accounts ({admins.length})
                  </h2>
                  <div className="mt-4 overflow-x-auto">
                    <table className="w-full text-left text-sm">
                      <thead className="border-b border-slate-200 bg-slate-50 text-xs font-semibold uppercase text-slate-600">
                        <tr>
                          <th className="px-4 py-3">Username</th>
                          <th className="px-4 py-3">Full Name</th>
                          <th className="px-4 py-3">Assigned Business</th>
                          <th className="px-4 py-3">Status</th>
                          <th className="px-4 py-3">Last Login</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-100">
                        {admins.map((a) => (
                          <tr key={a.id}>
                            <td className="px-4 py-3 font-mono text-xs font-semibold">
                              {a.username}
                            </td>
                            <td className="px-4 py-3">{a.fullName}</td>
                            <td className="px-4 py-3 text-xs font-medium text-blue-700">
                              {a.tenant?.name ?? "Unassigned"} ({a.tenant?.code})
                            </td>
                            <td className="px-4 py-3">
                              <span className="rounded-full bg-emerald-50 px-2.5 py-0.5 text-xs font-semibold text-emerald-700">
                                {a.status}
                              </span>
                            </td>
                            <td className="px-4 py-3 text-xs text-slate-500">
                              {a.lastLoginAt ? new Date(a.lastLoginAt).toLocaleString() : "Never"}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* TAB 4: PLANS */}
              {activeTab === "PLANS" && (
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <h2 className="text-base font-bold text-slate-900">
                      SaaS Subscription Plans & Quotas
                    </h2>
                    <button
                      onClick={() => setShowNewPlanModal(true)}
                      className="rounded-lg bg-slate-900 px-4 py-2 text-xs font-semibold text-white"
                    >
                      + Create Plan
                    </button>
                  </div>
                  <div className="grid gap-6 md:grid-cols-3">
                    {plans.map((p) => (
                      <div key={p.id} className="rounded-xl border border-slate-200 bg-white p-6">
                        <span className="rounded bg-blue-50 px-2 py-0.5 font-mono text-xs font-semibold text-blue-700">
                          {p.code}
                        </span>
                        <h3 className="mt-2 text-lg font-bold text-slate-900">{p.name}</h3>
                        <p className="mt-1 text-xs text-slate-500">{p.description}</p>
                        <p className="mt-4 text-2xl font-extrabold text-slate-900">
                          {formatINR(p.monthlyPrice)}{" "}
                          <span className="text-xs font-normal text-slate-500">/ month</span>
                        </p>
                        <p className="text-xs text-slate-500">
                          Annual: {formatINR(p.annualPrice)} • Trial: {p.trialDays} days
                        </p>
                        <div className="mt-4 space-y-1 border-t border-slate-100 pt-3 text-xs text-slate-600">
                          <p>• Max Users: {p.maxUsers}</p>
                          <p>• Max Goods: {p.maxGoodsRecords}</p>
                          <p>• Max Buyers & Sellers: {p.maxBuyersAndSellers}</p>
                          <p>• Active Subscriptions: {p._count?.subscriptions ?? 0}</p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* TAB 5: SUBSCRIPTIONS */}
              {activeTab === "SUBSCRIPTIONS" && (
                <div className="rounded-xl border border-slate-200 bg-white p-6">
                  <h2 className="text-base font-bold text-slate-900">
                    Tenant Subscriptions ({subscriptions.length})
                  </h2>
                  <div className="mt-4 overflow-x-auto">
                    <table className="w-full text-left text-sm">
                      <thead className="border-b border-slate-200 bg-slate-50 text-xs font-semibold uppercase text-slate-600">
                        <tr>
                          <th className="px-4 py-3">Business</th>
                          <th className="px-4 py-3">Plan</th>
                          <th className="px-4 py-3">Cycle</th>
                          <th className="px-4 py-3">Status</th>
                          <th className="px-4 py-3">Expiry Date</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-100">
                        {subscriptions.map((s) => (
                          <tr key={s.id}>
                            <td className="px-4 py-3 font-semibold text-slate-900">
                              {s.tenant?.name} ({s.tenant?.code})
                            </td>
                            <td className="px-4 py-3">{s.plan?.name}</td>
                            <td className="px-4 py-3 text-xs">{s.billingCycle}</td>
                            <td className="px-4 py-3">
                              <span className="rounded-full bg-blue-50 px-2.5 py-0.5 text-xs font-semibold text-blue-700">
                                {s.status}
                              </span>
                            </td>
                            <td className="px-4 py-3 text-xs text-slate-600">
                              {new Date(s.endDate).toLocaleDateString()}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* TAB 6: PAYMENTS */}
              {activeTab === "PAYMENTS" && (
                <div className="rounded-xl border border-slate-200 bg-white p-6">
                  <h2 className="text-base font-bold text-slate-900">
                    SaaS Subscription Payments ({payments.length})
                  </h2>
                  <div className="mt-4 overflow-x-auto">
                    <table className="w-full text-left text-sm">
                      <thead className="border-b border-slate-200 bg-slate-50 text-xs font-semibold uppercase text-slate-600">
                        <tr>
                          <th className="px-4 py-3">Business</th>
                          <th className="px-4 py-3">Plan</th>
                          <th className="px-4 py-3">Gateway & Ref</th>
                          <th className="px-4 py-3">Amount</th>
                          <th className="px-4 py-3">Status</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-100">
                        {payments.map((p) => (
                          <tr key={p.id}>
                            <td className="px-4 py-3 font-semibold">{p.tenant?.name}</td>
                            <td className="px-4 py-3 text-xs">{p.subscription?.plan?.name}</td>
                            <td className="px-4 py-3 font-mono text-xs">
                              {p.gateway} / {p.transactionRef || p.gatewayPaymentId || "-"}
                            </td>
                            <td className="px-4 py-3 font-bold text-slate-900">
                              {formatINR(p.amount)}
                            </td>
                            <td className="px-4 py-3">
                              <span className="rounded-full bg-emerald-50 px-2.5 py-0.5 text-xs font-semibold text-emerald-700">
                                {p.status}
                              </span>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* TAB 7: SETTINGS */}
              {activeTab === "SETTINGS" && settings && (
                <form
                  onSubmit={handleSaveSettings}
                  className="max-w-2xl space-y-4 rounded-xl border border-slate-200 bg-white p-6"
                >
                  <h2 className="text-base font-bold text-slate-900">
                    Global Platform Settings & Maintenance Control
                  </h2>
                  <div className="grid gap-4 sm:grid-cols-2">
                    <div>
                      <label className="block text-xs font-semibold uppercase text-slate-700">
                        Platform Name
                      </label>
                      <input
                        type="text"
                        value={settings.platformName || ""}
                        onChange={(e) =>
                          setSettings({ ...settings, platformName: e.target.value })
                        }
                        className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold uppercase text-slate-700">
                        Support Email
                      </label>
                      <input
                        type="email"
                        value={settings.contactEmail || ""}
                        onChange={(e) =>
                          setSettings({ ...settings, contactEmail: e.target.value })
                        }
                        className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold uppercase text-slate-700">
                        Support Phone
                      </label>
                      <input
                        type="text"
                        value={settings.contactPhone || ""}
                        onChange={(e) =>
                          setSettings({ ...settings, contactPhone: e.target.value })
                        }
                        className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold uppercase text-slate-700">
                        Default Trial Days
                      </label>
                      <input
                        type="number"
                        value={settings.defaultTrialDays || 14}
                        onChange={(e) =>
                          setSettings({
                            ...settings,
                            defaultTrialDays: Number(e.target.value),
                          })
                        }
                        className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                      />
                    </div>
                  </div>
                  <div className="flex items-center gap-6 pt-2 text-sm">
                    <label className="flex items-center gap-2">
                      <input
                        type="checkbox"
                        checked={Boolean(settings.allowPublicRegistration)}
                        onChange={(e) =>
                          setSettings({
                            ...settings,
                            allowPublicRegistration: e.target.checked,
                          })
                        }
                      />
                      Allow Public Business Registration
                    </label>
                    <label className="flex items-center gap-2 text-red-700">
                      <input
                        type="checkbox"
                        checked={Boolean(settings.maintenanceMode)}
                        onChange={(e) =>
                          setSettings({ ...settings, maintenanceMode: e.target.checked })
                        }
                      />
                      Enable Platform Maintenance Mode
                    </label>
                  </div>
                  <button
                    type="submit"
                    className="rounded-lg bg-blue-600 px-5 py-2.5 text-xs font-semibold text-white hover:bg-blue-700"
                  >
                    Save Platform Configuration
                  </button>
                </form>
              )}

              {/* TAB 8: AUDIT LOGS */}
              {activeTab === "AUDIT" && (
                <div className="rounded-xl border border-slate-200 bg-white p-6">
                  <h2 className="text-base font-bold text-slate-900">
                    Immutable Platform Security & Audit Logs
                  </h2>
                  <div className="mt-4 overflow-x-auto">
                    <table className="w-full text-left text-sm">
                      <thead className="border-b border-slate-200 bg-slate-50 text-xs font-semibold uppercase text-slate-600">
                        <tr>
                          <th className="px-4 py-3">Timestamp</th>
                          <th className="px-4 py-3">Action</th>
                          <th className="px-4 py-3">Actor</th>
                          <th className="px-4 py-3">Tenant</th>
                          <th className="px-4 py-3">Entity</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-100">
                        {auditLogs.map((log) => (
                          <tr key={log.id}>
                            <td className="px-4 py-2.5 text-xs text-slate-500">
                              {new Date(log.createdAt).toLocaleString()}
                            </td>
                            <td className="px-4 py-2.5 font-mono text-xs font-semibold text-blue-700">
                              {log.action}
                            </td>
                            <td className="px-4 py-2.5 text-xs">
                              {log.user?.username ?? "System"}
                            </td>
                            <td className="px-4 py-2.5 text-xs">
                              {log.tenant?.name ?? "Platform"}
                            </td>
                            <td className="px-4 py-2.5 text-xs text-slate-500">
                              {log.entityType} ({log.entityId?.slice(0, 8) || "-"})
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}
            </>
          )}
        </main>
      </div>

      {/* Modal: Provision New Tenant Business */}
      {showNewBizModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 p-4 backdrop-blur-sm overflow-y-auto">
          <div className="w-full max-w-xl rounded-2xl bg-white p-6 shadow-2xl my-8">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div>
                <h3 className="text-lg font-bold text-slate-900">
                  Provision New Shop / Store
                </h3>
                <p className="text-xs text-slate-500">
                  Creates Tenant ID, 30-Day Free Trial License (Max 3 Users), and Store Admin credentials
                </p>
              </div>
              <button
                onClick={() => setShowNewBizModal(false)}
                className="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-600"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <form onSubmit={handleCreateBusiness} className="mt-4 space-y-3.5 text-xs">
              <div>
                <label className="block font-semibold text-slate-700 uppercase tracking-wider mb-1">
                  Shop / Store Name *
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. BSG Trading Corp / Lakshmi Vegetable Mandi"
                  value={newBizForm.name}
                  onChange={(e) => setNewBizForm({ ...newBizForm, name: e.target.value })}
                  className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-blue-600 focus:outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 uppercase tracking-wider mb-1">
                    City / Town *
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Coimbatore / Madurai"
                    value={newBizForm.city}
                    onChange={(e) => setNewBizForm({ ...newBizForm, city: e.target.value })}
                    className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-blue-600 focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 uppercase tracking-wider mb-1">
                    Market Location *
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Gandhi Market / Koyambedu"
                    value={newBizForm.marketLocation}
                    onChange={(e) => setNewBizForm({ ...newBizForm, marketLocation: e.target.value })}
                    className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-blue-600 focus:outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 uppercase tracking-wider mb-1">
                    Owner Phone *
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. 9841238910"
                    value={newBizForm.ownerPhone}
                    onChange={(e) => setNewBizForm({ ...newBizForm, ownerPhone: e.target.value })}
                    className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-blue-600 focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 uppercase tracking-wider mb-1">
                    Owner Email *
                  </label>
                  <input
                    type="email"
                    required
                    placeholder="owner@bsg.com"
                    value={newBizForm.ownerEmail}
                    onChange={(e) => setNewBizForm({ ...newBizForm, ownerEmail: e.target.value })}
                    className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-blue-600 focus:outline-none"
                  />
                </div>
              </div>

              <div className="rounded-xl border border-slate-200 bg-slate-50/70 p-3.5 space-y-3">
                <span className="font-bold text-slate-800 uppercase tracking-wider text-[11px] block">
                  Store Admin Login Account
                </span>
                <input
                  type="text"
                  required
                  placeholder="Admin Full Name (e.g. Kannan Murugan)"
                  value={newBizForm.adminFullName}
                  onChange={(e) => setNewBizForm({ ...newBizForm, adminFullName: e.target.value })}
                  className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm focus:border-blue-600 focus:outline-none"
                />
                <div className="grid grid-cols-2 gap-3">
                  <input
                    type="text"
                    required
                    placeholder="Admin Username (e.g. kannan_admin)"
                    value={newBizForm.adminUsername}
                    onChange={(e) => setNewBizForm({ ...newBizForm, adminUsername: e.target.value })}
                    className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm focus:border-blue-600 focus:outline-none"
                  />
                  <input
                    type="password"
                    required
                    placeholder="Admin Password"
                    value={newBizForm.adminPassword}
                    onChange={(e) => setNewBizForm({ ...newBizForm, adminPassword: e.target.value })}
                    className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm focus:border-blue-600 focus:outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3 pt-1">
                <div>
                  <label className="block font-semibold text-slate-700 uppercase tracking-wider mb-1">
                    Free Trial Days
                  </label>
                  <input
                    type="number"
                    min="1"
                    max="365"
                    value={newBizForm.trialDays}
                    onChange={(e) => setNewBizForm({ ...newBizForm, trialDays: Number(e.target.value) })}
                    className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-blue-600 focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 uppercase tracking-wider mb-1">
                    Max User Login Seats
                  </label>
                  <input
                    type="number"
                    readOnly
                    value={3}
                    className="w-full rounded-lg border border-slate-200 bg-slate-100 px-3 py-2 text-sm font-semibold text-slate-700 cursor-not-allowed"
                  />
                  <p className="text-[10px] text-slate-500 mt-0.5">Strictly 3 users (1 Admin + 2 Staff)</p>
                </div>
              </div>

              <div className="rounded-lg border border-blue-200 bg-blue-50/70 p-3">
                <label className="flex items-center gap-2 font-semibold text-blue-900 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={newBizForm.enableAllFeatures}
                    onChange={(e) => setNewBizForm({ ...newBizForm, enableAllFeatures: e.target.checked })}
                    className="h-4 w-4 rounded border-blue-400 text-blue-600 focus:ring-blue-500"
                  />
                  <span>⚡ 1-Click: Enable All 10 Mandi Features by Default</span>
                </label>
                <p className="text-[11px] text-blue-700 mt-1 pl-6">
                  Includes Multi-Product Lots, Multi-Product Billing, Bag Weighment Scale, Smart Chart Auctions, Partner Ledgers, and WhatsApp bills.
                </p>
              </div>

              <div className="flex justify-end gap-2 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setShowNewBizModal(false)}
                  className="rounded-lg border border-slate-300 px-4 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-5 py-2 text-xs font-semibold text-white hover:bg-blue-700 shadow"
                >
                  <CheckCircle2 className="h-4 w-4" />
                  Provision Shop & Issue License
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal: Shop License & Feature Governance */}
      {selectedBizForLicense && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 p-4 backdrop-blur-sm overflow-y-auto">
          <div className="w-full max-w-2xl rounded-2xl bg-white p-6 shadow-2xl my-8">
            <div className="flex items-start justify-between border-b border-slate-100 pb-3">
              <div>
                <div className="flex items-center gap-2">
                  <h3 className="text-lg font-bold text-slate-900">
                    {selectedBizForLicense.name}
                  </h3>
                  <span className="font-mono text-xs rounded bg-slate-100 px-2 py-0.5 font-bold text-slate-700">
                    {selectedBizForLicense.code}
                  </span>
                  <span className={`text-[11px] font-bold rounded-full px-2.5 py-0.5 ${
                    selectedBizForLicense.status === "ACTIVE"
                      ? "bg-emerald-50 text-emerald-700"
                      : "bg-amber-50 text-amber-700"
                  }`}>
                    {selectedBizForLicense.status}
                  </span>
                </div>
                <p className="text-xs text-slate-500 mt-0.5">
                  Tenant Governance • License Key & 10 Mandi Feature Switches
                </p>
              </div>
              <button
                onClick={() => setSelectedBizForLicense(null)}
                className="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-600"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <div className="mt-4 space-y-5 text-xs max-h-[75vh] overflow-y-auto pr-1">
              {/* License Key Card */}
              <div className="rounded-xl border border-slate-200 bg-slate-50 p-3.5 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="font-bold uppercase tracking-wider text-slate-700 flex items-center gap-1.5">
                    <Key className="h-3.5 w-3.5 text-blue-600" />
                    License Key & Quota Limits
                  </span>
                  <span className="text-[11px] font-bold text-slate-600">
                    Max Login Limit: 3 Users (Strict)
                  </span>
                </div>

                <div className="flex items-center gap-2">
                  <input
                    type="text"
                    readOnly
                    value={selectedBizForLicense.licenseKey || "No License Generated"}
                    className="flex-1 rounded-lg border border-slate-300 bg-white font-mono text-xs font-semibold px-3 py-2 text-slate-800"
                  />
                  <button
                    onClick={() => copyToClipboard(selectedBizForLicense.licenseKey)}
                    className="inline-flex items-center gap-1 rounded-lg border border-slate-300 bg-white px-3 py-2 font-semibold text-slate-700 hover:bg-slate-50 shadow-sm"
                  >
                    {copiedKey === selectedBizForLicense.licenseKey ? (
                      <>
                        <Check className="h-3.5 w-3.5 text-emerald-600" />
                        Copied
                      </>
                    ) : (
                      <>
                        <Copy className="h-3.5 w-3.5" />
                        Copy
                      </>
                    )}
                  </button>
                  <button
                    onClick={() => handleRegenerateKey(selectedBizForLicense.id)}
                    className="inline-flex items-center gap-1 rounded-lg border border-slate-300 bg-white px-3 py-2 font-semibold text-amber-700 hover:bg-amber-50 shadow-sm"
                  >
                    <RefreshCw className="h-3.5 w-3.5" />
                    Regenerate
                  </button>
                </div>
              </div>

              {/* Master 1-Click Feature Activation */}
              <div className="rounded-xl border border-emerald-200 bg-emerald-50/80 p-4">
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <div>
                    <h4 className="font-bold text-emerald-950 flex items-center gap-1.5 text-sm">
                      <Zap className="h-4 w-4 text-emerald-600" />
                      1-Click Mandi Suite Master Switch
                    </h4>
                    <p className="text-[11px] text-emerald-800 mt-0.5">
                      Instantly enable all 10 features for this shop without configuring individually.
                    </p>
                  </div>
                  <button
                    onClick={() => handleEnableAllFeatures(selectedBizForLicense.id)}
                    className="inline-flex items-center gap-1.5 rounded-lg bg-emerald-600 px-4 py-2 font-bold text-white hover:bg-emerald-700 shadow-sm transition"
                  >
                    <Sparkles className="h-4 w-4" />
                    Enable All 10 Features (1-Click)
                  </button>
                </div>
              </div>

              {/* Granular Feature Toggles */}
              <div>
                <div className="flex items-center justify-between mb-2">
                  <h4 className="font-bold text-slate-900 text-sm">
                    Granular Feature Toggles (10 Mandi Capabilities)
                  </h4>
                  <span className="text-[11px] text-slate-500">
                    {((selectedBizForLicense.enabledFeatures as string[]) || []).length} / 10 Active
                  </span>
                </div>
                <div className="divide-y divide-slate-100 rounded-xl border border-slate-200 bg-white">
                  {MANDI_FEATURES.map((feat) => {
                    const activeFeatures =
                      (selectedBizForLicense.enabledFeatures as string[]) ||
                      MANDI_FEATURES.map((f) => f.key);
                    const isEnabled = activeFeatures.includes(feat.key);

                    return (
                      <div
                        key={feat.key}
                        className="flex items-center justify-between p-3 hover:bg-slate-50/60 transition"
                      >
                        <div className="pr-4">
                          <p className="font-semibold text-slate-900 text-xs">{feat.name}</p>
                          <p className="text-[11px] text-slate-500">{feat.desc}</p>
                        </div>
                        <button
                          type="button"
                          onClick={() => handleToggleFeature(selectedBizForLicense.id, feat.key)}
                          className={`relative inline-flex h-5 w-10 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none ${
                            isEnabled ? "bg-blue-600" : "bg-slate-300"
                          }`}
                        >
                          <span
                            className={`pointer-events-none inline-block h-4 w-4 transform rounded-full bg-white shadow-lg ring-0 transition duration-200 ease-in-out ${
                              isEnabled ? "translate-x-5" : "translate-x-0"
                            }`}
                          />
                        </button>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Subscription & Free Trial Management */}
              <div className="rounded-xl border border-slate-200 bg-slate-50 p-3.5 space-y-3">
                <h4 className="font-bold text-slate-900 text-sm">
                  Subscription & Free Trial Controls
                </h4>
                <div className="flex flex-wrap items-center gap-2">
                  <span className="font-semibold text-slate-700">Extend Free Trial:</span>
                  <button
                    onClick={() => handleExtendTrial(selectedBizForLicense.id, 15)}
                    className="rounded-lg border border-slate-300 bg-white px-2.5 py-1 font-semibold text-slate-700 hover:bg-slate-100"
                  >
                    +15 Days
                  </button>
                  <button
                    onClick={() => handleExtendTrial(selectedBizForLicense.id, 30)}
                    className="rounded-lg border border-slate-300 bg-white px-2.5 py-1 font-semibold text-slate-700 hover:bg-slate-100"
                  >
                    +30 Days
                  </button>
                  <button
                    onClick={() => handleExtendTrial(selectedBizForLicense.id, 60)}
                    className="rounded-lg border border-slate-300 bg-white px-2.5 py-1 font-semibold text-slate-700 hover:bg-slate-100"
                  >
                    +60 Days
                  </button>

                  <div className="ml-auto">
                    <button
                      onClick={() => handleActivateSubscription(selectedBizForLicense.id, 12)}
                      className="rounded-lg bg-slate-900 px-3 py-1 font-semibold text-white hover:bg-slate-800 shadow-sm"
                    >
                      Activate 1-Year Paid License
                    </button>
                  </div>
                </div>
              </div>

              {/* Active User Sessions (Seats Enforcement: Max 3) */}
              <div className="rounded-xl border border-slate-200 bg-white p-3.5 space-y-2.5">
                <div className="flex items-center justify-between">
                  <div>
                    <h4 className="font-bold text-slate-900 text-sm flex items-center gap-1.5">
                      <UserCheck className="h-4 w-4 text-blue-600" />
                      Active Concurrent User Sessions
                    </h4>
                    <p className="text-[11px] text-slate-500">
                      Seats Occupied: <strong>{licenseSessions.length} / {selectedBizForLicense.maxUsers || 3} Users</strong>. If a user forgot to log out, you can revoke their session to free up a seat.
                    </p>
                  </div>
                </div>

                {loadingSessions ? (
                  <p className="text-slate-400 italic py-2">Loading active sessions...</p>
                ) : licenseSessions.length === 0 ? (
                  <p className="text-slate-400 italic py-2">No users currently logged in for this shop.</p>
                ) : (
                  <div className="divide-y divide-slate-100 border border-slate-100 rounded-lg">
                    {licenseSessions.map((s) => (
                      <div key={s.id} className="flex items-center justify-between p-2.5">
                        <div>
                          <p className="font-semibold text-slate-800">
                            {s.user?.fullName} ({s.user?.username})
                          </p>
                          <p className="text-[10px] text-slate-500">
                            IP: {s.ipAddress || "Unknown"} • Active: {new Date(s.lastActiveAt).toLocaleTimeString()}
                          </p>
                        </div>
                        <button
                          onClick={() => handleRevokeSession(selectedBizForLicense.id, s.userId)}
                          className="rounded bg-red-50 border border-red-200 px-2 py-1 text-[11px] font-semibold text-red-700 hover:bg-red-100"
                        >
                          Revoke / Free Seat
                        </button>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>

            <div className="flex justify-end gap-2 pt-4 border-t border-slate-100 mt-4">
              <button
                type="button"
                onClick={() => setSelectedBizForLicense(null)}
                className="rounded-lg bg-slate-900 px-5 py-2 text-xs font-semibold text-white hover:bg-slate-800"
              >
                Done
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal: Printable License Certificate */}
      {certModalBiz && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 p-4 backdrop-blur-sm overflow-y-auto">
          <div className="w-full max-w-xl rounded-2xl bg-white p-8 shadow-2xl my-8 border-4 border-slate-900">
            {loadingCert || !certData ? (
              <div className="text-center py-12 text-slate-500">Loading License Certificate...</div>
            ) : (
              <div className="space-y-6">
                <div className="text-center border-b-2 border-slate-900 pb-4">
                  <div className="inline-flex items-center justify-center h-12 w-12 rounded-full bg-slate-900 text-white mb-2">
                    <ShieldCheck className="h-6 w-6" />
                  </div>
                  <h2 className="text-xl font-black uppercase tracking-widest text-slate-900">
                    Official Software License Certificate
                  </h2>
                  <p className="text-xs text-slate-600 font-medium uppercase tracking-wider mt-1">
                    Mandi OS • Agricultural Buyer-Seller Cloud Platform
                  </p>
                </div>

                <div className="grid grid-cols-2 gap-4 text-xs">
                  <div>
                    <span className="text-[10px] uppercase font-bold text-slate-400 block">Registered Shop</span>
                    <strong className="text-sm text-slate-900">{certData.shopName}</strong>
                    <div className="text-slate-500 font-mono text-[11px]">Tenant Code: {certData.shopCode}</div>
                  </div>
                  <div>
                    <span className="text-[10px] uppercase font-bold text-slate-400 block">Market Location</span>
                    <span className="text-xs text-slate-800 font-medium">{certData.marketLocation}, {certData.city}</span>
                  </div>
                  <div>
                    <span className="text-[10px] uppercase font-bold text-slate-400 block">Owner Contact</span>
                    <span className="text-xs text-slate-800">{certData.ownerPhone}</span>
                  </div>
                  <div>
                    <span className="text-[10px] uppercase font-bold text-slate-400 block">Authorized Seat Quota</span>
                    <strong className="text-xs text-blue-700">Max {certData.maxUsers} Users (1 Admin + 2 Staff)</strong>
                  </div>
                </div>

                <div className="rounded-xl border-2 border-dashed border-slate-300 bg-slate-50 p-3 text-center">
                  <span className="text-[10px] uppercase font-bold text-slate-500 block mb-1">
                    Software License Authentication Key
                  </span>
                  <p className="font-mono text-xs font-bold text-slate-900 select-all tracking-wider">
                    {certData.licenseKey || "BSG-LIC-PROVISIONAL"}
                  </p>
                </div>

                <div>
                  <span className="text-[10px] uppercase font-bold text-slate-500 block mb-2">
                    Activated Mandi Capabilities (10/10 Enabled)
                  </span>
                  <div className="grid grid-cols-2 gap-1.5 text-[11px]">
                    {((certData.enabledFeatures as string[]) || MANDI_FEATURES.map((f) => f.key)).map((fKey: string) => {
                      const feat = MANDI_FEATURES.find((f) => f.key === fKey);
                      return (
                        <div key={fKey} className="flex items-center gap-1.5 text-slate-700">
                          <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600 shrink-0" />
                          <span className="truncate">{feat?.name || fKey}</span>
                        </div>
                      );
                    })}
                  </div>
                </div>

                <div className="flex items-center justify-between border-t border-slate-200 pt-4 text-xs">
                  <div>
                    <span className="text-[10px] text-slate-400 block">License Issued</span>
                    <span className="text-slate-600">{new Date(certData.issuedAt).toLocaleDateString()}</span>
                  </div>
                  <div className="text-right">
                    <span className="text-[10px] text-slate-400 block">Validity</span>
                    <span className="font-semibold text-emerald-700">
                      {certData.subscriptionEndsAt
                        ? `Valid till ${new Date(certData.subscriptionEndsAt).toLocaleDateString()}`
                        : certData.trialEndsAt
                        ? `Free Trial till ${new Date(certData.trialEndsAt).toLocaleDateString()}`
                        : "Active"}
                    </span>
                  </div>
                </div>

                <div className="flex justify-end gap-2 pt-2 border-t border-slate-100">
                  <button
                    type="button"
                    onClick={() => window.print()}
                    className="inline-flex items-center gap-1.5 rounded-lg bg-slate-900 px-4 py-2 text-xs font-semibold text-white hover:bg-slate-800"
                  >
                    <Printer className="h-4 w-4" />
                    Print Certificate
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setCertModalBiz(null);
                      setCertData(null);
                    }}
                    className="rounded-lg border border-slate-300 px-4 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-50"
                  >
                    Close
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Modal: Create Plan */}
      {showNewPlanModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 p-4">
          <div className="w-full max-w-lg rounded-2xl bg-white p-6 shadow-xl">
            <h3 className="text-lg font-bold text-slate-900">Create Subscription Plan</h3>
            <form onSubmit={handleCreatePlan} className="mt-4 space-y-3">
              <div className="grid grid-cols-2 gap-3">
                <input
                  type="text"
                  required
                  placeholder="Plan Code (e.g. PRO_PLUS)"
                  value={newPlanForm.code}
                  onChange={(e) => setNewPlanForm({ ...newPlanForm, code: e.target.value })}
                  className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                />
                <input
                  type="text"
                  required
                  placeholder="Plan Display Name"
                  value={newPlanForm.name}
                  onChange={(e) => setNewPlanForm({ ...newPlanForm, name: e.target.value })}
                  className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <input
                  type="number"
                  required
                  placeholder="Monthly Price (INR)"
                  value={newPlanForm.monthlyPrice}
                  onChange={(e) =>
                    setNewPlanForm({ ...newPlanForm, monthlyPrice: Number(e.target.value) })
                  }
                  className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                />
                <input
                  type="number"
                  required
                  placeholder="Annual Price (INR)"
                  value={newPlanForm.annualPrice}
                  onChange={(e) =>
                    setNewPlanForm({ ...newPlanForm, annualPrice: Number(e.target.value) })
                  }
                  className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                />
              </div>
              <div className="flex justify-end gap-2 pt-3">
                <button
                  type="button"
                  onClick={() => setShowNewPlanModal(false)}
                  className="rounded-lg border border-slate-300 px-4 py-2 text-xs font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="rounded-lg bg-slate-900 px-4 py-2 text-xs font-semibold text-white"
                >
                  Save Plan
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
