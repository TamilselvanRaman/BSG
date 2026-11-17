"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import {
  apiFetch,
  clearStoredSession,
  exportRowsToCsv,
  formatINR,
  getStoredSession,
  performDirectLogin,
} from "@/lib/api";
import { BsgIcon } from "@/components/BsgLogo";
import {
  AlertTriangle,
  BarChart3,
  BookOpen,
  Boxes,
  CheckCircle2,
  Clock,
  FileSpreadsheet,
  FileText,
  Key,
  Layers,
  LogOut,
  PackagePlus,
  Plus,
  Printer,
  RefreshCw,
  Search,
  Settings,
  ShieldCheck,
  ShoppingBag,
  Store,
  User,
  Users,
  Wallet,
} from "lucide-react";

type WorkspaceTab =
  | "DASHBOARD"
  | "SMART_CHART"
  | "GOODS_LOTS"
  | "BILL_BOOKS"
  | "PARTNERS"
  | "LEDGERS_ADVANCES"
  | "INVENTORY"
  | "REPORTS"
  | "USERS"
  | "SETTINGS";

export function BusinessWorkspace({ mode }: { mode: "ADMIN" | "EMPLOYEE" }) {
  const router = useRouter();
  const [user, setUser] = useState<any>(null);
  const [activeTab, setActiveTab] = useState<WorkspaceTab>("DASHBOARD");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [toast, setToast] = useState<string | null>(null);

  // Global search
  const [searchQuery, setSearchQuery] = useState("");
  const [searchResults, setSearchResults] = useState<any>(null);

  // Core data states
  const [dashboard, setDashboard] = useState<any>(null);
  const [buyers, setBuyers] = useState<any[]>([]);
  const [sellers, setSellers] = useState<any[]>([]);
  const [goods, setGoods] = useState<any[]>([]);
  const [lots, setLots] = useState<any[]>([]);
  const [entries, setEntries] = useState<any[]>([]);
  const [smartCharts, setSmartCharts] = useState<any[]>([]);
  const [auctions, setAuctions] = useState<any[]>([]);
  const [purchases, setPurchases] = useState<any[]>([]);
  const [sales, setSales] = useState<any[]>([]);
  const [payments, setPayments] = useState<any[]>([]);
  const [advances, setAdvances] = useState<any[]>([]);
  const [inventory, setInventory] = useState<any>(null);
  const [dailySummary, setDailySummary] = useState<any>(null);
  const [profitLoss, setProfitLoss] = useState<any>(null);
  const [employeesData, setEmployeesData] = useState<any>({ users: [], availablePermissions: [] });
  const [profileData, setProfileData] = useState<any>({ profile: {}, settings: {} });

  // Selected partner ledger
  const [selectedLedgerType, setSelectedLedgerType] = useState<"BUYER" | "SELLER">("BUYER");
  const [selectedLedgerPartnerId, setSelectedLedgerPartnerId] = useState("");
  const [ledgerData, setLedgerData] = useState<any>(null);

  // Forms
  const [billType, setBillType] = useState<"SALE" | "PURCHASE">("SALE");
  const [billStep, setBillStep] = useState<1 | 2 | 3>(1);
  const [billPartyId, setBillPartyId] = useState("");
  const [billVehicleNo, setBillVehicleNo] = useState("");
  const [billIsRmc, setBillIsRmc] = useState(false);
  const [billItems, setBillItems] = useState<
    Array<{
      goodsId: string;
      lotId?: string;
      bagsCount: number;
      grossWeight: number;
      tareWeight: number;
      unitPrice: number;
    }>
  >([{ goodsId: "", bagsCount: 1, grossWeight: 100, tareWeight: 0, unitPrice: 25 }]);
  const [billLabourCharge, setBillLabourCharge] = useState(0);
  const [billDiscount, setBillDiscount] = useState(0);
  const [billSpotPaid, setBillSpotPaid] = useState(0);
  const [billPaymentMethod, setBillPaymentMethod] = useState("CASH");

  // Goods entry form
  const [entryForm, setEntryForm] = useState({
    sellerId: "",
    goodsId: "",
    vehicleNumber: "",
    bagsCount: 10,
    grossWeight: 500,
    tareWeight: 10,
    costRate: 22,
    sellRate: 28,
  });

  // Partner form
  const [partnerRole, setPartnerRole] = useState<"BUYER" | "SELLER">("BUYER");
  const [partnerForm, setPartnerForm] = useState({
    name: "",
    phone: "",
    villageOrCity: "",
    openingBalance: 0,
  });

  // New Goods form
  const [goodsForm, setGoodsForm] = useState({
    name: "",
    categoryName: "General Commodities",
    unit: "KG",
    purchasePrice: 20,
    sellingPrice: 26,
    openingStock: 500,
    minimumStock: 50,
  });

  // Payment & Advance forms
  const [paymentForm, setPaymentForm] = useState({
    direction: "INBOUND_FROM_BUYER",
    buyerId: "",
    sellerId: "",
    amount: 1000,
    method: "CASH",
    notes: "",
  });

  const [advanceForm, setAdvanceForm] = useState({
    direction: "INBOUND_FROM_BUYER",
    buyerId: "",
    sellerId: "",
    amount: 2000,
    method: "CASH",
    notes: "",
  });

  // New Employee form
  const [empForm, setEmpForm] = useState({
    username: "",
    fullName: "",
    phone: "",
    password: "",
    roleType: "BUSINESS_USER" as "ADMIN" | "BUSINESS_USER",
    designation: "Billing Operator",
  });

  function notify(msg: string) {
    setToast(msg);
    setTimeout(() => setToast(null), 3500);
  }

  async function loadAllWorkspaceData() {
    setLoading(true);
    setError(null);
    try {
      const [
        dash,
        byr,
        slr,
        gds,
        lts,
        ent,
        sc,
        auc,
        pur,
        sls,
        pmt,
        adv,
        inv,
        dSum,
        prof,
      ] = await Promise.all([
        apiFetch("/business/dashboard"),
        apiFetch("/buyers"),
        apiFetch("/sellers"),
        apiFetch("/goods"),
        apiFetch("/goods-lots"),
        apiFetch("/goods-entries"),
        apiFetch("/smart-charts").catch(() => []),
        apiFetch("/auctions").catch(() => []),
        apiFetch("/purchases"),
        apiFetch("/sales"),
        apiFetch("/payments"),
        apiFetch("/advances"),
        apiFetch("/inventory"),
        apiFetch("/reports/daily-summary").catch(() => null),
        apiFetch("/business/profile"),
      ]);

      setDashboard(dash);
      setBuyers(byr);
      setSellers(slr);
      setGoods(gds);
      setLots(lts);
      setEntries(ent);
      setSmartCharts(sc);
      setAuctions(auc);
      setPurchases(pur);
      setSales(sls);
      setPayments(pmt);
      setAdvances(adv);
      setInventory(inv);
      setDailySummary(dSum);
      setProfileData(prof);

      if (byr.length > 0 && !billPartyId) setBillPartyId(byr[0].id);
      if (gds.length > 0 && !billItems[0].goodsId) {
        setBillItems([
          {
            goodsId: gds[0].id,
            bagsCount: 10,
            grossWeight: 500,
            tareWeight: 5,
            unitPrice: Number(gds[0].sellingPrice || 25),
          },
        ]);
      }
      if (slr.length > 0 && !entryForm.sellerId) {
        setEntryForm((prev) => ({
          ...prev,
          sellerId: slr[0].id,
          goodsId: gds[0]?.id || "",
        }));
      }

      const { user: storedUser } = getStoredSession();
      if (storedUser?.role === "ADMIN") {
        const [emp, pl] = await Promise.all([
          apiFetch("/business/users").catch(() => ({ users: [], availablePermissions: [] })),
          apiFetch("/reports/profit-loss").catch(() => null),
        ]);
        setEmployeesData(emp);
        setProfitLoss(pl);
      }
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    let { user: stored } = getStoredSession();
    if (!stored) {
      const mock = performDirectLogin(mode === "ADMIN" ? "vinayaka_admin" : "vinayaka_staff");
      stored = mock.user;
    }
    setUser(stored);
    loadAllWorkspaceData();
  }, [router, mode]);

  async function handleGlobalSearch(e: React.FormEvent) {
    e.preventDefault();
    if (!searchQuery.trim()) {
      setSearchResults(null);
      return;
    }
    try {
      const res = await apiFetch(`/business/search?q=${encodeURIComponent(searchQuery)}`);
      setSearchResults(res);
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleCreateGoodsEntry(e: React.FormEvent) {
    e.preventDefault();
    try {
      await apiFetch("/goods-entries", {
        method: "POST",
        body: JSON.stringify(entryForm),
      });
      notify("Arrival Goods Entry & Lot created.");
      loadAllWorkspaceData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleCreateSmartChart() {
    if (!goods[0]) return;
    try {
      await apiFetch("/smart-charts", {
        method: "POST",
        body: JSON.stringify({
          title: `Morning Arrival Smart Chart (${new Date().toLocaleDateString()})`,
          items: [
            {
              goodsId: goods[0].id,
              lotId: lots[0]?.id,
              sellerName: sellers[0]?.name || "Farmer",
              buyerName: buyers[0]?.name || "Buyer",
              bagsCount: 25,
              quantity: 1250,
              unit: goods[0].unit || "KG",
              rate: Number(goods[0].sellingPrice || 30),
            },
          ],
        }),
      });
      notify("Smart Chart recorded.");
      loadAllWorkspaceData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleSubmitBill(e: React.FormEvent) {
    e.preventDefault();
    try {
      if (billType === "SALE") {
        await apiFetch("/sales", {
          method: "POST",
          body: JSON.stringify({
            buyerId: billPartyId,
            vehicleNumber: billVehicleNo || undefined,
            isRmcApplicable: billIsRmc,
            labourCharge: billLabourCharge,
            discountAmount: billDiscount,
            receivedAmount: billSpotPaid,
            paymentMethod: billPaymentMethod,
            items: billItems,
          }),
        });
        notify("Sales Bill confirmed! Stock & Buyer Ledger updated.");
      } else {
        await apiFetch("/purchases", {
          method: "POST",
          body: JSON.stringify({
            sellerId: billPartyId,
            vehicleNumber: billVehicleNo || undefined,
            labourCharge: billLabourCharge,
            discountAmount: billDiscount,
            paidAmount: billSpotPaid,
            paymentMethod: billPaymentMethod,
            items: billItems,
          }),
        });
        notify("Purchase Bill confirmed! Stock & Seller Ledger updated.");
      }
      setBillStep(1);
      loadAllWorkspaceData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleCancelBill(type: "sales" | "purchases", id: string) {
    const reason = window.prompt("Enter cancellation reason (Required for audit trail):", "Rate / Weight correction");
    if (!reason) return;
    try {
      await apiFetch(`/${type}/${id}/cancel`, {
        method: "POST",
        body: JSON.stringify({ reason }),
      });
      notify("Bill cancelled and stock/ledger reversed.");
      loadAllWorkspaceData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleGeneratePdf(documentType: string, referenceId: string) {
    try {
      const doc = await apiFetch<{ id: string; downloadUrl: string }>("/documents/pdf", {
        method: "POST",
        body: JSON.stringify({ documentType, referenceId }),
      });
      const baseUrl = (process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:4000/api/v1").replace(
        "/api/v1",
        ""
      );
      window.open(`${baseUrl}${doc.downloadUrl}`, "_blank");
      notify("Branded PDF generated.");
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleCreatePartner(e: React.FormEvent) {
    e.preventDefault();
    try {
      const endpoint = partnerRole === "BUYER" ? "/buyers" : "/sellers";
      await apiFetch(endpoint, {
        method: "POST",
        body: JSON.stringify(partnerForm),
      });
      setPartnerForm({ name: "", phone: "", villageOrCity: "", openingBalance: 0 });
      notify(`${partnerRole} added.`);
      loadAllWorkspaceData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleCreateGoods(e: React.FormEvent) {
    e.preventDefault();
    try {
      await apiFetch("/goods", {
        method: "POST",
        body: JSON.stringify(goodsForm),
      });
      setGoodsForm({
        name: "",
        categoryName: "General Commodities",
        unit: "KG",
        purchasePrice: 20,
        sellingPrice: 26,
        openingStock: 500,
        minimumStock: 50,
      });
      notify("Goods item added to catalog.");
      loadAllWorkspaceData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleLoadLedger(type: "BUYER" | "SELLER", id: string) {
    if (!id) return;
    setSelectedLedgerType(type);
    setSelectedLedgerPartnerId(id);
    try {
      const endpoint = type === "BUYER" ? `/buyers/${id}/ledger` : `/sellers/${id}/ledger`;
      const data = await apiFetch(endpoint);
      setLedgerData(data);
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleCreatePayment(e: React.FormEvent) {
    e.preventDefault();
    try {
      await apiFetch("/payments", {
        method: "POST",
        body: JSON.stringify({
          direction: paymentForm.direction,
          buyerId:
            paymentForm.direction === "INBOUND_FROM_BUYER" ? paymentForm.buyerId : undefined,
          sellerId:
            paymentForm.direction === "OUTBOUND_TO_SELLER" ? paymentForm.sellerId : undefined,
          amount: paymentForm.amount,
          method: paymentForm.method,
          notes: paymentForm.notes,
        }),
      });
      notify("Payment settled and ledger updated.");
      loadAllWorkspaceData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleCreateAdvance(e: React.FormEvent) {
    e.preventDefault();
    try {
      await apiFetch("/advances", {
        method: "POST",
        body: JSON.stringify({
          direction: advanceForm.direction,
          buyerId:
            advanceForm.direction === "INBOUND_FROM_BUYER" ? advanceForm.buyerId : undefined,
          sellerId:
            advanceForm.direction === "OUTBOUND_TO_SELLER" ? advanceForm.sellerId : undefined,
          amount: advanceForm.amount,
          method: advanceForm.method,
          notes: advanceForm.notes,
        }),
      });
      notify("Partner advance recorded.");
      loadAllWorkspaceData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleCreateEmployee(e: React.FormEvent) {
    e.preventDefault();
    try {
      await apiFetch("/business/users", {
        method: "POST",
        body: JSON.stringify({
          ...empForm,
          designation:
            empForm.designation ||
            (empForm.roleType === "ADMIN" ? "Sub Admin / Manager" : "Billing Operator"),
          permissions:
            empForm.roleType === "ADMIN"
              ? [
                  "partners:read",
                  "partners:write",
                  "goods:read",
                  "goods:write",
                  "lots:read",
                  "lots:write",
                  "smart_chart:read",
                  "smart_chart:write",
                  "purchases:read",
                  "purchases:write",
                  "sales:read",
                  "sales:write",
                  "payments:read",
                  "payments:write",
                  "inventory:read",
                  "inventory:adjust",
                  "ledgers:read",
                  "ledgers:export",
                  "reports:read",
                  "reports:profit_loss",
                  "reports:export",
                  "documents:generate",
                ]
              : [
                  "partners:read",
                  "goods:read",
                  "lots:read",
                  "lots:write",
                  "smart_chart:read",
                  "smart_chart:write",
                  "purchases:read",
                  "purchases:write",
                  "sales:read",
                  "sales:write",
                  "payments:read",
                  "inventory:read",
                  "documents:generate",
                ],
        }),
      });
      const createdRole = empForm.roleType;
      setEmpForm({
        username: "",
        fullName: "",
        phone: "",
        password: "",
        roleType: "BUSINESS_USER",
        designation: "Billing Operator",
      });
      notify(
        createdRole === "ADMIN"
          ? "Sub Admin created with full access to all 10 features."
          : "Staff / Cashier account created."
      );
      loadAllWorkspaceData();
    } catch (err: any) {
      setError(err.message);
    }
  }

  async function handleSaveBusinessProfile(e: React.FormEvent) {
    e.preventDefault();
    try {
      await apiFetch("/business/profile", {
        method: "PATCH",
        body: JSON.stringify(profileData),
      });
      notify("Business profile & customization saved.");
    } catch (err: any) {
      setError(err.message);
    }
  }

  // Live preview calculation for 3-step bill wizard
  const previewSubtotal = billItems.reduce((sum, i) => {
    const net = Math.max(0, Number(i.grossWeight) - Number(i.tareWeight));
    return sum + net * Number(i.unitPrice);
  }, 0);
  const previewRmc = billType === "SALE" && billIsRmc ? previewSubtotal * 0.01 : 0;
  const previewGrandTotal = Math.max(
    0,
    previewSubtotal + Number(billLabourCharge) + previewRmc - Number(billDiscount)
  );
  const previewDue = Math.max(0, previewGrandTotal - Number(billSpotPaid));

  const m = dashboard?.metrics || {};

  return (
    <div className="flex min-h-screen bg-slate-100">
      {/* Sidebar */}
      <aside className="flex w-64 flex-col bg-slate-900 text-slate-200">
        <div className="border-b border-slate-800 px-5 py-4">
          <div className="flex items-center gap-3 text-white">
            <BsgIcon size={36} className="rounded-xl shadow-sm shrink-0" />
            <div className="min-w-0">
              <span className="block text-sm font-bold truncate">
                {user?.tenantName || "BSG Mandi Workspace"}
              </span>
              <span className="block text-[11px] text-emerald-400 font-semibold">
                {mode === "ADMIN" ? "BSG Sub Admin Portal" : "BSG Staff Cashier"}
              </span>
            </div>
          </div>
        </div>

        <nav className="flex-1 space-y-1 p-3 text-xs font-medium">
          {[
            { id: "DASHBOARD", label: "A. Main Dashboard & mOS", icon: BarChart3 },
            { id: "SMART_CHART", label: "B. Smart Chart & Auctions", icon: Layers },
            { id: "GOODS_LOTS", label: "C. Goods & Lot Entries", icon: PackagePlus },
            { id: "BILL_BOOKS", label: "D. Purchase & Sales Bills", icon: BookOpen },
            { id: "PARTNERS", label: "E. Buyers & Sellers", icon: Users },
            { id: "LEDGERS_ADVANCES", label: "F. Ledgers & Advances", icon: Wallet },
            { id: "INVENTORY", label: "G. Inventory & Stock", icon: Boxes },
            { id: "REPORTS", label: "H. Reports & Daily Summary", icon: FileSpreadsheet },
            ...(mode === "ADMIN"
              ? [
                  { id: "USERS", label: "I. Employees & RBAC", icon: ShoppingBag },
                  { id: "SETTINGS", label: "J. Settings & Customization", icon: Settings },
                ]
              : []),
          ].map((item) => {
            const Icon = item.icon;
            const active = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id as WorkspaceTab)}
                className={`flex w-full items-center gap-2.5 rounded-lg px-3 py-2.5 transition ${
                  active
                    ? "bg-emerald-600 text-white shadow-xs"
                    : "text-slate-300 hover:bg-slate-800 hover:text-white"
                }`}
              >
                <Icon className="h-4 w-4 shrink-0" />
                <span className="truncate">{item.label}</span>
              </button>
            );
          })}
        </nav>

        <div className="border-t border-slate-800 p-4">
          <div className="mb-2 text-xs text-slate-400">
            Signed in as <strong className="text-white">{user?.username}</strong>
          </div>
          <button
            onClick={() => {
              clearStoredSession();
              router.push("/login");
            }}
            className="flex w-full items-center justify-center gap-2 rounded-lg bg-slate-800 px-3 py-2 text-xs font-semibold text-slate-200 hover:bg-red-600 hover:text-white"
          >
            <LogOut className="h-3.5 w-3.5" />
            Sign Out
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="flex flex-1 flex-col">
        {/* Top Bar with Global Search & Quick Actions */}
        <header className="flex flex-wrap items-center justify-between gap-4 border-b border-slate-200 bg-white px-6 py-3.5">
          <div className="flex items-center gap-4">
            <form onSubmit={handleGlobalSearch} className="relative flex w-72 lg:w-80 items-center">
              <Search className="absolute left-3 h-4 w-4 text-slate-400" />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search buyer, seller, phone, bill #, lot #..."
                className="w-full rounded-lg border border-slate-300 py-1.5 pl-9 pr-3 text-xs focus:border-emerald-600 focus:ring-1 focus:ring-emerald-600 focus:outline-none"
              />
            </form>

            {/* Trial & License Badge */}
            {profileData?.tenant?.status === "TRIAL" || employeesData?.trialEndsAt ? (
              <div className="hidden sm:flex items-center gap-2 rounded-lg bg-amber-50 border border-amber-200 px-2.5 py-1 text-xs font-semibold text-amber-800 shadow-sm">
                <span className="h-2 w-2 rounded-full bg-amber-500" />
                <span>
                  Free Trial:{" "}
                  {Math.max(
                    0,
                    Math.ceil(
                      (new Date(
                        profileData?.tenant?.trialEndsAt || employeesData?.trialEndsAt || Date.now()
                      ).getTime() -
                        Date.now()) /
                        (1000 * 60 * 60 * 24)
                    )
                  )}{" "}
                  Days Left
                </span>
                <span className="rounded bg-amber-200/80 px-1.5 py-0.5 text-[10px] font-bold text-amber-900">
                  All 10 Features Active
                </span>
              </div>
            ) : (
              <div className="hidden sm:flex items-center gap-1.5 rounded-full bg-emerald-50 border border-emerald-200 px-3 py-1 text-xs font-semibold text-emerald-800 shadow-sm">
                <ShieldCheck className="h-3.5 w-3.5 text-emerald-600" />
                <span>Licensed Shop</span>
                <span className="rounded bg-emerald-100 px-1.5 py-0.5 text-[10px] text-emerald-800">
                  Max 3 Users
                </span>
              </div>
            )}
          </div>

          {/* Quick Actions Bar (Spec Section A) */}
          <div className="flex flex-wrap items-center gap-2">
            <button
              onClick={() => setActiveTab("GOODS_LOTS")}
              className="rounded-lg border border-slate-300 bg-white px-3 py-1.5 text-xs font-semibold text-slate-700 hover:bg-slate-50"
            >
              + Arrival Entry
            </button>
            <button
              onClick={() => {
                setBillType("SALE");
                setActiveTab("BILL_BOOKS");
              }}
              className="rounded-lg bg-emerald-700 px-3 py-1.5 text-xs font-semibold text-white hover:bg-emerald-800"
            >
              + Sales Bill
            </button>
            <button
              onClick={() => {
                setBillType("PURCHASE");
                setActiveTab("BILL_BOOKS");
              }}
              className="rounded-lg bg-slate-900 px-3 py-1.5 text-xs font-semibold text-white hover:bg-slate-800"
            >
              + Purchase Bill
            </button>
            <button
              onClick={loadAllWorkspaceData}
              className="rounded-lg border border-slate-300 p-1.5 text-slate-600 hover:bg-slate-50"
              title="Refresh Workspace"
            >
              <RefreshCw className="h-4 w-4" />
            </button>
          </div>
        </header>

        {/* Global Search Results Drawer */}
        {searchResults && (
          <div className="mx-6 mt-4 rounded-xl border border-emerald-200 bg-emerald-50/70 p-4 text-xs">
            <div className="flex items-center justify-between">
              <span className="font-bold text-slate-900">
                Global Search Results for &ldquo;{searchQuery}&rdquo;
              </span>
              <button
                onClick={() => setSearchResults(null)}
                className="font-semibold text-emerald-800 hover:underline"
              >
                Close
              </button>
            </div>
            <div className="mt-2 grid gap-3 sm:grid-cols-4">
              <div>
                <p className="font-semibold text-slate-700">Buyers ({searchResults.buyers?.length})</p>
                {searchResults.buyers?.map((b: any) => (
                  <p key={b.id} className="text-slate-600">{b.name} ({b.phone})</p>
                ))}
              </div>
              <div>
                <p className="font-semibold text-slate-700">Sellers ({searchResults.sellers?.length})</p>
                {searchResults.sellers?.map((s: any) => (
                  <p key={s.id} className="text-slate-600">{s.name} ({s.phone})</p>
                ))}
              </div>
              <div>
                <p className="font-semibold text-slate-700">Lots ({searchResults.lots?.length})</p>
                {searchResults.lots?.map((l: any) => (
                  <p key={l.id} className="text-slate-600">{l.lotNumber} — {l.goods?.name}</p>
                ))}
              </div>
              <div>
                <p className="font-semibold text-slate-700">
                  Bills ({(searchResults.salesBills?.length || 0) + (searchResults.purchaseBills?.length || 0)})
                </p>
                {searchResults.salesBills?.map((sb: any) => (
                  <p key={sb.id} className="text-slate-600">{sb.billNumber} ({sb.buyer?.name})</p>
                ))}
              </div>
            </div>
          </div>
        )}

        {toast && (
          <div className="mx-6 mt-4 rounded-lg bg-emerald-600 px-4 py-2.5 text-xs font-semibold text-white shadow">
            {toast}
          </div>
        )}
        {error && (
          <div className="mx-6 mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-2.5 text-xs font-medium text-red-700">
            {error}
          </div>
        )}

        <main className="flex-1 p-6">
          {loading ? (
            <div className="rounded-xl border border-slate-200 bg-white p-12 text-center text-sm text-slate-500">
              Loading tenant workspace data...
            </div>
          ) : (
            <>
              {/* ============================================================
                  SECTION A: MAIN DASHBOARD & mOS OVERVIEW
                 ============================================================ */}
              {activeTab === "DASHBOARD" && (
                <div className="space-y-6">
                  <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <span className="text-xs font-semibold uppercase text-slate-500">
                        Total Sales & Receivables
                      </span>
                      <p className="mt-2 text-2xl font-extrabold text-emerald-700">
                        {formatINR(m.totalSalesAmount)}
                      </p>
                      <span className="mt-1 block text-xs text-slate-600">
                        Buyer Receivables: <strong>{formatINR(m.totalReceivables)}</strong>
                      </span>
                    </div>

                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <span className="text-xs font-semibold uppercase text-slate-500">
                        Total Purchases & Payables
                      </span>
                      <p className="mt-2 text-2xl font-extrabold text-slate-900">
                        {formatINR(m.totalPurchasesAmount)}
                      </p>
                      <span className="mt-1 block text-xs text-slate-600">
                        Seller Payables: <strong>{formatINR(m.totalPayables)}</strong>
                      </span>
                    </div>

                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <span className="text-xs font-semibold uppercase text-slate-500">
                        Stock Valuation & Lots
                      </span>
                      <p className="mt-2 text-2xl font-extrabold text-emerald-700">
                        {formatINR(m.totalInventoryValue)}
                      </p>
                      <span className="mt-1 block text-xs text-slate-600">
                        {m.totalGoods ?? 0} Goods • {m.activeLots ?? 0} Active Lots
                      </span>
                    </div>

                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <span className="text-xs font-semibold uppercase text-slate-500">
                        Partners & Low Stock Alerts
                      </span>
                      <p className="mt-2 text-2xl font-extrabold text-slate-900">
                        {(m.totalBuyers ?? 0) + (m.totalSellers ?? 0)} Partners
                      </p>
                      <span className="mt-1 block text-xs text-amber-600">
                        {m.lowStockCount ?? 0} Low Stock Items
                      </span>
                    </div>
                  </div>

                  {/* Recent Sales & Purchases */}
                  <div className="grid gap-6 lg:grid-cols-2">
                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <h3 className="text-sm font-bold text-slate-900">Recent Sales Bills</h3>
                      <div className="mt-3 divide-y divide-slate-100 text-xs">
                        {(dashboard?.recentSales || []).map((sb: any) => (
                          <div key={sb.id} className="flex items-center justify-between py-2.5">
                            <div>
                              <span className="font-mono font-bold text-emerald-700">
                                {sb.billNumber}
                              </span>{" "}
                              — {sb.buyer?.name}
                              <p className="text-slate-500">
                                {new Date(sb.billDate).toLocaleDateString()} • Status: {sb.status}
                              </p>
                            </div>
                            <div className="text-right">
                              <p className="font-bold text-slate-900">{formatINR(sb.grandTotal)}</p>
                              <p className="text-slate-500">Due: {formatINR(sb.outstandingAmount)}</p>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>

                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <h3 className="text-sm font-bold text-slate-900">Recent Purchase Bills</h3>
                      <div className="mt-3 divide-y divide-slate-100 text-xs">
                        {(dashboard?.recentPurchases || []).map((pb: any) => (
                          <div key={pb.id} className="flex items-center justify-between py-2.5">
                            <div>
                              <span className="font-mono font-bold text-slate-900">
                                {pb.billNumber}
                              </span>{" "}
                              — {pb.seller?.name}
                              <p className="text-slate-500">
                                {new Date(pb.billDate).toLocaleDateString()} • Status: {pb.status}
                              </p>
                            </div>
                            <div className="text-right">
                              <p className="font-bold text-slate-900">{formatINR(pb.grandTotal)}</p>
                              <p className="text-slate-500">Payable: {formatINR(pb.outstandingAmount)}</p>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* ============================================================
                  SECTION B: SMART CHART & ARRIVAL / AUCTION
                 ============================================================ */}
              {activeTab === "SMART_CHART" && (
                <div className="space-y-6">
                  <div className="flex items-center justify-between rounded-xl border border-slate-200 bg-white p-5">
                    <div>
                      <h2 className="text-base font-bold text-slate-900">
                        Smart Chart & Arrival / Auction Board
                      </h2>
                      <p className="text-xs text-slate-500">
                        Track open lots, record live auction allocations, and generate Smart Chart
                        summaries
                      </p>
                    </div>
                    <button
                      onClick={handleCreateSmartChart}
                      className="inline-flex items-center gap-1.5 rounded-lg bg-emerald-700 px-4 py-2 text-xs font-semibold text-white hover:bg-emerald-800"
                    >
                      <Plus className="h-4 w-4" />
                      Generate Today&apos;s Smart Chart
                    </button>
                  </div>

                  {/* Active Lots List */}
                  <div className="rounded-xl border border-slate-200 bg-white p-5">
                    <h3 className="text-sm font-bold text-slate-900">
                      Active Arrival Lots ({lots.length})
                    </h3>
                    <div className="mt-3 overflow-x-auto">
                      <table className="w-full text-left text-xs">
                        <thead className="border-b border-slate-200 bg-slate-50 uppercase text-slate-600">
                          <tr>
                            <th className="px-3 py-2.5">Lot #</th>
                            <th className="px-3 py-2.5">Seller</th>
                            <th className="px-3 py-2.5">Goods</th>
                            <th className="px-3 py-2.5">Vehicle #</th>
                            <th className="px-3 py-2.5">Bags</th>
                            <th className="px-3 py-2.5">Initial Qty</th>
                            <th className="px-3 py-2.5">Sold Qty</th>
                            <th className="px-3 py-2.5">Remaining</th>
                            <th className="px-3 py-2.5">Status</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                          {lots.map((l) => (
                            <tr key={l.id}>
                              <td className="px-3 py-2.5 font-mono font-bold text-emerald-700">
                                {l.lotNumber}
                              </td>
                              <td className="px-3 py-2.5 font-medium">{l.seller?.name}</td>
                              <td className="px-3 py-2.5">{l.goods?.name}</td>
                              <td className="px-3 py-2.5">{l.vehicleNumber || "-"}</td>
                              <td className="px-3 py-2.5">{l.bagsOrCount}</td>
                              <td className="px-3 py-2.5">
                                {l.initialQuantity} {l.unit}
                              </td>
                              <td className="px-3 py-2.5">
                                {l.soldQuantity} {l.unit}
                              </td>
                              <td className="px-3 py-2.5 font-bold text-emerald-700">
                                {l.remainingQuantity} {l.unit}
                              </td>
                              <td className="px-3 py-2.5">
                                <span className="rounded-md bg-emerald-50 px-2 py-0.5 font-semibold text-emerald-800 border border-emerald-200">
                                  {l.status}
                                </span>
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>

                  {/* Smart Charts List */}
                  <div className="rounded-xl border border-slate-200 bg-white p-5">
                    <h3 className="text-sm font-bold text-slate-900">
                      Saved Smart Charts ({smartCharts.length})
                    </h3>
                    <div className="mt-3 space-y-3">
                      {smartCharts.map((sc) => (
                        <div
                          key={sc.id}
                          className="flex items-center justify-between rounded-lg border border-slate-200 p-4 text-xs"
                        >
                          <div>
                            <span className="font-mono font-bold text-slate-900">
                              {sc.chartNumber}
                            </span>{" "}
                            — <strong>{sc.title}</strong>
                            <p className="mt-1 text-slate-500">
                              Total Bags: {sc.totalBags} • Total Weight: {sc.totalWeight} KG •
                              Status: {sc.status}
                            </p>
                          </div>
                          <div className="text-right">
                            <p className="text-sm font-extrabold text-emerald-700">
                              {formatINR(sc.totalAmount)}
                            </p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              )}

              {/* ============================================================
                  SECTION C: GOODS & LOT RECORDS (ARRIVAL ENTRIES)
                 ============================================================ */}
              {activeTab === "GOODS_LOTS" && (
                <div className="grid gap-6 lg:grid-cols-3">
                  {/* Left: Create Arrival Goods Entry */}
                  <form
                    onSubmit={handleCreateGoodsEntry}
                    className="space-y-3 rounded-xl border border-slate-200 bg-white p-5"
                  >
                    <h3 className="text-sm font-bold text-slate-900">
                      Record Incoming Goods Entry & Lot
                    </h3>
                    <div>
                      <label className="block text-xs font-semibold text-slate-700">
                        Select Seller / Farmer *
                      </label>
                      <select
                        required
                        value={entryForm.sellerId}
                        onChange={(e) => setEntryForm({ ...entryForm, sellerId: e.target.value })}
                        className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-xs"
                      >
                        <option value="">-- Choose Seller --</option>
                        {sellers.map((s) => (
                          <option key={s.id} value={s.id}>
                            {s.name} ({s.villageOrCity || s.phone})
                          </option>
                        ))}
                      </select>
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-slate-700">
                        Select Goods / Product *
                      </label>
                      <select
                        required
                        value={entryForm.goodsId}
                        onChange={(e) => setEntryForm({ ...entryForm, goodsId: e.target.value })}
                        className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-xs"
                      >
                        <option value="">-- Choose Goods --</option>
                        {goods.map((g) => (
                          <option key={g.id} value={g.id}>
                            {g.name} ({g.unit})
                          </option>
                        ))}
                      </select>
                    </div>

                    <div className="grid grid-cols-2 gap-2">
                      <div>
                        <label className="block text-xs font-semibold text-slate-700">
                          Vehicle Number
                        </label>
                        <input
                          type="text"
                          placeholder="KA-07-T-4490"
                          value={entryForm.vehicleNumber}
                          onChange={(e) =>
                            setEntryForm({ ...entryForm, vehicleNumber: e.target.value })
                          }
                          className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-1.5 text-xs"
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-semibold text-slate-700">
                          Bags / Count
                        </label>
                        <input
                          type="number"
                          min={1}
                          value={entryForm.bagsCount}
                          onChange={(e) =>
                            setEntryForm({ ...entryForm, bagsCount: Number(e.target.value) })
                          }
                          className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-1.5 text-xs"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-2">
                      <div>
                        <label className="block text-xs font-semibold text-slate-700">
                          Gross Weight (KG)
                        </label>
                        <input
                          type="number"
                          step="0.01"
                          value={entryForm.grossWeight}
                          onChange={(e) =>
                            setEntryForm({ ...entryForm, grossWeight: Number(e.target.value) })
                          }
                          className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-1.5 text-xs"
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-semibold text-slate-700">
                          Tare Deduction (KG)
                        </label>
                        <input
                          type="number"
                          step="0.01"
                          value={entryForm.tareWeight}
                          onChange={(e) =>
                            setEntryForm({ ...entryForm, tareWeight: Number(e.target.value) })
                          }
                          className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-1.5 text-xs"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-2">
                      <div>
                        <label className="block text-xs font-semibold text-slate-700">
                          Cost Rate / KG
                        </label>
                        <input
                          type="number"
                          step="0.01"
                          value={entryForm.costRate}
                          onChange={(e) =>
                            setEntryForm({ ...entryForm, costRate: Number(e.target.value) })
                          }
                          className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-1.5 text-xs"
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-semibold text-slate-700">
                          Sell Rate / KG
                        </label>
                        <input
                          type="number"
                          step="0.01"
                          value={entryForm.sellRate}
                          onChange={(e) =>
                            setEntryForm({ ...entryForm, sellRate: Number(e.target.value) })
                          }
                          className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-1.5 text-xs"
                        />
                      </div>
                    </div>

                    <button
                      type="submit"
                      className="w-full rounded-lg bg-emerald-700 py-2.5 text-xs font-semibold text-white hover:bg-emerald-800"
                    >
                      Save Goods Entry & Create Lot
                    </button>
                  </form>

                  {/* Right: Goods Catalog & Entries List */}
                  <div className="space-y-6 lg:col-span-2">
                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <h3 className="text-sm font-bold text-slate-900">
                        Add New Product to Goods Catalog
                      </h3>
                      <form onSubmit={handleCreateGoods} className="mt-3 grid gap-3 sm:grid-cols-4">
                        <input
                          type="text"
                          required
                          placeholder="Goods Name"
                          value={goodsForm.name}
                          onChange={(e) => setGoodsForm({ ...goodsForm, name: e.target.value })}
                          className="rounded-lg border border-slate-300 px-3 py-1.5 text-xs"
                        />
                        <input
                          type="number"
                          placeholder="Purchase Price"
                          value={goodsForm.purchasePrice}
                          onChange={(e) =>
                            setGoodsForm({ ...goodsForm, purchasePrice: Number(e.target.value) })
                          }
                          className="rounded-lg border border-slate-300 px-3 py-1.5 text-xs"
                        />
                        <input
                          type="number"
                          placeholder="Selling Price"
                          value={goodsForm.sellingPrice}
                          onChange={(e) =>
                            setGoodsForm({ ...goodsForm, sellingPrice: Number(e.target.value) })
                          }
                          className="rounded-lg border border-slate-300 px-3 py-1.5 text-xs"
                        />
                        <button
                          type="submit"
                          className="rounded-lg bg-slate-900 px-3 py-1.5 text-xs font-semibold text-white"
                        >
                          + Add Goods
                        </button>
                      </form>
                    </div>

                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <h3 className="text-sm font-bold text-slate-900">
                        Goods Arrival Entry Register ({entries.length})
                      </h3>
                      <div className="mt-3 overflow-x-auto">
                        <table className="w-full text-left text-xs">
                          <thead className="border-b border-slate-200 bg-slate-50 uppercase text-slate-600">
                            <tr>
                              <th className="px-3 py-2">Entry #</th>
                              <th className="px-3 py-2">Seller</th>
                              <th className="px-3 py-2">Goods</th>
                              <th className="px-3 py-2">Lot #</th>
                              <th className="px-3 py-2">Net Wt</th>
                              <th className="px-3 py-2">Rates</th>
                              <th className="px-3 py-2">Total Cost</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-slate-100">
                            {entries.map((ent) => (
                              <tr key={ent.id}>
                                <td className="px-3 py-2 font-mono font-bold">{ent.entryNumber}</td>
                                <td className="px-3 py-2">{ent.seller?.name}</td>
                                <td className="px-3 py-2">{ent.goods?.name}</td>
                                <td className="px-3 py-2 font-mono text-emerald-700">
                                  {ent.lot?.lotNumber || "-"}
                                </td>
                                <td className="px-3 py-2">
                                  {ent.netWeight} {ent.unit}
                                </td>
                                <td className="px-3 py-2">
                                  Buy: ₹{ent.costRate} / Sell: ₹{ent.sellRate}
                                </td>
                                <td className="px-3 py-2 font-bold">{formatINR(ent.totalCost)}</td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* ============================================================
                  SECTION D: 3-STEP PURCHASE & SALES BILLING BOOKS
                 ============================================================ */}
              {activeTab === "BILL_BOOKS" && (
                <div className="space-y-6">
                  {/* 3-Step Bill Creation Wizard */}
                  <div className="rounded-xl border border-slate-200 bg-white p-6">
                    <div className="flex flex-wrap items-center justify-between gap-4 border-b border-slate-200 pb-4">
                      <div className="flex items-center gap-2">
                        <button
                          type="button"
                          onClick={() => {
                            setBillType("SALE");
                            if (buyers[0]) setBillPartyId(buyers[0].id);
                          }}
                          className={`rounded-lg px-4 py-2 text-xs font-bold ${
                            billType === "SALE"
                              ? "bg-emerald-700 text-white"
                              : "bg-slate-100 text-slate-700"
                          }`}
                        >
                          Sell Bill Book (Sales Bill)
                        </button>
                        <button
                          type="button"
                          onClick={() => {
                            setBillType("PURCHASE");
                            if (sellers[0]) setBillPartyId(sellers[0].id);
                          }}
                          className={`rounded-lg px-4 py-2 text-xs font-bold ${
                            billType === "PURCHASE"
                              ? "bg-slate-900 text-white"
                              : "bg-slate-100 text-slate-700"
                          }`}
                        >
                          Buy Bill Book (Purchase Bill)
                        </button>
                      </div>

                      <div className="flex items-center gap-2 text-xs font-semibold">
                        {[1, 2, 3].map((s) => (
                          <button
                            key={s}
                            type="button"
                            onClick={() => setBillStep(s as 1 | 2 | 3)}
                            className={`rounded-full px-3 py-1 ${
                              billStep === s
                                ? "bg-emerald-700 text-white"
                                : "bg-slate-100 text-slate-600"
                            }`}
                          >
                            Step {s}:{" "}
                            {s === 1
                              ? "Party Details"
                              : s === 2
                              ? "Goods & Weight"
                              : "Charges & Payment"}
                          </button>
                        ))}
                      </div>
                    </div>

                    <form onSubmit={handleSubmitBill} className="mt-5 space-y-4">
                      {/* Step 1: Party Details */}
                      {billStep === 1 && (
                        <div className="grid gap-4 sm:grid-cols-3">
                          <div>
                            <label className="block text-xs font-semibold text-slate-700">
                              Select {billType === "SALE" ? "Buyer" : "Seller"} *
                            </label>
                            <select
                              required
                              value={billPartyId}
                              onChange={(e) => setBillPartyId(e.target.value)}
                              className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-xs"
                            >
                              {(billType === "SALE" ? buyers : sellers).map((p) => (
                                <option key={p.id} value={p.id}>
                                  {p.name} ({p.code}) — Bal: {formatINR(p.currentBalance)}
                                </option>
                              ))}
                            </select>
                          </div>

                          <div>
                            <label className="block text-xs font-semibold text-slate-700">
                              Vehicle Number
                            </label>
                            <input
                              type="text"
                              value={billVehicleNo}
                              onChange={(e) => setBillVehicleNo(e.target.value)}
                              placeholder="KA-01-AB-1234"
                              className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-xs"
                            />
                          </div>

                          {billType === "SALE" && (
                            <div className="flex items-end pb-2">
                              <label className="flex items-center gap-2 text-xs font-semibold text-slate-700">
                                <input
                                  type="checkbox"
                                  checked={billIsRmc}
                                  onChange={(e) => setBillIsRmc(e.target.checked)}
                                />
                                Apply 1% RMC Market Cess
                              </label>
                            </div>
                          )}

                          <div className="sm:col-span-3 flex justify-end">
                            <button
                              type="button"
                              onClick={() => setBillStep(2)}
                              className="rounded-lg bg-slate-900 px-5 py-2 text-xs font-semibold text-white"
                            >
                              Next: Step 2 (Goods & Weight) →
                            </button>
                          </div>
                        </div>
                      )}

                      {/* Step 2: Goods Line Items */}
                      {billStep === 2 && (
                        <div className="space-y-3">
                          {billItems.map((item, idx) => (
                            <div
                              key={idx}
                              className="grid gap-3 rounded-lg border border-slate-200 bg-slate-50 p-3 sm:grid-cols-5"
                            >
                              <div>
                                <label className="block text-[11px] font-semibold text-slate-600">
                                  Goods Item
                                </label>
                                <select
                                  value={item.goodsId}
                                  onChange={(e) => {
                                    const next = [...billItems];
                                    next[idx].goodsId = e.target.value;
                                    setBillItems(next);
                                  }}
                                  className="mt-1 w-full rounded border border-slate-300 px-2 py-1.5 text-xs"
                                >
                                  {goods.map((g) => (
                                    <option key={g.id} value={g.id}>
                                      {g.name} (Stock: {g.currentStock})
                                    </option>
                                  ))}
                                </select>
                              </div>

                              <div>
                                <label className="block text-[11px] font-semibold text-slate-600">
                                  Bags Count
                                </label>
                                <input
                                  type="number"
                                  min={1}
                                  value={item.bagsCount}
                                  onChange={(e) => {
                                    const next = [...billItems];
                                    next[idx].bagsCount = Number(e.target.value);
                                    setBillItems(next);
                                  }}
                                  className="mt-1 w-full rounded border border-slate-300 px-2 py-1.5 text-xs"
                                />
                              </div>

                              <div>
                                <label className="block text-[11px] font-semibold text-slate-600">
                                  Gross Wt (KG)
                                </label>
                                <input
                                  type="number"
                                  step="0.01"
                                  value={item.grossWeight}
                                  onChange={(e) => {
                                    const next = [...billItems];
                                    next[idx].grossWeight = Number(e.target.value);
                                    setBillItems(next);
                                  }}
                                  className="mt-1 w-full rounded border border-slate-300 px-2 py-1.5 text-xs"
                                />
                              </div>

                              <div>
                                <label className="block text-[11px] font-semibold text-slate-600">
                                  Tare Wt (KG)
                                </label>
                                <input
                                  type="number"
                                  step="0.01"
                                  value={item.tareWeight}
                                  onChange={(e) => {
                                    const next = [...billItems];
                                    next[idx].tareWeight = Number(e.target.value);
                                    setBillItems(next);
                                  }}
                                  className="mt-1 w-full rounded border border-slate-300 px-2 py-1.5 text-xs"
                                />
                              </div>

                              <div>
                                <label className="block text-[11px] font-semibold text-slate-600">
                                  Rate / KG (₹)
                                </label>
                                <input
                                  type="number"
                                  step="0.01"
                                  value={item.unitPrice}
                                  onChange={(e) => {
                                    const next = [...billItems];
                                    next[idx].unitPrice = Number(e.target.value);
                                    setBillItems(next);
                                  }}
                                  className="mt-1 w-full rounded border border-slate-300 px-2 py-1.5 text-xs"
                                />
                              </div>
                            </div>
                          ))}

                          <div className="flex items-center justify-between pt-2">
                            <button
                              type="button"
                              onClick={() =>
                                setBillItems([
                                  ...billItems,
                                  {
                                    goodsId: goods[0]?.id || "",
                                    bagsCount: 5,
                                    grossWeight: 250,
                                    tareWeight: 2,
                                    unitPrice: 25,
                                  },
                                ])
                              }
                              className="rounded border border-slate-300 px-3 py-1.5 text-xs font-semibold text-slate-700"
                            >
                              + Add Another Goods Line
                            </button>
                            <button
                              type="button"
                              onClick={() => setBillStep(3)}
                              className="rounded-lg bg-slate-900 px-5 py-2 text-xs font-semibold text-white"
                            >
                              Next: Step 3 (Charges & Payment) →
                            </button>
                          </div>
                        </div>
                      )}

                      {/* Step 3: Charges, On-Spot Payment & Review */}
                      {billStep === 3 && (
                        <div className="space-y-4">
                          <div className="grid gap-4 sm:grid-cols-4">
                            <div>
                              <label className="block text-xs font-semibold text-slate-700">
                                Labour / Hamali Charge (₹)
                              </label>
                              <input
                                type="number"
                                value={billLabourCharge}
                                onChange={(e) => setBillLabourCharge(Number(e.target.value))}
                                className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-xs"
                              />
                            </div>
                            <div>
                              <label className="block text-xs font-semibold text-slate-700">
                                Discount (₹)
                              </label>
                              <input
                                type="number"
                                value={billDiscount}
                                onChange={(e) => setBillDiscount(Number(e.target.value))}
                                className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-xs"
                              />
                            </div>
                            <div>
                              <label className="block text-xs font-semibold text-slate-700">
                                On-Spot {billType === "SALE" ? "Received" : "Paid"} Amount (₹)
                              </label>
                              <input
                                type="number"
                                value={billSpotPaid}
                                onChange={(e) => setBillSpotPaid(Number(e.target.value))}
                                className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-xs"
                              />
                            </div>
                            <div>
                              <label className="block text-xs font-semibold text-slate-700">
                                Payment Mode
                              </label>
                              <select
                                value={billPaymentMethod}
                                onChange={(e) => setBillPaymentMethod(e.target.value)}
                                className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-xs"
                              >
                                <option value="CASH">CASH</option>
                                <option value="UPI">UPI</option>
                                <option value="BANK_TRANSFER">BANK TRANSFER</option>
                                <option value="CHEQUE">CHEQUE</option>
                              </select>
                            </div>
                          </div>

                          <div className="flex flex-wrap items-center justify-between rounded-xl bg-slate-900 p-4 text-xs text-white">
                            <div className="space-y-1">
                              <p>Subtotal: <strong>{formatINR(previewSubtotal)}</strong></p>
                              <p>Labour + RMC Cess: <strong>{formatINR(billLabourCharge + previewRmc)}</strong></p>
                            </div>
                            <div className="text-right">
                              <p className="text-base font-extrabold text-emerald-400">
                                Grand Total: {formatINR(previewGrandTotal)}
                              </p>
                              <p className="text-slate-300">
                                Balance Due on Bill: {formatINR(previewDue)}
                              </p>
                            </div>
                          </div>

                          <div className="flex justify-end gap-3">
                            <button
                              type="button"
                              onClick={() => setBillStep(2)}
                              className="rounded-lg border border-slate-300 px-4 py-2 text-xs font-semibold"
                            >
                              ← Back
                            </button>
                            <button
                              type="submit"
                              className="rounded-lg bg-emerald-700 px-6 py-2.5 text-xs font-bold text-white hover:bg-emerald-800"
                            >
                              Confirm & Save {billType === "SALE" ? "Sales" : "Purchase"} Bill
                            </button>
                          </div>
                        </div>
                      )}
                    </form>
                  </div>

                  {/* Sales & Purchase Bill Books */}
                  <div className="grid gap-6 lg:grid-cols-2">
                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <h3 className="text-sm font-bold text-slate-900">
                        Sell Bill Book ({sales.length})
                      </h3>
                      <div className="mt-3 overflow-x-auto">
                        <table className="w-full text-left text-xs">
                          <thead className="border-b border-slate-200 bg-slate-50 uppercase text-slate-600">
                            <tr>
                              <th className="px-2.5 py-2">Bill #</th>
                              <th className="px-2.5 py-2">Buyer</th>
                              <th className="px-2.5 py-2">Total</th>
                              <th className="px-2.5 py-2">Due</th>
                              <th className="px-2.5 py-2">Status</th>
                              <th className="px-2.5 py-2 text-right">Actions</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-slate-100">
                            {sales.map((sb) => (
                              <tr key={sb.id}>
                                <td className="px-2.5 py-2 font-mono font-bold text-emerald-700">
                                  {sb.billNumber}
                                </td>
                                <td className="px-2.5 py-2">{sb.buyer?.name}</td>
                                <td className="px-2.5 py-2 font-bold">{formatINR(sb.grandTotal)}</td>
                                <td className="px-2.5 py-2 text-amber-700">
                                  {formatINR(sb.outstandingAmount)}
                                </td>
                                <td className="px-2.5 py-2">
                                  <span className="rounded bg-slate-100 px-2 py-0.5 font-semibold">
                                    {sb.status}
                                  </span>
                                </td>
                                <td className="px-2.5 py-2 text-right space-x-1">
                                  <button
                                    onClick={() => handleGeneratePdf("SALES_BILL", sb.id)}
                                    className="inline-flex items-center gap-1 rounded bg-emerald-50 px-2 py-1 text-[11px] font-semibold text-emerald-800 hover:bg-emerald-100"
                                  >
                                    <Printer className="h-3 w-3" />
                                    PDF
                                  </button>
                                  {sb.status !== "CANCELLED" && (
                                    <button
                                      onClick={() => handleCancelBill("sales", sb.id)}
                                      className="rounded bg-red-50 px-2 py-1 text-[11px] font-semibold text-red-700 hover:bg-red-100"
                                    >
                                      Cancel
                                    </button>
                                  )}
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>

                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <h3 className="text-sm font-bold text-slate-900">
                        Buy Bill Book ({purchases.length})
                      </h3>
                      <div className="mt-3 overflow-x-auto">
                        <table className="w-full text-left text-xs">
                          <thead className="border-b border-slate-200 bg-slate-50 uppercase text-slate-600">
                            <tr>
                              <th className="px-2.5 py-2">Bill #</th>
                              <th className="px-2.5 py-2">Seller</th>
                              <th className="px-2.5 py-2">Total</th>
                              <th className="px-2.5 py-2">Payable</th>
                              <th className="px-2.5 py-2">Status</th>
                              <th className="px-2.5 py-2 text-right">Actions</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-slate-100">
                            {purchases.map((pb) => (
                              <tr key={pb.id}>
                                <td className="px-2.5 py-2 font-mono font-bold">
                                  {pb.billNumber}
                                </td>
                                <td className="px-2.5 py-2">{pb.seller?.name}</td>
                                <td className="px-2.5 py-2 font-bold">{formatINR(pb.grandTotal)}</td>
                                <td className="px-2.5 py-2 text-amber-700">
                                  {formatINR(pb.outstandingAmount)}
                                </td>
                                <td className="px-2.5 py-2">
                                  <span className="rounded bg-slate-100 px-2 py-0.5 font-semibold">
                                    {pb.status}
                                  </span>
                                </td>
                                <td className="px-2.5 py-2 text-right space-x-1">
                                  <button
                                    onClick={() => handleGeneratePdf("PURCHASE_BILL", pb.id)}
                                    className="inline-flex items-center gap-1 rounded bg-emerald-50 px-2 py-1 text-[11px] font-semibold text-emerald-800 hover:bg-emerald-100"
                                  >
                                    <Printer className="h-3 w-3" />
                                    PDF
                                  </button>
                                  {pb.status !== "CANCELLED" && (
                                    <button
                                      onClick={() => handleCancelBill("purchases", pb.id)}
                                      className="rounded bg-red-50 px-2 py-1 text-[11px] font-semibold text-red-700 hover:bg-red-100"
                                    >
                                      Cancel
                                    </button>
                                  )}
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* ============================================================
                  SECTION E: PARTNERS (BUYERS & SELLERS)
                 ============================================================ */}
              {activeTab === "PARTNERS" && (
                <div className="space-y-6">
                  <form
                    onSubmit={handleCreatePartner}
                    className="grid gap-3 rounded-xl border border-slate-200 bg-white p-5 sm:grid-cols-6"
                  >
                    <select
                      value={partnerRole}
                      onChange={(e) => setPartnerRole(e.target.value as "BUYER" | "SELLER")}
                      className="rounded-lg border border-slate-300 px-3 py-2 text-xs font-semibold"
                    >
                      <option value="BUYER">New Buyer</option>
                      <option value="SELLER">New Seller / Farmer</option>
                    </select>
                    <input
                      type="text"
                      required
                      placeholder="Partner Full Name *"
                      value={partnerForm.name}
                      onChange={(e) => setPartnerForm({ ...partnerForm, name: e.target.value })}
                      className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                    />
                    <input
                      type="text"
                      required
                      placeholder="Phone Number *"
                      value={partnerForm.phone}
                      onChange={(e) => setPartnerForm({ ...partnerForm, phone: e.target.value })}
                      className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                    />
                    <input
                      type="text"
                      placeholder="Village / City"
                      value={partnerForm.villageOrCity}
                      onChange={(e) =>
                        setPartnerForm({ ...partnerForm, villageOrCity: e.target.value })
                      }
                      className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                    />
                    <input
                      type="number"
                      placeholder="Opening Balance"
                      value={partnerForm.openingBalance}
                      onChange={(e) =>
                        setPartnerForm({ ...partnerForm, openingBalance: Number(e.target.value) })
                      }
                      className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                    />
                    <button
                      type="submit"
                      className="rounded-lg bg-emerald-700 px-4 py-2 text-xs font-semibold text-white hover:bg-emerald-800"
                    >
                      + Save Partner
                    </button>
                  </form>

                  <div className="grid gap-6 lg:grid-cols-2">
                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <div className="flex items-center justify-between">
                        <h3 className="text-sm font-bold text-slate-900">
                          Buyers Directory ({buyers.length})
                        </h3>
                        <button
                          onClick={() => exportRowsToCsv("buyers.csv", buyers)}
                          className="text-xs font-semibold text-emerald-700 hover:underline"
                        >
                          Export CSV
                        </button>
                      </div>
                      <div className="mt-3 divide-y divide-slate-100 text-xs">
                        {buyers.map((b) => (
                          <div key={b.id} className="flex items-center justify-between py-2.5">
                            <div>
                              <p className="font-bold text-slate-900">
                                {b.name} <span className="font-mono text-slate-400">({b.code})</span>
                              </p>
                              <p className="text-slate-500">
                                {b.phone} • {b.villageOrCity || "General"}
                              </p>
                            </div>
                            <div className="text-right">
                              <p className="font-bold text-emerald-700">{formatINR(b.currentBalance)}</p>
                              <button
                                onClick={() => {
                                  setActiveTab("LEDGERS_ADVANCES");
                                  handleLoadLedger("BUYER", b.id);
                                }}
                                className="text-[11px] font-semibold text-slate-600 underline"
                              >
                                View Ledger
                              </button>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>

                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <div className="flex items-center justify-between">
                        <h3 className="text-sm font-bold text-slate-900">
                          Sellers / Farmers Directory ({sellers.length})
                        </h3>
                        <button
                          onClick={() => exportRowsToCsv("sellers.csv", sellers)}
                          className="text-xs font-semibold text-emerald-700 hover:underline"
                        >
                          Export CSV
                        </button>
                      </div>
                      <div className="mt-3 divide-y divide-slate-100 text-xs">
                        {sellers.map((s) => (
                          <div key={s.id} className="flex items-center justify-between py-2.5">
                            <div>
                              <p className="font-bold text-slate-900">
                                {s.name} <span className="font-mono text-slate-400">({s.code})</span>
                              </p>
                              <p className="text-slate-500">
                                {s.phone} • {s.villageOrCity || "General"}
                              </p>
                            </div>
                            <div className="text-right">
                              <p className="font-bold text-emerald-700">
                                {formatINR(s.currentBalance)}
                              </p>
                              <button
                                onClick={() => {
                                  setActiveTab("LEDGERS_ADVANCES");
                                  handleLoadLedger("SELLER", s.id);
                                }}
                                className="text-[11px] font-semibold text-slate-600 underline"
                              >
                                View Ledger
                              </button>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* ============================================================
                  SECTION F: LEDGERS, PAYMENTS & ADVANCES
                 ============================================================ */}
              {activeTab === "LEDGERS_ADVANCES" && (
                <div className="space-y-6">
                  <div className="grid gap-6 lg:grid-cols-2">
                    {/* Record Payment */}
                    <form
                      onSubmit={handleCreatePayment}
                      className="space-y-3 rounded-xl border border-slate-200 bg-white p-5"
                    >
                      <h3 className="text-sm font-bold text-slate-900">
                        Record Partner Payment / Receipt
                      </h3>
                      <div className="grid grid-cols-2 gap-3">
                        <select
                          value={paymentForm.direction}
                          onChange={(e) =>
                            setPaymentForm({ ...paymentForm, direction: e.target.value })
                          }
                          className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                        >
                          <option value="INBOUND_FROM_BUYER">Receipt From Buyer</option>
                          <option value="OUTBOUND_TO_SELLER">Payment To Seller</option>
                        </select>

                        {paymentForm.direction === "INBOUND_FROM_BUYER" ? (
                          <select
                            required
                            value={paymentForm.buyerId}
                            onChange={(e) =>
                              setPaymentForm({ ...paymentForm, buyerId: e.target.value })
                            }
                            className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                          >
                            <option value="">-- Select Buyer --</option>
                            {buyers.map((b) => (
                              <option key={b.id} value={b.id}>
                                {b.name} (Due: {formatINR(b.currentBalance)})
                              </option>
                            ))}
                          </select>
                        ) : (
                          <select
                            required
                            value={paymentForm.sellerId}
                            onChange={(e) =>
                              setPaymentForm({ ...paymentForm, sellerId: e.target.value })
                            }
                            className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                          >
                            <option value="">-- Select Seller --</option>
                            {sellers.map((s) => (
                              <option key={s.id} value={s.id}>
                                {s.name} (Payable: {formatINR(s.currentBalance)})
                              </option>
                            ))}
                          </select>
                        )}
                      </div>

                      <div className="grid grid-cols-3 gap-2">
                        <input
                          type="number"
                          required
                          placeholder="Amount (₹)"
                          value={paymentForm.amount}
                          onChange={(e) =>
                            setPaymentForm({ ...paymentForm, amount: Number(e.target.value) })
                          }
                          className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                        />
                        <select
                          value={paymentForm.method}
                          onChange={(e) =>
                            setPaymentForm({ ...paymentForm, method: e.target.value })
                          }
                          className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                        >
                          <option value="CASH">CASH</option>
                          <option value="UPI">UPI</option>
                          <option value="BANK_TRANSFER">BANK</option>
                        </select>
                        <button
                          type="submit"
                          className="rounded-lg bg-emerald-700 px-3 py-2 text-xs font-semibold text-white hover:bg-emerald-800"
                        >
                          Save Payment
                        </button>
                      </div>
                    </form>

                    {/* Record Advance */}
                    <form
                      onSubmit={handleCreateAdvance}
                      className="space-y-3 rounded-xl border border-slate-200 bg-white p-5"
                    >
                      <h3 className="text-sm font-bold text-slate-900">
                        Record Partner Advance (Token / Pre-Payment)
                      </h3>
                      <div className="grid grid-cols-2 gap-3">
                        <select
                          value={advanceForm.direction}
                          onChange={(e) =>
                            setAdvanceForm({ ...advanceForm, direction: e.target.value })
                          }
                          className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                        >
                          <option value="INBOUND_FROM_BUYER">Buyer Advance Received</option>
                          <option value="OUTBOUND_TO_SELLER">Seller Advance Issued</option>
                        </select>

                        {advanceForm.direction === "INBOUND_FROM_BUYER" ? (
                          <select
                            required
                            value={advanceForm.buyerId}
                            onChange={(e) =>
                              setAdvanceForm({ ...advanceForm, buyerId: e.target.value })
                            }
                            className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                          >
                            <option value="">-- Select Buyer --</option>
                            {buyers.map((b) => (
                              <option key={b.id} value={b.id}>{b.name}</option>
                            ))}
                          </select>
                        ) : (
                          <select
                            required
                            value={advanceForm.sellerId}
                            onChange={(e) =>
                              setAdvanceForm({ ...advanceForm, sellerId: e.target.value })
                            }
                            className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                          >
                            <option value="">-- Select Seller --</option>
                            {sellers.map((s) => (
                              <option key={s.id} value={s.id}>{s.name}</option>
                            ))}
                          </select>
                        )}
                      </div>

                      <div className="grid grid-cols-2 gap-2">
                        <input
                          type="number"
                          required
                          placeholder="Advance Amount (₹)"
                          value={advanceForm.amount}
                          onChange={(e) =>
                            setAdvanceForm({ ...advanceForm, amount: Number(e.target.value) })
                          }
                          className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                        />
                        <button
                          type="submit"
                          className="rounded-lg bg-slate-900 px-3 py-2 text-xs font-semibold text-white"
                        >
                          Save Advance
                        </button>
                      </div>
                    </form>
                  </div>

                  {/* Partner Running Balance Ledger Viewer */}
                  <div className="rounded-xl border border-slate-200 bg-white p-5">
                    <div className="flex flex-wrap items-center justify-between gap-3">
                      <h3 className="text-sm font-bold text-slate-900">
                        Partner Running Balance Ledger Statement
                      </h3>
                      <div className="flex items-center gap-2">
                        <select
                          value={selectedLedgerType}
                          onChange={(e) =>
                            setSelectedLedgerType(e.target.value as "BUYER" | "SELLER")
                          }
                          className="rounded-lg border border-slate-300 px-3 py-1.5 text-xs"
                        >
                          <option value="BUYER">Buyer Ledger</option>
                          <option value="SELLER">Seller Ledger</option>
                        </select>
                        <select
                          value={selectedLedgerPartnerId}
                          onChange={(e) => handleLoadLedger(selectedLedgerType, e.target.value)}
                          className="rounded-lg border border-slate-300 px-3 py-1.5 text-xs"
                        >
                          <option value="">-- Choose Partner --</option>
                          {(selectedLedgerType === "BUYER" ? buyers : sellers).map((p) => (
                            <option key={p.id} value={p.id}>{p.name}</option>
                          ))}
                        </select>
                      </div>
                    </div>

                    {ledgerData && (
                      <div className="mt-4">
                        <div className="mb-3 flex flex-wrap gap-6 rounded-lg bg-slate-50 p-3 text-xs">
                          <span>
                            Opening: <strong>{formatINR(ledgerData.summary?.openingBalance)}</strong>
                          </span>
                          <span>
                            Total Debit: <strong>{formatINR(ledgerData.summary?.totalDebit)}</strong>
                          </span>
                          <span>
                            Total Credit: <strong>{formatINR(ledgerData.summary?.totalCredit)}</strong>
                          </span>
                          <span className="text-emerald-700">
                            Closing Balance:{" "}
                            <strong>{formatINR(ledgerData.summary?.closingBalance)}</strong>
                          </span>
                        </div>

                        <table className="w-full text-left text-xs">
                          <thead className="border-b border-slate-200 bg-slate-50 uppercase text-slate-600">
                            <tr>
                              <th className="px-3 py-2">Date</th>
                              <th className="px-3 py-2">Type</th>
                              <th className="px-3 py-2">Ref #</th>
                              <th className="px-3 py-2">Description</th>
                              <th className="px-3 py-2 text-right">Debit</th>
                              <th className="px-3 py-2 text-right">Credit</th>
                              <th className="px-3 py-2 text-right">Running Bal</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-slate-100">
                            {(ledgerData.entries || []).map((e: any) => (
                              <tr key={e.id}>
                                <td className="px-3 py-2">
                                  {new Date(e.entryDate).toLocaleDateString()}
                                </td>
                                <td className="px-3 py-2 font-mono">{e.entryType}</td>
                                <td className="px-3 py-2 font-mono">{e.referenceNo}</td>
                                <td className="px-3 py-2">{e.description}</td>
                                <td className="px-3 py-2 text-right">
                                  {formatINR(e.debitAmount)}
                                </td>
                                <td className="px-3 py-2 text-right">
                                  {formatINR(e.creditAmount)}
                                </td>
                                <td className="px-3 py-2 text-right font-bold">
                                  {formatINR(e.runningBalance)}
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

              {/* ============================================================
                  SECTION G: INVENTORY & STOCK SUMMARY
                 ============================================================ */}
              {activeTab === "INVENTORY" && (
                <div className="rounded-xl border border-slate-200 bg-white p-5">
                  <div className="flex items-center justify-between">
                    <div>
                      <h3 className="text-sm font-bold text-slate-900">
                        Stock Summary Table (Opening + Purchases − Sales = Closing)
                      </h3>
                      <p className="text-xs text-slate-500">
                        Total Stock Valuation: <strong>{formatINR(inventory?.totalValuation)}</strong>
                      </p>
                    </div>
                    <button
                      onClick={() =>
                        exportRowsToCsv("inventory-stock.csv", inventory?.stockTable || [])
                      }
                      className="rounded-lg border border-slate-300 px-3 py-1.5 text-xs font-semibold"
                    >
                      Export Stock CSV
                    </button>
                  </div>

                  <div className="mt-4 overflow-x-auto">
                    <table className="w-full text-left text-xs">
                      <thead className="border-b border-slate-200 bg-slate-50 uppercase text-slate-600">
                        <tr>
                          <th className="px-3 py-2.5">Code</th>
                          <th className="px-3 py-2.5">Goods Name</th>
                          <th className="px-3 py-2.5">Opening</th>
                          <th className="px-3 py-2.5">Inward</th>
                          <th className="px-3 py-2.5">Outward</th>
                          <th className="px-3 py-2.5">Closing Stock</th>
                          <th className="px-3 py-2.5">Valuation</th>
                          <th className="px-3 py-2.5">Status</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-100">
                        {(inventory?.stockTable || []).map((row: any) => (
                          <tr key={row.id}>
                            <td className="px-3 py-2.5 font-mono">{row.code}</td>
                            <td className="px-3 py-2.5 font-bold">{row.name}</td>
                            <td className="px-3 py-2.5">
                              {row.openingQuantity} {row.unit}
                            </td>
                            <td className="px-3 py-2.5 text-emerald-700">
                              +{row.inwardQuantity} {row.unit}
                            </td>
                            <td className="px-3 py-2.5 text-amber-700">
                              -{row.outwardQuantity} {row.unit}
                            </td>
                            <td className="px-3 py-2.5 font-extrabold">
                              {row.closingQuantity} {row.unit}
                            </td>
                            <td className="px-3 py-2.5 font-semibold">
                              {formatINR(row.stockValuation)}
                            </td>
                            <td className="px-3 py-2.5">
                              <span
                                className={`rounded-full px-2 py-0.5 font-semibold ${
                                  row.stockStatus === "IN_STOCK"
                                    ? "bg-emerald-50 text-emerald-700"
                                    : "bg-red-50 text-red-700"
                                }`}
                              >
                                {row.stockStatus}
                              </span>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* ============================================================
                  SECTION H: REPORTS (DAILY SUMMARY, GROSS PROFIT, RMC)
                 ============================================================ */}
              {activeTab === "REPORTS" && (
                <div className="space-y-6">
                  <div className="grid gap-4 sm:grid-cols-4">
                    <div className="rounded-xl border border-slate-200 bg-white p-4">
                      <span className="text-xs text-slate-500">Daily Summary Purchases</span>
                      <p className="mt-1 text-lg font-extrabold text-slate-900">
                        {formatINR(dailySummary?.totals?.totalPurchaseAmount)}
                      </p>
                    </div>
                    <div className="rounded-xl border border-slate-200 bg-white p-4">
                      <span className="text-xs text-slate-500">Daily Summary Sales</span>
                      <p className="mt-1 text-lg font-extrabold text-emerald-700">
                        {formatINR(dailySummary?.totals?.totalSalesAmount)}
                      </p>
                    </div>
                    <div className="rounded-xl border border-slate-200 bg-white p-4">
                      <span className="text-xs text-slate-500">Collections Received</span>
                      <p className="mt-1 text-lg font-extrabold text-emerald-700">
                        {formatINR(dailySummary?.totals?.totalCollections)}
                      </p>
                    </div>
                    <div className="rounded-xl border border-slate-200 bg-white p-4">
                      <span className="text-xs text-slate-500">Net Gross Profit</span>
                      <p className="mt-1 text-lg font-extrabold text-teal-700">
                        {formatINR(profitLoss?.summary?.netGrossProfit)} (
                        {profitLoss?.summary?.marginPercent ?? 0}%)
                      </p>
                    </div>
                  </div>

                  {profitLoss && (
                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <div className="flex items-center justify-between">
                        <h3 className="text-sm font-bold text-slate-900">
                          Gross Profit Breakdown Report
                        </h3>
                        <button
                          onClick={() =>
                            exportRowsToCsv("gross-profit-report.csv", profitLoss.items || [])
                          }
                          className="text-xs font-semibold text-emerald-700 hover:underline"
                        >
                          Export CSV
                        </button>
                      </div>
                      <div className="mt-3 overflow-x-auto">
                        <table className="w-full text-left text-xs">
                          <thead className="border-b border-slate-200 bg-slate-50 uppercase text-slate-600">
                            <tr>
                              <th className="px-3 py-2">Bill #</th>
                              <th className="px-3 py-2">Buyer</th>
                              <th className="px-3 py-2">Goods</th>
                              <th className="px-3 py-2">Qty</th>
                              <th className="px-3 py-2">Revenue</th>
                              <th className="px-3 py-2">COGS</th>
                              <th className="px-3 py-2">Gross Profit</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-slate-100">
                            {(profitLoss.items || []).map((item: any, i: number) => (
                              <tr key={i}>
                                <td className="px-3 py-2 font-mono">{item.billNumber}</td>
                                <td className="px-3 py-2">{item.buyerName}</td>
                                <td className="px-3 py-2">{item.goodsName}</td>
                                <td className="px-3 py-2">
                                  {item.quantity} {item.unit}
                                </td>
                                <td className="px-3 py-2">{formatINR(item.revenue)}</td>
                                <td className="px-3 py-2">{formatINR(item.costOfGoodsSold)}</td>
                                <td className="px-3 py-2 font-bold text-emerald-700">
                                  {formatINR(item.grossProfit)}
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  )}
                </div>
              )}

              {/* ============================================================
                  SECTION I: EMPLOYEES & GRANULAR RBAC (ADMIN ONLY)
                 ============================================================ */}
              {activeTab === "USERS" && mode === "ADMIN" && (() => {
                const maxUsers = employeesData?.maxUsers ?? profileData?.tenant?.maxUsers ?? 3;
                const currentUsersCount = employeesData?.users?.length || 0;
                const isSeatLimitReached = currentUsersCount >= maxUsers;
                const activeSessionsCount = employeesData?.activeSessionsCount ?? 0;

                return (
                  <div className="space-y-6">
                    {/* License Seat Quota Overview */}
                    <div className="grid gap-3 sm:grid-cols-3">
                      <div className="rounded-xl border border-slate-200 bg-white p-4">
                        <span className="text-[11px] font-bold uppercase tracking-wider text-slate-500">
                          Shop User Accounts
                        </span>
                        <div className="flex items-baseline gap-2 mt-1">
                          <p className="text-2xl font-extrabold text-slate-900">
                            {currentUsersCount} / {maxUsers}
                          </p>
                          <span className={`text-xs font-bold ${isSeatLimitReached ? "text-amber-600" : "text-emerald-600"}`}>
                            {isSeatLimitReached ? "Max Limit Reached" : `${maxUsers - currentUsersCount} Seat(s) Available`}
                          </span>
                        </div>
                        <div className="w-full bg-slate-100 rounded-full h-2 mt-2">
                          <div
                            className={`h-2 rounded-full transition-all ${isSeatLimitReached ? "bg-amber-500" : "bg-emerald-600"}`}
                            style={{ width: `${Math.min(100, (currentUsersCount / maxUsers) * 100)}%` }}
                          />
                        </div>
                      </div>

                      <div className="rounded-xl border border-slate-200 bg-white p-4">
                        <span className="text-[11px] font-bold uppercase tracking-wider text-slate-500">
                          Active Login Sessions
                        </span>
                        <p className="text-2xl font-extrabold text-emerald-700 mt-1">
                          {activeSessionsCount} / {maxUsers}
                        </p>
                        <p className="text-[11px] text-slate-500 mt-1">
                          Live authenticated devices (Mobile + Web)
                        </p>
                      </div>

                      <div className="rounded-xl border border-slate-200 bg-white p-4">
                        <span className="text-[11px] font-bold uppercase tracking-wider text-slate-500">
                          Shop License Key
                        </span>
                        <p className="text-xs font-mono font-bold text-slate-800 mt-1 truncate">
                          {employeesData?.licenseKey || profileData?.tenant?.licenseKey || "BSG-LIC-TRIAL-3SEATS"}
                        </p>
                        <span className="inline-block mt-1 rounded bg-emerald-50 px-2 py-0.5 text-[10px] font-semibold text-emerald-800 border border-emerald-200">
                          Max 3 Users Quota Enforced
                        </span>
                      </div>
                    </div>

                    {/* Alert banner if limit reached */}
                    {isSeatLimitReached ? (
                      <div className="rounded-xl border border-amber-300 bg-amber-50/80 p-4 text-xs">
                        <div className="flex items-center gap-2 font-bold text-amber-900">
                          <AlertTriangle className="h-4 w-4 text-amber-600 shrink-0" />
                          <span>Tenant License Limit Reached: Maximum {maxUsers} Users Allowed</span>
                        </div>
                        <p className="mt-1 text-amber-800 pl-6">
                          Your current shop license permits a maximum of {maxUsers} users (1 Store Admin + {maxUsers - 1} Staff/Cashiers).
                          All {maxUsers} accounts are assigned. To add another employee, remove an inactive account or contact Super Admin to upgrade seat capacity.
                        </p>
                      </div>
                    ) : (
                      <form
                        onSubmit={handleCreateEmployee}
                        className="grid gap-3 rounded-xl border border-slate-200 bg-white p-5 sm:grid-cols-6"
                      >
                        <select
                          value={empForm.roleType}
                          onChange={(e) =>
                            setEmpForm({
                              ...empForm,
                              roleType: e.target.value as "ADMIN" | "BUSINESS_USER",
                              designation:
                                e.target.value === "ADMIN"
                                  ? "Sub Admin / Store Manager"
                                  : "Billing Operator / Cashier",
                            })
                          }
                          className="rounded-lg border border-slate-300 px-3 py-2 text-xs font-semibold bg-white text-slate-800"
                        >
                          <option value="BUSINESS_USER">Staff / Cashier (Billing & Weighment)</option>
                          <option value="ADMIN">Sub Admin (Full Access to All 10 Features)</option>
                        </select>
                        <input
                          type="text"
                          required
                          placeholder="Username *"
                          value={empForm.username}
                          onChange={(e) => setEmpForm({ ...empForm, username: e.target.value })}
                          className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                        />
                        <input
                          type="text"
                          required
                          placeholder="Full Name *"
                          value={empForm.fullName}
                          onChange={(e) => setEmpForm({ ...empForm, fullName: e.target.value })}
                          className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                        />
                        <input
                          type="text"
                          placeholder="Phone"
                          value={empForm.phone}
                          onChange={(e) => setEmpForm({ ...empForm, phone: e.target.value })}
                          className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                        />
                        <input
                          type="password"
                          required
                          placeholder="Temporary Password *"
                          value={empForm.password}
                          onChange={(e) => setEmpForm({ ...empForm, password: e.target.value })}
                          className="rounded-lg border border-slate-300 px-3 py-2 text-xs"
                        />
                        <button
                          type="submit"
                          className="rounded-lg bg-emerald-600 px-4 py-2 text-xs font-semibold text-white hover:bg-emerald-700 shadow-sm transition"
                        >
                          + Create {empForm.roleType === "ADMIN" ? "Sub Admin" : "Staff"}
                        </button>
                      </form>
                    )}

                    <div className="rounded-xl border border-slate-200 bg-white p-5">
                      <div className="flex items-center justify-between mb-3">
                        <h3 className="text-sm font-bold text-slate-900">
                          Business Users & Staff Accounts ({employeesData?.users?.length || 0} / {maxUsers})
                        </h3>
                        <span className="text-[11px] text-slate-500 font-medium">
                          Strict License Limit: Max {maxUsers} Users
                        </span>
                      </div>
                      <div className="mt-3 divide-y divide-slate-100 text-xs">
                        {(employeesData?.users || []).map((u: any) => (
                          <div key={u.id} className="flex items-center justify-between py-3">
                            <div>
                              <p className="font-bold text-slate-900 flex items-center gap-2">
                                <span>{u.fullName}</span>
                                <span className="font-mono text-[11px] font-normal text-slate-500">
                                  (@{u.username})
                                </span>
                              </p>
                              <p className="text-slate-500 mt-0.5">
                                Designation: {u.designation || u.role?.name} • Status:{" "}
                                <span className="text-emerald-600 font-medium">{u.status}</span>
                              </p>
                            </div>
                            <div>
                              {u.role?.code === "ADMIN" ? (
                                <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 border border-emerald-300 px-2.5 py-1 text-[11px] font-bold text-emerald-800 shadow-xs">
                                  <Store className="h-3.5 w-3.5 text-emerald-700" />
                                  <span>Sub Admin (All Features)</span>
                                </span>
                              ) : (
                                <span className="inline-flex items-center gap-1.5 rounded-full bg-slate-100 border border-slate-300 px-2.5 py-1 text-[11px] font-semibold text-slate-700 shadow-xs">
                                  <User className="h-3.5 w-3.5 text-slate-500" />
                                  <span>Staff / Cashier</span>
                                </span>
                              )}
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                );
              })()}

              {/* ============================================================
                  SECTION J: SETTINGS & CUSTOMIZATION (ADMIN ONLY)
                 ============================================================ */}
              {activeTab === "SETTINGS" && mode === "ADMIN" && (
                <form
                  onSubmit={handleSaveBusinessProfile}
                  className="max-w-3xl space-y-4 rounded-xl border border-slate-200 bg-white p-6"
                >
                  <h3 className="text-base font-bold text-slate-900">
                    Business Identity, Bill Prefixes & Calculation Customization
                  </h3>
                  <div className="grid gap-4 sm:grid-cols-2">
                    <div>
                      <label className="block text-xs font-semibold text-slate-700">
                        Business Name
                      </label>
                      <input
                        type="text"
                        value={profileData.profile?.businessName || ""}
                        onChange={(e) =>
                          setProfileData({
                            ...profileData,
                            profile: { ...profileData.profile, businessName: e.target.value },
                          })
                        }
                        className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-xs"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold text-slate-700">
                        GST Number
                      </label>
                      <input
                        type="text"
                        value={profileData.profile?.gstNumber || ""}
                        onChange={(e) =>
                          setProfileData({
                            ...profileData,
                            profile: { ...profileData.profile, gstNumber: e.target.value },
                          })
                        }
                        className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-xs"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold text-slate-700">
                        Sales Bill Prefix
                      </label>
                      <input
                        type="text"
                        value={profileData.profile?.salesPrefix || "SB"}
                        onChange={(e) =>
                          setProfileData({
                            ...profileData,
                            profile: { ...profileData.profile, salesPrefix: e.target.value },
                          })
                        }
                        className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-xs"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold text-slate-700">
                        Purchase Bill Prefix
                      </label>
                      <input
                        type="text"
                        value={profileData.profile?.purchasePrefix || "PB"}
                        onChange={(e) =>
                          setProfileData({
                            ...profileData,
                            profile: { ...profileData.profile, purchasePrefix: e.target.value },
                          })
                        }
                        className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-xs"
                      />
                    </div>
                  </div>
                  <button
                    type="submit"
                    className="rounded-lg bg-emerald-700 px-5 py-2.5 text-xs font-semibold text-white hover:bg-emerald-800"
                  >
                    Save Business Settings
                  </button>
                </form>
              )}
            </>
          )}
        </main>
      </div>
    </div>
  );
}
