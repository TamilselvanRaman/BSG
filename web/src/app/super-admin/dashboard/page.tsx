"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { apiFetch, clearStoredSession, formatINR, getStoredSession } from "@/lib/api";
import {
  Activity,
  Building2,
  CreditCard,
  Layers,
  LogOut,
  Plus,
  RefreshCw,
  Settings,
  Shield,
  Users,
} from "lucide-react";

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
    ownerEmail: "",
    ownerPhone: "",
    adminFullName: "",
    adminUsername: "",
    adminPassword: "",
  });

  // Modal state for creating a new Subscription Plan
  const [showNewPlanModal, setShowNewPlanModal] = useState(false);
  const [newPlanForm, setNewPlanForm] = useState({
    code: "",
    name: "",
    description: "",
    monthlyPrice: 1999,
    annualPrice: 19990,
    maxUsers: 10,
    maxGoodsRecords: 2000,
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
        ownerEmail: "",
        ownerPhone: "",
        adminFullName: "",
        adminUsername: "",
        adminPassword: "",
      });
      notify("New tenant business and Admin provisioned.");
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
                  <div className="flex items-center justify-between">
                    <h2 className="text-base font-bold text-slate-900">
                      All Registered Tenant Businesses ({businesses.length})
                    </h2>
                  </div>
                  <div className="mt-4 overflow-x-auto">
                    <table className="w-full text-left text-sm">
                      <thead className="border-b border-slate-200 bg-slate-50 text-xs font-semibold uppercase text-slate-600">
                        <tr>
                          <th className="px-4 py-3">Code</th>
                          <th className="px-4 py-3">Business Name</th>
                          <th className="px-4 py-3">Contact</th>
                          <th className="px-4 py-3">Plan</th>
                          <th className="px-4 py-3">Records</th>
                          <th className="px-4 py-3">Status</th>
                          <th className="px-4 py-3 text-right">Actions</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-100">
                        {businesses.map((b) => (
                          <tr key={b.id}>
                            <td className="px-4 py-3 font-mono text-xs">{b.code}</td>
                            <td className="px-4 py-3 font-semibold text-slate-900">{b.name}</td>
                            <td className="px-4 py-3 text-xs text-slate-600">
                              {b.ownerEmail}
                              <br />
                              {b.ownerPhone}
                            </td>
                            <td className="px-4 py-3 text-xs font-medium">
                              {b.subscriptions?.[0]?.plan?.name ?? "Trial"}
                            </td>
                            <td className="px-4 py-3 text-xs text-slate-600">
                              {b._count?.users ?? 0} Users • {b._count?.goods ?? 0} Goods
                            </td>
                            <td className="px-4 py-3">
                              <span
                                className={`rounded-full px-2.5 py-0.5 text-xs font-semibold ${
                                  b.status === "ACTIVE"
                                    ? "bg-emerald-50 text-emerald-700"
                                    : b.status === "SUSPENDED"
                                    ? "bg-red-50 text-red-700"
                                    : "bg-amber-50 text-amber-700"
                                }`}
                              >
                                {b.status}
                              </span>
                            </td>
                            <td className="px-4 py-3 text-right">
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
                            </td>
                          </tr>
                        ))}
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
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 p-4">
          <div className="w-full max-w-lg rounded-2xl bg-white p-6 shadow-xl">
            <h3 className="text-lg font-bold text-slate-900">
              Provision New Tenant Business & Admin
            </h3>
            <form onSubmit={handleCreateBusiness} className="mt-4 space-y-3">
              <input
                type="text"
                required
                placeholder="Business Name"
                value={newBizForm.name}
                onChange={(e) => setNewBizForm({ ...newBizForm, name: e.target.value })}
                className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
              />
              <div className="grid grid-cols-2 gap-3">
                <input
                  type="email"
                  required
                  placeholder="Owner Email"
                  value={newBizForm.ownerEmail}
                  onChange={(e) => setNewBizForm({ ...newBizForm, ownerEmail: e.target.value })}
                  className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                />
                <input
                  type="text"
                  required
                  placeholder="Owner Phone"
                  value={newBizForm.ownerPhone}
                  onChange={(e) => setNewBizForm({ ...newBizForm, ownerPhone: e.target.value })}
                  className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                />
              </div>
              <input
                type="text"
                required
                placeholder="Admin Full Name"
                value={newBizForm.adminFullName}
                onChange={(e) => setNewBizForm({ ...newBizForm, adminFullName: e.target.value })}
                className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
              />
              <div className="grid grid-cols-2 gap-3">
                <input
                  type="text"
                  required
                  placeholder="Admin Username"
                  value={newBizForm.adminUsername}
                  onChange={(e) => setNewBizForm({ ...newBizForm, adminUsername: e.target.value })}
                  className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                />
                <input
                  type="password"
                  required
                  placeholder="Admin Password"
                  value={newBizForm.adminPassword}
                  onChange={(e) => setNewBizForm({ ...newBizForm, adminPassword: e.target.value })}
                  className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                />
              </div>
              <div className="flex justify-end gap-2 pt-3">
                <button
                  type="button"
                  onClick={() => setShowNewBizModal(false)}
                  className="rounded-lg border border-slate-300 px-4 py-2 text-xs font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="rounded-lg bg-blue-600 px-4 py-2 text-xs font-semibold text-white"
                >
                  Create Business
                </button>
              </div>
            </form>
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
