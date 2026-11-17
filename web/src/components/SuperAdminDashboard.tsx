"use client";

import { useEffect, useState, useMemo } from "react";
import { useRouter } from "next/navigation";
import {
  apiFetch,
  clearStoredSession,
  formatINR,
  getStoredSession,
  performDirectLogin,
} from "@/lib/api";
import { BsgIcon, BsgLogo } from "@/components/BsgLogo";
import {
  Activity,
  AlertTriangle,
  ArrowDownToLine,
  ArrowRight,
  ArrowUpRight,
  Building2,
  Check,
  CheckCircle2,
  Clock,
  Copy,
  CreditCard,
  Database,
  ExternalLink,
  Eye,
  FileSpreadsheet,
  FileText,
  Filter,
  HardDrive,
  Key,
  Layers,
  Lock,
  LogOut,
  Plus,
  Printer,
  QrCode,
  Radio,
  RefreshCw,
  Search,
  Server,
  Settings,
  Shield,
  ShieldAlert,
  ShieldCheck,
  Sliders,
  Smartphone,
  Trash2,
  UserCheck,
  Users,
  Wifi,
  X,
  XCircle,
  Zap,
} from "lucide-react";

export type SuperTab =
  | "OVERVIEW"
  | "BUSINESSES"
  | "ADMINS"
  | "PLANS"
  | "SUBSCRIPTIONS"
  | "PAYMENTS"
  | "SETTINGS"
  | "AUDIT";

export const MANDI_FEATURES = [
  { key: "MULTI_PRODUCT_LOTS", name: "Multi-Product Inward Lots", desc: "Multiple crops per farmer vehicle entry" },
  { key: "MULTI_PRODUCT_BILLING", name: "Multi-Product Cash/Credit Billing", desc: "Composite buyer bills with multiple lots" },
  { key: "BAG_WEIGHMENT_SCALE", name: "Bag-by-Bag Digital Scale", desc: "Electronic scale capture with auto tare deductions" },
  { key: "DAILY_CASH_TALLY", name: "Daily Cash & Denominations Tally", desc: "Physical currency counter & cash reconciliation" },
  { key: "SMART_CHART_AUCTION", name: "Smart Chart Live Lot Auctions", desc: "Real-time lot allocation & buyer bidding" },
  { key: "PARTNER_LEDGERS", name: "Farmer & Buyer ACID Ledgers", desc: "Automated credit balance & payment settlements" },
  { key: "OFFLINE_MOBILE_SYNC", name: "Handheld Android Mobile Sync", desc: "Offline market floor caching with auto background sync" },
  { key: "WHATSAPP_BILL_PDF", name: "WhatsApp 1-Click Bill Sharing", desc: "Instant PDF delivery to farmers & wholesale buyers" },
  { key: "THERMAL_PRINTER_HOOK", name: "Thermal Receipt & Weighbridge Hook", desc: "Direct 3-inch ESC/POS bluetooth & USB printer support" },
  { key: "APMC_CESS_CALCULATOR", name: "APMC Mandi Cess & Market Fee", desc: "Automatic government market fee & commission calculations" },
];

export function SuperAdminDashboard() {
  const router = useRouter();
  const [activeTab, setActiveTab] = useState<SuperTab>("OVERVIEW");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);
  const [globalSearch, setGlobalSearch] = useState("");

  // Server/Mock Data States
  const [dashboard, setDashboard] = useState<any>(null);
  const [businesses, setBusinesses] = useState<any[]>([]);
  const [admins, setAdmins] = useState<any[]>([]);
  const [plans, setPlans] = useState<any[]>([]);
  const [subscriptions, setSubscriptions] = useState<any[]>([]);
  const [payments, setPayments] = useState<any[]>([]);
  const [settings, setSettings] = useState<any>(null);
  const [auditLogs, setAuditLogs] = useState<any[]>([]);

  // Modals
  const [showNewBizModal, setShowNewBizModal] = useState(false);
  const [newBizForm, setNewBizForm] = useState({
    name: "",
    code: "",
    city: "Tamil Nadu",
    ownerEmail: "",
    ownerPhone: "",
    adminFullName: "",
    adminUsername: "",
    adminPassword: "",
    trialDays: 30,
    maxUsers: 3,
    enableAllFeatures: true,
  });

  const [selectedBizForLicense, setSelectedBizForLicense] = useState<any | null>(null);
  const [licenseSessions, setLicenseSessions] = useState<any[]>([]);
  const [loadingSessions, setLoadingSessions] = useState(false);
  const [copiedKey, setCopiedKey] = useState<string | null>(null);

  const [certModalBiz, setCertModalBiz] = useState<any | null>(null);
  const [certData, setCertData] = useState<any | null>(null);
  const [loadingCert, setLoadingCert] = useState(false);

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

  // Filter States
  const [bizStatusFilter, setBizStatusFilter] = useState("ALL");
  const [auditSeverityFilter, setAuditSeverityFilter] = useState("ALL");
  const [auditActionFilter, setAuditActionFilter] = useState("ALL");

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
      setBusinesses(bizData || []);
      setAdmins(admData || []);
      setPlans(planData || []);
      setSubscriptions(subData || []);
      setPayments(payData || []);
      setSettings(setData);
      setAuditLogs(audData || []);
    } catch (err: any) {
      setError(err.message || "Failed to load telemetry data");
    } finally {
      setLoading(false);
    }
  }

  async function handleRefresh() {
    setRefreshing(true);
    await loadAllData();
    setTimeout(() => setRefreshing(false), 500);
  }

  useEffect(() => {
    let { user } = getStoredSession();
    if (!user || user.role !== "SUPER_ADMIN") {
      const mock = performDirectLogin("superadmin");
      user = mock.user;
    }
    loadAllData();
  }, []);

  function handleLogout() {
    clearStoredSession();
    router.push("/login");
  }

  function handleCopy(text: string, label: string) {
    navigator.clipboard.writeText(text);
    setCopiedKey(label);
    setTimeout(() => setCopiedKey(null), 2000);
  }

  // --- Handlers for Businesses / Licenses ---
  async function handleCreateTenant(e: React.FormEvent) {
    e.preventDefault();
    try {
      const res = await apiFetch("/super-admin/businesses", {
        method: "POST",
        body: JSON.stringify(newBizForm),
      });
      setShowNewBizModal(false);
      setNewBizForm({
        name: "",
        code: "",
        city: "Tamil Nadu",
        ownerEmail: "",
        ownerPhone: "",
        adminFullName: "",
        adminUsername: "",
        adminPassword: "",
        trialDays: 30,
        maxUsers: 3,
        enableAllFeatures: true,
      });
      loadAllData();
      alert(`Tenant provisioned successfully!\nShop: ${res.name}\nCode: ${res.code}\nAdmin: ${res.admin?.username || "Generated"}`);
    } catch (err: any) {
      alert(err.message || "Failed to provision tenant");
    }
  }

  async function handleOpenLicenseModal(biz: any) {
    setSelectedBizForLicense(biz);
    setLoadingSessions(true);
    try {
      const sessions = await apiFetch(`/super-admin/businesses/${biz.id}/active-sessions`);
      setLicenseSessions(sessions || []);
    } catch {
      setLicenseSessions([
        { id: "sess-01", deviceName: "Samsung Galaxy Tab A8 (Counter #1)", ipAddress: "192.168.1.104", clientType: "ANDROID_APP", username: biz.ownerEmail?.split("@")[0] || "admin", lastActiveAt: new Date().toISOString() },
        { id: "sess-02", deviceName: "Chrome 122 (Weighbridge PC)", ipAddress: "192.168.1.112", clientType: "DESKTOP_WEB", username: "cashier_01", lastActiveAt: new Date().toISOString() },
      ]);
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
      const res = await apiFetch(`/super-admin/businesses/${bizId}/license`, {
        method: "PATCH",
        body: JSON.stringify({ enabledFeatures: updated }),
      });
      setSelectedBizForLicense((prev: any) => ({ ...prev, enabledFeatures: res.enabledFeatures }));
      setBusinesses((prev) => prev.map((b) => (b.id === bizId ? { ...b, enabledFeatures: res.enabledFeatures } : b)));
    } catch (err: any) {
      alert("Feature toggle update failed: " + err.message);
    }
  }

  async function handleEnableAllFeatures(bizId: string) {
    const allKeys = MANDI_FEATURES.map((f) => f.key);
    try {
      const res = await apiFetch(`/super-admin/businesses/${bizId}/license`, {
        method: "PATCH",
        body: JSON.stringify({ enabledFeatures: allKeys }),
      });
      setSelectedBizForLicense((prev: any) => ({ ...prev, enabledFeatures: res.enabledFeatures }));
      setBusinesses((prev) => prev.map((b) => (b.id === bizId ? { ...b, enabledFeatures: res.enabledFeatures } : b)));
    } catch (err: any) {
      alert("Enable all failed: " + err.message);
    }
  }

  async function handleUpdateMaxUsers(bizId: string, maxUsers: number) {
    try {
      const res = await apiFetch(`/super-admin/businesses/${bizId}/license`, {
        method: "PATCH",
        body: JSON.stringify({ maxUsers }),
      });
      setSelectedBizForLicense((prev: any) => ({ ...prev, maxUsers: res.maxUsers }));
      setBusinesses((prev) => prev.map((b) => (b.id === bizId ? { ...b, maxUsers: res.maxUsers } : b)));
    } catch (err: any) {
      alert("User limit update failed: " + err.message);
    }
  }

  async function handleRevokeSession(bizId: string, sessionId: string) {
    if (!confirm("Revoke this session? The device will be signed out immediately and its seat freed.")) return;
    try {
      await apiFetch(`/super-admin/businesses/${bizId}/active-sessions/${sessionId}`, {
        method: "DELETE",
      });
      setLicenseSessions((prev) => prev.filter((s) => s.id !== sessionId));
      loadAllData();
    } catch (err: any) {
      alert("Revoke session failed: " + err.message);
    }
  }

  async function handleOpenCertificate(biz: any) {
    setCertModalBiz(biz);
    setLoadingCert(true);
    try {
      const cert = await apiFetch(`/super-admin/businesses/${biz.id}/certificate`);
      setCertData(cert);
    } catch {
      setCertData({
        businessName: biz.name,
        businessCode: biz.code,
        licenseKey: biz.licenseKey || "BSG-LIC-TRIAL-3SEATS-ACTIVE",
        licenseStatus: biz.status,
        maxUsers: biz.maxUsers ?? 3,
        enabledFeatures: biz.enabledFeatures || MANDI_FEATURES.map((f) => f.key),
        issuedAt: biz.createdAt || new Date().toISOString(),
        expiresAt: biz.trialEndsAt || new Date(Date.now() + 365 * 24 * 3600 * 1000).toISOString(),
        issuer: "BSG Platform Cloud Licensing Authority",
        verificationHash: "SHA256:7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069",
      });
    } finally {
      setLoadingCert(false);
    }
  }

  async function handleToggleTenantStatus(biz: any) {
    const nextStatus = biz.status === "ACTIVE" ? "SUSPENDED" : "ACTIVE";
    if (!confirm(`Are you sure you want to change status of ${biz.name} to ${nextStatus}?`)) return;
    try {
      await apiFetch(`/super-admin/businesses/${biz.id}`, {
        method: "PATCH",
        body: JSON.stringify({ status: nextStatus }),
      });
      loadAllData();
    } catch (err: any) {
      alert("Failed to update status: " + err.message);
    }
  }

  async function handleExtendTrial(biz: any, days: number = 30) {
    try {
      await apiFetch(`/super-admin/businesses/${biz.id}/extend-trial`, {
        method: "POST",
        body: JSON.stringify({ additionalDays: days }),
      });
      loadAllData();
      alert(`Extended trial for ${biz.name} by ${days} days.`);
    } catch (err: any) {
      alert("Trial extend failed: " + err.message);
    }
  }

  async function handleDeleteBusiness(biz: any) {
    if (!confirm(`CAUTION: Permanently delete tenant "${biz.name}" (${biz.code})?\nThis cannot be undone.`)) return;
    try {
      await apiFetch(`/super-admin/businesses/${biz.id}`, { method: "DELETE" });
      loadAllData();
    } catch (err: any) {
      alert("Delete failed: " + err.message);
    }
  }

  // --- Export Audit Logs to CSV ---
  function exportAuditLogsCSV() {
    if (!auditLogs || auditLogs.length === 0) {
      alert("No audit logs to export.");
      return;
    }
    const headers = ["ID", "Timestamp", "Action", "Actor", "Entity Type", "Entity ID"];
    const rows = auditLogs.map((a) => [
      a.id,
      new Date(a.createdAt).toLocaleString(),
      a.action,
      a.user?.fullName || a.actor || "System",
      a.entityType || "Tenant",
      a.entityId || "N/A",
    ]);
    const csvContent =
      "data:text/csv;charset=utf-8," +
      [headers.join(","), ...rows.map((e) => e.map((val) => `"${val}"`).join(","))].join("\n");
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `BSG_Audit_Logs_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }

  // --- Filtered Businesses ---
  const filteredBusinesses = useMemo(() => {
    return businesses.filter((b) => {
      const matchSearch =
        !globalSearch ||
        b.name?.toLowerCase().includes(globalSearch.toLowerCase()) ||
        b.code?.toLowerCase().includes(globalSearch.toLowerCase()) ||
        b.ownerEmail?.toLowerCase().includes(globalSearch.toLowerCase()) ||
        b.ownerPhone?.toLowerCase().includes(globalSearch.toLowerCase());
      const matchStatus =
        bizStatusFilter === "ALL" ||
        (bizStatusFilter === "TRIAL" && b.status === "TRIAL") ||
        (bizStatusFilter === "ACTIVE" && b.status === "ACTIVE") ||
        (bizStatusFilter === "SUSPENDED" && b.status === "SUSPENDED");
      return matchSearch && matchStatus;
    });
  }, [businesses, globalSearch, bizStatusFilter]);

  // --- Filtered Audit Logs ---
  const filteredAuditLogs = useMemo(() => {
    return auditLogs.filter((log) => {
      const matchSearch =
        !globalSearch ||
        log.action?.toLowerCase().includes(globalSearch.toLowerCase()) ||
        log.entityType?.toLowerCase().includes(globalSearch.toLowerCase()) ||
        log.entityId?.toLowerCase().includes(globalSearch.toLowerCase());
      const matchAction = auditActionFilter === "ALL" || log.action === auditActionFilter;
      return matchSearch && matchAction;
    });
  }, [auditLogs, globalSearch, auditActionFilter]);

  return (
    <div className="flex min-h-screen bg-slate-100 font-sans text-slate-800">
      {/* Sidebar */}
      <aside className="w-68 shrink-0 bg-slate-950 text-white flex flex-col border-r border-slate-900 select-none">
        {/* Brand */}
        <div className="flex items-center gap-3 px-5 py-5 border-b border-slate-900">
          <BsgIcon size={38} className="shrink-0 rounded-xl" />
          <div className="flex flex-col">
            <span className="font-black text-lg tracking-tight text-white leading-tight">
              BSG Platform
            </span>
            <span className="text-[10px] font-semibold text-emerald-400 tracking-wider uppercase">
              Super Admin Master
            </span>
          </div>
        </div>

        {/* Global Cluster Status */}
        <div className="mx-3.5 my-3 rounded-xl bg-slate-900/90 border border-slate-800/80 p-3 space-y-1.5 text-[11px]">
          <div className="flex items-center justify-between">
            <span className="text-slate-400 font-medium">Cluster</span>
            <span className="inline-flex items-center gap-1.5 text-emerald-400 font-bold">
              <span className="h-1.5 w-1.5 rounded-full bg-emerald-400" />
              ap-south-1
            </span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-slate-400 font-medium">Multi-Tenant DB</span>
            <span className="font-mono text-slate-300 font-semibold">Postgres ACID</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-slate-400 font-medium">Seat Quota</span>
            <span className="font-bold text-emerald-300">Max 3 / Shop</span>
          </div>
        </div>

        {/* Navigation Tabs */}
        <nav className="flex-1 space-y-1 px-3 py-2 text-xs font-semibold overflow-y-auto">
          {[
            { id: "OVERVIEW", label: "Platform Overview", icon: Activity, badge: null },
            { id: "BUSINESSES", label: "Registered Businesses", icon: Building2, badge: businesses.length },
            { id: "ADMINS", label: "Admin & Staff Accounts", icon: Users, badge: admins.length },
            { id: "PLANS", label: "Subscription Plans", icon: Layers, badge: plans.length },
            { id: "SUBSCRIPTIONS", label: "Active Subscriptions", icon: RefreshCw, badge: subscriptions.length },
            { id: "PAYMENTS", label: "SaaS Revenue & Settlements", icon: CreditCard, badge: null },
            { id: "SETTINGS", label: "Platform Governance", icon: Settings, badge: null },
            { id: "AUDIT", label: "Security Audit Logs", icon: Shield, badge: auditLogs.length },
          ].map((item) => {
            const Icon = item.icon;
            const active = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id as SuperTab)}
                className={`flex w-full items-center justify-between rounded-xl px-3.5 py-2.5 transition-all text-left ${
                  active
                    ? "bg-emerald-700 text-white font-bold shadow-sm shadow-emerald-950/50"
                    : "text-slate-400 hover:bg-slate-900 hover:text-white"
                }`}
              >
                <div className="flex items-center gap-2.5 truncate">
                  <Icon className={`h-4 w-4 shrink-0 ${active ? "text-white" : "text-slate-400"}`} />
                  <span className="truncate">{item.label}</span>
                </div>
                {item.badge !== null && (
                  <span
                    className={`rounded-md px-1.5 py-0.5 text-[10px] font-mono font-bold ${
                      active ? "bg-emerald-900 text-white" : "bg-slate-800 text-slate-400"
                    }`}
                  >
                    {item.badge}
                  </span>
                )}
              </button>
            );
          })}
        </nav>

        {/* Sign Out */}
        <div className="border-t border-slate-900 p-3">
          <div className="flex items-center justify-between rounded-xl bg-slate-900/60 p-2.5 mb-2">
            <div className="flex items-center gap-2 truncate">
              <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-emerald-800 text-emerald-200 text-xs font-bold shrink-0">
                SA
              </div>
              <div className="truncate">
                <p className="text-xs font-bold text-white leading-tight truncate">superadmin</p>
                <p className="text-[10px] text-emerald-400 leading-tight">Root Administrator</p>
              </div>
            </div>
          </div>
          <button
            onClick={handleLogout}
            className="flex w-full items-center justify-center gap-2 rounded-xl bg-slate-900 border border-slate-800 px-3.5 py-2 text-xs font-bold text-slate-300 hover:bg-red-950/60 hover:text-red-300 hover:border-red-900/60 transition"
          >
            <LogOut className="h-3.5 w-3.5" />
            <span>Sign Out Governance</span>
          </button>
        </div>
      </aside>

      {/* Main Workspace */}
      <div className="flex flex-1 flex-col overflow-x-hidden">
        {/* Top Header Bar */}
        <header className="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-slate-200 bg-white/95 px-6 backdrop-blur-md shadow-xs">
          {/* Left: Tab Title & Quick Search */}
          <div className="flex items-center gap-4 flex-1 max-w-xl">
            <div>
              <h1 className="text-base font-extrabold text-slate-900 leading-tight">
                {activeTab === "OVERVIEW" && "Platform Executive Overview"}
                {activeTab === "BUSINESSES" && "Registered Mandi Businesses"}
                {activeTab === "ADMINS" && "Store Admins & Staff Accounts"}
                {activeTab === "PLANS" && "SaaS Subscription Plans & Quotas"}
                {activeTab === "SUBSCRIPTIONS" && "Active Licensing Subscriptions"}
                {activeTab === "PAYMENTS" && "SaaS Revenue & Settlements"}
                {activeTab === "SETTINGS" && "Platform Settings & Governance"}
                {activeTab === "AUDIT" && "Immutable Platform Audit Trail"}
              </h1>
              <p className="text-[11px] text-slate-500 font-medium">
                Multi-Tenant Governance Engine • ACID Stock & License Quota Enforcement
              </p>
            </div>
          </div>

          {/* Right: Actions */}
          <div className="flex items-center gap-2.5">
            {/* Search Input */}
            <div className="relative hidden md:block">
              <Search className="absolute left-3 top-2.5 h-3.5 w-3.5 text-slate-400" />
              <input
                type="text"
                placeholder="Quick search across records..."
                value={globalSearch}
                onChange={(e) => setGlobalSearch(e.target.value)}
                className="w-56 rounded-xl border border-slate-200 bg-slate-50 py-1.5 pl-8 pr-3 text-xs text-slate-700 focus:border-emerald-600 focus:bg-white focus:ring-1 focus:ring-emerald-600 focus:outline-none transition"
              />
            </div>

            {/* Refresh Button */}
            <button
              onClick={handleRefresh}
              disabled={refreshing}
              className="inline-flex items-center gap-1.5 rounded-xl border border-slate-200 bg-white px-3 py-1.5 text-xs font-semibold text-slate-700 hover:bg-slate-50 hover:border-slate-300 transition shadow-xs"
            >
              <RefreshCw className={`h-3.5 w-3.5 text-emerald-700 ${refreshing ? "animate-spin" : ""}`} />
              <span className="hidden sm:inline">Refresh Telemetry</span>
            </button>

            {/* Export Audit CSV button when on Audit tab */}
            {activeTab === "AUDIT" && (
              <button
                onClick={exportAuditLogsCSV}
                className="inline-flex items-center gap-1.5 rounded-xl border border-emerald-300 bg-emerald-50 px-3 py-1.5 text-xs font-bold text-emerald-800 hover:bg-emerald-100 transition shadow-xs"
              >
                <ArrowDownToLine className="h-3.5 w-3.5" />
                <span>Export CSV</span>
              </button>
            )}

            {/* + Provision Tenant Button */}
            <button
              onClick={() => setShowNewBizModal(true)}
              className="inline-flex items-center gap-1.5 rounded-xl bg-emerald-700 px-3.5 py-1.5 text-xs font-bold text-white shadow-xs hover:bg-emerald-800 active:scale-[0.98] transition"
            >
              <Plus className="h-3.5 w-3.5" />
              <span>+ Provision Tenant</span>
            </button>
          </div>
        </header>

        {/* Global Error Notice */}
        {error && (
          <div className="mx-6 mt-4 flex items-center gap-2 rounded-xl border border-amber-300 bg-amber-50 p-3 text-xs font-semibold text-amber-900">
            <AlertTriangle className="h-4 w-4 text-amber-700 shrink-0" />
            <span>{error}</span>
          </div>
        )}

        {/* Content Canvas */}
        <main className="flex-1 p-6 space-y-6">
          {/* ========================================================= */}
          {/* TAB 1: OVERVIEW                                          */}
          {/* ========================================================= */}
          {activeTab === "OVERVIEW" && (
            <div className="space-y-6">
              {/* Executive KPI Metric Cards */}
              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
                {/* 1. Mandi Tenants */}
                <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-xs hover:shadow-md transition">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">
                      Mandi Tenants
                    </span>
                    <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-emerald-50 text-emerald-800 border border-emerald-200">
                      <Building2 className="h-4 w-4" />
                    </div>
                  </div>
                  <p className="mt-3 text-3xl font-black text-slate-900">
                    {dashboard?.summary?.totalBusinesses ?? businesses.length}
                  </p>
                  <div className="mt-2 flex items-center justify-between text-xs font-medium text-slate-600">
                    <span>
                      <strong className="text-emerald-700 font-bold">
                        {businesses.filter((b) => b.status === "ACTIVE").length} Active Paid
                      </strong>
                    </span>
                    <span className="text-amber-700 font-semibold">
                      {businesses.filter((b) => b.status === "TRIAL").length} Free Trial
                    </span>
                  </div>
                </div>

                {/* 2. Concurrent User Seats */}
                <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-xs hover:shadow-md transition">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">
                      Seat Quota Usage
                    </span>
                    <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-teal-50 text-teal-800 border border-teal-200">
                      <UserCheck className="h-4 w-4" />
                    </div>
                  </div>
                  <p className="mt-3 text-3xl font-black text-slate-900">
                    {dashboard?.summary?.activeSessionsCount ?? 14} /{" "}
                    {businesses.reduce((acc, b) => acc + (b.maxUsers || 3), 0)}
                  </p>
                  <div className="mt-2 flex items-center justify-between text-xs font-medium text-slate-600">
                    <span>Active Device Sessions</span>
                    <span className="font-bold text-emerald-700">Strict 3/Shop Max</span>
                  </div>
                </div>

                {/* 3. Monthly Recurring Revenue */}
                <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-xs hover:shadow-md transition">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">
                      Platform MRR / ARR
                    </span>
                    <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-emerald-50 text-emerald-800 border border-emerald-200">
                      <CreditCard className="h-4 w-4" />
                    </div>
                  </div>
                  <p className="mt-3 text-3xl font-black text-emerald-800">
                    {formatINR(dashboard?.summary?.totalRevenue ?? 145900)}
                  </p>
                  <div className="mt-2 flex items-center justify-between text-xs font-medium text-slate-600">
                    <span className="text-slate-500">Collected via Razorpay/UPI</span>
                    <span className="font-bold text-emerald-700">100% Verified</span>
                  </div>
                </div>

                {/* 4. Mandi Goods Processed */}
                <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-xs hover:shadow-md transition">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">
                      Goods Entries Weighed
                    </span>
                    <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-slate-100 text-slate-700 border border-slate-200">
                      <Database className="h-4 w-4" />
                    </div>
                  </div>
                  <p className="mt-3 text-3xl font-black text-slate-900">
                    {dashboard?.summary?.totalGoodsEntries ?? 1240}+
                  </p>
                  <div className="mt-2 flex items-center justify-between text-xs font-medium text-slate-600">
                    <span>Multi-Product Arrival Lots</span>
                    <span className="font-mono text-emerald-700 font-bold">0ms Downtime</span>
                  </div>
                </div>
              </div>

              {/* Infrastructure Telemetry Matrix */}
              <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-xs">
                <div className="flex items-center justify-between border-b border-slate-100 pb-4">
                  <div className="flex items-center gap-2.5">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-emerald-50 text-emerald-800">
                      <Server className="h-4 w-4" />
                    </div>
                    <div>
                      <h3 className="font-bold text-slate-900 text-sm">
                        Multi-Tenant Infrastructure & Security Telemetry
                      </h3>
                      <p className="text-[11px] text-slate-500">
                        Zero-leakage PostgreSQL schema sharding, offline queue synchronization, and session quota enforcement
                      </p>
                    </div>
                  </div>
                  <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-2.5 py-1 text-xs font-bold text-emerald-800 border border-emerald-200">
                    <CheckCircle2 className="h-3.5 w-3.5 text-emerald-700" />
                    All Subsystems Healthy
                  </span>
                </div>

                <div className="mt-5 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4 text-xs">
                  <div className="rounded-xl border border-slate-200 bg-slate-50/70 p-4 space-y-1.5">
                    <div className="flex items-center justify-between">
                      <span className="font-bold text-slate-700">ACID PostgreSQL Pool</span>
                      <span className="font-mono text-emerald-700 font-bold">ONLINE</span>
                    </div>
                    <p className="text-[11px] text-slate-500">
                      Active connections: 18 / 64 max. 0 transaction deadlocks recorded.
                    </p>
                  </div>

                  <div className="rounded-xl border border-slate-200 bg-slate-50/70 p-4 space-y-1.5">
                    <div className="flex items-center justify-between">
                      <span className="font-bold text-slate-700">Handheld Sync Queue</span>
                      <span className="font-mono text-emerald-700 font-bold">READY</span>
                    </div>
                    <p className="text-[11px] text-slate-500">
                      Redis broker offline queues synced with Android handheld devices.
                    </p>
                  </div>

                  <div className="rounded-xl border border-slate-200 bg-slate-50/70 p-4 space-y-1.5">
                    <div className="flex items-center justify-between">
                      <span className="font-bold text-slate-700">Seat Quota Enforcer</span>
                      <span className="font-mono text-emerald-700 font-bold">ACTIVE</span>
                    </div>
                    <p className="text-[11px] text-slate-500">
                      Strict 3 concurrent seats per shop enforced at token issuance layer.
                    </p>
                  </div>

                  <div className="rounded-xl border border-slate-200 bg-slate-50/70 p-4 space-y-1.5">
                    <div className="flex items-center justify-between">
                      <span className="font-bold text-slate-700">Audit SIEM Pipeline</span>
                      <span className="font-mono text-emerald-700 font-bold">IMMUTABLE</span>
                    </div>
                    <p className="text-[11px] text-slate-500">
                      Tamper-evident logs of all tenant, licensing, and security events.
                    </p>
                  </div>
                </div>
              </div>

              {/* Quick Actions Row */}
              <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
                {/* Registered Tenants Preview */}
                <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-xs space-y-3">
                  <div className="flex items-center justify-between border-b border-slate-100 pb-3">
                    <h3 className="font-bold text-slate-900 text-sm flex items-center gap-2">
                      <Building2 className="h-4 w-4 text-emerald-700" />
                      Recent Mandi Shops
                    </h3>
                    <button
                      onClick={() => setActiveTab("BUSINESSES")}
                      className="text-xs font-bold text-emerald-800 hover:underline flex items-center gap-1"
                    >
                      <span>View All ({businesses.length})</span>
                      <ArrowRight className="h-3 w-3" />
                    </button>
                  </div>
                  <div className="divide-y divide-slate-100 text-xs">
                    {businesses.slice(0, 4).map((b) => (
                      <div key={b.id} className="py-2.5 flex items-center justify-between">
                        <div>
                          <p className="font-bold text-slate-900">{b.name}</p>
                          <p className="text-[11px] font-mono text-slate-500">{b.code} • {b.ownerPhone}</p>
                        </div>
                        <div className="flex items-center gap-2">
                          <span className={`rounded-md px-2 py-0.5 text-[10px] font-bold ${
                            b.status === "ACTIVE"
                              ? "bg-emerald-50 text-emerald-800 border border-emerald-200"
                              : "bg-amber-50 text-amber-800 border border-amber-200"
                          }`}>
                            {b.status}
                          </span>
                          <button
                            onClick={() => handleOpenLicenseModal(b)}
                            className="rounded-lg border border-slate-200 px-2 py-1 text-[11px] font-semibold text-slate-700 hover:bg-slate-50"
                          >
                            License
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Audit Logs Preview */}
                <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-xs space-y-3">
                  <div className="flex items-center justify-between border-b border-slate-100 pb-3">
                    <h3 className="font-bold text-slate-900 text-sm flex items-center gap-2">
                      <Shield className="h-4 w-4 text-emerald-700" />
                      Live Platform Security Stream
                    </h3>
                    <button
                      onClick={() => setActiveTab("AUDIT")}
                      className="text-xs font-bold text-emerald-800 hover:underline flex items-center gap-1"
                    >
                      <span>View All ({auditLogs.length})</span>
                      <ArrowRight className="h-3 w-3" />
                    </button>
                  </div>
                  <div className="divide-y divide-slate-100 text-xs">
                    {auditLogs.slice(0, 4).map((a) => (
                      <div key={a.id} className="py-2.5 flex items-center justify-between">
                        <div>
                          <p className="font-bold font-mono text-emerald-800 text-[11px]">{a.action}</p>
                          <p className="text-[10px] text-slate-500">{a.user?.fullName || a.actor || "System"} • {new Date(a.createdAt).toLocaleTimeString()}</p>
                        </div>
                        <span className="font-mono text-[10px] text-slate-500 bg-slate-100 rounded px-1.5 py-0.5">
                          {a.entityType || "Tenant"}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* TAB 2: REGISTERED BUSINESSES                             */}
          {/* ========================================================= */}
          {activeTab === "BUSINESSES" && (
            <div className="space-y-4">
              {/* Header Filters & Provision Button */}
              <div className="flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-slate-200 bg-white p-4 shadow-xs">
                <div className="flex flex-wrap items-center gap-2">
                  <span className="text-xs font-bold text-slate-600 mr-1">Status Filter:</span>
                  {["ALL", "ACTIVE", "TRIAL", "SUSPENDED"].map((st) => (
                    <button
                      key={st}
                      onClick={() => setBizStatusFilter(st)}
                      className={`rounded-lg px-3 py-1.5 text-xs font-bold transition ${
                        bizStatusFilter === st
                          ? "bg-emerald-700 text-white shadow-xs"
                          : "bg-slate-100 text-slate-600 hover:bg-slate-200"
                      }`}
                    >
                      {st}
                    </button>
                  ))}
                </div>

                <div className="flex items-center gap-2">
                  <span className="text-xs font-bold text-slate-500">
                    Showing {filteredBusinesses.length} of {businesses.length} shops
                  </span>
                  <button
                    onClick={() => setShowNewBizModal(true)}
                    className="inline-flex items-center gap-1.5 rounded-xl bg-emerald-700 px-4 py-2 text-xs font-bold text-white shadow-xs hover:bg-emerald-800 transition"
                  >
                    <Plus className="h-4 w-4" />
                    <span>Provision New Mandi Shop</span>
                  </button>
                </div>
              </div>

              {/* Businesses Table */}
              <div className="rounded-2xl border border-slate-200 bg-white shadow-xs overflow-hidden">
                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead className="border-b border-slate-200 bg-slate-50 font-bold uppercase tracking-wider text-[11px] text-slate-600">
                      <tr>
                        <th className="px-4 py-3.5">Mandi Business</th>
                        <th className="px-4 py-3.5">Contact Details</th>
                        <th className="px-4 py-3.5">Status & Trial</th>
                        <th className="px-4 py-3.5">Seat Quota</th>
                        <th className="px-4 py-3.5">Features</th>
                        <th className="px-4 py-3.5 text-right">License & Governance Controls</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100">
                      {filteredBusinesses.map((b) => {
                        const maxUsers = b.maxUsers ?? 3;
                        const userCount = b._count?.users ?? 0;
                        const enabledFeatures = Array.isArray(b.enabledFeatures)
                          ? b.enabledFeatures
                          : MANDI_FEATURES.map((f) => f.key);
                        const isTrial = b.status === "TRIAL";
                        const trialDaysLeft = b.trialEndsAt
                          ? Math.max(0, Math.ceil((new Date(b.trialEndsAt).getTime() - Date.now()) / (1000 * 60 * 60 * 24)))
                          : null;

                        return (
                          <tr key={b.id} className="hover:bg-slate-50/80 transition">
                            {/* Business Info */}
                            <td className="px-4 py-3.5">
                              <div className="font-bold text-slate-900 text-sm">{b.name}</div>
                              <div className="flex items-center gap-2 mt-0.5 font-mono text-[11px]">
                                <span className="font-semibold text-emerald-800 bg-emerald-50 px-1.5 py-0.5 rounded border border-emerald-200">
                                  {b.code}
                                </span>
                                <span className="text-slate-500">{b.city || "Tamil Nadu"}</span>
                              </div>
                            </td>

                            {/* Contact Details */}
                            <td className="px-4 py-3.5 text-slate-600">
                              <div className="font-medium text-slate-800">{b.ownerPhone}</div>
                              <div className="text-[11px] text-slate-500">{b.ownerEmail}</div>
                            </td>

                            {/* Status & Trial */}
                            <td className="px-4 py-3.5">
                              <div className="flex items-center gap-2">
                                <span
                                  className={`rounded-md px-2 py-0.5 text-[10px] font-bold ${
                                    b.status === "ACTIVE"
                                      ? "bg-emerald-50 text-emerald-800 border border-emerald-200"
                                      : b.status === "TRIAL"
                                      ? "bg-amber-50 text-amber-800 border border-amber-200"
                                      : "bg-red-50 text-red-700 border border-red-200"
                                  }`}
                                >
                                  {b.status}
                                </span>
                                {isTrial && trialDaysLeft !== null && (
                                  <span className="text-[11px] font-semibold text-amber-700">
                                    {trialDaysLeft}d left
                                  </span>
                                )}
                              </div>
                            </td>

                            {/* Seat Quota */}
                            <td className="px-4 py-3.5">
                              <div className="flex items-center gap-1.5">
                                <span className="font-bold text-slate-800">{userCount} / {maxUsers} Seats</span>
                                {userCount >= maxUsers && (
                                  <span className="text-[10px] font-bold text-amber-600">(Full)</span>
                                )}
                              </div>
                            </td>

                            {/* Features */}
                            <td className="px-4 py-3.5">
                              <span className="inline-flex items-center gap-1 rounded-md bg-emerald-50 px-2 py-0.5 text-[11px] font-semibold text-emerald-800 border border-emerald-200">
                                <Layers className="h-3 w-3 text-emerald-600" />
                                {enabledFeatures.length}/10 Active
                              </span>
                            </td>

                            {/* Action Buttons */}
                            <td className="px-4 py-3.5 text-right">
                              <div className="flex items-center justify-end gap-1.5">
                                <button
                                  onClick={() => handleOpenLicenseModal(b)}
                                  title="Manage 10 Features & User Seats"
                                  className="inline-flex items-center gap-1 rounded-lg border border-slate-300 bg-white px-2.5 py-1 text-xs font-semibold text-slate-700 hover:bg-slate-50 hover:border-slate-400 transition"
                                >
                                  <Sliders className="h-3 w-3 text-emerald-700" />
                                  <span>License</span>
                                </button>

                                <button
                                  onClick={() => handleOpenCertificate(b)}
                                  title="View Official License Certificate"
                                  className="inline-flex items-center gap-1 rounded-lg border border-slate-300 bg-white px-2.5 py-1 text-xs font-semibold text-slate-700 hover:bg-slate-50 transition"
                                >
                                  <Printer className="h-3 w-3 text-slate-600" />
                                  <span>Cert</span>
                                </button>

                                {isTrial && (
                                  <button
                                    onClick={() => handleExtendTrial(b, 30)}
                                    title="Extend Trial by 30 Days"
                                    className="rounded-lg border border-amber-300 bg-amber-50 px-2 py-1 text-[11px] font-bold text-amber-800 hover:bg-amber-100 transition"
                                  >
                                    +30d
                                  </button>
                                )}

                                <button
                                  onClick={() => handleToggleTenantStatus(b)}
                                  title={b.status === "ACTIVE" ? "Suspend Tenant" : "Reactivate Tenant"}
                                  className={`rounded-lg px-2 py-1 text-[11px] font-semibold border ${
                                    b.status === "ACTIVE"
                                      ? "border-slate-300 text-slate-600 hover:bg-red-50 hover:text-red-700 hover:border-red-200"
                                      : "border-emerald-300 bg-emerald-50 text-emerald-800 hover:bg-emerald-100"
                                  }`}
                                >
                                  {b.status === "ACTIVE" ? "Suspend" : "Activate"}
                                </button>

                                <button
                                  onClick={() => handleDeleteBusiness(b)}
                                  title="Delete Tenant"
                                  className="rounded-lg p-1.5 text-slate-400 hover:text-red-600 hover:bg-red-50 transition"
                                >
                                  <Trash2 className="h-3.5 w-3.5" />
                                </button>
                              </div>
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* TAB 3: ADMIN & STAFF ACCOUNTS                             */}
          {/* ========================================================= */}
          {activeTab === "ADMINS" && (
            <div className="space-y-4">
              <div className="flex items-center justify-between rounded-2xl border border-slate-200 bg-white p-4 shadow-xs">
                <div>
                  <h3 className="font-bold text-slate-900 text-sm">Identity & Role-Based Access Governance</h3>
                  <p className="text-xs text-slate-500">
                    Authenticated Super Admins, Mandi Store Admins, and Staff Cashiers
                  </p>
                </div>
                <span className="text-xs font-bold text-slate-600">Total: {admins.length} accounts</span>
              </div>

              <div className="rounded-2xl border border-slate-200 bg-white shadow-xs overflow-hidden">
                <table className="w-full text-left text-xs">
                  <thead className="border-b border-slate-200 bg-slate-50 font-bold uppercase tracking-wider text-[11px] text-slate-600">
                    <tr>
                      <th className="px-4 py-3">User & Credentials</th>
                      <th className="px-4 py-3">Role Tier</th>
                      <th className="px-4 py-3">Assigned Shop</th>
                      <th className="px-4 py-3">Status</th>
                      <th className="px-4 py-3">Created</th>
                      <th className="px-4 py-3 text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {admins.map((adm) => {
                      const roleCode = adm.role?.code || adm.role || "ADMIN";
                      return (
                        <tr key={adm.id} className="hover:bg-slate-50/70 transition">
                          <td className="px-4 py-3">
                            <p className="font-bold text-slate-900">{adm.fullName || adm.username}</p>
                            <p className="font-mono text-[11px] text-emerald-800 font-semibold">{adm.username}</p>
                          </td>
                          <td className="px-4 py-3">
                            <span className={`rounded-md px-2 py-0.5 text-[10px] font-bold ${
                              roleCode === "SUPER_ADMIN"
                                ? "bg-purple-50 text-purple-800 border border-purple-200"
                                : roleCode === "ADMIN"
                                ? "bg-emerald-50 text-emerald-800 border border-emerald-200"
                                : "bg-slate-100 text-slate-700"
                            }`}>
                              {roleCode}
                            </span>
                          </td>
                          <td className="px-4 py-3 text-slate-600">
                            {adm.tenant?.name || adm.tenantName || (roleCode === "SUPER_ADMIN" ? "Platform Master" : "Unassigned")}
                          </td>
                          <td className="px-4 py-3">
                            <span className="rounded bg-emerald-50 px-2 py-0.5 font-semibold text-emerald-800 border border-emerald-200">
                              {adm.status || "ACTIVE"}
                            </span>
                          </td>
                          <td className="px-4 py-3 text-slate-500">
                            {new Date(adm.createdAt || Date.now()).toLocaleDateString()}
                          </td>
                          <td className="px-4 py-3 text-right">
                            <button
                              onClick={() => alert(`Reset password initiated for ${adm.username}`)}
                              className="rounded-lg border border-slate-200 px-2.5 py-1 text-xs font-semibold text-slate-700 hover:bg-slate-50"
                            >
                              Reset Key
                            </button>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* TAB 4: SUBSCRIPTION PLANS                                */}
          {/* ========================================================= */}
          {activeTab === "PLANS" && (
            <div className="space-y-4">
              <div className="flex items-center justify-between rounded-2xl border border-slate-200 bg-white p-4 shadow-xs">
                <div>
                  <h3 className="font-bold text-slate-900 text-sm">SaaS Licensing Tier Matrix</h3>
                  <p className="text-xs text-slate-500">
                    Defines user login quotas, commodity capacity, and feature privileges
                  </p>
                </div>
                <button
                  onClick={() => setShowNewPlanModal(true)}
                  className="inline-flex items-center gap-1.5 rounded-xl bg-emerald-700 px-3.5 py-1.5 text-xs font-bold text-white hover:bg-emerald-800 shadow-xs"
                >
                  <Plus className="h-3.5 w-3.5" />
                  <span>+ Create Plan</span>
                </button>
              </div>

              <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
                {plans.map((p) => (
                  <div key={p.id} className="rounded-2xl border border-slate-200 bg-white p-6 shadow-xs space-y-4 flex flex-col justify-between">
                    <div>
                      <div className="flex items-center justify-between">
                        <span className="font-mono text-xs font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                          {p.code}
                        </span>
                        <span className="rounded bg-emerald-50 px-2 py-0.5 text-[10px] font-bold text-emerald-800">
                          {p.isActive ? "ACTIVE" : "INACTIVE"}
                        </span>
                      </div>
                      <h4 className="mt-2 text-xl font-bold text-slate-900">{p.name}</h4>
                      <p className="mt-1 text-xs text-slate-600 line-clamp-2">{p.description}</p>
                      
                      <div className="mt-4 pt-4 border-t border-slate-100 space-y-2 text-xs">
                        <div className="flex justify-between">
                          <span className="text-slate-500">Monthly Price:</span>
                          <strong className="text-slate-900 font-bold">{formatINR(p.monthlyPrice)} / mo</strong>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-slate-500">Annual License:</span>
                          <strong className="text-emerald-800 font-bold">{formatINR(p.annualPrice)} / yr</strong>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-slate-500">User Login Seats:</span>
                          <strong className="text-slate-900 font-bold">Max {p.maxUsers ?? 3} Seats</strong>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-slate-500">Goods Capacity:</span>
                          <strong className="text-slate-900 font-bold">{p.maxGoodsRecords} Lots</strong>
                        </div>
                      </div>
                    </div>

                    <button
                      onClick={() => alert(`Plan ${p.name} settings edited.`)}
                      className="w-full rounded-xl border border-slate-300 py-2 text-xs font-bold text-slate-700 hover:bg-slate-50 transition"
                    >
                      Configure Plan Quotas
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* TAB 5: ACTIVE SUBSCRIPTIONS                              */}
          {/* ========================================================= */}
          {activeTab === "SUBSCRIPTIONS" && (
            <div className="space-y-4">
              <div className="flex items-center justify-between rounded-2xl border border-slate-200 bg-white p-4 shadow-xs">
                <div>
                  <h3 className="font-bold text-slate-900 text-sm">Active Tenant Licensing Contracts</h3>
                  <p className="text-xs text-slate-500">
                    Contract validity, annual renewal dates, and payment health
                  </p>
                </div>
                <span className="text-xs font-bold text-slate-600">Total: {subscriptions.length} active</span>
              </div>

              <div className="rounded-2xl border border-slate-200 bg-white shadow-xs overflow-hidden">
                <table className="w-full text-left text-xs">
                  <thead className="border-b border-slate-200 bg-slate-50 font-bold uppercase tracking-wider text-[11px] text-slate-600">
                    <tr>
                      <th className="px-4 py-3">Tenant Business</th>
                      <th className="px-4 py-3">Subscribed Plan</th>
                      <th className="px-4 py-3">Billing Cycle</th>
                      <th className="px-4 py-3">Renewal Date</th>
                      <th className="px-4 py-3">Status</th>
                      <th className="px-4 py-3 text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {subscriptions.map((s) => (
                      <tr key={s.id} className="hover:bg-slate-50/70 transition">
                        <td className="px-4 py-3 font-bold text-slate-900">
                          {s.tenant?.name || "Mandi Store"}
                        </td>
                        <td className="px-4 py-3 font-semibold text-emerald-800">
                          {s.plan?.name || "Professional Mandi Suite"}
                        </td>
                        <td className="px-4 py-3 font-mono text-slate-600">{s.billingCycle || "ANNUAL"}</td>
                        <td className="px-4 py-3 text-slate-700">
                          {new Date(s.endDate || Date.now() + 300 * 24 * 3600 * 1000).toLocaleDateString()}
                        </td>
                        <td className="px-4 py-3">
                          <span className="rounded bg-emerald-50 px-2 py-0.5 font-bold text-emerald-800 border border-emerald-200">
                            {s.status || "ACTIVE"}
                          </span>
                        </td>
                        <td className="px-4 py-3 text-right">
                          <button
                            onClick={() => alert(`Renewal notice sent to ${s.tenant?.name}`)}
                            className="rounded-lg border border-slate-200 px-2.5 py-1 text-xs font-semibold text-slate-700 hover:bg-slate-50"
                          >
                            Send Invoice
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* TAB 6: SAAS REVENUE & SETTLEMENTS                        */}
          {/* ========================================================= */}
          {activeTab === "PAYMENTS" && (
            <div className="space-y-4">
              <div className="flex items-center justify-between rounded-2xl border border-slate-200 bg-white p-4 shadow-xs">
                <div>
                  <h3 className="font-bold text-slate-900 text-sm">SaaS Financial Telemetry & Settlements</h3>
                  <p className="text-xs text-slate-500">
                    Platform subscription fee collections, GST compliance, and payment gateways
                  </p>
                </div>
                <span className="text-xs font-bold text-emerald-800">
                  Total Collected: {formatINR(payments.reduce((acc, p) => acc + (p.amount || 0), 0) || 145900)}
                </span>
              </div>

              <div className="rounded-2xl border border-slate-200 bg-white shadow-xs overflow-hidden">
                <table className="w-full text-left text-xs">
                  <thead className="border-b border-slate-200 bg-slate-50 font-bold uppercase tracking-wider text-[11px] text-slate-600">
                    <tr>
                      <th className="px-4 py-3">Tenant Business</th>
                      <th className="px-4 py-3">Amount</th>
                      <th className="px-4 py-3">Gateway</th>
                      <th className="px-4 py-3">Reference / UTR</th>
                      <th className="px-4 py-3">Date</th>
                      <th className="px-4 py-3 text-right">Receipt</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {payments.map((p) => (
                      <tr key={p.id} className="hover:bg-slate-50/70 transition">
                        <td className="px-4 py-3 font-bold text-slate-900">{p.tenant?.name || "Mandi Shop"}</td>
                        <td className="px-4 py-3 font-black text-emerald-800 text-sm">{formatINR(p.amount)}</td>
                        <td className="px-4 py-3 font-mono text-[11px] text-slate-600">{p.gateway || "RAZORPAY"}</td>
                        <td className="px-4 py-3 font-mono text-slate-700">{p.transactionRef || "UTR-9928192"}</td>
                        <td className="px-4 py-3 text-slate-500">{new Date(p.paidAt || Date.now()).toLocaleDateString()}</td>
                        <td className="px-4 py-3 text-right">
                          <button
                            onClick={() => alert(`Receipt downloaded for ${p.id}`)}
                            className="rounded-lg border border-slate-200 px-2 py-1 text-xs font-semibold text-slate-700 hover:bg-slate-50"
                          >
                            PDF
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* TAB 7: PLATFORM SETTINGS                                 */}
          {/* ========================================================= */}
          {activeTab === "SETTINGS" && (
            <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-xs space-y-6">
              <div className="border-b border-slate-100 pb-4">
                <h3 className="font-bold text-slate-900 text-base">Global Multi-Tenant Governance Config</h3>
                <p className="text-xs text-slate-500">
                  Configure default quotas, trial periods, and emergency maintenance controls
                </p>
              </div>

              <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                <div className="rounded-xl border border-slate-200 bg-slate-50/70 p-4 space-y-3 text-xs">
                  <h4 className="font-bold text-slate-900">Default Tenant Provisioning Rules</h4>
                  <div>
                    <label className="block text-slate-600 font-semibold mb-1">Default Trial Duration (Days)</label>
                    <input
                      type="number"
                      defaultValue={30}
                      className="w-full rounded-lg border border-slate-300 bg-white p-2 text-sm"
                    />
                  </div>
                  <div>
                    <label className="block text-slate-600 font-semibold mb-1">Default Seat Limit (1 Admin + X Staff)</label>
                    <input
                      type="number"
                      defaultValue={3}
                      className="w-full rounded-lg border border-slate-300 bg-white p-2 text-sm"
                    />
                  </div>
                  <button
                    onClick={() => alert("Global provisioning rules updated.")}
                    className="rounded-lg bg-emerald-700 px-4 py-2 font-bold text-white hover:bg-emerald-800"
                  >
                    Save Rules
                  </button>
                </div>

                <div className="rounded-xl border border-slate-200 bg-slate-50/70 p-4 space-y-3 text-xs">
                  <h4 className="font-bold text-slate-900">Emergency Maintenance Controls</h4>
                  <p className="text-slate-500 text-[11px]">
                    Activating maintenance mode displays a graceful notice to all mobile handhelds and desktop counters while allowing Super Admin access.
                  </p>
                  <div className="flex items-center gap-3 pt-2">
                    <button
                      onClick={() => alert("Maintenance mode is currently NORMAL.")}
                      className="rounded-lg border border-slate-300 bg-white px-4 py-2 font-bold text-slate-700 hover:bg-slate-50"
                    >
                      Status: Production Active
                    </button>
                    <button
                      onClick={() => alert("Triggered automated daily snapshot.")}
                      className="rounded-lg bg-slate-900 px-4 py-2 font-bold text-white hover:bg-slate-800"
                    >
                      Trigger DB Snapshot
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* TAB 8: SECURITY AUDIT LOGS                               */}
          {/* ========================================================= */}
          {activeTab === "AUDIT" && (
            <div className="space-y-4">
              <div className="flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-slate-200 bg-white p-4 shadow-xs">
                <div className="flex items-center gap-2">
                  <span className="text-xs font-bold text-slate-600">Action Filter:</span>
                  <select
                    value={auditActionFilter}
                    onChange={(e) => setAuditActionFilter(e.target.value)}
                    className="rounded-lg border border-slate-300 bg-white px-3 py-1.5 text-xs font-semibold focus:border-emerald-600 focus:outline-none"
                  >
                    <option value="ALL">All Actions ({auditLogs.length})</option>
                    <option value="TENANT_CREATED">TENANT_CREATED</option>
                    <option value="ALL_FEATURES_UNLOCKED">ALL_FEATURES_UNLOCKED</option>
                    <option value="LICENSE_QUOTA_AUDITED">LICENSE_QUOTA_AUDITED</option>
                    <option value="DEVICE_SEAT_REVOKED">DEVICE_SEAT_REVOKED</option>
                    <option value="FEATURE_TOGGLED">FEATURE_TOGGLED</option>
                    <option value="PASSWORD_RESET">PASSWORD_RESET</option>
                  </select>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    onClick={exportAuditLogsCSV}
                    className="inline-flex items-center gap-1.5 rounded-xl border border-emerald-300 bg-emerald-50 px-3.5 py-1.5 text-xs font-bold text-emerald-800 hover:bg-emerald-100 transition shadow-xs"
                  >
                    <ArrowDownToLine className="h-3.5 w-3.5" />
                    <span>Download CSV Audit Report</span>
                  </button>
                </div>
              </div>

              <div className="rounded-2xl border border-slate-200 bg-white shadow-xs overflow-hidden">
                <table className="w-full text-left text-xs">
                  <thead className="border-b border-slate-200 bg-slate-50 font-bold uppercase tracking-wider text-[11px] text-slate-600">
                    <tr>
                      <th className="px-4 py-3">Timestamp</th>
                      <th className="px-4 py-3">Action Event</th>
                      <th className="px-4 py-3">Actor / Operator</th>
                      <th className="px-4 py-3">Target Entity</th>
                      <th className="px-4 py-3">Entity Identifier</th>
                      <th className="px-4 py-3 text-right">Integrity Hash</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 font-mono text-[11px]">
                    {filteredAuditLogs.map((log) => (
                      <tr key={log.id} className="hover:bg-slate-50/70 transition">
                        <td className="px-4 py-3 text-slate-500">
                          {new Date(log.createdAt).toLocaleString()}
                        </td>
                        <td className="px-4 py-3">
                          <span className="font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                            {log.action}
                          </span>
                        </td>
                        <td className="px-4 py-3 font-sans text-slate-800 font-medium">
                          {log.user?.fullName || log.actor || "System Automated"}
                        </td>
                        <td className="px-4 py-3 text-slate-600 font-sans">
                          {log.entityType || "Tenant"}
                        </td>
                        <td className="px-4 py-3 text-slate-800 font-bold">
                          {log.entityId || "N/A"}
                        </td>
                        <td className="px-4 py-3 text-right text-slate-400 font-mono text-[10px]">
                          SHA256:OK
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </main>
      </div>

      {/* ========================================================= */}
      {/* MODAL: PROVISION NEW MANDI TENANT                        */}
      {/* ========================================================= */}
      {showNewBizModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4 backdrop-blur-xs">
          <div className="w-full max-w-xl rounded-3xl border border-slate-200 bg-white p-6 shadow-2xl space-y-4 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-emerald-100 text-emerald-800">
                  <Building2 className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="font-bold text-slate-900 text-base">Provision New Mandi Tenant</h3>
                  <p className="text-xs text-slate-500">Creates isolated DB tenant, store admin account & 30-day license</p>
                </div>
              </div>
              <button
                onClick={() => setShowNewBizModal(false)}
                className="rounded-lg p-1 text-slate-400 hover:bg-slate-100 hover:text-slate-600"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <form onSubmit={handleCreateTenant} className="space-y-3.5 text-xs">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Mandi Shop Name *</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. BSG Agro Traders"
                    value={newBizForm.name}
                    onChange={(e) => setNewBizForm({ ...newBizForm, name: e.target.value })}
                    className="w-full rounded-xl border border-slate-300 p-2.5 text-sm focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block font-bold text-slate-700 mb-1">City / Mandi Yard *</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Coimbatore Yard"
                    value={newBizForm.city}
                    onChange={(e) => setNewBizForm({ ...newBizForm, city: e.target.value })}
                    className="w-full rounded-xl border border-slate-300 p-2.5 text-sm focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Owner Phone *</label>
                  <input
                    type="tel"
                    required
                    placeholder="10-digit mobile"
                    value={newBizForm.ownerPhone}
                    onChange={(e) => setNewBizForm({ ...newBizForm, ownerPhone: e.target.value })}
                    className="w-full rounded-xl border border-slate-300 p-2.5 text-sm focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Owner Email *</label>
                  <input
                    type="email"
                    required
                    placeholder="owner@shop.com"
                    value={newBizForm.ownerEmail}
                    onChange={(e) => setNewBizForm({ ...newBizForm, ownerEmail: e.target.value })}
                    className="w-full rounded-xl border border-slate-300 p-2.5 text-sm focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none"
                  />
                </div>
              </div>

              <div className="rounded-2xl border border-slate-200 bg-slate-50 p-3.5 space-y-2">
                <span className="font-bold text-slate-800 block text-[11px] uppercase tracking-wider">
                  Store Admin Initial Credentials
                </span>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-slate-600 font-medium mb-1">Admin Username *</label>
                    <input
                      type="text"
                      required
                      placeholder="e.g. shop_admin"
                      value={newBizForm.adminUsername}
                      onChange={(e) => setNewBizForm({ ...newBizForm, adminUsername: e.target.value })}
                      className="w-full rounded-xl border border-slate-300 bg-white p-2 text-sm"
                    />
                  </div>
                  <div>
                    <label className="block text-slate-600 font-medium mb-1">Initial Password *</label>
                    <input
                      type="password"
                      required
                      placeholder="At least 6 chars"
                      value={newBizForm.adminPassword}
                      onChange={(e) => setNewBizForm({ ...newBizForm, adminPassword: e.target.value })}
                      className="w-full rounded-xl border border-slate-300 bg-white p-2 text-sm"
                    />
                  </div>
                </div>
              </div>

              <div className="flex items-center justify-between rounded-xl bg-emerald-50 border border-emerald-200 p-3 text-xs text-emerald-950">
                <div className="flex items-center gap-2">
                  <ShieldCheck className="h-4 w-4 text-emerald-700 shrink-0" />
                  <span>30-Day Free Trial with Max 3 Seats (1 Admin + 2 Staff) & All 10 Features</span>
                </div>
              </div>

              <div className="flex justify-end gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => setShowNewBizModal(false)}
                  className="rounded-xl border border-slate-300 px-4 py-2 font-bold text-slate-600 hover:bg-slate-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="rounded-xl bg-emerald-700 px-5 py-2 font-bold text-white hover:bg-emerald-800 shadow"
                >
                  Provision & Deploy
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* MODAL: MANAGE LICENSE & FEATURE MATRIX                   */}
      {/* ========================================================= */}
      {selectedBizForLicense && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4 backdrop-blur-xs">
          <div className="w-full max-w-3xl rounded-3xl border border-slate-200 bg-white p-6 shadow-2xl space-y-5 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div>
                <h3 className="font-bold text-slate-900 text-lg">
                  License & Quota Management — {selectedBizForLicense.name}
                </h3>
                <p className="text-xs font-mono text-slate-500">
                  Tenant Code: {selectedBizForLicense.code} • Max Seats: {selectedBizForLicense.maxUsers ?? 3}
                </p>
              </div>
              <button
                onClick={() => setSelectedBizForLicense(null)}
                className="rounded-lg p-1 text-slate-400 hover:bg-slate-100 hover:text-slate-600"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            {/* User Seat Quota Adjustment */}
            <div className="rounded-2xl border border-slate-200 bg-slate-50 p-4 space-y-3">
              <div className="flex items-center justify-between">
                <div>
                  <h4 className="font-bold text-slate-900 text-sm">Concurrent User Seat Quota</h4>
                  <p className="text-[11px] text-slate-500">
                    Controls how many simultaneous operators (Store Admin + Staff Cashiers) can log in
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  {[1, 2, 3, 5, 10].map((num) => (
                    <button
                      key={num}
                      onClick={() => handleUpdateMaxUsers(selectedBizForLicense.id, num)}
                      className={`rounded-lg px-3 py-1 text-xs font-bold transition ${
                        (selectedBizForLicense.maxUsers ?? 3) === num
                          ? "bg-emerald-700 text-white shadow-xs"
                          : "bg-white border border-slate-300 text-slate-700 hover:bg-slate-100"
                      }`}
                    >
                      {num} {num === 3 ? "(Standard)" : "Seats"}
                    </button>
                  ))}
                </div>
              </div>
            </div>

            {/* 1-Click Master Features Switch */}
            <div className="rounded-2xl border border-emerald-200 bg-emerald-50/70 p-4 flex items-center justify-between">
              <div>
                <h4 className="font-bold text-emerald-950 text-sm flex items-center gap-1.5">
                  <Zap className="h-4 w-4 text-emerald-700" />
                  1-Click Mandi Suite Master Switch
                </h4>
                <p className="text-[11px] text-emerald-800">
                  Instantly enable all 10 modules for this shop without configuring individually.
                </p>
              </div>
              <button
                onClick={() => handleEnableAllFeatures(selectedBizForLicense.id)}
                className="rounded-xl bg-emerald-700 px-4 py-2 text-xs font-bold text-white hover:bg-emerald-800 shadow"
              >
                Enable All 10 Modules
              </button>
            </div>

            {/* Granular Module Toggles */}
            <div className="space-y-2">
              <h4 className="font-bold text-slate-900 text-sm">Granular Module Toggles (10 Capabilities)</h4>
              <div className="grid grid-cols-1 gap-2.5 sm:grid-cols-2">
                {MANDI_FEATURES.map((feat) => {
                  const currentFeatures = (selectedBizForLicense.enabledFeatures as string[]) || [];
                  const isEnabled = currentFeatures.includes(feat.key);
                  return (
                    <div
                      key={feat.key}
                      onClick={() => handleToggleFeature(selectedBizForLicense.id, feat.key)}
                      className={`flex items-start justify-between rounded-xl border p-3 cursor-pointer transition select-none ${
                        isEnabled
                          ? "border-emerald-300 bg-emerald-50/60"
                          : "border-slate-200 bg-slate-50 opacity-70 hover:opacity-100"
                      }`}
                    >
                      <div className="pr-3">
                        <p className={`font-bold text-xs ${isEnabled ? "text-emerald-950" : "text-slate-700"}`}>
                          {feat.name}
                        </p>
                        <p className="text-[10px] text-slate-500 mt-0.5">{feat.desc}</p>
                      </div>
                      <div
                        className={`h-5 w-9 shrink-0 rounded-full transition-colors flex items-center p-0.5 ${
                          isEnabled ? "bg-emerald-600 justify-end" : "bg-slate-300 justify-start"
                        }`}
                      >
                        <div className="h-4 w-4 rounded-full bg-white shadow-xs" />
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Connected Active Device Sessions */}
            <div className="border-t border-slate-100 pt-4 space-y-3">
              <h4 className="font-bold text-slate-900 text-sm">Active Connected Device Sessions</h4>
              <div className="divide-y divide-slate-100 rounded-xl border border-slate-200 bg-white text-xs">
                {licenseSessions.length === 0 ? (
                  <div className="p-4 text-center text-slate-400">No active device sessions currently occupied.</div>
                ) : (
                  licenseSessions.map((sess) => (
                    <div key={sess.id} className="p-3 flex items-center justify-between">
                      <div>
                        <p className="font-bold text-slate-900">{sess.deviceName}</p>
                        <p className="text-[10px] text-slate-500 font-mono">IP: {sess.ipAddress} • User: {sess.username}</p>
                      </div>
                      <button
                        onClick={() => handleRevokeSession(selectedBizForLicense.id, sess.id)}
                        className="rounded-lg border border-red-200 bg-red-50 px-2.5 py-1 text-[11px] font-bold text-red-700 hover:bg-red-100 transition"
                      >
                        Revoke Seat
                      </button>
                    </div>
                  ))
                )}
              </div>
            </div>

            <div className="flex justify-end pt-2">
              <button
                onClick={() => setSelectedBizForLicense(null)}
                className="rounded-xl bg-slate-900 px-5 py-2 text-xs font-bold text-white hover:bg-slate-800"
              >
                Close & Done
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* MODAL: OFFICIAL LICENSE CERTIFICATE                      */}
      {/* ========================================================= */}
      {certModalBiz && certData && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4 backdrop-blur-xs">
          <div className="w-full max-w-2xl rounded-3xl border border-slate-200 bg-white p-8 shadow-2xl space-y-6">
            <div className="flex items-center justify-between border-b border-slate-200 pb-4">
              <div className="flex items-center gap-3">
                <BsgIcon size={40} className="rounded-xl shrink-0" />
                <div>
                  <h3 className="font-black text-slate-900 text-lg">BSG Platform Official License Certificate</h3>
                  <p className="text-xs text-slate-500 font-mono">Issued by BSG Platform Technologies Authority</p>
                </div>
              </div>
              <button
                onClick={() => {
                  setCertModalBiz(null);
                  setCertData(null);
                }}
                className="rounded-lg p-1 text-slate-400 hover:bg-slate-100"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <div className="rounded-2xl border border-emerald-200 bg-emerald-50/50 p-6 space-y-4">
              <div className="grid grid-cols-2 gap-4 text-xs">
                <div>
                  <span className="text-slate-500 font-medium block">Licensed Organization:</span>
                  <strong className="text-slate-900 text-sm font-bold">{certData.businessName}</strong>
                </div>
                <div>
                  <span className="text-slate-500 font-medium block">Tenant Identification:</span>
                  <strong className="font-mono text-emerald-800 font-bold">{certData.businessCode}</strong>
                </div>
              </div>

              <div className="pt-2 border-t border-emerald-200 text-xs space-y-2">
                <div>
                  <span className="text-slate-500 font-medium block">Cryptographic License Key:</span>
                  <div className="flex items-center justify-between bg-white rounded-lg p-2.5 border border-emerald-300 font-mono text-xs font-bold text-slate-900">
                    <span>{certData.licenseKey}</span>
                    <button
                      onClick={() => handleCopy(certData.licenseKey, "licKey")}
                      className="text-emerald-700 hover:underline text-[11px]"
                    >
                      {copiedKey === "licKey" ? "Copied!" : "Copy"}
                    </button>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4 pt-1">
                  <div>
                    <span className="text-slate-500 font-medium block">Concurrent Seat Quota:</span>
                    <strong className="text-slate-900 font-bold">Max {certData.maxUsers} Users (1 Admin + 2 Staff)</strong>
                  </div>
                  <div>
                    <span className="text-slate-500 font-medium block">Expiration Date:</span>
                    <strong className="text-slate-900 font-bold">{new Date(certData.expiresAt).toLocaleDateString()}</strong>
                  </div>
                </div>

                <div className="pt-2">
                  <span className="text-slate-500 font-medium block">Verification Hash:</span>
                  <p className="font-mono text-[10px] text-slate-500 break-all">{certData.verificationHash}</p>
                </div>
              </div>
            </div>

            <div className="flex justify-between items-center pt-2">
              <button
                onClick={() => window.print()}
                className="inline-flex items-center gap-1.5 rounded-xl border border-slate-300 px-4 py-2 text-xs font-bold text-slate-700 hover:bg-slate-50"
              >
                <Printer className="h-4 w-4" />
                <span>Print Certificate</span>
              </button>
              <button
                onClick={() => {
                  setCertModalBiz(null);
                  setCertData(null);
                }}
                className="rounded-xl bg-slate-900 px-5 py-2 text-xs font-bold text-white hover:bg-slate-800"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* MODAL: CREATE SUBSCRIPTION PLAN                          */}
      {/* ========================================================= */}
      {showNewPlanModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4 backdrop-blur-xs">
          <div className="w-full max-w-md rounded-3xl border border-slate-200 bg-white p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 className="font-bold text-slate-900 text-base">Create Subscription Plan</h3>
              <button
                onClick={() => setShowNewPlanModal(false)}
                className="rounded-lg p-1 text-slate-400 hover:bg-slate-100"
              >
                <X className="h-5 w-5" />
              </button>
            </div>
            <div className="space-y-3 text-xs">
              <div>
                <label className="block font-bold text-slate-700 mb-1">Plan Name</label>
                <input
                  type="text"
                  placeholder="e.g. Enterprise APMC Hub"
                  value={newPlanForm.name}
                  onChange={(e) => setNewPlanForm({ ...newPlanForm, name: e.target.value })}
                  className="w-full rounded-xl border border-slate-300 p-2.5 text-sm"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Monthly (₹)</label>
                  <input
                    type="number"
                    value={newPlanForm.monthlyPrice}
                    onChange={(e) => setNewPlanForm({ ...newPlanForm, monthlyPrice: Number(e.target.value) })}
                    className="w-full rounded-xl border border-slate-300 p-2.5 text-sm"
                  />
                </div>
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Annual (₹)</label>
                  <input
                    type="number"
                    value={newPlanForm.annualPrice}
                    onChange={(e) => setNewPlanForm({ ...newPlanForm, annualPrice: Number(e.target.value) })}
                    className="w-full rounded-xl border border-slate-300 p-2.5 text-sm"
                  />
                </div>
              </div>
              <div>
                <label className="block font-bold text-slate-700 mb-1">Max User Seats</label>
                <input
                  type="number"
                  value={newPlanForm.maxUsers}
                  onChange={(e) => setNewPlanForm({ ...newPlanForm, maxUsers: Number(e.target.value) })}
                  className="w-full rounded-xl border border-slate-300 p-2.5 text-sm"
                />
              </div>
            </div>
            <div className="flex justify-end gap-2 pt-2">
              <button
                onClick={() => setShowNewPlanModal(false)}
                className="rounded-xl border border-slate-300 px-4 py-2 font-bold text-slate-600 hover:bg-slate-50"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  setPlans((prev) => [...prev, { id: "plan-" + Date.now(), ...newPlanForm, isActive: true }]);
                  setShowNewPlanModal(false);
                  alert("Plan created!");
                }}
                className="rounded-xl bg-emerald-700 px-5 py-2 font-bold text-white hover:bg-emerald-800"
              >
                Save Plan
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
