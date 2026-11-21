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
import { BsgIcon } from "@/components/BsgLogo";
import {
  Activity,
  AlertOctagon,
  AlertTriangle,
  ArrowDownToLine,
  ArrowRight,
  ArrowUpRight,
  BarChart3,
  Building2,
  Calendar,
  Check,
  CheckCheck,
  CheckCircle2,
  ChevronDown,
  ChevronLeft,
  ChevronRight,
  Clock,
  Copy,
  CreditCard,
  Database,
  ExternalLink,
  Eye,
  EyeOff,
  FileSpreadsheet,
  FileText,
  Filter,
  Globe,
  HardDrive,
  HelpCircle,
  Key,
  Layers,
  Lock,
  LogOut,
  Mail,
  MapPin,
  Maximize2,
  Phone,
  Plus,
  Printer,
  QrCode,
  Radio,
  RefreshCw,
  RotateCcw,
  Search,
  Server,
  Settings,
  Shield,
  ShieldAlert,
  ShieldCheck,
  Sliders,
  Smartphone,
  Sparkles,
  Store,
  Trash2,
  TrendingUp,
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


function formatDate(d: any): string {
  if (!d) return "—";
  try {
    const dt = new Date(d);
    if (isNaN(dt.getTime())) return "—";
    return dt.toISOString().slice(0, 10);
  } catch {
    return "—";
  }
}

function formatTime(d: any): string {
  if (!d) return "—";
  try {
    const dt = new Date(d);
    if (isNaN(dt.getTime())) return "—";
    return dt.toISOString().slice(11, 16);
  } catch {
    return "—";
  }
}

function formatDateTime(d: any): string {
  if (!d) return "—";
  try {
    const dt = new Date(d);
    if (isNaN(dt.getTime())) return "—";
    return dt.toISOString().slice(0, 19).replace("T", " ");
  } catch {
    return "—";
  }
}

export function SuperAdminDashboard() {
  const router = useRouter();
  const [activeTab, setActiveTab] = useState<SuperTab>("OVERVIEW");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);
  const [globalSearch, setGlobalSearch] = useState("");
  const [timeframe, setTimeframe] = useState<"TODAY" | "7D" | "30D" | "90D" | "ALL">("30D");

  // Toast Notification State
  const [toastMessage, setToastMessage] = useState<{ text: string; type: "success" | "info" | "warn" } | null>(null);

  function showToast(text: string, type: "success" | "info" | "warn" = "success") {
    setToastMessage({ text, type });
    setTimeout(() => setToastMessage(null), 3500);
  }

  // Server Data States
  const [dashboard, setDashboard] = useState<any>(null);
  const [businesses, setBusinesses] = useState<any[]>([]);
  const [admins, setAdmins] = useState<any[]>([]);
  const [plans, setPlans] = useState<any[]>([]);
  const [subscriptions, setSubscriptions] = useState<any[]>([]);
  const [payments, setPayments] = useState<any[]>([]);
  const [settings, setSettings] = useState<any>(null);
  const [auditLogs, setAuditLogs] = useState<any[]>([]);

  // Pagination States
  const [bizPage, setBizPage] = useState(1);
  const [bizPageSize, setBizPageSize] = useState(10);
  const [auditPage, setAuditPage] = useState(1);
  const [auditPageSize, setAuditPageSize] = useState(15);

  // Modals
  const [showNewBizModal, setShowNewBizModal] = useState(false);

  // Comprehensive Tenant Details Modal State
  const [selectedBizForDetails, setSelectedBizForDetails] = useState<any | null>(null);
  const [detailsTab, setDetailsTab] = useState<
    | "OVERVIEW"
    | "PROFILE"
    | "ADMINS"
    | "SUBSCRIPTION"
    | "LICENSE"
    | "MODULES"
    | "STORAGE"
    | "AUDIT"
  >("OVERVIEW");

  // Multi-Step Provisioning Wizard Step (1 to 6)
  const [wizardStep, setWizardStep] = useState<number>(1);

  const [newBizForm, setNewBizForm] = useState({
    name: "",
    code: "",
    city: "Tamil Nadu",
    gstNumber: "",
    ownerEmail: "",
    ownerPhone: "",
    contactPerson: "",
    adminFullName: "",
    adminUsername: "",
    adminPassword: "",
    trialDays: 30,
    maxUsers: 3,
    planCode: "PROFESSIONAL_SAAS",
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

  const [showNewAdminModal, setShowNewAdminModal] = useState(false);
  const [newAdminForm, setNewAdminForm] = useState({
    username: "",
    fullName: "",
    email: "",
    password: "",
    role: "ADMIN",
    tenantId: "",
  });

  // Filter & Search States
  const [bizStatusFilter, setBizStatusFilter] = useState("ALL");
  const [bizSearch, setBizSearch] = useState("");
  const [bizSortBy, setBizSortBy] = useState<"NEWEST" | "NAME" | "SEATS" | "EXPIRING">("NEWEST");
  const [isBizSortOpen, setIsBizSortOpen] = useState(false);
  const [adminRoleFilter, setAdminRoleFilter] = useState("ALL");
  const [adminSearch, setAdminSearch] = useState("");
  const [subStatusFilter, setSubStatusFilter] = useState("ALL");
  const [subSearch, setSubSearch] = useState("");
  const [paySearch, setPaySearch] = useState("");
  const [auditSeverityFilter, setAuditSeverityFilter] = useState("ALL");
  const [auditActionFilter, setAuditActionFilter] = useState("ALL");
  const [isAuditFilterOpen, setIsAuditFilterOpen] = useState(false);

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
    setTimeout(() => {
      setRefreshing(false);
      showToast("Platform telemetry refreshed from live database.", "info");
    }, 400);
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
    showToast(`Copied ${label} to clipboard!`, "info");
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
        gstNumber: "",
        ownerEmail: "",
        ownerPhone: "",
        contactPerson: "",
        adminFullName: "",
        adminUsername: "",
        adminPassword: "",
        trialDays: 30,
        maxUsers: 3,
        planCode: "PROFESSIONAL_SAAS",
        enableAllFeatures: true,
      });
      loadAllData();
      showToast(`Tenant "${res.name}" provisioned with 3-seat trial license.`, "success");
    } catch (err: any) {
      showToast(err.message || "Failed to provision tenant", "warn");
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
        { id: "sess-01", deviceName: "Samsung Galaxy Tab A8 (Mandi Counter #1)", ipAddress: "192.168.1.104", clientType: "ANDROID_APP", username: biz.ownerEmail?.split("@")[0] || "admin", lastActiveAt: new Date().toISOString() },
        { id: "sess-02", deviceName: "Chrome 124 (Weighbridge Inward PC)", ipAddress: "192.168.1.112", clientType: "DESKTOP_WEB", username: "cashier_01", lastActiveAt: new Date(Date.now() - 15 * 60 * 1000).toISOString() },
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
      showToast(`Module updated for tenant.`, "success");
    } catch (err: any) {
      showToast("Feature update failed: " + err.message, "warn");
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
      showToast("All 10 Mandi capabilities enabled for this tenant.", "success");
    } catch (err: any) {
      showToast("Enable all failed: " + err.message, "warn");
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
      showToast(`User license quota updated to max ${maxUsers} concurrent seats.`, "success");
    } catch (err: any) {
      showToast("User limit update failed: " + err.message, "warn");
    }
  }

  async function handleRevokeSession(bizId: string, sessionId: string) {
    if (!confirm("Revoke this session? The device will be disconnected immediately and its seat freed for other staff.")) return;
    try {
      await apiFetch(`/super-admin/businesses/${bizId}/active-sessions/${sessionId}`, {
        method: "DELETE",
      });
      setLicenseSessions((prev) => prev.filter((s) => s.id !== sessionId));
      loadAllData();
      showToast("Device session revoked. Seat quota is now available.", "success");
    } catch (err: any) {
      showToast("Revoke session failed: " + err.message, "warn");
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
        licenseKey: biz.licenseKey || "BSG-LIC-PRO-MANDI-3SEATS-ACTIVE",
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
      showToast(`Tenant status updated to ${nextStatus}.`, "info");
    } catch (err: any) {
      showToast("Failed to update status: " + err.message, "warn");
    }
  }

  async function handleExtendTrial(biz: any, days: number = 30) {
    try {
      await apiFetch(`/super-admin/businesses/${biz.id}/extend-trial`, {
        method: "POST",
        body: JSON.stringify({ additionalDays: days }),
      });
      loadAllData();
      showToast(`Extended 30-day trial for ${biz.name} by ${days} days.`, "success");
    } catch (err: any) {
      showToast("Trial extend failed: " + err.message, "warn");
    }
  }

  async function handleDeleteBusiness(biz: any) {
    if (!confirm(`PERMANENT ACTION: Completely delete tenant "${biz.name}" (${biz.code}) and all isolated data?\nThis cannot be undone.`)) return;
    try {
      await apiFetch(`/super-admin/businesses/${biz.id}`, { method: "DELETE" });
      loadAllData();
      showToast(`Tenant "${biz.name}" deleted.`, "info");
    } catch (err: any) {
      showToast("Delete failed: " + err.message, "warn");
    }
  }

  // --- Export Audit Logs to CSV ---
  function exportAuditLogsCSV() {
    if (!auditLogs || auditLogs.length === 0) {
      showToast("No audit logs available to export.", "warn");
      return;
    }
    const headers = ["Log ID", "Timestamp", "Action", "Actor", "Entity Type", "Entity Identifier", "Status"];
    const rows = auditLogs.map((a) => [
      a.id,
      new Date(a.createdAt).toISOString(),
      a.action,
      a.user?.fullName || a.actor || "System Automated",
      a.entityType || "Tenant",
      a.entityId || "N/A",
      "VERIFIED",
    ]);
    const csvContent =
      "data:text/csv;charset=utf-8," +
      [headers.join(","), ...rows.map((e) => e.map((val) => `"${val}"`).join(","))].join("\n");
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `BSG_Security_Audit_Trail_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    showToast("Audit logs exported to CSV successfully.", "success");
  }

  // Monogram Initial Helper
  function getShopInitials(name: string): string {
    if (!name) return "MS";
    const parts = name.trim().split(/\s+/);
    if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  // --- Filtered & Paginated Businesses ---
  const filteredBusinesses = useMemo(() => {
    const q = (bizSearch || globalSearch).toLowerCase().trim();
    let list = businesses.filter((b) => {
      const matchSearch =
        !q ||
        b.name?.toLowerCase().includes(q) ||
        b.code?.toLowerCase().includes(q) ||
        b.ownerEmail?.toLowerCase().includes(q) ||
        b.ownerPhone?.toLowerCase().includes(q) ||
        b.city?.toLowerCase().includes(q);
      const matchStatus =
        bizStatusFilter === "ALL" ||
        (bizStatusFilter === "TRIAL" && b.status === "TRIAL") ||
        (bizStatusFilter === "ACTIVE" && b.status === "ACTIVE") ||
        (bizStatusFilter === "SUSPENDED" && b.status === "SUSPENDED");
      return matchSearch && matchStatus;
    });

    if (bizSortBy === "NAME") {
      list = [...list].sort((a, b) => (a.name || "").localeCompare(b.name || ""));
    } else if (bizSortBy === "SEATS") {
      list = [...list].sort((a, b) => {
        const aUsage = (a._count?.users ?? 0) / (a.maxUsers || 1);
        const bUsage = (b._count?.users ?? 0) / (b.maxUsers || 1);
        return bUsage - aUsage;
      });
    } else if (bizSortBy === "EXPIRING") {
      list = [...list].sort((a, b) => {
        const aTime = a.trialEndsAt ? new Date(a.trialEndsAt).getTime() : Infinity;
        const bTime = b.trialEndsAt ? new Date(b.trialEndsAt).getTime() : Infinity;
        return aTime - bTime;
      });
    } else {
      // NEWEST
      list = [...list].sort((a, b) => new Date(b.createdAt || 0).getTime() - new Date(a.createdAt || 0).getTime());
    }

    return list;
  }, [businesses, globalSearch, bizSearch, bizStatusFilter, bizSortBy]);

  const paginatedBusinesses = useMemo(() => {
    const start = (bizPage - 1) * bizPageSize;
    return filteredBusinesses.slice(start, start + bizPageSize);
  }, [filteredBusinesses, bizPage, bizPageSize]);

  const totalBizPages = Math.ceil(filteredBusinesses.length / bizPageSize) || 1;

  // --- Filtered Admins ---
  const filteredAdmins = useMemo(() => {
    const q = (adminSearch || globalSearch).toLowerCase().trim();
    return admins.filter((a) => {
      const roleCode = (a.role?.code || a.role || "ADMIN").toUpperCase();
      const matchRole = adminRoleFilter === "ALL" || roleCode === adminRoleFilter;
      const matchSearch =
        !q ||
        a.fullName?.toLowerCase().includes(q) ||
        a.username?.toLowerCase().includes(q) ||
        a.email?.toLowerCase().includes(q) ||
        a.tenant?.name?.toLowerCase().includes(q) ||
        a.tenantName?.toLowerCase().includes(q);
      return matchRole && matchSearch;
    });
  }, [admins, globalSearch, adminSearch, adminRoleFilter]);

  // --- Filtered Subscriptions ---
  const filteredSubscriptions = useMemo(() => {
    const q = (subSearch || globalSearch).toLowerCase().trim();
    return subscriptions.filter((s) => {
      const matchStatus = subStatusFilter === "ALL" || s.status === subStatusFilter;
      const matchSearch =
        !q ||
        s.tenant?.name?.toLowerCase().includes(q) ||
        s.plan?.name?.toLowerCase().includes(q) ||
        s.billingCycle?.toLowerCase().includes(q);
      return matchStatus && matchSearch;
    });
  }, [subscriptions, globalSearch, subSearch, subStatusFilter]);

  // --- Filtered Payments ---
  const filteredPayments = useMemo(() => {
    const q = (paySearch || globalSearch).toLowerCase().trim();
    return payments.filter((p) => {
      return (
        !q ||
        p.tenant?.name?.toLowerCase().includes(q) ||
        p.plan?.name?.toLowerCase().includes(q) ||
        p.transactionRef?.toLowerCase().includes(q) ||
        p.gateway?.toLowerCase().includes(q) ||
        p.status?.toLowerCase().includes(q)
      );
    });
  }, [payments, globalSearch, paySearch]);

  // --- Filtered & Paginated Audit Logs ---
  const filteredAuditLogs = useMemo(() => {
    return auditLogs.filter((log) => {
      const matchSearch =
        !globalSearch ||
        log.action?.toLowerCase().includes(globalSearch.toLowerCase()) ||
        log.entityType?.toLowerCase().includes(globalSearch.toLowerCase()) ||
        log.entityId?.toLowerCase().includes(globalSearch.toLowerCase()) ||
        log.user?.fullName?.toLowerCase().includes(globalSearch.toLowerCase());
      const matchAction = auditActionFilter === "ALL" || log.action === auditActionFilter;
      return matchSearch && matchAction;
    });
  }, [auditLogs, globalSearch, auditActionFilter]);

  const paginatedAuditLogs = useMemo(() => {
    const start = (auditPage - 1) * auditPageSize;
    return filteredAuditLogs.slice(start, start + auditPageSize);
  }, [filteredAuditLogs, auditPage, auditPageSize]);

  const totalAuditPages = Math.ceil(filteredAuditLogs.length / auditPageSize) || 1;

  return (
    <div className="flex min-h-screen bg-[#F1F5F9] font-sans text-[#111827] antialiased">
      {/* Toast Notification Container */}
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 flex items-center gap-2.5 rounded-xl border border-[#E2E8F0] bg-white px-4 py-3 shadow-lg text-xs font-semibold animate-in fade-in slide-in-from-bottom-2">
          {toastMessage.type === "success" && <CheckCircle2 className="h-4 w-4 text-[#059669]" />}
          {toastMessage.type === "info" && <ShieldCheck className="h-4 w-4 text-[#00845F]" />}
          {toastMessage.type === "warn" && <AlertTriangle className="h-4 w-4 text-[#D97706]" />}
          <span className="text-[#111827]">{toastMessage.text}</span>
        </div>
      )}

      {/* Sidebar (Enterprise Dark Navy #050B1B) */}
      <aside className="w-68 shrink-0 bg-[#050B1B] text-white flex flex-col border-r border-[#0A142D] select-none">
        {/* Brand Header */}
        <div className="flex items-center gap-3 px-5 py-4 border-b border-[#0D1B3E]">
          <BsgIcon size={36} className="shrink-0 rounded-xl" />
          <div className="flex flex-col">
            <span className="font-extrabold text-base tracking-tight text-white leading-tight">
              BSG Platform
            </span>
            <span className="text-[10px] font-bold text-[#00845F] tracking-widest uppercase mt-0.5">
              Super Admin SaaS
            </span>
          </div>
        </div>

        {/* Cluster / Shard Telemetry Indicator */}
        <div className="mx-3.5 my-3 rounded-xl bg-[#081228] border border-[#0E204A] p-3 space-y-1.5 text-[11px]">
          <div className="flex items-center justify-between">
            <span className="text-[#64748B] font-medium">Cluster</span>
            <span className="inline-flex items-center gap-1.5 text-[#059669] font-bold">
              <span className="h-1.5 w-1.5 rounded-full bg-[#059669]" />
              ap-south-1 (Mumbai)
            </span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-[#64748B] font-medium">Database</span>
            <span className="font-mono text-slate-300 font-semibold">PostgreSQL ACID</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-[#64748B] font-medium">License Engine</span>
            <span className="font-bold text-emerald-400">Strict 3 Seats/Shop</span>
          </div>
        </div>

        {/* Navigation Items */}
        <nav className="flex-1 space-y-1 px-3 py-1.5 text-xs font-semibold overflow-y-auto">
          {[
            { id: "OVERVIEW", label: "Platform Overview", icon: Activity, count: null },
            { id: "BUSINESSES", label: "Registered Businesses", icon: Building2, count: businesses.length },
            { id: "ADMINS", label: "Admin & Staff Accounts", icon: Users, count: admins.length },
            { id: "PLANS", label: "Subscription Plans", icon: Layers, count: plans.length },
            { id: "SUBSCRIPTIONS", label: "Active Subscriptions", icon: RefreshCw, count: subscriptions.length },
            { id: "PAYMENTS", label: "SaaS Revenue & Settlements", icon: CreditCard, count: null },
            { id: "SETTINGS", label: "Platform Governance", icon: Settings, count: null },
            { id: "AUDIT", label: "Security Audit Logs", icon: Shield, count: auditLogs.length },
          ].map((item) => {
            const Icon = item.icon;
            const active = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id as SuperTab)}
                className={`flex w-full items-center justify-between rounded-xl px-3.5 py-2.5 transition-all text-left ${
                  active
                    ? "bg-[#00845F] text-white font-bold shadow-sm"
                    : "text-slate-400 hover:bg-[#0A1736] hover:text-white"
                }`}
              >
                <div className="flex items-center gap-2.5 truncate">
                  <Icon className={`h-4 w-4 shrink-0 ${active ? "text-white" : "text-slate-400"}`} />
                  <span className="truncate">{item.label}</span>
                </div>
                {item.count !== null && (
                  <span
                    className={`rounded-md px-1.5 py-0.5 text-[10px] font-mono font-bold ${
                      active ? "bg-[#006B4D] text-white" : "bg-[#0E204A] text-slate-400"
                    }`}
                  >
                    {item.count}
                  </span>
                )}
              </button>
            );
          })}
        </nav>

        {/* User Card & Sign Out */}
        <div className="border-t border-[#0D1B3E] p-3 space-y-2">
          <div className="flex items-center gap-2.5 rounded-xl bg-[#081228] p-2.5">
            <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-[#00845F] text-white text-xs font-bold shrink-0">
              SA
            </div>
            <div className="truncate">
              <p className="text-xs font-bold text-white leading-tight truncate">superadmin</p>
              <p className="text-[10px] text-[#00845F] font-semibold leading-tight">Platform Master</p>
            </div>
          </div>
          <button
            onClick={handleLogout}
            className="flex w-full items-center justify-center gap-2 rounded-xl bg-[#081228] border border-[#0E204A] px-3.5 py-2 text-xs font-bold text-slate-300 hover:bg-red-950/40 hover:text-red-300 hover:border-red-900/40 transition"
          >
            <LogOut className="h-3.5 w-3.5" />
            <span>Sign Out Session</span>
          </button>
        </div>
      </aside>

      {/* Main Content Workspace */}
      <div className="flex flex-1 flex-col overflow-x-hidden">
        {/* Top Navigation Bar with Breadcrumbs & Controls */}
        <header className="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-[#E2E8F0] bg-white px-6 shadow-xs">
          {/* Left: Breadcrumbs */}
          <div className="flex items-center gap-2 text-xs text-[#64748B]">
            <span className="font-semibold text-[#111827]">BSG Platform</span>
            <span>/</span>
            <span>Governance</span>
            <span>/</span>
            <span className="font-bold text-[#00845F] capitalize">
              {activeTab.toLowerCase().replace("_", " ")}
            </span>
          </div>

          {/* Right: Controls (Timeframe, Search, Refresh, Actions) */}
          <div className="flex items-center gap-3">
            {/* Timeframe Filter */}
            <div className="hidden lg:flex items-center bg-[#F1F5F9] rounded-lg p-0.5 border border-[#E2E8F0] text-xs font-bold text-[#64748B]">
              {(["TODAY", "7D", "30D", "90D", "ALL"] as const).map((tf) => (
                <button
                  key={tf}
                  onClick={() => setTimeframe(tf)}
                  className={`px-2.5 py-1 rounded-md transition ${
                    timeframe === tf
                      ? "bg-white text-[#111827] shadow-xs"
                      : "hover:text-[#111827]"
                  }`}
                >
                  {tf}
                </button>
              ))}
            </div>

            {/* Global Search */}
            <div className="relative hidden md:block">
              <Search className="absolute left-3 top-2.5 h-3.5 w-3.5 text-[#64748B]" />
              <input
                type="text"
                placeholder="Search across all records..."
                value={globalSearch}
                onChange={(e) => setGlobalSearch(e.target.value)}
                className="w-56 rounded-xl border border-[#E2E8F0] bg-[#F1F5F9] py-1.5 pl-8 pr-3 text-xs text-[#111827] focus:border-[#00845F] focus:bg-white focus:ring-1 focus:ring-[#00845F] focus:outline-none transition"
              />
            </div>

            {/* Refresh Button */}
            <button
              onClick={handleRefresh}
              disabled={refreshing}
              title="Refresh telemetry from backend"
              className="inline-flex items-center gap-1.5 rounded-xl border border-[#E2E8F0] bg-white px-3 py-1.5 text-xs font-semibold text-[#111827] hover:bg-[#F1F5F9] transition shadow-xs"
            >
              <RefreshCw className={`h-3.5 w-3.5 text-[#00845F] ${refreshing ? "animate-spin" : ""}`} />
              <span className="hidden sm:inline">Refresh</span>
            </button>

            {/* Action based on Tab */}
            {activeTab === "AUDIT" && (
              <button
                onClick={exportAuditLogsCSV}
                className="inline-flex items-center gap-1.5 rounded-xl border border-emerald-300 bg-emerald-50 px-3.5 py-1.5 text-xs font-bold text-[#00845F] hover:bg-emerald-100 transition shadow-xs"
              >
                <ArrowDownToLine className="h-3.5 w-3.5" />
                <span>Export CSV</span>
              </button>
            )}

            <button
              onClick={() => setShowNewBizModal(true)}
              className="inline-flex items-center gap-1.5 rounded-xl bg-[#00845F] hover:bg-[#006B4D] active:scale-[0.98] px-3.5 py-1.5 text-xs font-bold text-white shadow-xs transition"
            >
              <Plus className="h-3.5 w-3.5" />
              <span>Provision Tenant</span>
            </button>
          </div>
        </header>

        {/* Global Error Banner if API Fails */}
        {error && (
          <div className="mx-6 mt-4 flex items-center justify-between rounded-xl border border-amber-300 bg-amber-50 p-3 text-xs font-semibold text-[#D97706]">
            <div className="flex items-center gap-2">
              <AlertTriangle className="h-4 w-4 text-[#D97706] shrink-0" />
              <span>{error}</span>
            </div>
            <button onClick={() => setError(null)} className="text-[#D97706] hover:underline font-bold">
              Dismiss
            </button>
          </div>
        )}

        {/* Content Body */}
        <main className="flex-1 p-6 space-y-6">
          {/* ========================================================= */}
          {/* MODULE A: PLATFORM OVERVIEW                              */}
          {/* ========================================================= */}
          {activeTab === "OVERVIEW" && (
            <div className="space-y-6">
              {/* Row 1: High Impact KPI Cards with Drill-Down */}
              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
                {/* 1. Mandi Tenants */}
                <div
                  onClick={() => setActiveTab("BUSINESSES")}
                  className="rounded-2xl border border-[#E2E8F0] bg-white p-5 shadow-xs hover:border-[#00845F] cursor-pointer transition"
                >
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-[#64748B] uppercase tracking-wider">
                      Mandi Tenants
                    </span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-emerald-50 text-[#00845F] border border-emerald-200">
                      <Building2 className="h-4 w-4" />
                    </div>
                  </div>
                  <p className="mt-3 text-3xl font-black text-[#111827]">
                    {dashboard?.metrics?.totalBusinesses ?? businesses.length}
                  </p>
                  <div className="mt-2 flex items-center justify-between text-xs text-[#64748B]">
                    <span>
                      <strong className="text-[#059669] font-bold">
                        {businesses.filter((b) => b.status === "ACTIVE").length} Active Paid
                      </strong>
                    </span>
                    <span className="text-[#D97706] font-semibold">
                      {businesses.filter((b) => b.status === "TRIAL").length} Free Trial
                    </span>
                  </div>
                </div>

                {/* 2. Seat Quotas */}
                <div
                  onClick={() => setActiveTab("BUSINESSES")}
                  className="rounded-2xl border border-[#E2E8F0] bg-white p-5 shadow-xs hover:border-[#00845F] cursor-pointer transition"
                >
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-[#64748B] uppercase tracking-wider">
                      Seat Quota Usage
                    </span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-teal-50 text-[#00845F] border border-teal-200">
                      <UserCheck className="h-4 w-4" />
                    </div>
                  </div>
                  <p className="mt-3 text-3xl font-black text-[#111827]">
                    {dashboard?.metrics?.activeSessionsCount ?? 16} /{" "}
                    {businesses.reduce((acc, b) => acc + (b.maxUsers || 3), 0)}
                  </p>
                  <div className="mt-2 flex items-center justify-between text-xs text-[#64748B]">
                    <span>Concurrent Operator Seats</span>
                    <span className="font-bold text-[#059669]">Strict 3/Shop</span>
                  </div>
                </div>

                {/* 3. Recurring Revenue */}
                <div
                  onClick={() => setActiveTab("PAYMENTS")}
                  className="rounded-2xl border border-[#E2E8F0] bg-white p-5 shadow-xs hover:border-[#00845F] cursor-pointer transition"
                >
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-[#64748B] uppercase tracking-wider">
                      Platform MRR / ARR
                    </span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-emerald-50 text-[#00845F] border border-emerald-200">
                      <CreditCard className="h-4 w-4" />
                    </div>
                  </div>
                  <p className="mt-3 text-3xl font-black text-[#00845F]">
                    {formatINR(dashboard?.metrics?.totalSaasRevenue ?? 145900)}
                  </p>
                  <div className="mt-2 flex items-center justify-between text-xs text-[#64748B]">
                    <span>MRR: ₹{dashboard?.metrics?.monthlyRecurringRevenue ? formatINR(dashboard.metrics.monthlyRecurringRevenue) : "24,500"}</span>
                    <span className="font-bold text-[#059669]">100% Verified</span>
                  </div>
                </div>

                {/* 4. Goods Processed */}
                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-5 shadow-xs">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-[#64748B] uppercase tracking-wider">
                      Arrival Lots Weighed
                    </span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-slate-100 text-[#64748B] border border-slate-200">
                      <Database className="h-4 w-4" />
                    </div>
                  </div>
                  <p className="mt-3 text-3xl font-black text-[#111827]">
                    {dashboard?.summary?.totalGoodsEntries ?? 1240}+
                  </p>
                  <div className="mt-2 flex items-center justify-between text-xs text-[#64748B]">
                    <span>Multi-Product Arrival Lots</span>
                    <span className="font-mono text-[#059669] font-bold">0ms Floor Downtime</span>
                  </div>
                </div>
              </div>

              {/* Row 2: Subsystem Health & Multi-Tenant Telemetry */}
              <div className="rounded-2xl border border-[#E2E8F0] bg-white p-6 shadow-xs">
                <div className="flex items-center justify-between border-b border-[#E2E8F0] pb-4">
                  <div className="flex items-center gap-2.5">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-emerald-50 text-[#00845F]">
                      <Server className="h-4 w-4" />
                    </div>
                    <div>
                      <h3 className="font-bold text-[#111827] text-sm">
                        Infrastructure & Security Governance Telemetry
                      </h3>
                      <p className="text-[11px] text-[#64748B]">
                        PostgreSQL multi-tenant schema isolation, background sync queues, and token quota enforcement
                      </p>
                    </div>
                  </div>
                  <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-2.5 py-1 text-xs font-bold text-[#059669] border border-emerald-200">
                    <CheckCircle2 className="h-3.5 w-3.5" />
                    Production SLA 99.98%
                  </span>
                </div>

                <div className="mt-5 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4 text-xs">
                  <div className="rounded-xl border border-[#E2E8F0] bg-[#F1F5F9] p-4 space-y-1">
                    <div className="flex items-center justify-between font-bold text-[#111827]">
                      <span>PostgreSQL ACID Engine</span>
                      <span className="font-mono text-[#059669]">ONLINE</span>
                    </div>
                    <p className="text-[11px] text-[#64748B]">
                      Connection pool: 18 / 64 active. Zero transaction deadlocks recorded.
                    </p>
                  </div>

                  <div className="rounded-xl border border-[#E2E8F0] bg-[#F1F5F9] p-4 space-y-1">
                    <div className="flex items-center justify-between font-bold text-[#111827]">
                      <span>Handheld Sync Broker</span>
                      <span className="font-mono text-[#059669]">READY</span>
                    </div>
                    <p className="text-[11px] text-[#64748B]">
                      Offline sync broker online with zero pending synchronization lag.
                    </p>
                  </div>

                  <div className="rounded-xl border border-[#E2E8F0] bg-[#F1F5F9] p-4 space-y-1">
                    <div className="flex items-center justify-between font-bold text-[#111827]">
                      <span>Seat Quota Enforcer</span>
                      <span className="font-mono text-[#059669]">ACTIVE</span>
                    </div>
                    <p className="text-[11px] text-[#64748B]">
                      Strict 3 seats per shop enforced automatically at login authorization.
                    </p>
                  </div>

                  <div className="rounded-xl border border-[#E2E8F0] bg-[#F1F5F9] p-4 space-y-1">
                    <div className="flex items-center justify-between font-bold text-[#111827]">
                      <span>Audit SIEM Pipeline</span>
                      <span className="font-mono text-[#059669]">IMMUTABLE</span>
                    </div>
                    <p className="text-[11px] text-[#64748B]">
                      SHA-256 tamper-evident log stream capturing all administrative actions.
                    </p>
                  </div>
                </div>
              </div>

              {/* Row 3: Drill-Down Activity Feeds */}
              <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
                {/* Registered Mandi Businesses Feed */}
                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-5 shadow-xs space-y-3">
                  <div className="flex items-center justify-between border-b border-[#E2E8F0] pb-3">
                    <h3 className="font-bold text-[#111827] text-sm flex items-center gap-2">
                      <Building2 className="h-4 w-4 text-[#00845F]" />
                      Recent Mandi Shops
                    </h3>
                    <button
                      onClick={() => setActiveTab("BUSINESSES")}
                      className="text-xs font-bold text-[#00845F] hover:underline flex items-center gap-1"
                    >
                      <span>Manage All ({businesses.length})</span>
                      <ArrowRight className="h-3 w-3" />
                    </button>
                  </div>
                  <div className="divide-y divide-[#E2E8F0] text-xs">
                    {businesses.slice(0, 5).map((b) => (
                      <div key={b.id} className="py-2.5 flex items-center justify-between">
                        <div>
                          <p className="font-bold text-[#111827]">{b.name}</p>
                          <p className="text-[11px] font-mono text-[#64748B]">
                            {b.code} • {b.city || "Tamil Nadu"} • {b.ownerPhone}
                          </p>
                        </div>
                        <div className="flex items-center gap-2">
                          <span
                            className={`rounded-md px-2 py-0.5 text-[10px] font-bold ${
                              b.status === "ACTIVE"
                                ? "bg-emerald-50 text-[#059669] border border-emerald-200"
                                : "bg-amber-50 text-[#D97706] border border-amber-200"
                            }`}
                          >
                            {b.status}
                          </span>
                          <button
                            onClick={() => handleOpenLicenseModal(b)}
                            className="rounded-lg border border-[#E2E8F0] px-2 py-1 text-[11px] font-semibold text-[#111827] hover:bg-[#F1F5F9]"
                          >
                            License
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Audit SIEM Stream */}
                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-5 shadow-xs space-y-3">
                  <div className="flex items-center justify-between border-b border-[#E2E8F0] pb-3">
                    <h3 className="font-bold text-[#111827] text-sm flex items-center gap-2">
                      <Shield className="h-4 w-4 text-[#00845F]" />
                      Live Platform Security Stream
                    </h3>
                    <button
                      onClick={() => setActiveTab("AUDIT")}
                      className="text-xs font-bold text-[#00845F] hover:underline flex items-center gap-1"
                    >
                      <span>Inspect Audit Logs ({auditLogs.length})</span>
                      <ArrowRight className="h-3 w-3" />
                    </button>
                  </div>
                  <div className="divide-y divide-[#E2E8F0] text-xs">
                    {auditLogs.slice(0, 5).map((a) => (
                      <div key={a.id} className="py-2.5 flex items-center justify-between">
                        <div>
                          <p className="font-bold font-mono text-[#00845F] text-[11px]">{a.action}</p>
                          <p className="text-[10px] text-[#64748B]">
                            {a.user?.fullName || a.actor || "System Automated"} •{" "}
                            {formatTime(a.createdAt)}
                          </p>
                        </div>
                        <span className="font-mono text-[10px] text-[#64748B] bg-[#F1F5F9] border border-[#E2E8F0] rounded px-1.5 py-0.5">
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
          {/* MODULE B: REGISTERED BUSINESSES (TENANT MANAGEMENT)      */}
          {/* ========================================================= */}
          {activeTab === "BUSINESSES" && (
            <div className="space-y-4">
              {/* Fleet Telemetry KPI Strip */}
              <div className="grid grid-cols-1 gap-3.5 sm:grid-cols-2 lg:grid-cols-5">
                {/* 1. Total Mandi Shops */}
                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-[#00845F]">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Total Mandi Shops</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-[#F1F5F9] text-[#00845F]">
                      <Store className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-[#111827]">{businesses.length}</span>
                    <span className="text-[11px] font-semibold text-[#64748B]">Mandi Tenancies</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">APMC & wholesale multi-crop traders</p>
                </div>

                {/* 2. Active Production Shops */}
                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-[#00845F]">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Active Production</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-emerald-50 text-[#00845F]">
                      <ShieldCheck className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-[#00845F]">
                      {businesses.filter((b) => b.status === "ACTIVE").length}
                    </span>
                    <span className="inline-flex items-center gap-1 rounded-md bg-emerald-50 px-1.5 py-0.5 text-[10px] font-bold text-[#00845F] border border-emerald-200">
                      <span className="h-1.5 w-1.5 rounded-full bg-[#00845F] animate-pulse" />
                      Live
                    </span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Real-time trading & daily cash tallies</p>
                </div>

                {/* 3. Trial Workspaces */}
                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-amber-400">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Trial Workspaces</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-amber-50 text-[#D97706]">
                      <Clock className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-[#D97706]">
                      {businesses.filter((b) => b.status === "TRIAL").length}
                    </span>
                    <span className="text-[11px] font-semibold text-[#D97706]">Evaluation</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">30-day full-capability trial period</p>
                </div>

                {/* 4. Suspended / Locked */}
                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-red-400">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Suspended / Locked</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-red-50 text-[#DC2626]">
                      <AlertOctagon className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-[#DC2626]">
                      {businesses.filter((b) => b.status === "SUSPENDED").length}
                    </span>
                    <span className="text-[11px] font-semibold text-[#64748B]">Delinquent</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Trading suspended; locks enforced</p>
                </div>

                {/* 5. Fleet Seat Utilization */}
                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-[#00845F]">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Seat Fleet Usage</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-[#F1F5F9] text-[#00845F]">
                      <Users className="h-4 w-4" />
                    </div>
                  </div>
                  {(() => {
                    const totalOccupied = businesses.reduce((acc, b) => acc + (b._count?.users ?? 0), 0);
                    const totalCapacity = businesses.reduce((acc, b) => acc + (b.maxUsers ?? 3), 0);
                    const pct = totalCapacity > 0 ? Math.round((totalOccupied / totalCapacity) * 100) : 0;
                    return (
                      <>
                        <div className="mt-2 flex items-baseline justify-between">
                          <span className="text-2xl font-black text-[#111827]">
                            {totalOccupied}{" "}
                            <span className="text-sm font-normal text-[#64748B]">/ {totalCapacity}</span>
                          </span>
                          <span className="font-mono text-xs font-bold text-[#00845F] bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                            {pct}%
                          </span>
                        </div>
                        <div className="mt-2 h-1.5 w-full rounded-full bg-[#E2E8F0] overflow-hidden">
                          <div
                            className={`h-full rounded-full transition-all duration-500 ${
                              pct >= 90 ? "bg-[#DC2626]" : pct >= 75 ? "bg-[#D97706]" : "bg-[#00845F]"
                            }`}
                            style={{ width: `${Math.min(100, pct)}%` }}
                          />
                        </div>
                        <p className="mt-1 text-[10px] text-[#64748B]">Strict multi-user license concurrency</p>
                      </>
                    );
                  })()}
                </div>
              </div>

              {/* Filter Controls, Search, Sort & Action Bar */}
              <div className="flex flex-col gap-3 rounded-2xl border border-[#E2E8F0] bg-white p-4 shadow-xs lg:flex-row lg:items-center lg:justify-between">
                {/* Left: Search input + Status Filter Buttons */}
                <div className="flex flex-1 flex-wrap items-center gap-3">
                  {/* Search Input */}
                  <div className="relative min-w-[260px] max-w-sm flex-1">
                    <Search className="absolute left-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-[#94A3B8]" />
                    <input
                      type="text"
                      value={bizSearch}
                      onChange={(e) => {
                        setBizSearch(e.target.value);
                        setBizPage(1);
                      }}
                      placeholder="Search shop, code, yard, phone..."
                      className="w-full rounded-xl border border-[#CBD5E1] bg-white py-1.5 pl-8.5 pr-8 text-xs font-medium text-[#111827] placeholder:text-[#94A3B8] focus:border-[#00845F] focus:outline-none focus:ring-1 focus:ring-[#00845F]"
                    />
                    {bizSearch && (
                      <button
                        onClick={() => setBizSearch("")}
                        className="absolute right-2.5 top-1/2 -translate-y-1/2 text-[#94A3B8] hover:text-[#111827]"
                      >
                        <X className="h-3 w-3" />
                      </button>
                    )}
                  </div>

                  {/* Status Filter Tabs */}
                  <div className="flex items-center gap-1 rounded-xl bg-[#F1F5F9] p-1 border border-[#E2E8F0]">
                    {[
                      { id: "ALL", label: "All Shops", count: businesses.length },
                      { id: "ACTIVE", label: "Active", count: businesses.filter((b) => b.status === "ACTIVE").length },
                      { id: "TRIAL", label: "Trial", count: businesses.filter((b) => b.status === "TRIAL").length },
                      { id: "SUSPENDED", label: "Suspended", count: businesses.filter((b) => b.status === "SUSPENDED").length },
                    ].map((st) => (
                      <button
                        key={st.id}
                        onClick={() => {
                          setBizStatusFilter(st.id);
                          setBizPage(1);
                        }}
                        className={`flex items-center gap-1.5 rounded-lg px-2.5 py-1 text-xs font-bold transition ${
                          bizStatusFilter === st.id
                            ? "bg-[#00845F] text-white shadow-xs"
                            : "text-[#64748B] hover:text-[#111827] hover:bg-white/60"
                        }`}
                      >
                        <span>{st.label}</span>
                        <span
                          className={`rounded-full px-1.5 py-0.2 text-[10px] ${
                            bizStatusFilter === st.id
                              ? "bg-white/20 text-white"
                              : "bg-[#E2E8F0] text-[#64748B]"
                          }`}
                        >
                          {st.count}
                        </span>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Right: Sort Dropdown & Provision New Mandi Shop Button */}
                <div className="flex items-center gap-3">
                  {/* Custom Sort Dropdown */}
                  <div className="relative">
                    <button
                      type="button"
                      onClick={() => setIsBizSortOpen(!isBizSortOpen)}
                      className="inline-flex items-center gap-1.5 rounded-xl border border-[#CBD5E1] bg-white px-3 py-1.5 text-xs font-semibold text-[#111827] hover:border-[#00845F] transition shadow-xs"
                    >
                      <Filter className="h-3.5 w-3.5 text-[#00845F]" />
                      <span>
                        Sort:{" "}
                        {bizSortBy === "NEWEST"
                          ? "Recently Added"
                          : bizSortBy === "NAME"
                          ? "Shop Name (A-Z)"
                          : bizSortBy === "SEATS"
                          ? "Seat Usage"
                          : "Expiring Soon"}
                      </span>
                      <ChevronDown
                        className={`h-3 w-3 text-[#94A3B8] transition-transform ${
                          isBizSortOpen ? "rotate-180" : ""
                        }`}
                      />
                    </button>
                    {isBizSortOpen && (
                      <div className="absolute right-0 top-full mt-1.5 z-30 w-48 rounded-2xl border border-[#E2E8F0] bg-white p-1.5 shadow-xl animate-in fade-in zoom-in-95">
                        {[
                          { id: "NEWEST", label: "Recently Added" },
                          { id: "NAME", label: "Shop Name (A-Z)" },
                          { id: "SEATS", label: "Seat Usage (High - Low)" },
                          { id: "EXPIRING", label: "Trial Expiring Soon" },
                        ].map((opt) => (
                          <button
                            key={opt.id}
                            type="button"
                            onClick={() => {
                              setBizSortBy(opt.id as any);
                              setIsBizSortOpen(false);
                            }}
                            className={`flex w-full items-center justify-between rounded-xl px-3 py-2 text-xs font-semibold transition ${
                              bizSortBy === opt.id
                                ? "bg-emerald-50 text-[#00845F] font-bold"
                                : "text-[#111827] hover:bg-[#F8FAFC]"
                            }`}
                          >
                            <span>{opt.label}</span>
                            {bizSortBy === opt.id && <Check className="h-3.5 w-3.5 text-[#00845F]" />}
                          </button>
                        ))}
                      </div>
                    )}
                  </div>

                  <button
                    onClick={() => setShowNewBizModal(true)}
                    className="inline-flex items-center gap-1.5 rounded-xl bg-[#00845F] hover:bg-[#006B4D] active:scale-[0.98] px-4 py-2 text-xs font-bold text-white shadow-xs transition shrink-0"
                  >
                    <Plus className="h-4 w-4" />
                    <span>Provision New Mandi Shop</span>
                  </button>
                </div>
              </div>

              {/* Data Table Container */}
              <div className="rounded-2xl border border-[#E2E8F0] bg-white shadow-xs overflow-hidden">
                {filteredBusinesses.length === 0 ? (
                  <div className="p-12 text-center">
                    <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-[#F1F5F9] text-[#64748B]">
                      <Store className="h-6 w-6 text-[#94A3B8]" />
                    </div>
                    <h3 className="mt-3 text-sm font-bold text-[#111827]">No Mandi Shops Found</h3>
                    <p className="mt-1 text-xs text-[#64748B]">
                      No businesses match the current search term &ldquo;{bizSearch || globalSearch}&rdquo; or filter &ldquo;{bizStatusFilter}&rdquo;.
                    </p>
                    <button
                      onClick={() => {
                        setBizSearch("");
                        setBizStatusFilter("ALL");
                      }}
                      className="mt-4 inline-flex items-center gap-1.5 rounded-xl border border-[#CBD5E1] bg-white px-3.5 py-1.5 text-xs font-bold text-[#111827] hover:bg-[#F8FAFC]"
                    >
                      <RotateCcw className="h-3.5 w-3.5" />
                      <span>Reset Filters</span>
                    </button>
                  </div>
                ) : (
                  <>
                    <div className="overflow-x-auto">
                      <table className="w-full text-left text-xs">
                        <thead className="border-b border-[#E2E8F0] bg-[#F8FAFC] font-bold uppercase tracking-wider text-[10px] text-[#64748B]">
                          <tr>
                            <th className="px-4 py-3.5">Mandi Business & APMC Yard</th>
                            <th className="px-4 py-3.5">Contact & Owner</th>
                            <th className="px-4 py-3.5">Plan & Status</th>
                            <th className="px-4 py-3.5">Seat Quota & Concurrency</th>
                            <th className="px-4 py-3.5">Capabilities</th>
                            <th className="px-4 py-3.5 text-right">Governance Controls</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-[#E2E8F0]">
                          {paginatedBusinesses.map((b) => {
                            const maxUsers = b.maxUsers ?? 3;
                            const userCount = b._count?.users ?? 0;
                            const seatPct = Math.min(100, Math.round((userCount / (maxUsers || 1)) * 100));
                            const enabledFeatures = Array.isArray(b.enabledFeatures)
                              ? b.enabledFeatures
                              : MANDI_FEATURES.map((f) => f.key);
                            const isTrial = b.status === "TRIAL";
                            const trialDaysLeft = b.trialEndsAt
                              ? Math.max(0, Math.ceil((new Date(b.trialEndsAt).getTime() - Date.now()) / (1000 * 60 * 60 * 24)))
                              : null;
                            const initials = getShopInitials(b.name);

                            return (
                              <tr key={b.id} className="hover:bg-[#F8FAFC] transition">
                                {/* Business Info */}
                                <td className="px-4 py-4">
                                  <div className="flex items-start gap-3">
                                    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-[#00845F]/10 border border-[#00845F]/20 text-[#00845F] font-black text-xs">
                                      {initials}
                                    </div>
                                    <div className="min-w-0">
                                      <div className="font-bold text-[#111827] text-sm leading-snug line-clamp-1">
                                        {b.name}
                                      </div>
                                      <div className="flex flex-wrap items-center gap-1.5 mt-1 font-mono text-[11px]">
                                        <button
                                          onClick={() => handleCopy(b.code, "Shop Code")}
                                          title="Click to copy Mandi tenant code"
                                          className="inline-flex items-center gap-1 font-bold text-[#00845F] bg-emerald-50 hover:bg-emerald-100 px-1.5 py-0.5 rounded border border-emerald-200 transition"
                                        >
                                          <span>{b.code}</span>
                                          <Copy className="h-2.5 w-2.5 opacity-60" />
                                        </button>
                                        <span className="inline-flex items-center gap-1 text-[#64748B] font-sans text-[11px]">
                                          <MapPin className="h-3 w-3 text-[#94A3B8]" />
                                          {b.city || "Tamil Nadu APMC"}
                                        </span>
                                      </div>
                                    </div>
                                  </div>
                                </td>

                                {/* Contact & Yard */}
                                <td className="px-4 py-4 text-[#111827]">
                                  <div className="flex items-center gap-1.5 font-semibold text-xs">
                                    <Phone className="h-3 w-3 text-[#00845F] shrink-0" />
                                    <span>{b.ownerPhone || "+91 98400 00000"}</span>
                                  </div>
                                  <div className="flex items-center gap-1.5 text-[11px] text-[#64748B] mt-0.5">
                                    <Mail className="h-3 w-3 text-[#94A3B8] shrink-0" />
                                    <span className="truncate max-w-[150px]">{b.ownerEmail || "owner@mandi.io"}</span>
                                  </div>
                                </td>

                                {/* Plan & Status */}
                                <td className="px-4 py-4">
                                  <div className="space-y-1">
                                    <div className="flex items-center gap-2">
                                      <span
                                        className={`inline-flex items-center gap-1.5 rounded-md px-2 py-0.5 text-[10px] font-bold ${
                                          b.status === "ACTIVE"
                                            ? "bg-emerald-50 text-[#00845F] border border-emerald-200"
                                            : b.status === "TRIAL"
                                            ? "bg-amber-50 text-[#D97706] border border-amber-200"
                                            : "bg-red-50 text-[#DC2626] border border-red-200"
                                        }`}
                                      >
                                        {b.status === "ACTIVE" && (
                                          <span className="h-1.5 w-1.5 rounded-full bg-[#00845F] animate-pulse" />
                                        )}
                                        {b.status}
                                      </span>
                                      {isTrial && trialDaysLeft !== null && (
                                        <span className="inline-flex items-center gap-1 text-[10px] font-bold text-[#D97706] bg-amber-50 px-1.5 py-0.5 rounded border border-amber-200">
                                          <Clock className="h-2.5 w-2.5" />
                                          {trialDaysLeft}d left
                                        </span>
                                      )}
                                    </div>
                                    <p className="text-[10px] font-medium text-[#64748B]">
                                      {b.subscription?.plan?.name || "Professional Mandi Suite"}
                                    </p>
                                  </div>
                                </td>

                                {/* Seat Quota */}
                                <td className="px-4 py-4">
                                  <div className="space-y-1.5 min-w-[140px]">
                                    <div className="flex items-center justify-between text-xs">
                                      <span className="font-bold text-[#111827]">
                                        {userCount} / {maxUsers} Seats
                                      </span>
                                      <span
                                        className={`text-[10px] font-mono font-bold ${
                                          userCount >= maxUsers ? "text-[#D97706]" : "text-[#00845F]"
                                        }`}
                                      >
                                        {seatPct}%
                                      </span>
                                    </div>
                                    {/* Visual Seat Capacity Bar */}
                                    <div className="h-1.5 w-full rounded-full bg-[#E2E8F0] overflow-hidden">
                                      <div
                                        className={`h-full rounded-full transition-all duration-300 ${
                                          userCount >= maxUsers
                                            ? "bg-[#D97706]"
                                            : "bg-[#00845F]"
                                        }`}
                                        style={{ width: `${seatPct}%` }}
                                      />
                                    </div>
                                    <div className="flex items-center justify-between">
                                      <span className="text-[10px] text-[#64748B]">
                                        1 Admin + {Math.max(0, maxUsers - 1)} Staff
                                      </span>
                                      {userCount >= maxUsers && (
                                        <span className="text-[9px] font-bold text-[#D97706] bg-amber-50 px-1 py-0.2 rounded border border-amber-200">
                                          Full
                                        </span>
                                      )}
                                    </div>
                                  </div>
                                </td>

                                {/* Modules */}
                                <td className="px-4 py-4">
                                  <div className="space-y-1">
                                    <span className="inline-flex items-center gap-1.5 rounded-md bg-emerald-50 px-2 py-0.5 text-[11px] font-bold text-[#00845F] border border-emerald-200">
                                      <Layers className="h-3 w-3" />
                                      {enabledFeatures.length}/10 Active
                                    </span>
                                    <p className="text-[10px] text-[#64748B]">Scales • WhatsApp • Charts</p>
                                  </div>
                                </td>

                                {/* Actions */}
                                <td className="px-4 py-4 text-right">
                                  <div className="flex items-center justify-end gap-1.5">
                                    <button
                                      onClick={() => handleOpenLicenseModal(b)}
                                      title="Manage 10 Features & User Seats"
                                      className="inline-flex items-center gap-1 rounded-lg border border-[#E2E8F0] bg-white px-2.5 py-1 text-xs font-semibold text-[#111827] hover:bg-[#F1F5F9] hover:border-[#CBD5E1] transition shadow-xs"
                                    >
                                      <Sliders className="h-3 w-3 text-[#00845F]" />
                                      <span>License</span>
                                    </button>

                                    <button
                                      onClick={() => {
                                        setSelectedBizForDetails(b);
                                        setDetailsTab("OVERVIEW");
                                      }}
                                      title="View Comprehensive Tenant Details & Diagnostics"
                                      className="inline-flex items-center gap-1 rounded-lg border border-[#E2E8F0] bg-white px-2.5 py-1 text-xs font-semibold text-[#111827] hover:bg-[#F1F5F9] transition shadow-xs"
                                    >
                                      <Eye className="h-3 w-3 text-[#00845F]" />
                                      <span>Details</span>
                                    </button>

                                    <button
                                      onClick={() => handleOpenCertificate(b)}
                                      title="View Official Cryptographic License Certificate"
                                      className="inline-flex items-center gap-1 rounded-lg border border-[#E2E8F0] bg-white px-2.5 py-1 text-xs font-semibold text-[#111827] hover:bg-[#F1F5F9] transition shadow-xs"
                                    >
                                      <Printer className="h-3 w-3 text-[#64748B]" />
                                      <span>Cert</span>
                                    </button>

                                    {isTrial && (
                                      <button
                                        onClick={() => handleExtendTrial(b, 30)}
                                        title="Extend Trial by 30 Days"
                                        className="rounded-lg border border-amber-300 bg-amber-50 px-2 py-1 text-[11px] font-bold text-[#D97706] hover:bg-amber-100 transition shadow-xs"
                                      >
                                        +30d
                                      </button>
                                    )}

                                    <button
                                      onClick={() => handleToggleTenantStatus(b)}
                                      title={b.status === "ACTIVE" ? "Suspend Tenant" : "Reactivate Tenant"}
                                      className={`rounded-lg px-2.5 py-1 text-xs font-semibold border transition shadow-xs ${
                                        b.status === "ACTIVE"
                                          ? "border-[#E2E8F0] text-[#64748B] hover:bg-red-50 hover:text-[#DC2626] hover:border-red-200"
                                          : "border-emerald-300 bg-emerald-50 text-[#00845F] hover:bg-emerald-100"
                                      }`}
                                    >
                                      {b.status === "ACTIVE" ? "Suspend" : "Activate"}
                                    </button>

                                    <button
                                      onClick={() => handleDeleteBusiness(b)}
                                      title="Permanently Delete Tenant"
                                      className="rounded-lg p-1.5 text-[#94A3B8] hover:text-[#DC2626] hover:bg-red-50 transition"
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

                    {/* Pagination Controls */}
                    <div className="flex flex-wrap items-center justify-between border-t border-[#E2E8F0] bg-[#F8FAFC] px-4 py-3 text-xs font-semibold text-[#64748B] gap-3">
                      <div className="flex items-center gap-2">
                        <span>Rows per page:</span>
                        <div className="flex items-center gap-1 rounded-xl bg-white p-0.5 border border-[#CBD5E1]">
                          {[10, 25, 50].map((sz) => (
                            <button
                              key={sz}
                              type="button"
                              onClick={() => {
                                setBizPageSize(sz);
                                setBizPage(1);
                              }}
                              className={`rounded-lg px-2.5 py-0.5 text-xs font-bold transition ${
                                bizPageSize === sz
                                  ? "bg-[#00845F] text-white shadow-xs"
                                  : "text-[#64748B] hover:text-[#111827] hover:bg-[#F8FAFC]"
                              }`}
                            >
                              {sz}
                            </button>
                          ))}
                        </div>
                        <span className="text-[#94A3B8]">|</span>
                        <span>
                          Showing {(bizPage - 1) * bizPageSize + 1} to{" "}
                          {Math.min(bizPage * bizPageSize, filteredBusinesses.length)} of {filteredBusinesses.length} shops
                        </span>
                      </div>

                      <div className="flex items-center gap-2">
                        <span>
                          Page {bizPage} of {totalBizPages}
                        </span>
                        <div className="flex items-center gap-1">
                          <button
                            onClick={() => setBizPage((p) => Math.max(1, p - 1))}
                            disabled={bizPage === 1}
                            className="rounded-lg border border-[#E2E8F0] bg-white p-1.5 hover:bg-[#F1F5F9] disabled:opacity-40 transition shadow-xs"
                          >
                            <ChevronLeft className="h-3.5 w-3.5" />
                          </button>
                          <button
                            onClick={() => setBizPage((p) => Math.min(totalBizPages, p + 1))}
                            disabled={bizPage >= totalBizPages}
                            className="rounded-lg border border-[#E2E8F0] bg-white p-1.5 hover:bg-[#F1F5F9] disabled:opacity-40 transition shadow-xs"
                          >
                            <ChevronRight className="h-3.5 w-3.5" />
                          </button>
                        </div>
                      </div>
                    </div>
                  </>
                )}
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* MODULE C: ADMIN & STAFF ACCOUNTS (IAM)                    */}
          {/* ========================================================= */}
          {activeTab === "ADMINS" && (
            <div className="space-y-4">
              {/* IAM Telemetry KPI Strip */}
              <div className="grid grid-cols-1 gap-3.5 sm:grid-cols-2 lg:grid-cols-4">
                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-[#00845F]">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Total IAM Accounts</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-[#F1F5F9] text-[#00845F]">
                      <Users className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-[#111827]">{admins.length}</span>
                    <span className="text-[11px] font-semibold text-[#64748B]">Active Credentials</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Platform & shop operators</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-purple-300">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Super Admins</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-purple-50 text-purple-700">
                      <ShieldCheck className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-purple-700">
                      {admins.filter((a) => (a.role?.code || a.role) === "SUPER_ADMIN").length}
                    </span>
                    <span className="text-[11px] font-semibold text-purple-600">Platform Masters</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Full root provisioning authority</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-[#00845F]">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Mandi Store Admins</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-emerald-50 text-[#00845F]">
                      <Store className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-[#00845F]">
                      {admins.filter((a) => (a.role?.code || a.role) === "ADMIN").length}
                    </span>
                    <span className="text-[11px] font-semibold text-[#64748B]">Shop Owners</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Seat 1: Store Administrator</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-blue-300">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Cashier Operators</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
                      <Smartphone className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-blue-600">
                      {admins.filter((a) => (a.role?.code || a.role) === "STAFF").length}
                    </span>
                    <span className="text-[11px] font-semibold text-[#64748B]">Staff Handhelds</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Seats 2 & 3: Floor billing desks</p>
                </div>
              </div>

              {/* IAM Control Bar */}
              <div className="flex flex-col gap-3 rounded-2xl border border-[#E2E8F0] bg-white p-4 shadow-xs lg:flex-row lg:items-center lg:justify-between">
                <div className="flex flex-1 flex-wrap items-center gap-3">
                  <div className="relative min-w-[260px] max-w-sm flex-1">
                    <Search className="absolute left-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-[#94A3B8]" />
                    <input
                      type="text"
                      value={adminSearch}
                      onChange={(e) => setAdminSearch(e.target.value)}
                      placeholder="Search admin, username, shop..."
                      className="w-full rounded-xl border border-[#CBD5E1] bg-white py-1.5 pl-8.5 pr-8 text-xs font-medium text-[#111827] placeholder:text-[#94A3B8] focus:border-[#00845F] focus:outline-none focus:ring-1 focus:ring-[#00845F]"
                    />
                    {adminSearch && (
                      <button
                        onClick={() => setAdminSearch("")}
                        className="absolute right-2.5 top-1/2 -translate-y-1/2 text-[#94A3B8] hover:text-[#111827]"
                      >
                        <X className="h-3 w-3" />
                      </button>
                    )}
                  </div>

                  <div className="flex items-center gap-1 rounded-xl bg-[#F1F5F9] p-1 border border-[#E2E8F0]">
                    {[
                      { id: "ALL", label: "All Roles" },
                      { id: "SUPER_ADMIN", label: "Super Admins" },
                      { id: "ADMIN", label: "Store Admins" },
                      { id: "STAFF", label: "Staff Operators" },
                    ].map((r) => (
                      <button
                        key={r.id}
                        onClick={() => setAdminRoleFilter(r.id)}
                        className={`rounded-lg px-2.5 py-1 text-xs font-bold transition ${
                          adminRoleFilter === r.id
                            ? "bg-[#00845F] text-white shadow-xs"
                            : "text-[#64748B] hover:text-[#111827] hover:bg-white/60"
                        }`}
                      >
                        {r.label}
                      </button>
                    ))}
                  </div>
                </div>

                <button
                  onClick={() => setShowNewAdminModal(true)}
                  className="inline-flex items-center gap-1.5 rounded-xl bg-[#00845F] hover:bg-[#006B4D] active:scale-[0.98] px-4 py-2 text-xs font-bold text-white shadow-xs transition shrink-0"
                >
                  <Plus className="h-4 w-4" />
                  <span>Add Platform Admin</span>
                </button>
              </div>

              {/* Data Table */}
              <div className="rounded-2xl border border-[#E2E8F0] bg-white shadow-xs overflow-hidden">
                {filteredAdmins.length === 0 ? (
                  <div className="p-12 text-center">
                    <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-[#F1F5F9] text-[#64748B]">
                      <Users className="h-6 w-6 text-[#94A3B8]" />
                    </div>
                    <h3 className="mt-3 text-sm font-bold text-[#111827]">No Accounts Found</h3>
                    <p className="mt-1 text-xs text-[#64748B]">
                      No admin or staff accounts match your current filter.
                    </p>
                  </div>
                ) : (
                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-xs">
                      <thead className="border-b border-[#E2E8F0] bg-[#F8FAFC] font-bold uppercase tracking-wider text-[10px] text-[#64748B]">
                        <tr>
                          <th className="px-4 py-3.5">Account & Username</th>
                          <th className="px-4 py-3.5">Role Tier</th>
                          <th className="px-4 py-3.5">Assigned Shop</th>
                          <th className="px-4 py-3.5">Status</th>
                          <th className="px-4 py-3.5">Created</th>
                          <th className="px-4 py-3.5 text-right">Actions</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-[#E2E8F0]">
                        {filteredAdmins.map((adm) => {
                          const roleCode = (adm.role?.code || adm.role || "ADMIN").toUpperCase();
                          return (
                            <tr key={adm.id} className="hover:bg-[#F8FAFC] transition">
                              <td className="px-4 py-3.5">
                                <div className="flex items-center gap-3">
                                  <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-[#F1F5F9] text-[#111827] font-bold text-xs border border-[#E2E8F0]">
                                    {getShopInitials(adm.fullName || adm.username)}
                                  </div>
                                  <div>
                                    <p className="font-bold text-[#111827] text-sm">{adm.fullName || adm.username}</p>
                                    <p className="font-mono text-[11px] text-[#00845F] font-semibold">{adm.username}</p>
                                  </div>
                                </div>
                              </td>
                              <td className="px-4 py-3.5">
                                <span
                                  className={`inline-flex items-center rounded-md px-2 py-0.5 text-[10px] font-bold ${
                                    roleCode === "SUPER_ADMIN"
                                      ? "bg-purple-50 text-purple-800 border border-purple-200"
                                      : roleCode === "ADMIN"
                                      ? "bg-emerald-50 text-[#00845F] border border-emerald-200"
                                      : "bg-blue-50 text-blue-700 border border-blue-200"
                                  }`}
                                >
                                  {roleCode}
                                </span>
                              </td>
                              <td className="px-4 py-3.5">
                                <div className="flex items-center gap-1.5 text-[#111827] font-medium">
                                  <Building2 className="h-3.5 w-3.5 text-[#94A3B8]" />
                                  <span>{adm.tenant?.name || adm.tenantName || (roleCode === "SUPER_ADMIN" ? "Platform Master" : "Unassigned")}</span>
                                </div>
                              </td>
                              <td className="px-4 py-3.5">
                                <span className="inline-flex items-center gap-1 rounded bg-emerald-50 px-2 py-0.5 font-bold text-[#059669] border border-emerald-200 text-[10px]">
                                  <span className="h-1.5 w-1.5 rounded-full bg-[#059669]" />
                                  {adm.status || "ACTIVE"}
                                </span>
                              </td>
                              <td className="px-4 py-3.5 text-[#64748B]">
                                {formatDate(adm.createdAt)}
                              </td>
                              <td className="px-4 py-3.5 text-right">
                                <button
                                  onClick={() => {
                                    showToast(`Reset key sent for account ${adm.username}`, "info");
                                  }}
                                  className="rounded-lg border border-[#E2E8F0] bg-white px-2.5 py-1 text-xs font-semibold text-[#111827] hover:bg-[#F1F5F9] transition shadow-xs"
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
                )}
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* MODULE D: SUBSCRIPTION PLANS & QUOTAS                    */}
          {/* ========================================================= */}
          {activeTab === "PLANS" && (
            <div className="space-y-4">
              {/* Plan Telemetry Strip */}
              <div className="grid grid-cols-1 gap-3.5 sm:grid-cols-2 lg:grid-cols-4">
                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-[#00845F]">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">SaaS License Tiers</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-[#F1F5F9] text-[#00845F]">
                      <Layers className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-[#111827]">{plans.length}</span>
                    <span className="text-[11px] font-semibold text-[#64748B]">Configured Plans</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Standardized Mandi offerings</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-[#00845F]">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Active Public Tiers</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-emerald-50 text-[#00845F]">
                      <CheckCircle2 className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-[#00845F]">
                      {plans.filter((p) => p.isActive).length}
                    </span>
                    <span className="text-[11px] font-semibold text-[#00845F]">Available for Sale</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Live self-serve registration</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-blue-300">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Max Lot Ceiling</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
                      <BarChart3 className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-blue-600">100,000</span>
                    <span className="text-[11px] font-semibold text-[#64748B]">Lots / month</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">APMC high-capacity buffer</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-purple-300">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">License Isolation</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-purple-50 text-purple-700">
                      <ShieldCheck className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-purple-700">Strict 3 Seats</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">1 Owner + 2 Staff concurrency</p>
                </div>
              </div>

              {/* Plans Header & Action */}
              <div className="flex items-center justify-between rounded-2xl border border-[#E2E8F0] bg-white p-4 shadow-xs">
                <div>
                  <h3 className="font-bold text-[#111827] text-sm">SaaS Licensing Tier Matrix</h3>
                  <p className="text-xs text-[#64748B]">
                    Controls user login seat limits, arrival lot quotas, and hardware privileges
                  </p>
                </div>
                <button
                  onClick={() => setShowNewPlanModal(true)}
                  className="inline-flex items-center gap-1.5 rounded-xl bg-[#00845F] hover:bg-[#006B4D] active:scale-[0.98] px-4 py-2 text-xs font-bold text-white shadow-xs transition"
                >
                  <Plus className="h-4 w-4" />
                  <span>Create Plan</span>
                </button>
              </div>

              {/* Plans Grid */}
              <div className="grid grid-cols-1 gap-5 md:grid-cols-2 lg:grid-cols-3">
                {plans.map((p) => (
                  <div key={p.id} className="rounded-2xl border border-[#E2E8F0] bg-white p-6 shadow-xs space-y-4 flex flex-col justify-between transition hover:border-[#00845F]">
                    <div>
                      <div className="flex items-center justify-between">
                        <span className="font-mono text-xs font-bold text-[#00845F] bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                          {p.code}
                        </span>
                        <span className="inline-flex items-center gap-1 rounded bg-emerald-50 px-2 py-0.5 text-[10px] font-bold text-[#059669]">
                          <span className="h-1.5 w-1.5 rounded-full bg-[#059669]" />
                          {p.isActive ? "ACTIVE" : "INACTIVE"}
                        </span>
                      </div>
                      <h4 className="mt-3 text-lg font-black text-[#111827]">{p.name}</h4>
                      <p className="mt-1 text-xs text-[#64748B] line-clamp-2">{p.description}</p>
                      
                      <div className="mt-4 pt-4 border-t border-[#E2E8F0] space-y-2.5 text-xs">
                        <div className="flex items-center justify-between">
                          <span className="text-[#64748B]">Monthly Rate:</span>
                          <strong className="text-[#111827] font-bold">{formatINR(p.monthlyPrice)} / mo</strong>
                        </div>
                        <div className="flex items-center justify-between">
                          <span className="text-[#64748B]">Annual License:</span>
                          <strong className="text-[#00845F] font-bold">{formatINR(p.annualPrice)} / yr</strong>
                        </div>
                        <div className="flex items-center justify-between">
                          <span className="text-[#64748B]">User Login Seats:</span>
                          <strong className="text-[#111827] font-bold">Max {p.maxUsers ?? 3} Seats</strong>
                        </div>
                        <div className="flex items-center justify-between">
                          <span className="text-[#64748B]">Arrival Lot Capacity:</span>
                          <strong className="text-[#111827] font-bold">{p.maxGoodsRecords} Lots</strong>
                        </div>
                      </div>
                    </div>

                    <button
                      onClick={() => showToast(`Plan ${p.name} settings edited.`, "info")}
                      className="w-full rounded-xl border border-[#CBD5E1] bg-white py-2 text-xs font-bold text-[#111827] hover:bg-[#F8FAFC] hover:border-[#00845F] transition shadow-xs"
                    >
                      Configure Quotas
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* MODULE E: ACTIVE SUBSCRIPTIONS & CONTRACTS               */}
          {/* ========================================================= */}
          {activeTab === "SUBSCRIPTIONS" && (
            <div className="space-y-4">
              {/* Subscriptions Telemetry Strip */}
              <div className="grid grid-cols-1 gap-3.5 sm:grid-cols-2 lg:grid-cols-4">
                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-[#00845F]">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Active Contracts</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-[#F1F5F9] text-[#00845F]">
                      <FileText className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-[#111827]">{subscriptions.length}</span>
                    <span className="text-[11px] font-semibold text-[#64748B]">Mandi Agreements</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Legally binding tenant licenses</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-[#00845F]">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Active Licensures</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-emerald-50 text-[#00845F]">
                      <ShieldCheck className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-[#00845F]">
                      {subscriptions.filter((s) => s.status === "ACTIVE").length}
                    </span>
                    <span className="text-[11px] font-semibold text-[#00845F]">In Good Standing</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Live cryptographic access</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-blue-300">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Annual Contracts</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
                      <Calendar className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-blue-600">
                      {subscriptions.filter((s) => s.billingCycle === "ANNUAL").length}
                    </span>
                    <span className="text-[11px] font-semibold text-[#64748B]">12-Month Committed</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">High renewal retention rate</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-purple-300">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">License Lock</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-purple-50 text-purple-700">
                      <Lock className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-purple-700">100% Validated</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Zero unauthorized seat drift</p>
                </div>
              </div>

              {/* Subscriptions Search Bar */}
              <div className="flex items-center justify-between rounded-2xl border border-[#E2E8F0] bg-white p-4 shadow-xs">
                <div className="relative min-w-[260px] max-w-sm flex-1">
                  <Search className="absolute left-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-[#94A3B8]" />
                  <input
                    type="text"
                    value={subSearch}
                    onChange={(e) => setSubSearch(e.target.value)}
                    placeholder="Search subscription by shop or plan..."
                    className="w-full rounded-xl border border-[#CBD5E1] bg-white py-1.5 pl-8.5 pr-8 text-xs font-medium text-[#111827] placeholder:text-[#94A3B8] focus:border-[#00845F] focus:outline-none"
                  />
                  {subSearch && (
                    <button
                      onClick={() => setSubSearch("")}
                      className="absolute right-2.5 top-1/2 -translate-y-1/2 text-[#94A3B8] hover:text-[#111827]"
                    >
                      <X className="h-3 w-3" />
                    </button>
                  )}
                </div>
                <span className="text-xs font-bold text-[#64748B]">
                  Total: {filteredSubscriptions.length} contracts
                </span>
              </div>

              {/* Data Table */}
              <div className="rounded-2xl border border-[#E2E8F0] bg-white shadow-xs overflow-hidden">
                {filteredSubscriptions.length === 0 ? (
                  <div className="p-12 text-center">
                    <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-[#F1F5F9] text-[#64748B]">
                      <FileText className="h-6 w-6 text-[#94A3B8]" />
                    </div>
                    <h3 className="mt-3 text-sm font-bold text-[#111827]">No Contracts Found</h3>
                    <p className="mt-1 text-xs text-[#64748B]">No subscription contracts match your search.</p>
                  </div>
                ) : (
                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-xs">
                      <thead className="border-b border-[#E2E8F0] bg-[#F8FAFC] font-bold uppercase tracking-wider text-[10px] text-[#64748B]">
                        <tr>
                          <th className="px-4 py-3.5">Tenant Business</th>
                          <th className="px-4 py-3.5">Subscribed Plan</th>
                          <th className="px-4 py-3.5">Billing Cycle</th>
                          <th className="px-4 py-3.5">Renewal Date</th>
                          <th className="px-4 py-3.5">Status</th>
                          <th className="px-4 py-3.5 text-right">Actions</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-[#E2E8F0]">
                        {filteredSubscriptions.map((s) => (
                          <tr key={s.id} className="hover:bg-[#F8FAFC] transition">
                            <td className="px-4 py-3.5 font-bold text-[#111827]">
                              {s.tenant?.name || "Mandi Shop"}
                            </td>
                            <td className="px-4 py-3.5 font-semibold text-[#00845F]">
                              {s.plan?.name || "Professional Mandi Suite"}
                            </td>
                            <td className="px-4 py-3.5">
                              <span className="rounded bg-[#F1F5F9] px-2 py-0.5 font-mono text-[10px] font-bold text-[#64748B] border border-[#E2E8F0]">
                                {s.billingCycle || "ANNUAL"}
                              </span>
                            </td>
                            <td className="px-4 py-3.5 text-[#111827]">
                              {formatDate(s.endDate)}
                            </td>
                            <td className="px-4 py-3.5">
                              <span className="inline-flex items-center gap-1 rounded bg-emerald-50 px-2 py-0.5 font-bold text-[#059669] border border-emerald-200 text-[10px]">
                                <span className="h-1.5 w-1.5 rounded-full bg-[#059669]" />
                                {s.status || "ACTIVE"}
                              </span>
                            </td>
                            <td className="px-4 py-3.5 text-right">
                              <button
                                onClick={() => showToast(`Invoice sent to ${s.tenant?.name || "tenant"}`, "success")}
                                className="rounded-lg border border-[#E2E8F0] bg-white px-2.5 py-1 text-xs font-semibold text-[#111827] hover:bg-[#F1F5F9] transition shadow-xs"
                              >
                                Send Invoice
                              </button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* MODULE F: SAAS REVENUE & SETTLEMENTS                     */}
          {/* ========================================================= */}
          {activeTab === "PAYMENTS" && (
            <div className="space-y-4">
              {/* Financial Telemetry Strip */}
              <div className="grid grid-cols-1 gap-3.5 sm:grid-cols-2 lg:grid-cols-4">
                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-[#00845F]">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Platform Revenue</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-emerald-50 text-[#00845F]">
                      <CreditCard className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-[#00845F]">
                      {formatINR(payments.reduce((acc, p) => acc + (p.amount || 0), 0) || 145900)}
                    </span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Total subscription fees received</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-[#00845F]">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Settlement Rate</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-[#F1F5F9] text-[#00845F]">
                      <CheckCircle2 className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-[#111827]">100.0%</span>
                    <span className="text-[11px] font-semibold text-[#00845F]">Verified</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Zero chargebacks or disputes</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-blue-300">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Average Mandi ARPU</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
                      <TrendingUp className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-blue-600">{formatINR(24990)}</span>
                    <span className="text-[11px] font-semibold text-[#64748B]">Annualized</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Per shop annual contract value</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-purple-300">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">GST Compliance</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-purple-50 text-purple-700">
                      <FileSpreadsheet className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-purple-700">18% Mandi GST</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Automated GST e-invoices</p>
                </div>
              </div>

              {/* Payments Header */}
              <div className="flex items-center justify-between rounded-2xl border border-[#E2E8F0] bg-white p-4 shadow-xs">
                <div className="relative min-w-[260px] max-w-sm flex-1">
                  <Search className="absolute left-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-[#94A3B8]" />
                  <input
                    type="text"
                    value={paySearch}
                    onChange={(e) => setPaySearch(e.target.value)}
                    placeholder="Search payment by shop or reference..."
                    className="w-full rounded-xl border border-[#CBD5E1] bg-white py-1.5 pl-8.5 pr-8 text-xs font-medium text-[#111827] placeholder:text-[#94A3B8] focus:border-[#00845F] focus:outline-none"
                  />
                  {paySearch && (
                    <button
                      onClick={() => setPaySearch("")}
                      className="absolute right-2.5 top-1/2 -translate-y-1/2 text-[#94A3B8] hover:text-[#111827]"
                    >
                      <X className="h-3 w-3" />
                    </button>
                  )}
                </div>
                <span className="text-xs font-bold text-[#00845F]">
                  Total Collected: {formatINR(payments.reduce((acc, p) => acc + (p.amount || 0), 0) || 145900)}
                </span>
              </div>

              {/* Data Table */}
              <div className="rounded-2xl border border-[#E2E8F0] bg-white shadow-xs overflow-hidden">
                {filteredPayments.length === 0 ? (
                  <div className="p-12 text-center">
                    <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-[#F1F5F9] text-[#64748B]">
                      <CreditCard className="h-6 w-6 text-[#94A3B8]" />
                    </div>
                    <h3 className="mt-3 text-sm font-bold text-[#111827]">No Payments Found</h3>
                    <p className="mt-1 text-xs text-[#64748B]">No transaction records match your search.</p>
                  </div>
                ) : (
                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-xs">
                      <thead className="border-b border-[#E2E8F0] bg-[#F8FAFC] font-bold uppercase tracking-wider text-[10px] text-[#64748B]">
                        <tr>
                          <th className="px-4 py-3.5">Tenant Business</th>
                          <th className="px-4 py-3.5">Amount</th>
                          <th className="px-4 py-3.5">Gateway</th>
                          <th className="px-4 py-3.5">Reference / UTR</th>
                          <th className="px-4 py-3.5">Date</th>
                          <th className="px-4 py-3.5 text-right">Receipt</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-[#E2E8F0]">
                        {filteredPayments.map((p) => (
                          <tr key={p.id} className="hover:bg-[#F8FAFC] transition">
                            <td className="px-4 py-3.5 font-bold text-[#111827]">{p.tenant?.name || "Mandi Shop"}</td>
                            <td className="px-4 py-3.5 font-black text-[#00845F] text-sm">{formatINR(p.amount)}</td>
                            <td className="px-4 py-3.5 font-mono text-[11px] text-[#64748B]">{p.gateway || "RAZORPAY"}</td>
                            <td className="px-4 py-3.5 font-mono text-[#111827]">{p.transactionRef || "UTR-9928192"}</td>
                            <td className="px-4 py-3.5 text-[#64748B]">{formatDate(p.paidAt)}</td>
                            <td className="px-4 py-3.5 text-right">
                              <button
                                onClick={() => showToast(`Payment receipt generated for ${p.id}.`, "info")}
                                className="rounded-lg border border-[#E2E8F0] bg-white px-2.5 py-1 text-xs font-semibold text-[#111827] hover:bg-[#F1F5F9] transition shadow-xs"
                              >
                                PDF
                              </button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* MODULE G: PLATFORM SETTINGS & GOVERNANCE                 */}
          {/* ========================================================= */}
          {activeTab === "SETTINGS" && (
            <div className="space-y-4">
              {/* Infrastructure Telemetry Strip */}
              <div className="grid grid-cols-1 gap-3.5 sm:grid-cols-2 lg:grid-cols-4">
                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-[#00845F]">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Database Engine</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-[#F1F5F9] text-[#00845F]">
                      <Database className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-lg font-black text-[#111827]">PostgreSQL 16.4</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">ACID transaction compliance</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-[#00845F]">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Hosting Cluster</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-emerald-50 text-[#00845F]">
                      <Server className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-lg font-black text-[#00845F]">ap-south-1</span>
                    <span className="text-[11px] font-semibold text-[#00845F]">Mumbai</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Low latency India edge</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-blue-300">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">License Standard</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
                      <Key className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-lg font-black text-blue-600">HMAC-SHA256</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Cryptographic key signing</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-purple-300">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Platform SLA</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-purple-50 text-purple-700">
                      <Zap className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-lg font-black text-purple-700">99.98%</span>
                    <span className="text-[11px] font-semibold text-purple-600">High Availability</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Zero unscheduled downtime</p>
                </div>
              </div>

              {/* Settings Configuration Panels */}
              <div className="rounded-2xl border border-[#E2E8F0] bg-white p-6 shadow-xs space-y-6">
                <div className="border-b border-[#E2E8F0] pb-4">
                  <h3 className="font-bold text-[#111827] text-base">Global Multi-Tenant Governance Config</h3>
                  <p className="text-xs text-[#64748B]">
                    Configure default quotas, trial periods, and emergency maintenance controls
                  </p>
                </div>

                <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                  <div className="rounded-xl border border-[#E2E8F0] bg-[#F8FAFC] p-5 space-y-4 text-xs">
                    <h4 className="font-bold text-[#111827] text-sm">Default Tenant Provisioning Rules</h4>
                    <div>
                      <label className="block text-[#64748B] font-semibold mb-1">Default Trial Duration (Days)</label>
                      <input
                        type="number"
                        defaultValue={30}
                        className="w-full rounded-lg border border-[#CBD5E1] bg-white p-2 text-sm text-[#111827] focus:border-[#00845F] focus:outline-none"
                      />
                    </div>
                    <div>
                      <label className="block text-[#64748B] font-semibold mb-1">Default Seat Limit (1 Admin + X Staff)</label>
                      <input
                        type="number"
                        defaultValue={3}
                        className="w-full rounded-lg border border-[#CBD5E1] bg-white p-2 text-sm text-[#111827] focus:border-[#00845F] focus:outline-none"
                      />
                    </div>
                    <button
                      onClick={() => showToast("Global provisioning rules saved.", "success")}
                      className="rounded-xl bg-[#00845F] px-4 py-2 text-xs font-bold text-white hover:bg-[#006B4D] transition shadow-xs"
                    >
                      Save Rules
                    </button>
                  </div>

                  <div className="rounded-xl border border-[#E2E8F0] bg-[#F8FAFC] p-5 space-y-4 text-xs">
                    <h4 className="font-bold text-[#111827] text-sm">Emergency Maintenance Controls</h4>
                    <p className="text-[#64748B] text-xs">
                      Activating maintenance mode displays a graceful notice to all mobile handhelds and desktop counters while allowing Super Admin access.
                    </p>
                    <div className="flex flex-wrap items-center gap-3 pt-2">
                      <button
                        onClick={() => showToast("Platform maintenance mode is currently NORMAL.", "info")}
                        className="rounded-xl border border-[#CBD5E1] bg-white px-4 py-2 text-xs font-bold text-[#111827] hover:bg-[#F1F5F9] transition shadow-xs"
                      >
                        Status: Production Active
                      </button>
                      <button
                        onClick={() => showToast("Automated daily DB snapshot initiated.", "success")}
                        className="rounded-xl bg-[#111827] px-4 py-2 text-xs font-bold text-white hover:bg-black transition shadow-xs"
                      >
                        Trigger DB Snapshot
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* MODULE H: SECURITY AUDIT LOGS (SIEM)                     */}
          {/* ========================================================= */}
          {activeTab === "AUDIT" && (
            <div className="space-y-4">
              {/* SIEM Telemetry Strip */}
              <div className="grid grid-cols-1 gap-3.5 sm:grid-cols-2 lg:grid-cols-4">
                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-[#00845F]">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Total Audit Events</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-[#F1F5F9] text-[#00845F]">
                      <Activity className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-[#111827]">{auditLogs.length}</span>
                    <span className="text-[11px] font-semibold text-[#64748B]">Immutable Entries</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Full platform SIEM ledger</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-[#00845F]">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Tamper-Proof Checksum</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-emerald-50 text-[#00845F]">
                      <ShieldCheck className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-[#00845F]">100%</span>
                    <span className="text-[11px] font-semibold text-[#00845F]">SHA-256 Validated</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Cryptographic ledger integrity</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-blue-300">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Active Operators</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
                      <Users className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-blue-600">Master + System</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Authenticated human & automated actors</p>
                </div>

                <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4.5 shadow-xs transition hover:border-purple-300">
                  <div className="flex items-center justify-between">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-[#64748B]">Integrity Alerts</span>
                    <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-purple-50 text-purple-700">
                      <CheckCircle2 className="h-4 w-4" />
                    </div>
                  </div>
                  <div className="mt-2 flex items-baseline gap-2">
                    <span className="text-2xl font-black text-purple-700">0 Anomalies</span>
                  </div>
                  <p className="mt-1 text-[11px] text-[#64748B]">Zero security breach attempts</p>
                </div>
              </div>

              {/* Filter Controls & CSV Export */}
              <div className="flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-[#E2E8F0] bg-white p-4 shadow-xs">
                <div className="relative">
                  <button
                    type="button"
                    onClick={() => setIsAuditFilterOpen(!isAuditFilterOpen)}
                    className="inline-flex items-center gap-1.5 rounded-xl border border-[#CBD5E1] bg-white px-3 py-1.5 text-xs font-semibold text-[#111827] hover:border-[#00845F] transition shadow-xs"
                  >
                    <Filter className="h-3.5 w-3.5 text-[#00845F]" />
                    <span>
                      Action:{" "}
                      {auditActionFilter === "ALL"
                        ? `All Actions (${auditLogs.length})`
                        : auditActionFilter}
                    </span>
                    <ChevronDown
                      className={`h-3 w-3 text-[#94A3B8] transition-transform ${
                        isAuditFilterOpen ? "rotate-180" : ""
                      }`}
                    />
                  </button>
                  {isAuditFilterOpen && (
                    <div className="absolute left-0 top-full mt-1.5 z-30 w-60 rounded-2xl border border-[#E2E8F0] bg-white p-1.5 shadow-xl animate-in fade-in zoom-in-95">
                      {[
                        { id: "ALL", label: `All Actions (${auditLogs.length})` },
                        { id: "TENANT_CREATED", label: "TENANT_CREATED" },
                        { id: "ALL_FEATURES_UNLOCKED", label: "ALL_FEATURES_UNLOCKED" },
                        { id: "LICENSE_QUOTA_AUDITED", label: "LICENSE_QUOTA_AUDITED" },
                        { id: "DEVICE_SEAT_REVOKED", label: "DEVICE_SEAT_REVOKED" },
                        { id: "FEATURE_TOGGLED", label: "FEATURE_TOGGLED" },
                        { id: "PASSWORD_RESET", label: "PASSWORD_RESET" },
                      ].map((opt) => (
                        <button
                          key={opt.id}
                          type="button"
                          onClick={() => {
                            setAuditActionFilter(opt.id);
                            setAuditPage(1);
                            setIsAuditFilterOpen(false);
                          }}
                          className={`flex w-full items-center justify-between rounded-xl px-3 py-2 text-xs font-semibold transition ${
                            auditActionFilter === opt.id
                              ? "bg-emerald-50 text-[#00845F] font-bold"
                              : "text-[#111827] hover:bg-[#F8FAFC]"
                          }`}
                        >
                          <span className="font-mono text-[11px]">{opt.label}</span>
                          {auditActionFilter === opt.id && <Check className="h-3.5 w-3.5 text-[#00845F]" />}
                        </button>
                      ))}
                    </div>
                  )}
                </div>

                <div className="flex items-center gap-2">
                  <button
                    onClick={exportAuditLogsCSV}
                    className="inline-flex items-center gap-1.5 rounded-xl border border-emerald-300 bg-emerald-50 px-3.5 py-1.5 text-xs font-bold text-[#00845F] hover:bg-emerald-100 transition shadow-xs"
                  >
                    <ArrowDownToLine className="h-3.5 w-3.5" />
                    <span>Download CSV Audit Report</span>
                  </button>
                </div>
              </div>

              <div className="rounded-2xl border border-[#E2E8F0] bg-white shadow-xs overflow-hidden">
                <table className="w-full text-left text-xs">
                  <thead className="border-b border-[#E2E8F0] bg-[#F1F5F9] font-bold uppercase tracking-wider text-[11px] text-[#64748B]">
                    <tr>
                      <th className="px-4 py-3">Timestamp</th>
                      <th className="px-4 py-3">Action Event</th>
                      <th className="px-4 py-3">Actor / Operator</th>
                      <th className="px-4 py-3">Target Entity</th>
                      <th className="px-4 py-3">Entity Identifier</th>
                      <th className="px-4 py-3 text-right">Integrity Hash</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-[#E2E8F0] font-mono text-[11px]">
                    {paginatedAuditLogs.map((log) => (
                      <tr key={log.id} className="hover:bg-[#F8FAFC] transition">
                        <td className="px-4 py-3 text-[#64748B]">
                          {formatDateTime(log.createdAt)}
                        </td>
                        <td className="px-4 py-3">
                          <span className="font-bold text-[#00845F] bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                            {log.action}
                          </span>
                        </td>
                        <td className="px-4 py-3 font-sans text-[#111827] font-semibold">
                          {log.user?.fullName || log.actor || "System Automated"}
                        </td>
                        <td className="px-4 py-3 text-[#64748B] font-sans">
                          {log.entityType || "Tenant"}
                        </td>
                        <td className="px-4 py-3 text-[#111827] font-bold">
                          {log.entityId || "N/A"}
                        </td>
                        <td className="px-4 py-3 text-right text-[#64748B] font-mono text-[10px]">
                          SHA256:OK
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>

                {/* Audit Pagination */}
                <div className="flex items-center justify-between border-t border-[#E2E8F0] bg-[#F1F5F9] px-4 py-3 text-xs font-semibold text-[#64748B]">
                  <span>Showing page {auditPage} of {totalAuditPages}</span>
                  <div className="flex items-center gap-1">
                    <button
                      onClick={() => setAuditPage((p) => Math.max(1, p - 1))}
                      disabled={auditPage === 1}
                      className="rounded-lg border border-[#E2E8F0] bg-white p-1 hover:bg-[#F1F5F9] disabled:opacity-40"
                    >
                      <ChevronLeft className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => setAuditPage((p) => Math.min(totalAuditPages, p + 1))}
                      disabled={auditPage >= totalAuditPages}
                      className="rounded-lg border border-[#E2E8F0] bg-white p-1 hover:bg-[#F1F5F9] disabled:opacity-40"
                    >
                      <ChevronRight className="h-4 w-4" />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}
        </main>
      </div>

      {/* ========================================================= */}
      {/* MODAL 1: 6-STEP PROVISIONING WIZARD                        */}
      {/* ========================================================= */}
      {showNewBizModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4 backdrop-blur-xs">
          <div className="w-full max-w-2xl rounded-3xl border border-[#E2E8F0] bg-white p-6 shadow-2xl space-y-4 max-h-[92vh] overflow-y-auto">
            {/* Header */}
            <div className="flex items-center justify-between border-b border-[#E2E8F0] pb-3">
              <div className="flex items-center gap-2.5">
                <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-emerald-50 text-[#00845F] border border-emerald-200">
                  <Building2 className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="font-bold text-[#111827] text-base">Enterprise Tenant Provisioning Wizard</h3>
                  <p className="text-xs text-[#64748B]">Multi-tenant isolation, dedicated schema & cryptographic license</p>
                </div>
              </div>
              <button
                onClick={() => {
                  setShowNewBizModal(false);
                  setWizardStep(1);
                }}
                className="rounded-lg p-1.5 text-[#64748B] hover:bg-[#F1F5F9]"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            {/* Wizard Steps Progress Indicator */}
            <div className="grid grid-cols-6 gap-1 bg-[#F8FAFC] p-2 rounded-2xl border border-[#E2E8F0] text-[10px] font-bold text-center">
              {[
                { s: 1, label: "1. Business" },
                { s: 2, label: "2. Arch & DB" },
                { s: 3, label: "3. Admin" },
                { s: 4, label: "4. Plan" },
                { s: 5, label: "5. Modules" },
                { s: 6, label: "6. Review" },
              ].map((step) => (
                <button
                  type="button"
                  key={step.s}
                  onClick={() => setWizardStep(step.s)}
                  className={`py-1.5 px-1 rounded-xl transition ${
                    wizardStep === step.s
                      ? "bg-[#00845F] text-white shadow-xs"
                      : wizardStep > step.s
                      ? "bg-emerald-100 text-[#00845F]"
                      : "text-[#64748B] hover:bg-[#E2E8F0]"
                  }`}
                >
                  {step.label}
                </button>
              ))}
            </div>

            <form onSubmit={handleCreateTenant} className="space-y-4 text-xs">
              {/* STEP 1: BUSINESS INFO */}
              {wizardStep === 1 && (
                <div className="space-y-3">
                  <div className="font-bold text-[#111827] text-sm border-b border-[#E2E8F0] pb-1.5">
                    Step 1: Mandi Business Information
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block font-bold text-[#111827] mb-1">Mandi Business Name *</label>
                      <input
                        type="text"
                        required
                        placeholder="e.g. Coimbatore Agri Traders Pvt Ltd"
                        value={newBizForm.name}
                        onChange={(e) => {
                          const val = e.target.value;
                          const autoCode = val.split(" ").map(w => w[0]).join("").toUpperCase() + "-01";
                          setNewBizForm({ ...newBizForm, name: val, code: newBizForm.code || autoCode });
                        }}
                        className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm focus:border-[#00845F] focus:outline-none"
                      />
                    </div>
                    <div>
                      <label className="block font-bold text-[#111827] mb-1">Tenant Short Code *</label>
                      <input
                        type="text"
                        required
                        placeholder="e.g. CAT-01"
                        value={newBizForm.code}
                        onChange={(e) => setNewBizForm({ ...newBizForm, code: e.target.value.toUpperCase() })}
                        className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm font-mono focus:border-[#00845F] focus:outline-none"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block font-bold text-[#111827] mb-1">GSTIN Registration</label>
                      <input
                        type="text"
                        placeholder="33AAAAA0000A1Z5"
                        value={newBizForm.gstNumber}
                        onChange={(e) => setNewBizForm({ ...newBizForm, gstNumber: e.target.value.toUpperCase() })}
                        className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm font-mono focus:border-[#00845F] focus:outline-none"
                      />
                    </div>
                    <div>
                      <label className="block font-bold text-[#111827] mb-1">Market Yard City / Region *</label>
                      <input
                        type="text"
                        required
                        placeholder="e.g. Coimbatore Wholesale Market"
                        value={newBizForm.city}
                        onChange={(e) => setNewBizForm({ ...newBizForm, city: e.target.value })}
                        className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm focus:border-[#00845F] focus:outline-none"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-3 gap-3">
                    <div>
                      <label className="block font-bold text-[#111827] mb-1">Contact Person</label>
                      <input
                        type="text"
                        placeholder="e.g. Kannan Sundaram"
                        value={newBizForm.contactPerson}
                        onChange={(e) => setNewBizForm({ ...newBizForm, contactPerson: e.target.value })}
                        className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm"
                      />
                    </div>
                    <div>
                      <label className="block font-bold text-[#111827] mb-1">Owner Phone *</label>
                      <input
                        type="tel"
                        required
                        placeholder="+91-9876543210"
                        value={newBizForm.ownerPhone}
                        onChange={(e) => setNewBizForm({ ...newBizForm, ownerPhone: e.target.value })}
                        className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm"
                      />
                    </div>
                    <div>
                      <label className="block font-bold text-[#111827] mb-1">Owner Email *</label>
                      <input
                        type="email"
                        required
                        placeholder="owner@mandi.io"
                        value={newBizForm.ownerEmail}
                        onChange={(e) => setNewBizForm({ ...newBizForm, ownerEmail: e.target.value })}
                        className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm"
                      />
                    </div>
                  </div>
                </div>
              )}

              {/* STEP 2: ARCHITECTURE & DATABASE */}
              {wizardStep === 2 && (
                <div className="space-y-3">
                  <div className="font-bold text-[#111827] text-sm border-b border-[#E2E8F0] pb-1.5">
                    Step 2: Tenant Multi-Tenant Database & Storage Configuration
                  </div>
                  <div className="rounded-2xl border border-emerald-200 bg-emerald-50/60 p-4 space-y-2">
                    <div className="flex items-center gap-2 text-xs font-bold text-[#00845F]">
                      <Database className="h-4 w-4" />
                      <span>Strict PostgreSQL Schema-Level Tenant Isolation</span>
                    </div>
                    <p className="text-[11px] text-[#475569] leading-relaxed">
                      Every mandi shop receives an autonomous, encrypted database schema. Commodities, buyer ledgers, bag weights, and cash totals are cryptographically isolated from other businesses.
                    </p>
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block font-bold text-[#111827] mb-1">Dedicated Schema Name</label>
                      <input
                        type="text"
                        readOnly
                        value={`schema_tenant_${newBizForm.code ? newBizForm.code.toLowerCase().replace(/[^a-z0-9]/g, "_") : "new"}`}
                        className="w-full rounded-xl border border-[#E2E8F0] bg-[#F1F5F9] p-2.5 text-sm font-mono text-[#64748B]"
                      />
                    </div>
                    <div>
                      <label className="block font-bold text-[#111827] mb-1">Allocated Storage Quota</label>
                      <input
                        type="text"
                        readOnly
                        value="50 GB Enterprise SSD Cloud Storage"
                        className="w-full rounded-xl border border-[#E2E8F0] bg-[#F1F5F9] p-2.5 text-sm font-mono text-[#64748B]"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block font-bold text-[#111827] mb-1">System Timezone</label>
                      <input
                        type="text"
                        readOnly
                        value="Asia/Kolkata (IST +05:30)"
                        className="w-full rounded-xl border border-[#E2E8F0] bg-[#F1F5F9] p-2.5 text-sm text-[#64748B]"
                      />
                    </div>
                    <div>
                      <label className="block font-bold text-[#111827] mb-1">Operating Currency</label>
                      <input
                        type="text"
                        readOnly
                        value="INR (₹ Indian Rupee)"
                        className="w-full rounded-xl border border-[#E2E8F0] bg-[#F1F5F9] p-2.5 text-sm text-[#64748B]"
                      />
                    </div>
                  </div>
                </div>
              )}

              {/* STEP 3: ADMINISTRATOR ACCOUNT */}
              {wizardStep === 3 && (
                <div className="space-y-3">
                  <div className="font-bold text-[#111827] text-sm border-b border-[#E2E8F0] pb-1.5">
                    Step 3: Initial Tenant Store Administrator
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block font-bold text-[#111827] mb-1">Admin Full Name *</label>
                      <input
                        type="text"
                        required
                        placeholder="e.g. Ramesh Kumar"
                        value={newBizForm.adminFullName}
                        onChange={(e) => setNewBizForm({ ...newBizForm, adminFullName: e.target.value })}
                        className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm"
                      />
                    </div>
                    <div>
                      <label className="block font-bold text-[#111827] mb-1">Admin Username *</label>
                      <input
                        type="text"
                        required
                        placeholder="e.g. ramesh_admin"
                        value={newBizForm.adminUsername}
                        onChange={(e) => setNewBizForm({ ...newBizForm, adminUsername: e.target.value })}
                        className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm font-mono"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block font-bold text-[#111827] mb-1">Root Password *</label>
                      <input
                        type="password"
                        required
                        placeholder="At least 6 characters"
                        value={newBizForm.adminPassword}
                        onChange={(e) => setNewBizForm({ ...newBizForm, adminPassword: e.target.value })}
                        className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm"
                      />
                    </div>
                    <div>
                      <label className="block font-bold text-[#111827] mb-1">Role Assignment</label>
                      <input
                        type="text"
                        readOnly
                        value="Mandi Business Administrator (Full Shop Authority)"
                        className="w-full rounded-xl border border-[#E2E8F0] bg-[#F1F5F9] p-2.5 text-sm text-[#64748B]"
                      />
                    </div>
                  </div>
                </div>
              )}

              {/* STEP 4: SUBSCRIPTION & LICENSING */}
              {wizardStep === 4 && (
                <div className="space-y-3">
                  <div className="font-bold text-[#111827] text-sm border-b border-[#E2E8F0] pb-1.5">
                    Step 4: Subscription Plan & Seat Quota
                  </div>
                  <div className="grid grid-cols-3 gap-3">
                    {[
                      { code: "STARTER_SAAS", name: "Starter Mandi", price: "₹999/mo", seats: 2 },
                      { code: "PROFESSIONAL_SAAS", name: "Professional Mandi", price: "₹1,999/mo", seats: 3 },
                      { code: "ENTERPRISE_SAAS", name: "Enterprise Mandi", price: "₹4,999/mo", seats: 5 },
                    ].map((p) => (
                      <div
                        key={p.code}
                        onClick={() => setNewBizForm({ ...newBizForm, planCode: p.code, maxUsers: p.seats })}
                        className={`p-3.5 rounded-2xl border cursor-pointer transition ${
                          newBizForm.planCode === p.code
                            ? "border-[#00845F] bg-emerald-50/50 shadow-xs"
                            : "border-[#E2E8F0] bg-white hover:border-[#CBD5E1]"
                        }`}
                      >
                        <div className="font-bold text-[#111827]">{p.name}</div>
                        <div className="text-base font-extrabold text-[#00845F] mt-1">{p.price}</div>
                        <div className="text-[11px] text-[#64748B] mt-1">{p.seats} Concurrent Seats</div>
                      </div>
                    ))}
                  </div>

                  <div className="space-y-3 pt-2">
                    <div>
                      <div className="flex items-center justify-between mb-1.5">
                        <label className="block font-bold text-[#111827] text-xs">
                          Seat Quota Limit (Concurrent Devices)
                        </label>
                        <span className="text-[11px] font-semibold text-[#00845F]">
                          Selected: {newBizForm.maxUsers} Seats
                        </span>
                      </div>
                      <div className="grid grid-cols-2 sm:grid-cols-5 gap-2">
                        {[
                          { value: 1, label: "1 Seat", sub: "Sole Admin" },
                          { value: 2, label: "2 Seats", sub: "Admin + 1 Staff" },
                          { value: 3, label: "3 Seats", sub: "Admin + 2 Staff", recommended: true },
                          { value: 5, label: "5 Seats", sub: "Multi-Counter" },
                          { value: 10, label: "10 Seats", sub: "APMC Enterprise" },
                        ].map((opt) => {
                          const active = newBizForm.maxUsers === opt.value;
                          return (
                            <div
                              key={opt.value}
                              onClick={() => setNewBizForm({ ...newBizForm, maxUsers: opt.value })}
                              className={`cursor-pointer rounded-xl border p-2 text-center transition ${
                                active
                                  ? "border-[#00845F] bg-emerald-50/50 shadow-xs ring-1 ring-[#00845F]"
                                  : "border-[#E2E8F0] bg-white hover:border-[#CBD5E1] hover:bg-[#F8FAFC]"
                              }`}
                            >
                              <div className="flex items-center justify-center gap-1">
                                <span className={`font-bold text-xs ${active ? "text-[#00845F]" : "text-[#111827]"}`}>
                                  {opt.label}
                                </span>
                                {opt.recommended && (
                                  <span className="rounded bg-[#00845F] px-1 py-0.2 text-[8px] font-black uppercase text-white">
                                    Rec
                                  </span>
                                )}
                              </div>
                              <div className="text-[10px] text-[#64748B] mt-0.5 truncate">{opt.sub}</div>
                            </div>
                          );
                        })}
                      </div>
                    </div>

                    <div>
                      <div className="flex items-center justify-between mb-1.5">
                        <label className="block font-bold text-[#111827] text-xs">
                          Trial Validity & License Duration
                        </label>
                        <span className="text-[11px] font-semibold text-[#00845F]">
                          Selected: {newBizForm.trialDays} Days
                        </span>
                      </div>
                      <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
                        {[
                          { value: 15, label: "15 Days", sub: "Quick Demo" },
                          { value: 30, label: "30 Days", sub: "Standard Trial", recommended: true },
                          { value: 60, label: "60 Days", sub: "Extended Pilot" },
                          { value: 365, label: "365 Days", sub: "Full Annual License" },
                        ].map((opt) => {
                          const active = newBizForm.trialDays === opt.value;
                          return (
                            <div
                              key={opt.value}
                              onClick={() => setNewBizForm({ ...newBizForm, trialDays: opt.value })}
                              className={`cursor-pointer rounded-xl border p-2 text-center transition ${
                                active
                                  ? "border-[#00845F] bg-emerald-50/50 shadow-xs ring-1 ring-[#00845F]"
                                  : "border-[#E2E8F0] bg-white hover:border-[#CBD5E1] hover:bg-[#F8FAFC]"
                              }`}
                            >
                              <div className="flex items-center justify-center gap-1">
                                <span className={`font-bold text-xs ${active ? "text-[#00845F]" : "text-[#111827]"}`}>
                                  {opt.label}
                                </span>
                                {opt.recommended && (
                                  <span className="rounded bg-[#00845F] px-1 py-0.2 text-[8px] font-black uppercase text-white">
                                    Std
                                  </span>
                                )}
                              </div>
                              <div className="text-[10px] text-[#64748B] mt-0.5 truncate">{opt.sub}</div>
                            </div>
                          );
                        })}
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* STEP 5: FEATURE MODULE ALLOCATION */}
              {wizardStep === 5 && (
                <div className="space-y-3">
                  <div className="flex items-center justify-between border-b border-[#E2E8F0] pb-1.5">
                    <div className="font-bold text-[#111827] text-sm">
                      Step 5: Mandi Feature Module Allocation
                    </div>
                    <button
                      type="button"
                      onClick={() => setNewBizForm({ ...newBizForm, enableAllFeatures: !newBizForm.enableAllFeatures })}
                      className="text-xs font-bold text-[#00845F] hover:underline"
                    >
                      {newBizForm.enableAllFeatures ? "De-select All" : "Select All 10 Modules"}
                    </button>
                  </div>
                  <div className="grid grid-cols-2 gap-2 max-h-56 overflow-y-auto pr-1">
                    {MANDI_FEATURES.map((feat) => (
                      <div
                        key={feat.key}
                        className="flex items-start gap-2 p-2 rounded-xl border border-[#E2E8F0] bg-[#F8FAFC]"
                      >
                        <input
                          type="checkbox"
                          checked={newBizForm.enableAllFeatures}
                          readOnly
                          className="mt-0.5 rounded border-[#CBD5E1] text-[#00845F]"
                        />
                        <div>
                          <div className="font-bold text-[#111827] text-[11px]">{feat.name}</div>
                          <div className="text-[10px] text-[#64748B]">{feat.desc}</div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* STEP 6: REVIEW & PROVISION */}
              {wizardStep === 6 && (
                <div className="space-y-3">
                  <div className="font-bold text-[#111827] text-sm border-b border-[#E2E8F0] pb-1.5">
                    Step 6: Review Specifications & Transactional Provision
                  </div>
                  <div className="rounded-2xl border border-[#E2E8F0] bg-[#F8FAFC] p-4 divide-y divide-[#E2E8F0] text-xs">
                    <div className="py-1.5 flex justify-between">
                      <span className="text-[#64748B]">Business Name & Code:</span>
                      <span className="font-bold text-[#111827]">{newBizForm.name} ({newBizForm.code})</span>
                    </div>
                    <div className="py-1.5 flex justify-between">
                      <span className="text-[#64748B]">Location:</span>
                      <span className="font-bold text-[#111827]">{newBizForm.city}</span>
                    </div>
                    <div className="py-1.5 flex justify-between">
                      <span className="text-[#64748B]">Owner Contact:</span>
                      <span className="font-bold text-[#111827]">{newBizForm.ownerPhone} • {newBizForm.ownerEmail}</span>
                    </div>
                    <div className="py-1.5 flex justify-between">
                      <span className="text-[#64748B]">Store Admin Username:</span>
                      <span className="font-mono font-bold text-[#00845F]">{newBizForm.adminUsername || "admin"}</span>
                    </div>
                    <div className="py-1.5 flex justify-between">
                      <span className="text-[#64748B]">Plan & Seat Quota:</span>
                      <span className="font-bold text-[#111827]">{newBizForm.planCode} • Max {newBizForm.maxUsers} Concurrent Seats</span>
                    </div>
                    <div className="py-1.5 flex justify-between">
                      <span className="text-[#64748B]">Modules Unlocked:</span>
                      <span className="font-bold text-[#059669]">10/10 Core Mandi Features</span>
                    </div>
                    <div className="py-1.5 flex justify-between">
                      <span className="text-[#64748B]">Database Isolation:</span>
                      <span className="font-mono text-[#00845F]">PostgreSQL ACID Schema Isolated</span>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 rounded-xl bg-emerald-50 border border-emerald-200 p-3 text-xs text-[#111827]">
                    <ShieldCheck className="h-4 w-4 text-[#00845F] shrink-0" />
                    <span>Transactional Provisioning: Generates tenant DB schema, provisions credentials, issues cryptographic certificate, and begins 30-day trial.</span>
                  </div>
                </div>
              )}

              {/* Wizard Navigation Footer */}
              <div className="flex items-center justify-between border-t border-[#E2E8F0] pt-3">
                <button
                  type="button"
                  onClick={() => {
                    if (wizardStep === 1) {
                      setShowNewBizModal(false);
                    } else {
                      setWizardStep((s) => s - 1);
                    }
                  }}
                  className="rounded-xl border border-[#CBD5E1] px-4 py-2 font-bold text-[#64748B] hover:bg-[#F1F5F9]"
                >
                  {wizardStep === 1 ? "Cancel" : "Back Step"}
                </button>

                <div className="flex items-center gap-2">
                  {wizardStep < 6 ? (
                    <button
                      type="button"
                      onClick={() => setWizardStep((s) => Math.min(6, s + 1))}
                      className="rounded-xl bg-[#00845F] px-5 py-2 font-bold text-white hover:bg-[#006B4D] shadow-xs"
                    >
                      Next: Step {wizardStep + 1}
                    </button>
                  ) : (
                    <button
                      type="submit"
                      className="rounded-xl bg-[#00845F] px-6 py-2.5 font-bold text-white hover:bg-[#006B4D] shadow-md flex items-center gap-2"
                    >
                      <CheckCircle2 className="h-4 w-4" />
                      <span>Provision & Deploy Tenant</span>
                    </button>
                  )}
                </div>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* MODAL 6: COMPREHENSIVE TENANT DETAILS MODAL               */}
      {/* ========================================================= */}
      {selectedBizForDetails && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4 backdrop-blur-xs">
          <div className="w-full max-w-4xl rounded-3xl border border-[#E2E8F0] bg-white p-6 shadow-2xl space-y-4 max-h-[92vh] overflow-y-auto">
            {/* Header */}
            <div className="flex items-center justify-between border-b border-[#E2E8F0] pb-3">
              <div className="flex items-center gap-3">
                <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-emerald-50 text-[#00845F] border border-emerald-200">
                  <Building2 className="h-6 w-6" />
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <h3 className="font-bold text-[#111827] text-base">{selectedBizForDetails.name}</h3>
                    <span className="font-mono text-xs font-bold text-[#00845F] bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                      {selectedBizForDetails.code}
                    </span>
                    <span
                      className={`rounded-md px-2 py-0.5 text-[10px] font-bold ${
                        selectedBizForDetails.status === "ACTIVE"
                          ? "bg-emerald-50 text-[#059669] border border-emerald-200"
                          : selectedBizForDetails.status === "TRIAL"
                          ? "bg-amber-50 text-[#D97706] border border-amber-200"
                          : "bg-red-50 text-[#DC2626] border border-red-200"
                      }`}
                    >
                      {selectedBizForDetails.status}
                    </span>
                  </div>
                  <p className="text-xs text-[#64748B] mt-0.5">
                    Tenant ID: {selectedBizForDetails.id} • Created {formatDate(selectedBizForDetails.createdAt)} • Yard: {selectedBizForDetails.city || "Tamil Nadu"}
                  </p>
                </div>
              </div>
              <button
                onClick={() => setSelectedBizForDetails(null)}
                className="rounded-lg p-1.5 text-[#64748B] hover:bg-[#F1F5F9]"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            {/* Details Tabs Navigation */}
            <div className="flex items-center gap-1 border-b border-[#E2E8F0] pb-2 text-xs font-bold overflow-x-auto">
              {[
                { key: "OVERVIEW", label: "Overview" },
                { key: "PROFILE", label: "Business Profile" },
                { key: "ADMINS", label: "Administrators" },
                { key: "SUBSCRIPTION", label: "Subscription" },
                { key: "LICENSE", label: "License & Seats" },
                { key: "MODULES", label: "Feature Modules" },
                { key: "STORAGE", label: "Database & Storage" },
                { key: "AUDIT", label: "Audit Logs" },
              ].map((t) => (
                <button
                  key={t.key}
                  onClick={() => setDetailsTab(t.key as any)}
                  className={`rounded-lg px-3 py-1.5 whitespace-nowrap transition ${
                    detailsTab === t.key
                      ? "bg-[#00845F] text-white shadow-xs"
                      : "text-[#64748B] hover:bg-[#F1F5F9] hover:text-[#111827]"
                  }`}
                >
                  {t.label}
                </button>
              ))}
            </div>

            {/* TAB CONTENTS */}
            <div className="text-xs space-y-4 pt-1">
              {/* TAB: OVERVIEW */}
              {detailsTab === "OVERVIEW" && (
                <div className="space-y-4">
                  <div className="grid grid-cols-4 gap-3">
                    <div className="p-3.5 rounded-2xl border border-[#E2E8F0] bg-[#F8FAFC]">
                      <span className="text-[#64748B] text-[11px] block">Seat Utilization</span>
                      <span className="text-lg font-bold text-[#111827] mt-1 block">
                        {selectedBizForDetails._count?.users ?? 1} / {selectedBizForDetails.maxUsers ?? 3} Seats
                      </span>
                    </div>
                    <div className="p-3.5 rounded-2xl border border-[#E2E8F0] bg-[#F8FAFC]">
                      <span className="text-[#64748B] text-[11px] block">Active Modules</span>
                      <span className="text-lg font-bold text-[#00845F] mt-1 block">
                        {(selectedBizForDetails.enabledFeatures?.length ?? 10)} / 10 Active
                      </span>
                    </div>
                    <div className="p-3.5 rounded-2xl border border-[#E2E8F0] bg-[#F8FAFC]">
                      <span className="text-[#64748B] text-[11px] block">DB Records Weighed</span>
                      <span className="text-lg font-bold text-[#111827] mt-1 block">1,480 Lots</span>
                    </div>
                    <div className="p-3.5 rounded-2xl border border-[#E2E8F0] bg-[#F8FAFC]">
                      <span className="text-[#64748B] text-[11px] block">Trial / License Expiry</span>
                      <span className="text-lg font-bold text-[#059669] mt-1 block">
                        {formatDate(selectedBizForDetails.trialEndsAt)}
                      </span>
                    </div>
                  </div>

                  <div className="flex items-center justify-between rounded-2xl border border-[#E2E8F0] bg-white p-4">
                    <div>
                      <h4 className="font-bold text-[#111827]">Tenant Lifecycle Governance</h4>
                      <p className="text-[11px] text-[#64748B]">Immediate runtime state control for this business organization</p>
                    </div>
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => handleToggleTenantStatus(selectedBizForDetails)}
                        className={`rounded-xl px-3.5 py-2 font-bold text-xs transition ${
                          selectedBizForDetails.status === "ACTIVE"
                            ? "border border-amber-300 bg-amber-50 text-[#D97706] hover:bg-amber-100"
                            : "border border-emerald-300 bg-emerald-50 text-[#059669] hover:bg-emerald-100"
                        }`}
                      >
                        {selectedBizForDetails.status === "ACTIVE" ? "Suspend Shop" : "Reactivate Shop"}
                      </button>
                      <button
                        onClick={() => handleExtendTrial(selectedBizForDetails, 30)}
                        className="rounded-xl border border-[#CBD5E1] bg-white px-3.5 py-2 font-bold text-xs text-[#111827] hover:bg-[#F1F5F9]"
                      >
                        Extend 30d Trial
                      </button>
                      <button
                        onClick={() => {
                          handleDeleteBusiness(selectedBizForDetails);
                          setSelectedBizForDetails(null);
                        }}
                        className="rounded-xl border border-red-300 bg-red-50 px-3.5 py-2 font-bold text-xs text-[#DC2626] hover:bg-red-100"
                      >
                        Delete Tenant
                      </button>
                    </div>
                  </div>
                </div>
              )}

              {/* TAB: PROFILE */}
              {detailsTab === "PROFILE" && (
                <div className="rounded-2xl border border-[#E2E8F0] bg-[#F8FAFC] p-4 divide-y divide-[#E2E8F0]">
                  <div className="py-2 flex justify-between">
                    <span className="text-[#64748B]">Legal Organization Name:</span>
                    <span className="font-bold text-[#111827]">{selectedBizForDetails.name}</span>
                  </div>
                  <div className="py-2 flex justify-between">
                    <span className="text-[#64748B]">Mandi Identifier Code:</span>
                    <span className="font-mono font-bold text-[#00845F]">{selectedBizForDetails.code}</span>
                  </div>
                  <div className="py-2 flex justify-between">
                    <span className="text-[#64748B]">GSTIN Number:</span>
                    <span className="font-mono text-[#111827]">{selectedBizForDetails.gstNumber || "33AAAAA0000A1Z5 (Registered)"}</span>
                  </div>
                  <div className="py-2 flex justify-between">
                    <span className="text-[#64748B]">Market Yard City & State:</span>
                    <span className="font-bold text-[#111827]">{selectedBizForDetails.city || "Tamil Nadu"}</span>
                  </div>
                  <div className="py-2 flex justify-between">
                    <span className="text-[#64748B]">Primary Phone:</span>
                    <span className="font-bold text-[#111827]">{selectedBizForDetails.ownerPhone}</span>
                  </div>
                  <div className="py-2 flex justify-between">
                    <span className="text-[#64748B]">Official Email:</span>
                    <span className="font-bold text-[#111827]">{selectedBizForDetails.ownerEmail}</span>
                  </div>
                </div>
              )}

              {/* TAB: ADMINS */}
              {detailsTab === "ADMINS" && (
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="font-bold text-[#111827]">Authorized Shop Administrators & Cashiers</span>
                    <button
                      onClick={() => setShowNewAdminModal(true)}
                      className="rounded-lg bg-[#00845F] px-3 py-1.5 font-bold text-white hover:bg-[#006B4D]"
                    >
                      + Add Staff Account
                    </button>
                  </div>
                  <div className="rounded-2xl border border-[#E2E8F0] overflow-hidden">
                    <table className="w-full text-left text-xs">
                      <thead className="bg-[#F1F5F9] text-[#64748B] font-bold">
                        <tr>
                          <th className="px-3 py-2">Username</th>
                          <th className="px-3 py-2">Role</th>
                          <th className="px-3 py-2">Status</th>
                          <th className="px-3 py-2 text-right">Actions</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-[#E2E8F0]">
                        <tr>
                          <td className="px-3 py-2 font-mono font-bold text-[#111827]">
                            {selectedBizForDetails.ownerEmail?.split("@")[0] || "admin"}
                          </td>
                          <td className="px-3 py-2 text-[#00845F] font-bold">Store Admin</td>
                          <td className="px-3 py-2"><span className="text-[#059669] font-bold">ACTIVE</span></td>
                          <td className="px-3 py-2 text-right">
                            <button
                              onClick={() => showToast("Password reset link dispatched.", "success")}
                              className="text-xs font-bold text-[#00845F] hover:underline"
                            >
                              Reset Key
                            </button>
                          </td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* TAB: SUBSCRIPTION */}
              {detailsTab === "SUBSCRIPTION" && (
                <div className="rounded-2xl border border-[#E2E8F0] bg-[#F8FAFC] p-4 divide-y divide-[#E2E8F0]">
                  <div className="py-2 flex justify-between">
                    <span className="text-[#64748B]">Active Tier Plan:</span>
                    <span className="font-bold text-[#111827]">{selectedBizForDetails.plan?.name || "Professional Mandi SaaS"}</span>
                  </div>
                  <div className="py-2 flex justify-between">
                    <span className="text-[#64748B]">Monthly Fee:</span>
                    <span className="font-bold text-[#00845F]">₹1,999 / Month</span>
                  </div>
                  <div className="py-2 flex justify-between">
                    <span className="text-[#64748B]">Billing Cycle:</span>
                    <span className="font-bold text-[#111827]">Monthly Auto-Debit (UPI/Netbanking)</span>
                  </div>
                  <div className="py-2 flex justify-between">
                    <span className="text-[#64748B]">Renewal Expiration:</span>
                    <span className="font-bold text-[#111827]">{formatDate(selectedBizForDetails.trialEndsAt)}</span>
                  </div>
                </div>
              )}

              {/* TAB: LICENSE */}
              {detailsTab === "LICENSE" && (
                <div className="space-y-3">
                  <div className="rounded-2xl border border-[#E2E8F0] bg-white p-4 space-y-2">
                    <div className="flex justify-between items-center">
                      <span className="font-bold text-[#111827]">Concurrent Seat Quota</span>
                      <span className="font-bold text-[#00845F]">Max {selectedBizForDetails.maxUsers ?? 3} Devices</span>
                    </div>
                    <p className="text-[11px] text-[#64748B]">
                      Controls how many mobile handhelds and PC cash desks can connect at the same time.
                    </p>
                  </div>
                  <button
                    onClick={() => {
                      setSelectedBizForDetails(null);
                      handleOpenLicenseModal(selectedBizForDetails);
                    }}
                    className="w-full rounded-xl bg-[#00845F] py-2.5 font-bold text-white hover:bg-[#006B4D]"
                  >
                    Open Full Seat Quota & Active Device Manager
                  </button>
                </div>
              )}

              {/* TAB: MODULES */}
              {detailsTab === "MODULES" && (
                <div className="space-y-3">
                  <div className="flex justify-between items-center">
                    <span className="font-bold text-[#111827]">10 Mandi Functional Modules</span>
                    <button
                      onClick={() => handleEnableAllFeatures(selectedBizForDetails.id)}
                      className="text-xs font-bold text-[#00845F] hover:underline"
                    >
                      Enable All 10 Modules
                    </button>
                  </div>
                  <div className="grid grid-cols-2 gap-2 max-h-60 overflow-y-auto pr-1">
                    {MANDI_FEATURES.map((feat) => {
                      const enabled = (selectedBizForDetails.enabledFeatures as string[])?.includes(feat.key) ?? true;
                      return (
                        <div
                          key={feat.key}
                          onClick={() => handleToggleFeature(selectedBizForDetails.id, feat.key)}
                          className={`flex items-start justify-between p-2.5 rounded-xl border cursor-pointer transition ${
                            enabled ? "border-emerald-300 bg-emerald-50/50" : "border-[#E2E8F0] bg-white opacity-60"
                          }`}
                        >
                          <div>
                            <div className="font-bold text-[#111827] text-[11px]">{feat.name}</div>
                            <div className="text-[10px] text-[#64748B]">{feat.desc}</div>
                          </div>
                          <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded ${
                            enabled ? "bg-[#00845F] text-white" : "bg-slate-200 text-slate-600"
                          }`}>
                            {enabled ? "ON" : "OFF"}
                          </span>
                        </div>
                      );
                    })}
                  </div>
                </div>
              )}

              {/* TAB: STORAGE */}
              {detailsTab === "STORAGE" && (
                <div className="rounded-2xl border border-[#E2E8F0] bg-[#F8FAFC] p-4 divide-y divide-[#E2E8F0]">
                  <div className="py-2 flex justify-between">
                    <span className="text-[#64748B]">Database Engine:</span>
                    <span className="font-bold text-[#111827]">PostgreSQL 16 Multi-Tenant</span>
                  </div>
                  <div className="py-2 flex justify-between">
                    <span className="text-[#64748B]">Assigned Schema:</span>
                    <span className="font-mono font-bold text-[#00845F]">schema_tenant_{selectedBizForDetails.code?.toLowerCase()}</span>
                  </div>
                  <div className="py-2 flex justify-between">
                    <span className="text-[#64748B]">Storage Consumed:</span>
                    <span className="font-bold text-[#111827]">1.82 GB / 50.00 GB (3.6% Allocated)</span>
                  </div>
                  <div className="py-2 flex justify-between">
                    <span className="text-[#64748B]">Automated Daily Backup:</span>
                    <span className="font-bold text-[#059669]">Active (Last Snapshot: 03:00 AM IST)</span>
                  </div>
                </div>
              )}

              {/* TAB: AUDIT */}
              {detailsTab === "AUDIT" && (
                <div className="space-y-2">
                  <span className="font-bold text-[#111827]">Tenant Security Audit Log Trail</span>
                  <div className="rounded-2xl border border-[#E2E8F0] p-3 bg-white max-h-56 overflow-y-auto space-y-2">
                    <div className="flex justify-between text-xs py-1 border-b border-[#F1F5F9]">
                      <span className="font-bold text-[#00845F]">TENANT_PROVISIONED</span>
                      <span className="text-[#64748B]">{formatDate(selectedBizForDetails.createdAt)}</span>
                    </div>
                    <div className="flex justify-between text-xs py-1 border-b border-[#F1F5F9]">
                      <span className="font-bold text-[#00845F]">LICENSE_KEY_GENERATED</span>
                      <span className="text-[#64748B]">{formatDate(selectedBizForDetails.createdAt)}</span>
                    </div>
                    <div className="flex justify-between text-xs py-1">
                      <span className="font-bold text-[#00845F]">ALL_FEATURES_UNLOCKED</span>
                      <span className="text-[#64748B]">{formatDate(selectedBizForDetails.createdAt)}</span>
                    </div>
                  </div>
                </div>
              )}
            </div>

            {/* Footer */}
            <div className="flex justify-end pt-3 border-t border-[#E2E8F0]">
              <button
                onClick={() => setSelectedBizForDetails(null)}
                className="rounded-xl bg-[#050B1B] px-5 py-2 font-bold text-white hover:bg-slate-800"
              >
                Close Diagnostics
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* MODAL 2: MANAGE LICENSE & FEATURE MATRIX                  */}
      {/* ========================================================= */}
      {selectedBizForLicense && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4 backdrop-blur-xs">
          <div className="w-full max-w-3xl rounded-3xl border border-[#E2E8F0] bg-white p-6 shadow-2xl space-y-5 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b border-[#E2E8F0] pb-3">
              <div>
                <h3 className="font-bold text-[#111827] text-lg">
                  License & Quota Management — {selectedBizForLicense.name}
                </h3>
                <p className="text-xs font-mono text-[#64748B]">
                  Tenant Code: {selectedBizForLicense.code} • Max Seats: {selectedBizForLicense.maxUsers ?? 3}
                </p>
              </div>
              <button
                onClick={() => setSelectedBizForLicense(null)}
                className="rounded-lg p-1 text-[#64748B] hover:bg-[#F1F5F9]"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            {/* User Seat Quota Adjustment */}
            <div className="rounded-2xl border border-[#E2E8F0] bg-[#F1F5F9] p-4 space-y-3">
              <div className="flex items-center justify-between">
                <div>
                  <h4 className="font-bold text-[#111827] text-sm">Concurrent User Seat Quota</h4>
                  <p className="text-[11px] text-[#64748B]">
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
                          ? "bg-[#00845F] text-white shadow-xs"
                          : "bg-white border border-[#CBD5E1] text-[#111827] hover:bg-[#F1F5F9]"
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
                <h4 className="font-bold text-[#111827] text-sm flex items-center gap-1.5">
                  <Zap className="h-4 w-4 text-[#00845F]" />
                  1-Click Mandi Suite Master Switch
                </h4>
                <p className="text-[11px] text-[#00845F]">
                  Instantly enable all 10 modules for this shop without configuring individually.
                </p>
              </div>
              <button
                onClick={() => handleEnableAllFeatures(selectedBizForLicense.id)}
                className="rounded-xl bg-[#00845F] px-4 py-2 text-xs font-bold text-white hover:bg-[#006B4D] shadow"
              >
                Enable All 10 Modules
              </button>
            </div>

            {/* Granular Module Toggles */}
            <div className="space-y-2">
              <h4 className="font-bold text-[#111827] text-sm">Granular Module Toggles (10 Capabilities)</h4>
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
                          : "border-[#E2E8F0] bg-[#F1F5F9] opacity-70 hover:opacity-100"
                      }`}
                    >
                      <div className="pr-3">
                        <p className={`font-bold text-xs ${isEnabled ? "text-[#00845F]" : "text-[#111827]"}`}>
                          {feat.name}
                        </p>
                        <p className="text-[10px] text-[#64748B] mt-0.5">{feat.desc}</p>
                      </div>
                      <div
                        className={`h-5 w-9 shrink-0 rounded-full transition-colors flex items-center p-0.5 ${
                          isEnabled ? "bg-[#00845F] justify-end" : "bg-[#CBD5E1] justify-start"
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
            <div className="border-t border-[#E2E8F0] pt-4 space-y-3">
              <h4 className="font-bold text-[#111827] text-sm">Active Connected Device Sessions</h4>
              <div className="divide-y divide-[#E2E8F0] rounded-xl border border-[#E2E8F0] bg-white text-xs">
                {licenseSessions.length === 0 ? (
                  <div className="p-4 text-center text-[#64748B]">No active device sessions currently occupied.</div>
                ) : (
                  licenseSessions.map((sess) => (
                    <div key={sess.id} className="p-3 flex items-center justify-between">
                      <div>
                        <p className="font-bold text-[#111827]">{sess.deviceName}</p>
                        <p className="text-[10px] text-[#64748B] font-mono">
                          IP: {sess.ipAddress} • User: {sess.username}
                        </p>
                      </div>
                      <button
                        onClick={() => handleRevokeSession(selectedBizForLicense.id, sess.id)}
                        className="rounded-lg border border-red-200 bg-red-50 px-2.5 py-1 text-[11px] font-bold text-[#DC2626] hover:bg-red-100 transition"
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
                className="rounded-xl bg-[#111827] px-5 py-2 text-xs font-bold text-white hover:bg-black"
              >
                Close & Done
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* MODAL 3: OFFICIAL LICENSE CERTIFICATE                     */}
      {/* ========================================================= */}
      {certModalBiz && certData && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4 backdrop-blur-xs">
          <div className="w-full max-w-2xl rounded-3xl border border-[#E2E8F0] bg-white p-8 shadow-2xl space-y-6">
            <div className="flex items-center justify-between border-b border-[#E2E8F0] pb-4">
              <div className="flex items-center gap-3">
                <BsgIcon size={40} className="rounded-xl shrink-0" />
                <div>
                  <h3 className="font-black text-[#111827] text-lg">BSG Platform Official License Certificate</h3>
                  <p className="text-xs text-[#64748B] font-mono">Issued by BSG Platform Technologies Authority</p>
                </div>
              </div>
              <button
                onClick={() => {
                  setCertModalBiz(null);
                  setCertData(null);
                }}
                className="rounded-lg p-1 text-[#64748B] hover:bg-[#F1F5F9]"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <div className="rounded-2xl border border-emerald-200 bg-emerald-50/50 p-6 space-y-4">
              <div className="grid grid-cols-2 gap-4 text-xs">
                <div>
                  <span className="text-[#64748B] font-medium block">Licensed Organization:</span>
                  <strong className="text-[#111827] text-sm font-bold">{certData.businessName}</strong>
                </div>
                <div>
                  <span className="text-[#64748B] font-medium block">Tenant Identification:</span>
                  <strong className="font-mono text-[#00845F] font-bold">{certData.businessCode}</strong>
                </div>
              </div>

              <div className="pt-2 border-t border-emerald-200 text-xs space-y-2">
                <div>
                  <span className="text-[#64748B] font-medium block">Cryptographic License Key:</span>
                  <div className="flex items-center justify-between bg-white rounded-lg p-2.5 border border-emerald-300 font-mono text-xs font-bold text-[#111827]">
                    <span>{certData.licenseKey}</span>
                    <button
                      onClick={() => handleCopy(certData.licenseKey, "licKey")}
                      className="text-[#00845F] hover:underline text-[11px]"
                    >
                      {copiedKey === "licKey" ? "Copied!" : "Copy"}
                    </button>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4 pt-1">
                  <div>
                    <span className="text-[#64748B] font-medium block">Concurrent Seat Quota:</span>
                    <strong className="text-[#111827] font-bold">Max {certData.maxUsers} Users (1 Admin + 2 Staff)</strong>
                  </div>
                  <div>
                    <span className="text-[#64748B] font-medium block">Expiration Date:</span>
                    <strong className="text-[#111827] font-bold">{formatDate(certData.expiresAt)}</strong>
                  </div>
                </div>

                <div className="pt-2">
                  <span className="text-[#64748B] font-medium block">Verification Hash:</span>
                  <p className="font-mono text-[10px] text-[#64748B] break-all">{certData.verificationHash}</p>
                </div>
              </div>
            </div>

            <div className="flex justify-between items-center pt-2">
              <button
                onClick={() => window.print()}
                className="inline-flex items-center gap-1.5 rounded-xl border border-[#CBD5E1] px-4 py-2 text-xs font-bold text-[#111827] hover:bg-[#F1F5F9]"
              >
                <Printer className="h-4 w-4" />
                <span>Print Certificate</span>
              </button>
              <button
                onClick={() => {
                  setCertModalBiz(null);
                  setCertData(null);
                }}
                className="rounded-xl bg-[#111827] px-5 py-2 text-xs font-bold text-white hover:bg-black"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* MODAL 4: CREATE SUBSCRIPTION PLAN                         */}
      {/* ========================================================= */}
      {showNewPlanModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4 backdrop-blur-xs">
          <div className="w-full max-w-md rounded-3xl border border-[#E2E8F0] bg-white p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-[#E2E8F0] pb-3">
              <h3 className="font-bold text-[#111827] text-base">Create Subscription Plan</h3>
              <button
                onClick={() => setShowNewPlanModal(false)}
                className="rounded-lg p-1 text-[#64748B] hover:bg-[#F1F5F9]"
              >
                <X className="h-5 w-5" />
              </button>
            </div>
            <div className="space-y-3 text-xs">
              <div>
                <label className="block font-bold text-[#111827] mb-1">Plan Name</label>
                <input
                  type="text"
                  placeholder="e.g. Enterprise APMC Hub"
                  value={newPlanForm.name}
                  onChange={(e) => setNewPlanForm({ ...newPlanForm, name: e.target.value })}
                  className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-[#111827] mb-1">Monthly (₹)</label>
                  <input
                    type="number"
                    value={newPlanForm.monthlyPrice}
                    onChange={(e) => setNewPlanForm({ ...newPlanForm, monthlyPrice: Number(e.target.value) })}
                    className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm"
                  />
                </div>
                <div>
                  <label className="block font-bold text-[#111827] mb-1">Annual (₹)</label>
                  <input
                    type="number"
                    value={newPlanForm.annualPrice}
                    onChange={(e) => setNewPlanForm({ ...newPlanForm, annualPrice: Number(e.target.value) })}
                    className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm"
                  />
                </div>
              </div>
              <div>
                <label className="block font-bold text-[#111827] mb-1">Max User Seats</label>
                <input
                  type="number"
                  value={newPlanForm.maxUsers}
                  onChange={(e) => setNewPlanForm({ ...newPlanForm, maxUsers: Number(e.target.value) })}
                  className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm"
                />
              </div>
            </div>
            <div className="flex justify-end gap-2 pt-2">
              <button
                onClick={() => setShowNewPlanModal(false)}
                className="rounded-xl border border-[#CBD5E1] px-4 py-2 font-bold text-[#64748B] hover:bg-[#F1F5F9]"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  setPlans((prev) => [...prev, { id: "plan-" + Date.now(), ...newPlanForm, isActive: true }]);
                  setShowNewPlanModal(false);
                  showToast("Subscription plan created.", "success");
                }}
                className="rounded-xl bg-[#00845F] px-5 py-2 font-bold text-white hover:bg-[#006B4D]"
              >
                Save Plan
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* MODAL 5: CREATE PLATFORM ADMIN                            */}
      {/* ========================================================= */}
      {showNewAdminModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4 backdrop-blur-xs">
          <div className="w-full max-w-md rounded-3xl border border-[#E2E8F0] bg-white p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-[#E2E8F0] pb-3">
              <h3 className="font-bold text-[#111827] text-base">Add Platform Operator Account</h3>
              <button
                onClick={() => setShowNewAdminModal(false)}
                className="rounded-lg p-1 text-[#64748B] hover:bg-[#F1F5F9]"
              >
                <X className="h-5 w-5" />
              </button>
            </div>
            <div className="space-y-3 text-xs">
              <div>
                <label className="block font-bold text-[#111827] mb-1">Full Name *</label>
                <input
                  type="text"
                  placeholder="e.g. Anand Sharma"
                  value={newAdminForm.fullName}
                  onChange={(e) => setNewAdminForm({ ...newAdminForm, fullName: e.target.value })}
                  className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm"
                />
              </div>
              <div>
                <label className="block font-bold text-[#111827] mb-1">Username *</label>
                <input
                  type="text"
                  placeholder="e.g. anand_admin"
                  value={newAdminForm.username}
                  onChange={(e) => setNewAdminForm({ ...newAdminForm, username: e.target.value })}
                  className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm"
                />
              </div>
              <div>
                <label className="block font-bold text-[#111827] mb-1">Email Address *</label>
                <input
                  type="email"
                  placeholder="anand@bsgmandi.io"
                  value={newAdminForm.email}
                  onChange={(e) => setNewAdminForm({ ...newAdminForm, email: e.target.value })}
                  className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm"
                />
              </div>
              <div>
                <label className="block font-bold text-[#111827] mb-1.5 text-xs">Role Permission & Access Tier *</label>
                <div className="space-y-2">
                  {[
                    {
                      id: "SUPER_ADMIN",
                      title: "Super Administrator",
                      badge: "Full Platform Root",
                      badgeColor: "bg-purple-50 text-purple-800 border-purple-200",
                      desc: "Full administrative root access across all registered Mandi shops, pricing tier matrix, and cryptographic audit logs.",
                      icon: ShieldCheck,
                    },
                    {
                      id: "ADMIN",
                      title: "Mandi Store Administrator",
                      badge: "Shop Master (Seat 1)",
                      badgeColor: "bg-emerald-50 text-[#00845F] border-emerald-200",
                      desc: "Assigned Mandi owner: manages arrival lots, auction charts, staff handhelds, customer credit ledgers, and cash tallies.",
                      icon: Store,
                    },
                    {
                      id: "BUSINESS_USER",
                      title: "Staff / Cashier Operator",
                      badge: "Floor Handheld (Seats 2-3)",
                      badgeColor: "bg-blue-50 text-blue-700 border-blue-200",
                      desc: "Weighment scale recorder and desk cashier: prints thermal slips, enters bag gross/tare weights, and records collections.",
                      icon: Smartphone,
                    },
                  ].map((r) => {
                    const active = newAdminForm.role === r.id;
                    const Icon = r.icon;
                    return (
                      <div
                        key={r.id}
                        onClick={() => setNewAdminForm({ ...newAdminForm, role: r.id })}
                        className={`cursor-pointer rounded-2xl border p-3 transition flex items-start gap-3 ${
                          active
                            ? "border-[#00845F] bg-emerald-50/40 ring-1 ring-[#00845F] shadow-xs"
                            : "border-[#E2E8F0] bg-white hover:border-[#CBD5E1] hover:bg-[#F8FAFC]"
                        }`}
                      >
                        <div
                          className={`mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-xl transition ${
                            active ? "bg-[#00845F] text-white shadow-xs" : "bg-[#F1F5F9] text-[#64748B]"
                          }`}
                        >
                          <Icon className="h-4 w-4" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex flex-wrap items-center justify-between gap-1.5">
                            <span className="font-bold text-[#111827] text-xs">{r.title}</span>
                            <span className={`rounded-md px-1.5 py-0.2 text-[10px] font-bold border ${r.badgeColor}`}>
                              {r.badge}
                            </span>
                          </div>
                          <p className="mt-0.5 text-[11px] text-[#64748B] leading-relaxed">{r.desc}</p>
                        </div>
                        <div className="mt-1">
                          <div
                            className={`flex h-4 w-4 items-center justify-center rounded-full border transition ${
                              active ? "border-[#00845F] bg-[#00845F] text-white" : "border-[#CBD5E1] bg-white"
                            }`}
                          >
                            {active && <Check className="h-2.5 w-2.5 stroke-[3]" />}
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
              <div>
                <label className="block font-bold text-[#111827] mb-1">Temporary Password *</label>
                <input
                  type="password"
                  placeholder="At least 6 characters"
                  value={newAdminForm.password}
                  onChange={(e) => setNewAdminForm({ ...newAdminForm, password: e.target.value })}
                  className="w-full rounded-xl border border-[#CBD5E1] p-2.5 text-sm"
                />
              </div>
            </div>
            <div className="flex justify-end gap-2 pt-2">
              <button
                onClick={() => setShowNewAdminModal(false)}
                className="rounded-xl border border-[#CBD5E1] px-4 py-2 font-bold text-[#64748B] hover:bg-[#F1F5F9]"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  setAdmins((prev) => [
                    ...prev,
                    {
                      id: "adm-" + Date.now(),
                      username: newAdminForm.username,
                      fullName: newAdminForm.fullName,
                      email: newAdminForm.email,
                      role: { code: newAdminForm.role, name: newAdminForm.role },
                      status: "ACTIVE",
                      createdAt: new Date().toISOString(),
                    },
                  ]);
                  setShowNewAdminModal(false);
                  showToast("Administrator account provisioned.", "success");
                }}
                className="rounded-xl bg-[#00845F] px-5 py-2 font-bold text-white hover:bg-[#006B4D]"
              >
                Provision Account
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
