"use client";

import React, { useState, useMemo } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useTheme } from "./ThemeProvider";
import { BsgIcon, BsgLogo } from "./BsgLogo";
import { formatINR } from "@/lib/api";
import {
  MOCK_BUSINESS_DASHBOARD,
  MOCK_BUYERS,
  MOCK_SELLERS,
  MOCK_GOODS,
  MOCK_GOODS_LOTS,
  MOCK_GOODS_ENTRIES,
  MOCK_SMART_CHARTS,
  MOCK_PURCHASES,
  MOCK_SALES,
  MOCK_PAYMENTS,
  MOCK_ADVANCES,
  MOCK_INVENTORY,
  MOCK_DAILY_SUMMARY,
  MOCK_PROFIT_LOSS,
  MOCK_EMPLOYEES,
  MOCK_BUSINESS_PROFILE,
} from "@/lib/mockStore";
import {
  Activity,
  AlertOctagon,
  AlertTriangle,
  ArrowDownRight,
  ArrowRight,
  ArrowUpRight,
  BarChart3,
  Boxes,
  Building2,
  Calendar,
  Check,
  CheckCircle2,
  ChevronDown,
  ChevronLeft,
  ChevronRight,
  Clock,
  Copy,
  CreditCard,
  Database,
  Download,
  ExternalLink,
  Eye,
  FileSpreadsheet,
  FileText,
  Filter,
  Flame,
  Globe,
  GripVertical,
  HelpCircle,
  History,
  Layers,
  LayoutDashboard,
  LineChart,
  Lock,
  LogOut,
  Mail,
  MapPin,
  Maximize2,
  Menu,
  MessageSquare,
  Moon,
  Package,
  PackagePlus,
  Percent,
  Phone,
  PhoneCall,
  Plus,
  Printer,
  QrCode,
  Radio,
  Receipt,
  RefreshCw,
  Scale,
  Search,
  Send,
  Server,
  Settings,
  Share2,
  Shield,
  ShieldAlert,
  ShieldCheck,
  Sliders,
  Smartphone,
  Sparkles,
  Store,
  Sun,
  TrendingDown,
  TrendingUp,
  Truck,
  Upload,
  User,
  UserCheck,
  Users,
  Wallet,
  Wifi,
  X,
  Zap,
} from "lucide-react";

export type WorkspaceModule =
  | "DASHBOARD"
  | "SMART_CHART"
  | "GOODS"
  | "BILLING"
  | "PARTNERS"
  | "LEDGER"
  | "INVENTORY"
  | "REPORTS"
  | "SETTINGS";

export function ClickSmartChartApp() {
  const router = useRouter();
  const { theme, toggleTheme } = useTheme();
  const isDark = theme === "dark";

  // Navigation & Layout State
  const [activeModule, setActiveModule] = useState<WorkspaceModule>("DASHBOARD");
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [notificationOpen, setNotificationOpen] = useState(false);
  const [userDropdownOpen, setUserDropdownOpen] = useState(false);

  // Sub-tab States
  const [smartChartTab, setSmartChartTab] = useState<"ACTIVE_LOTS" | "AUCTION_ALLOCATION" | "SALES_SUMMARY">("ACTIVE_LOTS");
  const [billingTab, setBillingTab] = useState<"SALES_BILLS" | "PURCHASE_BILLS">("SALES_BILLS");
  const [partnersTab, setPartnersTab] = useState<"ALL" | "BUYERS" | "SELLERS">("ALL");
  const [ledgerTab, setLedgerTab] = useState<"BUYER_LEDGER" | "SELLER_LEDGER" | "ADVANCES">("BUYER_LEDGER");
  const [reportsTab, setReportsTab] = useState<"DAILY_SUMMARY" | "SALES_REPORT" | "PURCHASE_REPORT" | "GROSS_PROFIT">("DAILY_SUMMARY");
  const [settingsTab, setSettingsTab] = useState<"PROFILE" | "RATES" | "WHATSAPP" | "TEAM">("PROFILE");

  // Modals & Action States
  const [showCreateLotModal, setShowCreateLotModal] = useState(false);
  const [showCreateBillModal, setShowCreateBillModal] = useState(false);
  const [showAddPartnerModal, setShowAddPartnerModal] = useState(false);
  const [showRecordAdvanceModal, setShowRecordAdvanceModal] = useState(false);
  const [showReceiptModal, setShowReceiptModal] = useState<any>(null);
  const [selectedLotForAuction, setSelectedLotForAuction] = useState<any>(null);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  function showToast(msg: string) {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3000);
  }

  // Live Data lists from mockStore with local mutation state
  const [lots, setLots] = useState(MOCK_GOODS_LOTS);
  const [salesBills, setSalesBills] = useState(MOCK_SALES);
  const [purchaseBills, setPurchaseBills] = useState(MOCK_PURCHASES);
  const [buyers, setBuyers] = useState(MOCK_BUYERS);
  const [sellers, setSellers] = useState(MOCK_SELLERS);
  const [goodsList, setGoodsList] = useState(MOCK_GOODS);
  const [advances, setAdvances] = useState(MOCK_ADVANCES);

  // New Lot Form State
  const [newLotSupplier, setNewLotSupplier] = useState(sellers[0]?.name || "");
  const [newLotVehicle, setNewLotVehicle] = useState("TN-38-BK-9021");
  const [newLotProduct, setNewLotProduct] = useState(goodsList[0]?.name || "");
  const [newLotBags, setNewLotBags] = useState("50");
  const [newLotGross, setNewLotGross] = useState("2550");
  const [newLotTare, setNewLotTare] = useState("50");

  // New Sales Bill Form State
  const [newBillBuyer, setNewBillBuyer] = useState(buyers[0]?.name || "");
  const [newBillProduct, setNewBillProduct] = useState(goodsList[0]?.name || "");
  const [newBillBags, setNewBillBags] = useState("20");
  const [newBillWeight, setNewBillWeight] = useState("1000");
  const [newBillRate, setNewBillRate] = useState("45");
  const [newBillLabour, setNewBillLabour] = useState("120");
  const [newBillPaymentType, setNewBillPaymentType] = useState<"CASH" | "CREDIT" | "GPAY">("CASH");

  // Add Partner Form State
  const [newPartnerName, setNewPartnerName] = useState("");
  const [newPartnerPhone, setNewPartnerPhone] = useState("");
  const [newPartnerCity, setNewPartnerCity] = useState("");
  const [newPartnerType, setNewPartnerType] = useState<"BUYER" | "SELLER">("BUYER");

  // Handlers
  function handleCreateLot() {
    if (!newLotSupplier || !newLotProduct) {
      showToast("Please fill in farmer supplier and crop product");
      return;
    }
    const bags = parseInt(newLotBags) || 10;
    const gross = parseFloat(newLotGross) || 1000;
    const tare = parseFloat(newLotTare) || 50;
    const net = gross - tare;
    const newLot = {
      id: `lot-${Date.now()}`,
      lotNumber: `LOT-2026-${Math.floor(1000 + Math.random() * 9000)}`,
      seller: { name: newLotSupplier },
      vehicleNumber: newLotVehicle,
      arrivalDate: new Date().toISOString(),
      totalBags: bags,
      grossWeight: gross,
      tareWeight: tare,
      netWeight: net,
      soldBags: 0,
      soldWeight: 0,
      remainingBags: bags,
      remainingWeight: net,
      status: "OPEN",
      items: [
        {
          id: `li-${Date.now()}`,
          goods: { name: newLotProduct },
          bagsCount: bags,
          grossWeight: gross,
          tareWeight: tare,
          netWeight: net,
        },
      ],
    };
    setLots([newLot, ...lots]);
    setShowCreateLotModal(false);
    showToast(`Lot ${newLot.lotNumber} registered successfully!`);
  }

  function handleCreateBill() {
    if (!newBillBuyer || !newBillProduct) {
      showToast("Please select customer and crop");
      return;
    }
    const weight = parseFloat(newBillWeight) || 500;
    const rate = parseFloat(newBillRate) || 40;
    const labour = parseFloat(newBillLabour) || 0;
    const gross = weight * rate;
    const cess = Math.round(gross * 0.01);
    const grand = gross + labour + cess;
    const bill = {
      id: `sal-${Date.now()}`,
      billNumber: `SB-2026-${Math.floor(1000 + Math.random() * 9000)}`,
      billDate: new Date().toISOString(),
      buyer: { name: newBillBuyer, code: "BYR-CASH" },
      grossAmount: gross,
      labourCharges: labour,
      marketCess: cess,
      commissionAmount: 0,
      grandTotal: grand,
      receivedAmount: newBillPaymentType === "CREDIT" ? 0 : grand,
      outstandingAmount: newBillPaymentType === "CREDIT" ? grand : 0,
      status: "POSTED",
    };
    setSalesBills([bill, ...salesBills]);
    setShowCreateBillModal(false);
    setShowReceiptModal(bill);
    showToast(`Sales Bill ${bill.billNumber} created!`);
  }

  function handleAddPartner() {
    if (!newPartnerName || !newPartnerPhone) {
      showToast("Please enter partner name and phone");
      return;
    }
    if (newPartnerType === "BUYER") {
      const p = {
        id: `byr-${Date.now()}`,
        code: `BYR-${Math.floor(100 + Math.random() * 900)}`,
        name: newPartnerName,
        phone: newPartnerPhone,
        villageOrCity: newPartnerCity || "Local Market Yard",
        category: "WHOLESALER",
        openingBalance: 0,
        currentBalance: 0,
        isActive: true,
      };
      setBuyers([...buyers, p]);
    } else {
      const p = {
        id: `slr-${Date.now()}`,
        code: `SLR-${Math.floor(100 + Math.random() * 900)}`,
        name: newPartnerName,
        phone: newPartnerPhone,
        villageOrCity: newPartnerCity || "Agricultural Belt",
        category: "FARMER",
        openingBalance: 0,
        currentBalance: 0,
        isActive: true,
      };
      setSellers([...sellers, p]);
    }
    setShowAddPartnerModal(false);
    showToast(`${newPartnerType === "BUYER" ? "Customer" : "Supplier"} partner added!`);
    setNewPartnerName("");
    setNewPartnerPhone("");
    setNewPartnerCity("");
  }

  return (
    <div
      className={`min-h-screen flex flex-col font-sans transition-colors duration-300 ${
        isDark ? "bg-[#080516] text-[#F8F5FF]" : "bg-[#F8F7FC] text-[#211936]"
      }`}
    >
      {/* Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 flex items-center gap-2.5 rounded-xl border border-[#9475F5] bg-[#15102B] px-4 py-3 text-sm font-semibold text-[#F8F5FF] shadow-glow animate-bounce">
          <Sparkles className="h-4 w-4 text-[#9475F5]" />
          <span>{toastMessage}</span>
        </div>
      )}

      {/* TOP HEADER NAVIGATION */}
      <header
        className={`sticky top-0 z-40 flex h-16 w-full items-center justify-between border-b px-4 sm:px-6 backdrop-blur-xl transition-colors duration-300 ${
          isDark
            ? "border-[#30264B] bg-[#080516]/85"
            : "border-[#E9E3F4] bg-[#FFFFFF]/90"
        }`}
      >
        <div className="flex items-center gap-3">
          {/* Mobile menu trigger */}
          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className={`rounded-xl p-2 lg:hidden transition ${
              isDark ? "hover:bg-[#15102B]" : "hover:bg-[#F2EEFA]"
            }`}
          >
            <Menu className="h-5 w-5" />
          </button>

          {/* Logo & Brand */}
          <Link href="/workspace/dashboard" className="flex items-center gap-2.5 group">
            <BsgIcon size={34} />
            <div className="hidden sm:flex flex-col">
              <div className="flex items-center gap-1.5 leading-none">
                <span className="text-base font-black tracking-tight">Click Smart Chart</span>
                <span
                  className={`rounded-md px-1.5 py-0.5 text-[9px] font-extrabold uppercase ${
                    isDark
                      ? "bg-[#15102B] text-[#B49AFF] border border-[#30264B]"
                      : "bg-[#F2EEFA] text-[#7955DF] border border-[#E9E3F4]"
                  }`}
                >
                  ENTERPRISE
                </span>
              </div>
              <span className={`text-[10.5px] font-medium leading-none mt-1 ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                Sri Vinayaka Agro Commodities • Mandi Yard 42
              </span>
            </div>
          </Link>

          {/* Breadcrumb / Active Module indicator */}
          <div className="hidden md:flex items-center gap-2 ml-4 pl-4 border-l border-opacity-30 border-[#30264B]">
            <span className={`text-xs font-semibold ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>Workspace</span>
            <ChevronRight className="h-3 w-3 opacity-40" />
            <span className="text-xs font-bold text-[#9475F5]">{activeModule}</span>
          </div>
        </div>

        {/* Global Search Bar */}
        <div className="hidden md:flex items-center flex-1 max-w-md mx-6">
          <div
            className={`flex w-full items-center gap-2.5 rounded-full border px-3.5 py-1.5 text-xs transition-all ${
              isDark
                ? "border-[#30264B] bg-[#15102B]/60 focus-within:border-[#9475F5] focus-within:ring-2 focus-within:ring-[#9475F5]/20"
                : "border-[#E9E3F4] bg-[#FFFFFF] focus-within:border-[#7955DF] focus-within:ring-2 focus-within:ring-[#7955DF]/20"
            }`}
          >
            <Search className={`h-4 w-4 ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`} />
            <input
              type="text"
              placeholder="Search lots, crops, farmers, bills, ledgers... (Ctrl + K)"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-transparent outline-none placeholder:text-xs placeholder:opacity-50"
            />
            <kbd className={`rounded px-1.5 py-0.5 text-[9px] font-mono border ${isDark ? "bg-[#0D0920] border-[#30264B] text-[#B7ADC9]" : "bg-gray-100 border-gray-300 text-gray-500"}`}>
              ⌘K
            </kbd>
          </div>
        </div>

        {/* Action Controls & Profile */}
        <div className="flex items-center gap-2.5">
          {/* Quick Action Button */}
          <button
            onClick={() => setShowCreateBillModal(true)}
            className="hidden sm:inline-flex items-center gap-1.5 rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] px-3.5 py-1.5 text-xs font-bold text-white shadow-glow hover:brightness-110 active:scale-95 transition-all"
          >
            <Plus className="h-3.5 w-3.5" />
            <span>+ New Bill</span>
          </button>

          {/* Quick Lot Inward Button */}
          <button
            onClick={() => setShowCreateLotModal(true)}
            className={`hidden sm:inline-flex items-center gap-1.5 rounded-xl border px-3 py-1.5 text-xs font-semibold transition ${
              isDark
                ? "border-[#30264B] bg-[#15102B] text-[#F8F5FF] hover:border-[#9475F5]"
                : "border-[#E9E3F4] bg-white text-[#211936] hover:border-[#7955DF]"
            }`}
          >
            <PackagePlus className="h-3.5 w-3.5 text-[#9475F5]" />
            <span>+ Inward Lot</span>
          </button>

          {/* Live Market Ticker Pill */}
          <div
            className={`hidden xl:flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold ${
              isDark ? "bg-[#15102B] text-[#10B981] border border-[#30264B]" : "bg-[#F2EEFA] text-[#059669] border border-[#E9E3F4]"
            }`}
          >
            <span className="h-2 w-2 rounded-full bg-[#10B981] animate-pulse" />
            <span>Market Trading Active</span>
          </div>

          {/* Notifications Trigger */}
          <div className="relative">
            <button
              onClick={() => setNotificationOpen(!notificationOpen)}
              className={`relative rounded-xl p-2 transition ${
                isDark ? "hover:bg-[#15102B] text-[#B7ADC9]" : "hover:bg-[#F2EEFA] text-[#777086]"
              }`}
              title="Notifications"
            >
              <Radio className="h-4 w-4" />
              <span className="absolute top-1.5 right-1.5 h-2 w-2 rounded-full bg-[#9475F5] ring-2 ring-[#080516]" />
            </button>

            {notificationOpen && (
              <div
                className={`absolute right-0 mt-2 w-80 rounded-2xl border p-4 shadow-2xl z-50 ${
                  isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                }`}
              >
                <div className="flex items-center justify-between pb-3 border-b border-opacity-30 border-[#30264B]">
                  <h4 className="text-xs font-bold uppercase tracking-wider">Mandi Real-time Alerts</h4>
                  <span className="text-[10px] text-[#9475F5]">3 Unread</span>
                </div>
                <div className="mt-3 space-y-2.5 text-xs">
                  <div className="p-2 rounded-xl bg-opacity-30 bg-[#9475F5]/10 border border-[#9475F5]/20">
                    <p className="font-semibold text-[#9475F5]">Farmer Inward Arrival</p>
                    <p className={`text-[11px] ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                      LOT-2026-0881: 80 Bags Tomato arrived via KA-04-E-8821.
                    </p>
                  </div>
                  <div className="p-2 rounded-xl bg-opacity-30 bg-amber-500/10 border border-amber-500/20">
                    <p className="font-semibold text-amber-400">Low Stock Alert</p>
                    <p className={`text-[11px] ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                      Grade-A Bangalore Tomato is below threshold (18 crates left).
                    </p>
                  </div>
                  <div className="p-2 rounded-xl bg-opacity-30 bg-emerald-500/10 border border-emerald-500/20">
                    <p className="font-semibold text-emerald-400">Payment Settled</p>
                    <p className={`text-[11px] ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                      Apex Fresh Mart cleared ₹50,000 via Cash Counter.
                    </p>
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Theme Toggle Button (Dark / Light) */}
          <button
            onClick={toggleTheme}
            className={`flex items-center justify-center rounded-xl p-2 transition-all border ${
              isDark
                ? "border-[#30264B] bg-[#15102B] text-[#B49AFF] hover:border-[#9475F5] hover:shadow-glow"
                : "border-[#E9E3F4] bg-white text-[#7955DF] hover:border-[#7955DF]"
            }`}
            title={`Switch to ${isDark ? "Light" : "Dark"} Mode`}
          >
            {isDark ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
          </button>

          {/* User Profile Dropdown */}
          <div className="relative">
            <button
              onClick={() => setUserDropdownOpen(!userDropdownOpen)}
              className={`flex items-center gap-2 rounded-xl p-1.5 transition ${
                isDark ? "hover:bg-[#15102B]" : "hover:bg-[#F2EEFA]"
              }`}
            >
              <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-gradient-to-tr from-[#9475F5] to-[#7955DF] text-white font-bold text-xs shadow-xs">
                RK
              </div>
              <ChevronDown className="h-3.5 w-3.5 opacity-60" />
            </button>

            {userDropdownOpen && (
              <div
                className={`absolute right-0 mt-2 w-64 rounded-2xl border p-3 shadow-2xl z-50 ${
                  isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                }`}
              >
                <div className="px-3 py-2 border-b border-opacity-30 border-[#30264B]">
                  <p className="font-bold text-xs">Ramesh Kumar</p>
                  <p className={`text-[11px] ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>Sub Admin • Mandi License #8841</p>
                </div>
                <div className="mt-2 space-y-1 text-xs">
                  <button
                    onClick={() => {
                      setActiveModule("SETTINGS");
                      setUserDropdownOpen(false);
                    }}
                    className={`w-full flex items-center gap-2 px-3 py-2 rounded-xl transition text-left ${
                      isDark ? "hover:bg-[#1E173D]" : "hover:bg-[#F2EEFA]"
                    }`}
                  >
                    <Settings className="h-3.5 w-3.5 text-[#9475F5]" />
                    <span>Business & Yard Settings</span>
                  </button>
                  <Link
                    href="/super-admin/dashboard"
                    className={`w-full flex items-center gap-2 px-3 py-2 rounded-xl transition text-left ${
                      isDark ? "hover:bg-[#1E173D]" : "hover:bg-[#F2EEFA]"
                    }`}
                  >
                    <ShieldCheck className="h-3.5 w-3.5 text-[#10B981]" />
                    <span>Super Admin Platform Governance</span>
                  </Link>
                  <Link
                    href="/"
                    className={`w-full flex items-center gap-2 px-3 py-2 rounded-xl transition text-left ${
                      isDark ? "hover:bg-[#1E173D]" : "hover:bg-[#F2EEFA]"
                    }`}
                  >
                    <Globe className="h-3.5 w-3.5 text-[#3B82F6]" />
                    <span>Public SaaS Portal</span>
                  </Link>
                  <div className="pt-1 border-t border-opacity-30 border-[#30264B]">
                    <button
                      onClick={() => {
                        showToast("Signed out from workspace");
                        router.push("/login");
                      }}
                      className="w-full flex items-center gap-2 px-3 py-2 rounded-xl text-rose-400 hover:bg-rose-500/10 transition text-left"
                    >
                      <LogOut className="h-3.5 w-3.5" />
                      <span>Sign Out</span>
                    </button>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </header>

      {/* WORKSPACE BODY WITH COLLAPSIBLE SIDEBAR */}
      <div className="flex flex-1 overflow-hidden">
        {/* COLLAPSIBLE ENTERPRISE SIDEBAR */}
        <aside
          className={`hidden lg:flex flex-col border-r transition-all duration-300 z-30 ${
            sidebarCollapsed ? "w-20" : "w-64"
          } ${isDark ? "border-[#30264B] bg-[#0D0920]" : "border-[#E9E3F4] bg-[#FFFFFF]"}`}
        >
          {/* Sidebar Top: Yard Brand Switcher */}
          <div className="p-4 border-b border-opacity-30 border-[#30264B] flex items-center justify-between">
            {!sidebarCollapsed ? (
              <div className="flex items-center gap-2.5">
                <div className="h-9 w-9 rounded-xl bg-gradient-to-br from-[#9475F5] to-[#7955DF] flex items-center justify-center text-white font-black text-sm shadow-glow shrink-0">
                  SV
                </div>
                <div className="flex flex-col leading-tight overflow-hidden">
                  <span className="text-xs font-bold truncate">Sri Vinayaka Agro</span>
                  <span className={`text-[10px] ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>APMC License #8841</span>
                </div>
              </div>
            ) : (
              <div className="mx-auto h-9 w-9 rounded-xl bg-gradient-to-br from-[#9475F5] to-[#7955DF] flex items-center justify-center text-white font-black text-sm shadow-glow">
                SV
              </div>
            )}
            <button
              onClick={() => setSidebarCollapsed(!sidebarCollapsed)}
              className={`rounded-lg p-1.5 transition ${isDark ? "hover:bg-[#15102B] text-[#B7ADC9]" : "hover:bg-[#F2EEFA] text-[#777086]"}`}
              title={sidebarCollapsed ? "Expand Sidebar" : "Collapse Sidebar"}
            >
              {sidebarCollapsed ? <ChevronRight className="h-4 w-4" /> : <ChevronLeft className="h-4 w-4" />}
            </button>
          </div>

          {/* Navigation Links for 9 Mandi Modules */}
          <nav className="flex-1 overflow-y-auto p-3 space-y-1.5">
            {[
              { id: "DASHBOARD", label: "Dashboard", icon: LayoutDashboard, badge: "Live" },
              { id: "SMART_CHART", label: "Smart Chart & Auction", icon: LineChart, badge: "6 Lots" },
              { id: "GOODS", label: "Goods Inward", icon: PackagePlus },
              { id: "BILLING", label: "Bill Book & Invoices", icon: Receipt },
              { id: "PARTNERS", label: "Farmers & Buyers", icon: Users },
              { id: "LEDGER", label: "Ledgers & Advances", icon: Wallet },
              { id: "INVENTORY", label: "Inventory & Stock", icon: Boxes },
              { id: "REPORTS", label: "Reports & Daily Tally", icon: BarChart3 },
              { id: "SETTINGS", label: "Mandi Settings", icon: Settings },
            ].map((item) => {
              const active = activeModule === item.id;
              const IconComp = item.icon;
              return (
                <button
                  key={item.id}
                  onClick={() => setActiveModule(item.id as WorkspaceModule)}
                  className={`w-full flex items-center gap-3 rounded-2xl px-3.5 py-2.5 text-xs font-semibold transition-all group ${
                    active
                      ? "bg-gradient-to-r from-[#9475F5] to-[#7955DF] text-white shadow-glow"
                      : isDark
                      ? "text-[#B7ADC9] hover:bg-[#15102B] hover:text-[#F8F5FF]"
                      : "text-[#777086] hover:bg-[#F2EEFA] hover:text-[#211936]"
                  }`}
                  title={item.label}
                >
                  <IconComp className={`h-4 w-4 shrink-0 transition-transform group-hover:scale-110 ${active ? "text-white" : "text-[#9475F5]"}`} />
                  {!sidebarCollapsed && (
                    <div className="flex flex-1 items-center justify-between overflow-hidden">
                      <span className="truncate">{item.label}</span>
                      {item.badge && (
                        <span
                          className={`rounded-full px-2 py-0.5 text-[10px] font-bold ${
                            active
                              ? "bg-white/20 text-white"
                              : isDark
                              ? "bg-[#15102B] text-[#B49AFF] border border-[#30264B]"
                              : "bg-[#F2EEFA] text-[#7955DF] border border-[#E9E3F4]"
                          }`}
                        >
                          {item.badge}
                        </span>
                      )}
                    </div>
                  )}
                </button>
              );
            })}

            {/* Platform Super Admin Switch */}
            <div className="pt-4 mt-4 border-t border-opacity-30 border-[#30264B]">
              <Link
                href="/super-admin/dashboard"
                className={`w-full flex items-center gap-3 rounded-2xl px-3.5 py-2.5 text-xs font-semibold transition-all ${
                  isDark
                    ? "text-[#B7ADC9] hover:bg-[#15102B] hover:text-[#10B981]"
                    : "text-[#777086] hover:bg-[#F2EEFA] hover:text-[#059669]"
                }`}
                title="Super Admin Governance"
              >
                <ShieldCheck className="h-4 w-4 text-[#10B981] shrink-0" />
                {!sidebarCollapsed && <span className="truncate">Platform Governance</span>}
              </Link>
            </div>
          </nav>

          {/* Sidebar Bottom License Status */}
          <div className="p-3 border-t border-opacity-30 border-[#30264B]">
            {!sidebarCollapsed ? (
              <div
                className={`rounded-2xl p-3 border text-xs ${
                  isDark ? "bg-[#15102B] border-[#30264B]" : "bg-[#F2EEFA] border-[#E9E3F4]"
                }`}
              >
                <div className="flex items-center justify-between mb-1.5">
                  <span className="font-bold text-[11px] text-[#9475F5]">Enterprise License</span>
                  <span className="text-[10px] text-emerald-400 font-bold">ACTIVE</span>
                </div>
                <p className={`text-[10px] leading-tight ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                  2 of 3 User Seats Active • 28 Days Trial Left
                </p>
              </div>
            ) : (
              <div className="flex justify-center" title="Enterprise License Active">
                <ShieldCheck className="h-5 w-5 text-[#10B981]" />
              </div>
            )}
          </div>
        </aside>

        {/* MOBILE NAVIGATION DRAWER */}
        {mobileMenuOpen && (
          <div className="fixed inset-0 z-50 flex lg:hidden">
            <div className="fixed inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setMobileMenuOpen(false)} />
            <div
              className={`relative flex w-72 flex-col p-4 shadow-2xl z-10 ${
                isDark ? "bg-[#0D0920] text-[#F8F5FF]" : "bg-white text-[#211936]"
              }`}
            >
              <div className="flex items-center justify-between pb-4 border-b border-opacity-30 border-[#30264B]">
                <div className="flex items-center gap-2">
                  <BsgIcon size={30} />
                  <span className="font-bold text-sm">Click Smart Chart</span>
                </div>
                <button onClick={() => setMobileMenuOpen(false)} className="rounded-lg p-1">
                  <X className="h-5 w-5" />
                </button>
              </div>
              <div className="mt-4 flex-1 space-y-1 overflow-y-auto">
                {[
                  { id: "DASHBOARD", label: "Dashboard", icon: LayoutDashboard },
                  { id: "SMART_CHART", label: "Smart Chart & Auction", icon: LineChart },
                  { id: "GOODS", label: "Goods Inward", icon: PackagePlus },
                  { id: "BILLING", label: "Bill Book & Invoices", icon: Receipt },
                  { id: "PARTNERS", label: "Farmers & Buyers", icon: Users },
                  { id: "LEDGER", label: "Ledgers & Advances", icon: Wallet },
                  { id: "INVENTORY", label: "Inventory & Stock", icon: Boxes },
                  { id: "REPORTS", label: "Reports & Daily Tally", icon: BarChart3 },
                  { id: "SETTINGS", label: "Mandi Settings", icon: Settings },
                ].map((item) => (
                  <button
                    key={item.id}
                    onClick={() => {
                      setActiveModule(item.id as WorkspaceModule);
                      setMobileMenuOpen(false);
                    }}
                    className={`w-full flex items-center gap-3 rounded-xl px-3.5 py-2.5 text-xs font-semibold ${
                      activeModule === item.id
                        ? "bg-[#9475F5] text-white"
                        : isDark
                        ? "text-[#B7ADC9] hover:bg-[#15102B]"
                        : "text-[#777086] hover:bg-[#F2EEFA]"
                    }`}
                  >
                    <item.icon className="h-4 w-4" />
                    <span>{item.label}</span>
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* MAIN WORKSPACE CONTENT AREA */}
        <main className="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8 nexi-ambient-bg">
          {/* MODULE 1: DASHBOARD */}
          {activeModule === "DASHBOARD" && (
            <div className="space-y-6 max-w-7xl mx-auto">
              {/* Welcome Banner */}
              <div
                className={`rounded-3xl border p-6 sm:p-8 relative overflow-hidden ${
                  isDark
                    ? "border-[#30264B] bg-gradient-to-r from-[#15102B] via-[#1E173D] to-[#15102B] shadow-glow-card"
                    : "border-[#E9E3F4] bg-gradient-to-r from-white via-[#F2EEFA] to-white shadow-sm"
                }`}
              >
                <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-4">
                  <div>
                    <div className="inline-flex items-center gap-2 rounded-full px-3 py-1 text-xs font-semibold bg-[#9475F5]/20 text-[#B49AFF] border border-[#9475F5]/30 mb-3">
                      <Sparkles className="h-3.5 w-3.5 text-[#9475F5]" />
                      <span>APMC Mandi Yard Floor Trading Live</span>
                    </div>
                    <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight">
                      Sri Vinayaka Mandi Operations
                    </h1>
                    <p className={`text-xs sm:text-sm mt-1 max-w-xl ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                      Multi-product inward consignment tracking, real-time electronic weighment billing, and ACID farmer & buyer ledgers.
                    </p>
                  </div>
                  <div className="flex items-center gap-3">
                    <button
                      onClick={() => setShowCreateLotModal(true)}
                      className="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] px-4 py-2.5 text-xs font-bold text-white shadow-glow hover:brightness-110 transition"
                    >
                      <PackagePlus className="h-4 w-4" />
                      <span>+ Inward Farm Lot</span>
                    </button>
                    <button
                      onClick={() => setShowCreateBillModal(true)}
                      className={`inline-flex items-center gap-2 rounded-xl border px-4 py-2.5 text-xs font-semibold transition ${
                        isDark ? "border-[#30264B] bg-[#15102B] hover:border-[#9475F5]" : "border-[#E9E3F4] bg-white hover:border-[#7955DF]"
                      }`}
                    >
                      <Receipt className="h-4 w-4 text-[#9475F5]" />
                      <span>Create Buyer Bill</span>
                    </button>
                  </div>
                </div>
              </div>

              {/* 5 High-Impact Metric Cards */}
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
                {[
                  {
                    title: "Total Inward Goods",
                    val: "18 Active Crops",
                    sub: "6 Open Farm Arrival Lots",
                    icon: Boxes,
                    accent: "#9475F5",
                  },
                  {
                    title: "Total Purchases",
                    val: formatINR(MOCK_BUSINESS_DASHBOARD.metrics.totalPurchasesAmount),
                    sub: `${MOCK_BUSINESS_DASHBOARD.metrics.totalPurchasesCount} Farmer Inward Bills`,
                    icon: TrendingDown,
                    accent: "#3B82F6",
                  },
                  {
                    title: "Total Sales",
                    val: formatINR(MOCK_BUSINESS_DASHBOARD.metrics.totalSalesAmount),
                    sub: `${MOCK_BUSINESS_DASHBOARD.metrics.totalSalesCount} Wholesale Invoices`,
                    icon: TrendingUp,
                    accent: "#10B981",
                  },
                  {
                    title: "Buyer Receivables",
                    val: formatINR(MOCK_BUSINESS_DASHBOARD.metrics.totalReceivables),
                    sub: "34 Active Buyers",
                    icon: Wallet,
                    accent: "#F59E0B",
                  },
                  {
                    title: "Today's Drawer Cash",
                    val: formatINR(MOCK_DAILY_SUMMARY.cashInHandClosing),
                    sub: "Net Verified in Tally",
                    icon: CreditCard,
                    accent: "#B49AFF",
                  },
                ].map((card, i) => {
                  const IconComp = card.icon;
                  return (
                    <div
                      key={i}
                      className={`rounded-2xl border p-5 transition-all hover:scale-[1.02] ${
                        isDark ? "border-[#30264B] bg-[#15102B] hover:border-[#9475F5]/60 hover:shadow-glow" : "border-[#E9E3F4] bg-white hover:border-[#7955DF]/60 shadow-sm"
                      }`}
                    >
                      <div className="flex items-center justify-between mb-3">
                        <span className={`text-xs font-semibold ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                          {card.title}
                        </span>
                        <div
                          className="h-8 w-8 rounded-xl flex items-center justify-center text-white"
                          style={{ backgroundColor: `${card.accent}25` }}
                        >
                          <IconComp className="h-4 w-4" style={{ color: card.accent }} />
                        </div>
                      </div>
                      <p className="text-lg font-black tracking-tight">{card.val}</p>
                      <p className={`text-[11px] mt-1 ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>{card.sub}</p>
                    </div>
                  );
                })}
              </div>

              {/* Performance Chart & Recent Live Feed */}
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Revenue & Volume Chart Overview */}
                <div
                  className={`lg:col-span-2 rounded-2xl border p-6 ${
                    isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                  }`}
                >
                  <div className="flex items-center justify-between mb-6">
                    <div>
                      <h3 className="text-sm font-bold">Weekly Mandi Trade Velocity</h3>
                      <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                        Daily Sales vs Procurement Outflow
                      </p>
                    </div>
                    <div className="flex items-center gap-3 text-xs">
                      <span className="flex items-center gap-1.5 font-semibold text-[#10B981]">
                        <span className="h-2 w-2 rounded-full bg-[#10B981]" /> Sales
                      </span>
                      <span className="flex items-center gap-1.5 font-semibold text-[#9475F5]">
                        <span className="h-2 w-2 rounded-full bg-[#9475F5]" /> Purchases
                      </span>
                    </div>
                  </div>

                  {/* Simulated Elegant Bar Graph */}
                  <div className="space-y-4 pt-2">
                    {[
                      { day: "Mon", sales: 85, pur: 70, sVal: "₹3.8L", pVal: "₹3.1L" },
                      { day: "Tue", sales: 92, pur: 78, sVal: "₹4.2L", pVal: "₹3.5L" },
                      { day: "Wed", sales: 65, pur: 55, sVal: "₹2.9L", pVal: "₹2.4L" },
                      { day: "Thu", sales: 98, pur: 82, sVal: "₹4.6L", pVal: "₹3.8L" },
                      { day: "Fri", sales: 75, pur: 68, sVal: "₹3.4L", pVal: "₹3.0L" },
                      { day: "Today (Sat)", sales: 90, pur: 75, sVal: "₹4.1L", pVal: "₹3.3L" },
                    ].map((item, idx) => (
                      <div key={idx} className="flex items-center gap-4 text-xs">
                        <span className="w-20 font-semibold">{item.day}</span>
                        <div className="flex-1 space-y-1">
                          <div className="h-2.5 w-full bg-opacity-20 bg-gray-600 rounded-full overflow-hidden flex">
                            <div className="h-full bg-gradient-to-r from-[#10B981] to-[#34D399] rounded-full" style={{ width: `${item.sales}%` }} />
                          </div>
                          <div className="h-2.5 w-full bg-opacity-20 bg-gray-600 rounded-full overflow-hidden flex">
                            <div className="h-full bg-gradient-to-r from-[#9475F5] to-[#7955DF] rounded-full" style={{ width: `${item.pur}%` }} />
                          </div>
                        </div>
                        <span className="w-24 text-right font-bold text-[11px] text-[#10B981]">{item.sVal}</span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Right Column: Low Stock Alerts & Quick Shortcuts */}
                <div className="space-y-6">
                  {/* Low Stock Alerts */}
                  <div
                    className={`rounded-2xl border p-5 ${
                      isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                    }`}
                  >
                    <div className="flex items-center justify-between mb-4">
                      <div className="flex items-center gap-2">
                        <AlertTriangle className="h-4 w-4 text-amber-400" />
                        <h4 className="text-xs font-bold uppercase tracking-wider">Yard Low Stock Warnings</h4>
                      </div>
                      <span className="rounded-full bg-amber-500/20 px-2 py-0.5 text-[10px] font-bold text-amber-400">
                        2 Items
                      </span>
                    </div>
                    <div className="space-y-3">
                      {MOCK_BUSINESS_DASHBOARD.lowStockItems.map((item) => (
                        <div
                          key={item.id}
                          className={`rounded-xl border p-3 flex items-center justify-between ${
                            isDark ? "border-[#30264B] bg-[#0D0920]" : "border-[#E9E3F4] bg-[#F8F7FC]"
                          }`}
                        >
                          <div>
                            <p className="font-bold text-xs">{item.name}</p>
                            <p className={`text-[10px] ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                              Threshold: {item.minimumStock} {item.unit}
                            </p>
                          </div>
                          <div className="text-right">
                            <p className="font-black text-amber-400 text-sm">{item.currentStock}</p>
                            <p className="text-[9px] uppercase font-bold text-amber-400/80">{item.unit} Left</p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Operational Shortcuts */}
                  <div
                    className={`rounded-2xl border p-5 ${
                      isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                    }`}
                  >
                    <h4 className="text-xs font-bold uppercase tracking-wider mb-3">Quick Navigation Shortcuts</h4>
                    <div className="grid grid-cols-2 gap-2.5 text-xs">
                      <button
                        onClick={() => {
                          setActiveModule("SMART_CHART");
                          setSmartChartTab("AUCTION_ALLOCATION");
                        }}
                        className={`rounded-xl border p-2.5 text-left font-semibold transition flex flex-col gap-1.5 ${
                          isDark ? "border-[#30264B] bg-[#0D0920] hover:border-[#9475F5]" : "border-[#E9E3F4] bg-[#F8F7FC] hover:border-[#7955DF]"
                        }`}
                      >
                        <LineChart className="h-4 w-4 text-[#9475F5]" />
                        <span>Live Lot Auction</span>
                      </button>
                      <button
                        onClick={() => {
                          setActiveModule("BILLING");
                          setBillingTab("SALES_BILLS");
                        }}
                        className={`rounded-xl border p-2.5 text-left font-semibold transition flex flex-col gap-1.5 ${
                          isDark ? "border-[#30264B] bg-[#0D0920] hover:border-[#9475F5]" : "border-[#E9E3F4] bg-[#F8F7FC] hover:border-[#7955DF]"
                        }`}
                      >
                        <Receipt className="h-4 w-4 text-[#10B981]" />
                        <span>Buyer Bill Book</span>
                      </button>
                      <button
                        onClick={() => {
                          setActiveModule("REPORTS");
                          setReportsTab("DAILY_SUMMARY");
                        }}
                        className={`rounded-xl border p-2.5 text-left font-semibold transition flex flex-col gap-1.5 ${
                          isDark ? "border-[#30264B] bg-[#0D0920] hover:border-[#9475F5]" : "border-[#E9E3F4] bg-[#F8F7FC] hover:border-[#7955DF]"
                        }`}
                      >
                        <CreditCard className="h-4 w-4 text-[#F59E0B]" />
                        <span>Cash Drawer Tally</span>
                      </button>
                      <button
                        onClick={() => {
                          setActiveModule("PARTNERS");
                        }}
                        className={`rounded-xl border p-2.5 text-left font-semibold transition flex flex-col gap-1.5 ${
                          isDark ? "border-[#30264B] bg-[#0D0920] hover:border-[#9475F5]" : "border-[#E9E3F4] bg-[#F8F7FC] hover:border-[#7955DF]"
                        }`}
                      >
                        <Users className="h-4 w-4 text-[#B49AFF]" />
                        <span>Farmer Balances</span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              {/* Recent Live Transactions Table */}
              <div
                className={`rounded-2xl border p-6 ${
                  isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                }`}
              >
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <h3 className="text-sm font-bold">Today's Mandi Bill Activity</h3>
                    <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                      Real-time counter cash bills and farmer inward purchase notes
                    </p>
                  </div>
                  <button
                    onClick={() => setActiveModule("BILLING")}
                    className="text-xs font-semibold text-[#9475F5] hover:underline flex items-center gap-1"
                  >
                    <span>View Bill Book</span>
                    <ArrowRight className="h-3 w-3" />
                  </button>
                </div>

                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead>
                      <tr className={`border-b ${isDark ? "border-[#30264B] text-[#B7ADC9]" : "border-[#E9E3F4] text-[#777086]"}`}>
                        <th className="pb-3 font-semibold">Bill / Ref #</th>
                        <th className="pb-3 font-semibold">Party Name</th>
                        <th className="pb-3 font-semibold">Type</th>
                        <th className="pb-3 font-semibold">Gross Amount</th>
                        <th className="pb-3 font-semibold">Settled</th>
                        <th className="pb-3 font-semibold">Balance Due</th>
                        <th className="pb-3 font-semibold text-right">Action</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-opacity-30 divide-[#30264B]">
                      {salesBills.map((b) => (
                        <tr key={b.id} className={`hover:bg-[#9475F5]/5 transition`}>
                          <td className="py-3 font-mono font-bold text-[#9475F5]">{b.billNumber}</td>
                          <td className="py-3 font-semibold">{b.buyer.name}</td>
                          <td className="py-3">
                            <span className="rounded-full bg-emerald-500/10 px-2 py-0.5 text-[10px] font-bold text-emerald-400">
                              SALES BILL
                            </span>
                          </td>
                          <td className="py-3 font-bold">{formatINR(b.grandTotal)}</td>
                          <td className="py-3 text-emerald-400 font-semibold">{formatINR(b.receivedAmount)}</td>
                          <td className="py-3 text-amber-400 font-semibold">{formatINR(b.outstandingAmount)}</td>
                          <td className="py-3 text-right">
                            <button
                              onClick={() => setShowReceiptModal(b)}
                              className="rounded-lg p-1.5 hover:bg-[#9475F5]/20 text-[#9475F5] transition"
                              title="Print Thermal Receipt"
                            >
                              <Printer className="h-4 w-4" />
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* MODULE 2: SMART CHART & AUCTION */}
          {activeModule === "SMART_CHART" && (
            <div className="space-y-6 max-w-7xl mx-auto">
              {/* Header & Sub-tabs */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <h2 className="text-xl font-bold tracking-tight">Smart Chart & Live Bidding Auctions</h2>
                  <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                    Floor lot allocation, bag weighment integration, and real-time wholesale buyer bidding.
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setShowCreateLotModal(true)}
                    className="inline-flex items-center gap-1.5 rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] px-3.5 py-2 text-xs font-bold text-white shadow-glow hover:brightness-110 transition"
                  >
                    <Plus className="h-3.5 w-3.5" />
                    <span>+ New Inward Lot</span>
                  </button>
                </div>
              </div>

              {/* Sub-tab Capsules */}
              <div className="flex gap-2 border-b border-opacity-30 border-[#30264B] pb-3">
                {[
                  { id: "ACTIVE_LOTS", label: "Active Arrival Lots" },
                  { id: "AUCTION_ALLOCATION", label: "Live Floor Auction & Allotment" },
                  { id: "SALES_SUMMARY", label: "Smart Chart Sales Summary" },
                ].map((t) => (
                  <button
                    key={t.id}
                    onClick={() => setSmartChartTab(t.id as any)}
                    className={`rounded-xl px-4 py-2 text-xs font-bold transition-all ${
                      smartChartTab === t.id
                        ? "bg-[#9475F5] text-white shadow-glow"
                        : isDark
                        ? "bg-[#15102B] text-[#B7ADC9] hover:text-white"
                        : "bg-white text-[#777086] hover:text-[#211936]"
                    }`}
                  >
                    {t.label}
                  </button>
                ))}
              </div>

              {/* Tab 1: ACTIVE LOTS */}
              {smartChartTab === "ACTIVE_LOTS" && (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                  {lots.map((lot) => (
                    <div
                      key={lot.id}
                      className={`rounded-2xl border p-5 transition-all hover:border-[#9475F5] ${
                        isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                      }`}
                    >
                      <div className="flex items-center justify-between pb-3 border-b border-opacity-30 border-[#30264B]">
                        <span className="font-mono font-bold text-sm text-[#9475F5]">{lot.lotNumber}</span>
                        <span
                          className={`rounded-full px-2.5 py-0.5 text-[10px] font-bold ${
                            lot.status === "OPEN"
                              ? "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20"
                              : "bg-gray-500/10 text-gray-400"
                          }`}
                        >
                          {lot.status}
                        </span>
                      </div>

                      <div className="mt-3 space-y-2 text-xs">
                        <div className="flex justify-between">
                          <span className={`${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>Farmer / Seller:</span>
                          <span className="font-bold">{lot.seller.name}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className={`${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>Vehicle Number:</span>
                          <span className="font-mono">{lot.vehicleNumber}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className={`${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>Total Packages:</span>
                          <span className="font-bold">{lot.totalBags} Bags</span>
                        </div>
                        <div className="flex justify-between">
                          <span className={`${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>Net Consignment Weight:</span>
                          <span className="font-bold text-[#9475F5]">{lot.netWeight} Kg</span>
                        </div>
                        <div className="flex justify-between pt-2 border-t border-opacity-30 border-[#30264B]">
                          <span className={`${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>Remaining Floor Stock:</span>
                          <span className="font-bold text-amber-400">{lot.remainingBags} Bags ({lot.remainingWeight} Kg)</span>
                        </div>
                      </div>

                      <div className="mt-4 pt-3 flex gap-2">
                        <button
                          onClick={() => {
                            setSelectedLotForAuction(lot);
                            setSmartChartTab("AUCTION_ALLOCATION");
                          }}
                          className="flex-1 rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] py-2 text-center text-xs font-bold text-white shadow-glow hover:brightness-110 transition"
                        >
                          Start Live Bidding
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {/* Tab 2: LIVE FLOOR AUCTION ALLOCATION */}
              {smartChartTab === "AUCTION_ALLOCATION" && (
                <div
                  className={`rounded-2xl border p-6 ${
                    isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                  }`}
                >
                  <div className="max-w-2xl mx-auto space-y-5">
                    <div className="text-center pb-4 border-b border-opacity-30 border-[#30264B]">
                      <span className="rounded-full bg-[#9475F5]/20 text-[#B49AFF] px-3 py-1 text-xs font-bold uppercase tracking-wider">
                        Live Auction Bidding Floor
                      </span>
                      <h3 className="text-xl font-bold mt-2">
                        Allocate Lot: {selectedLotForAuction?.lotNumber || lots[0]?.lotNumber}
                      </h3>
                      <p className={`text-xs mt-1 ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                        Farmer: {selectedLotForAuction?.seller?.name || lots[0]?.seller?.name} • Remaining: {selectedLotForAuction?.remainingBags || lots[0]?.remainingBags} Bags
                      </p>
                    </div>

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div>
                        <label className="block text-xs font-semibold mb-1">Select Winning Buyer</label>
                        <select
                          className={`w-full rounded-xl border p-2.5 text-xs outline-none ${
                            isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                          }`}
                        >
                          {buyers.map((b) => (
                            <option key={b.id} value={b.id}>
                              {b.name} ({b.villageOrCity})
                            </option>
                          ))}
                        </select>
                      </div>
                      <div>
                        <label className="block text-xs font-semibold mb-1">Allotted Bags Count</label>
                        <input
                          type="number"
                          defaultValue="20"
                          className={`w-full rounded-xl border p-2.5 text-xs outline-none ${
                            isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                          }`}
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-semibold mb-1">Winning Bid Rate (₹ / Kg)</label>
                        <input
                          type="number"
                          defaultValue="46"
                          className={`w-full rounded-xl border p-2.5 text-xs font-bold text-[#9475F5] outline-none ${
                            isDark ? "border-[#30264B] bg-[#0D0920]" : "border-[#E9E3F4] bg-white"
                          }`}
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-semibold mb-1">Electronic Scale Total Weight (Kg)</label>
                        <input
                          type="number"
                          defaultValue="1020"
                          className={`w-full rounded-xl border p-2.5 text-xs outline-none ${
                            isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                          }`}
                        />
                      </div>
                    </div>

                    <div className="p-4 rounded-xl border border-dashed border-[#9475F5]/40 bg-[#9475F5]/5 flex items-center justify-between text-xs">
                      <div>
                        <p className="font-semibold text-[#9475F5]">Calculated Line Bid Value</p>
                        <p className={`text-[11px] ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>1,020 Kg × ₹46/Kg + Labour Charges</p>
                      </div>
                      <p className="text-xl font-black text-emerald-400">₹46,920.00</p>
                    </div>

                    <button
                      onClick={() => {
                        showToast("Smart Chart Auction Allotment Recorded & Invoiced!");
                        setSmartChartTab("SALES_SUMMARY");
                      }}
                      className="w-full rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] py-3 text-xs font-bold text-white shadow-glow hover:brightness-110 transition"
                    >
                      Confirm Allotment & Generate Smart Chart Slip
                    </button>
                  </div>
                </div>
              )}

              {/* Tab 3: SALES SUMMARY */}
              {smartChartTab === "SALES_SUMMARY" && (
                <div
                  className={`rounded-2xl border p-6 ${
                    isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                  }`}
                >
                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-xs">
                      <thead>
                        <tr className={`border-b ${isDark ? "border-[#30264B] text-[#B7ADC9]" : "border-[#E9E3F4] text-[#777086]"}`}>
                          <th className="pb-3 font-semibold">Chart Slip #</th>
                          <th className="pb-3 font-semibold">Lot Number</th>
                          <th className="pb-3 font-semibold">Winning Buyer</th>
                          <th className="pb-3 font-semibold">Bid Rate (₹/Kg)</th>
                          <th className="pb-3 font-semibold">Allotted Bags</th>
                          <th className="pb-3 font-semibold">Weight</th>
                          <th className="pb-3 font-semibold">Total Amount</th>
                          <th className="pb-3 font-semibold text-right">Status</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-opacity-30 divide-[#30264B]">
                        {MOCK_SMART_CHARTS.map((sc) => (
                          <tr key={sc.id}>
                            <td className="py-3 font-mono font-bold text-[#9475F5]">{sc.chartNumber}</td>
                            <td className="py-3 font-mono">{sc.lot.lotNumber}</td>
                            <td className="py-3 font-semibold">{sc.buyer.name}</td>
                            <td className="py-3 font-bold">₹{sc.bidRate}</td>
                            <td className="py-3">{sc.allottedBags} Bags</td>
                            <td className="py-3">{sc.totalWeight} Kg</td>
                            <td className="py-3 font-bold text-emerald-400">{formatINR(sc.totalAmount)}</td>
                            <td className="py-3 text-right">
                              <span className="rounded-full bg-[#9475F5]/20 text-[#B49AFF] px-2.5 py-0.5 text-[10px] font-bold">
                                {sc.status}
                              </span>
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

          {/* MODULE 3: GOODS MANAGEMENT */}
          {activeModule === "GOODS" && (
            <div className="space-y-6 max-w-7xl mx-auto">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <h2 className="text-xl font-bold tracking-tight">Goods & Multi-Product Inward</h2>
                  <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                    Daily vehicle arrival registrations, automatic electronic tare deductions, and crop catalogue.
                  </p>
                </div>
                <button
                  onClick={() => setShowCreateLotModal(true)}
                  className="inline-flex items-center gap-1.5 rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] px-3.5 py-2 text-xs font-bold text-white shadow-glow hover:brightness-110 transition"
                >
                  <Plus className="h-3.5 w-3.5" />
                  <span>+ Inward Goods Entry</span>
                </button>
              </div>

              <div
                className={`rounded-2xl border p-6 ${
                  isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                }`}
              >
                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead>
                      <tr className={`border-b ${isDark ? "border-[#30264B] text-[#B7ADC9]" : "border-[#E9E3F4] text-[#777086]"}`}>
                        <th className="pb-3 font-semibold">Entry #</th>
                        <th className="pb-3 font-semibold">Farmer / Seller</th>
                        <th className="pb-3 font-semibold">Crop Produce</th>
                        <th className="pb-3 font-semibold">Vehicle #</th>
                        <th className="pb-3 font-semibold">Bags</th>
                        <th className="pb-3 font-semibold">Gross (Kg)</th>
                        <th className="pb-3 font-semibold">Tare (Kg)</th>
                        <th className="pb-3 font-semibold">Net Weight</th>
                        <th className="pb-3 font-semibold text-right">Status</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-opacity-30 divide-[#30264B]">
                      {MOCK_GOODS_ENTRIES.map((entry) => (
                        <tr key={entry.id}>
                          <td className="py-3 font-mono font-bold text-[#9475F5]">{entry.entryNumber}</td>
                          <td className="py-3 font-semibold">{entry.seller.name}</td>
                          <td className="py-3">{entry.goods.name}</td>
                          <td className="py-3 font-mono">{entry.vehicleNumber}</td>
                          <td className="py-3 font-bold">{entry.bagsCount} Bags</td>
                          <td className="py-3">{entry.grossWeight}</td>
                          <td className="py-3 text-rose-400">-{entry.tareWeight}</td>
                          <td className="py-3 font-bold text-emerald-400">{entry.netWeight} Kg</td>
                          <td className="py-3 text-right">
                            <span className="rounded-full bg-emerald-500/10 text-emerald-400 px-2.5 py-0.5 text-[10px] font-bold">
                              {entry.status}
                            </span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* MODULE 4: BILLING MANAGEMENT */}
          {activeModule === "BILLING" && (
            <div className="space-y-6 max-w-7xl mx-auto">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <h2 className="text-xl font-bold tracking-tight">Mandi Bill Books & Invoices</h2>
                  <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                    Instant cash and credit wholesale billing, hamali/labour deductions, and thermal receipt printing.
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setShowCreateBillModal(true)}
                    className="inline-flex items-center gap-1.5 rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] px-3.5 py-2 text-xs font-bold text-white shadow-glow hover:brightness-110 transition"
                  >
                    <Plus className="h-3.5 w-3.5" />
                    <span>+ Create Sales Bill</span>
                  </button>
                </div>
              </div>

              {/* Sub-tabs: Sales vs Purchases */}
              <div className="flex gap-2 border-b border-opacity-30 border-[#30264B] pb-3">
                <button
                  onClick={() => setBillingTab("SALES_BILLS")}
                  className={`rounded-xl px-4 py-2 text-xs font-bold transition-all ${
                    billingTab === "SALES_BILLS"
                      ? "bg-[#9475F5] text-white shadow-glow"
                      : isDark
                      ? "bg-[#15102B] text-[#B7ADC9] hover:text-white"
                      : "bg-white text-[#777086] hover:text-[#211936]"
                  }`}
                >
                  Wholesale Buyer Sales Bills ({salesBills.length})
                </button>
                <button
                  onClick={() => setBillingTab("PURCHASE_BILLS")}
                  className={`rounded-xl px-4 py-2 text-xs font-bold transition-all ${
                    billingTab === "PURCHASE_BILLS"
                      ? "bg-[#9475F5] text-white shadow-glow"
                      : isDark
                      ? "bg-[#15102B] text-[#B7ADC9] hover:text-white"
                      : "bg-white text-[#777086] hover:text-[#211936]"
                  }`}
                >
                  Farmer Purchase Settlement Bills ({purchaseBills.length})
                </button>
              </div>

              {/* Table */}
              <div
                className={`rounded-2xl border p-6 ${
                  isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                }`}
              >
                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead>
                      <tr className={`border-b ${isDark ? "border-[#30264B] text-[#B7ADC9]" : "border-[#E9E3F4] text-[#777086]"}`}>
                        <th className="pb-3 font-semibold">Bill #</th>
                        <th className="pb-3 font-semibold">Date</th>
                        <th className="pb-3 font-semibold">{billingTab === "SALES_BILLS" ? "Buyer Name" : "Farmer Supplier"}</th>
                        <th className="pb-3 font-semibold">Gross Amount</th>
                        <th className="pb-3 font-semibold">Labour / Cess</th>
                        <th className="pb-3 font-semibold">Grand Total</th>
                        <th className="pb-3 font-semibold">Settled</th>
                        <th className="pb-3 font-semibold">Due Balance</th>
                        <th className="pb-3 font-semibold text-right">Receipt</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-opacity-30 divide-[#30264B]">
                      {(billingTab === "SALES_BILLS" ? salesBills : purchaseBills).map((bill: any) => (
                        <tr key={bill.id}>
                          <td className="py-3 font-mono font-bold text-[#9475F5]">{bill.billNumber}</td>
                          <td className="py-3">{new Date(bill.billDate).toLocaleDateString()}</td>
                          <td className="py-3 font-semibold">{bill.buyer?.name || bill.seller?.name}</td>
                          <td className="py-3">{formatINR(bill.grossAmount)}</td>
                          <td className="py-3">₹{(bill.labourCharges || 0) + (bill.marketCess || 0)}</td>
                          <td className="py-3 font-bold text-emerald-400">{formatINR(bill.grandTotal)}</td>
                          <td className="py-3 text-emerald-400 font-semibold">{formatINR(bill.receivedAmount || bill.paidAmount)}</td>
                          <td className="py-3 text-amber-400 font-semibold">{formatINR(bill.outstandingAmount)}</td>
                          <td className="py-3 text-right">
                            <button
                              onClick={() => setShowReceiptModal(bill)}
                              className="rounded-lg p-1.5 hover:bg-[#9475F5]/20 text-[#9475F5] transition"
                              title="Print Thermal Receipt"
                            >
                              <Printer className="h-4 w-4" />
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* MODULE 5: PARTNERS (BUYERS & SELLERS) */}
          {activeModule === "PARTNERS" && (
            <div className="space-y-6 max-w-7xl mx-auto">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <h2 className="text-xl font-bold tracking-tight">Mandi Directory: Farmers & Buyers</h2>
                  <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                    Acquaintance ledger limits, WhatsApp contact cards, and pending balance settlements.
                  </p>
                </div>
                <button
                  onClick={() => setShowAddPartnerModal(true)}
                  className="inline-flex items-center gap-1.5 rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] px-3.5 py-2 text-xs font-bold text-white shadow-glow hover:brightness-110 transition"
                >
                  <Plus className="h-3.5 w-3.5" />
                  <span>+ Add New Partner</span>
                </button>
              </div>

              <div className="flex gap-2 border-b border-opacity-30 border-[#30264B] pb-3">
                {[
                  { id: "ALL", label: `All Partners (${buyers.length + sellers.length})` },
                  { id: "BUYERS", label: `Wholesale Buyers (${buyers.length})` },
                  { id: "SELLERS", label: `Farmers & Sellers (${sellers.length})` },
                ].map((t) => (
                  <button
                    key={t.id}
                    onClick={() => setPartnersTab(t.id as any)}
                    className={`rounded-xl px-4 py-2 text-xs font-bold transition-all ${
                      partnersTab === t.id
                        ? "bg-[#9475F5] text-white shadow-glow"
                        : isDark
                        ? "bg-[#15102B] text-[#B7ADC9] hover:text-white"
                        : "bg-white text-[#777086] hover:text-[#211936]"
                    }`}
                  >
                    {t.label}
                  </button>
                ))}
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                {(partnersTab === "ALL"
                  ? [...buyers.map((b) => ({ ...b, role: "BUYER" })), ...sellers.map((s) => ({ ...s, role: "SELLER" }))]
                  : partnersTab === "BUYERS"
                  ? buyers.map((b) => ({ ...b, role: "BUYER" }))
                  : sellers.map((s) => ({ ...s, role: "SELLER" }))
                ).map((partner: any) => (
                  <div
                    key={partner.id}
                    className={`rounded-2xl border p-5 transition hover:border-[#9475F5] ${
                      isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                    }`}
                  >
                    <div className="flex items-center justify-between pb-3 border-b border-opacity-30 border-[#30264B]">
                      <div className="flex items-center gap-2">
                        <span className="font-bold text-sm">{partner.name}</span>
                        <span
                          className={`rounded-full px-2 py-0.5 text-[9px] font-bold ${
                            partner.role === "BUYER"
                              ? "bg-blue-500/20 text-blue-400"
                              : "bg-emerald-500/20 text-emerald-400"
                          }`}
                        >
                          {partner.role}
                        </span>
                      </div>
                      <span className="font-mono text-xs text-[#9475F5] font-bold">{partner.code}</span>
                    </div>

                    <div className="mt-3 space-y-1.5 text-xs">
                      <div className="flex items-center gap-2 text-opacity-80">
                        <Phone className="h-3.5 w-3.5 text-[#9475F5]" />
                        <span>{partner.phone}</span>
                      </div>
                      <div className="flex items-center gap-2 text-opacity-80">
                        <MapPin className="h-3.5 w-3.5 text-[#9475F5]" />
                        <span>{partner.villageOrCity}</span>
                      </div>
                      <div className="flex justify-between pt-2 border-t border-opacity-30 border-[#30264B]">
                        <span className={`${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>Current Balance:</span>
                        <span className="font-bold text-amber-400">{formatINR(partner.currentBalance)}</span>
                      </div>
                    </div>

                    <div className="mt-4 pt-3 flex gap-2">
                      <button
                        onClick={() => {
                          setActiveModule("LEDGER");
                          showToast(`Opened ledger statement for ${partner.name}`);
                        }}
                        className={`flex-1 rounded-xl border py-2 text-center text-xs font-semibold transition ${
                          isDark ? "border-[#30264B] hover:bg-[#1E173D]" : "border-[#E9E3F4] hover:bg-[#F2EEFA]"
                        }`}
                      >
                        View Ledger
                      </button>
                      <button
                        onClick={() => showToast(`Sent WhatsApp statement link to ${partner.phone}`)}
                        className="rounded-xl bg-emerald-600 px-3 py-2 text-white hover:bg-emerald-500 transition"
                        title="Share Statement on WhatsApp"
                      >
                        <Share2 className="h-3.5 w-3.5" />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* MODULE 6: LEDGER & ADVANCES */}
          {activeModule === "LEDGER" && (
            <div className="space-y-6 max-w-7xl mx-auto">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <h2 className="text-xl font-bold tracking-tight">ACID Ledgers & Farmer Advances</h2>
                  <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                    Pre-season advances given to farmers, running balance debits/credits, and transaction history.
                  </p>
                </div>
                <button
                  onClick={() => setShowRecordAdvanceModal(true)}
                  className="inline-flex items-center gap-1.5 rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] px-3.5 py-2 text-xs font-bold text-white shadow-glow hover:brightness-110 transition"
                >
                  <Plus className="h-3.5 w-3.5" />
                  <span>+ Record Farmer Advance</span>
                </button>
              </div>

              {/* Sub-tabs */}
              <div className="flex gap-2 border-b border-opacity-30 border-[#30264B] pb-3">
                <button
                  onClick={() => setLedgerTab("BUYER_LEDGER")}
                  className={`rounded-xl px-4 py-2 text-xs font-bold transition-all ${
                    ledgerTab === "BUYER_LEDGER"
                      ? "bg-[#9475F5] text-white shadow-glow"
                      : isDark
                      ? "bg-[#15102B] text-[#B7ADC9] hover:text-white"
                      : "bg-white text-[#777086] hover:text-[#211936]"
                  }`}
                >
                  Buyer Wholesale Receivables
                </button>
                <button
                  onClick={() => setLedgerTab("SELLER_LEDGER")}
                  className={`rounded-xl px-4 py-2 text-xs font-bold transition-all ${
                    ledgerTab === "SELLER_LEDGER"
                      ? "bg-[#9475F5] text-white shadow-glow"
                      : isDark
                      ? "bg-[#15102B] text-[#B7ADC9] hover:text-white"
                      : "bg-white text-[#777086] hover:text-[#211936]"
                  }`}
                >
                  Farmer Supplier Payables
                </button>
                <button
                  onClick={() => setLedgerTab("ADVANCES")}
                  className={`rounded-xl px-4 py-2 text-xs font-bold transition-all ${
                    ledgerTab === "ADVANCES"
                      ? "bg-[#9475F5] text-white shadow-glow"
                      : isDark
                      ? "bg-[#15102B] text-[#B7ADC9] hover:text-white"
                      : "bg-white text-[#777086] hover:text-[#211936]"
                  }`}
                >
                  Farmer Advances Ledger ({advances.length})
                </button>
              </div>

              {/* Ledger Statement Table */}
              <div
                className={`rounded-2xl border p-6 ${
                  isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                }`}
              >
                {ledgerTab === "ADVANCES" ? (
                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-xs">
                      <thead>
                        <tr className={`border-b ${isDark ? "border-[#30264B] text-[#B7ADC9]" : "border-[#E9E3F4] text-[#777086]"}`}>
                          <th className="pb-3 font-semibold">Advance Ref #</th>
                          <th className="pb-3 font-semibold">Farmer Name</th>
                          <th className="pb-3 font-semibold">Date Given</th>
                          <th className="pb-3 font-semibold">Total Given</th>
                          <th className="pb-3 font-semibold">Deducted on Lots</th>
                          <th className="pb-3 font-semibold">Remaining Due</th>
                          <th className="pb-3 font-semibold text-right">Status</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-opacity-30 divide-[#30264B]">
                        {advances.map((adv) => (
                          <tr key={adv.id}>
                            <td className="py-3 font-mono font-bold text-[#9475F5]">{adv.advanceNumber}</td>
                            <td className="py-3 font-semibold">{adv.seller.name}</td>
                            <td className="py-3">{new Date(adv.advanceDate).toLocaleDateString()}</td>
                            <td className="py-3 font-bold">{formatINR(adv.amount)}</td>
                            <td className="py-3 text-emerald-400 font-semibold">{formatINR(adv.settledAmount)}</td>
                            <td className="py-3 text-amber-400 font-bold">{formatINR(adv.outstandingAmount)}</td>
                            <td className="py-3 text-right">
                              <span className="rounded-full bg-amber-500/20 text-amber-400 px-2.5 py-0.5 text-[10px] font-bold">
                                {adv.status}
                              </span>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                ) : (
                  <div className="space-y-4">
                    <div className="flex items-center justify-between pb-3 border-b border-opacity-30 border-[#30264B]">
                      <h4 className="text-xs font-bold uppercase tracking-wider">
                        {ledgerTab === "BUYER_LEDGER" ? "Active Buyer Balance Summary" : "Farmer Supplier Balance Summary"}
                      </h4>
                      <span className="text-xs font-bold text-[#9475F5]">ACID Compliant</span>
                    </div>
                    <div className="overflow-x-auto">
                      <table className="w-full text-left text-xs">
                        <thead>
                          <tr className={`border-b ${isDark ? "border-[#30264B] text-[#B7ADC9]" : "border-[#E9E3F4] text-[#777086]"}`}>
                            <th className="pb-3 font-semibold">Code</th>
                            <th className="pb-3 font-semibold">Party Name</th>
                            <th className="pb-3 font-semibold">Location</th>
                            <th className="pb-3 font-semibold">Opening Balance</th>
                            <th className="pb-3 font-semibold">Total Debits</th>
                            <th className="pb-3 font-semibold">Total Credits</th>
                            <th className="pb-3 font-semibold text-right">Net Closing Balance</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-opacity-30 divide-[#30264B]">
                          {(ledgerTab === "BUYER_LEDGER" ? buyers : sellers).map((p: any) => (
                            <tr key={p.id}>
                              <td className="py-3 font-mono font-bold text-[#9475F5]">{p.code}</td>
                              <td className="py-3 font-semibold">{p.name}</td>
                              <td className="py-3">{p.villageOrCity}</td>
                              <td className="py-3">{formatINR(p.openingBalance)}</td>
                              <td className="py-3 text-rose-400">{formatINR(p.currentBalance + 12000)}</td>
                              <td className="py-3 text-emerald-400">{formatINR(12000)}</td>
                              <td className="py-3 text-right font-black text-amber-400">{formatINR(p.currentBalance)}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* MODULE 7: INVENTORY & STOCK */}
          {activeModule === "INVENTORY" && (
            <div className="space-y-6 max-w-7xl mx-auto">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <h2 className="text-xl font-bold tracking-tight">Yard Inventory & Floor Stock</h2>
                  <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                    Real-time stock valuation in INR, inward arrivals vs sales allotments, and low stock indicators.
                  </p>
                </div>
              </div>

              <div
                className={`rounded-2xl border p-6 ${
                  isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                }`}
              >
                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead>
                      <tr className={`border-b ${isDark ? "border-[#30264B] text-[#B7ADC9]" : "border-[#E9E3F4] text-[#777086]"}`}>
                        <th className="pb-3 font-semibold">Produce Code</th>
                        <th className="pb-3 font-semibold">Crop Produce</th>
                        <th className="pb-3 font-semibold">Unit Type</th>
                        <th className="pb-3 font-semibold">Current Floor Stock</th>
                        <th className="pb-3 font-semibold">Reserved / Allotted</th>
                        <th className="pb-3 font-semibold">Available for Auction</th>
                        <th className="pb-3 font-semibold">Avg Cost</th>
                        <th className="pb-3 font-semibold text-right">Stock Valuation</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-opacity-30 divide-[#30264B]">
                      {MOCK_INVENTORY.map((inv) => (
                        <tr key={inv.id}>
                          <td className="py-3 font-mono font-bold text-[#9475F5]">{inv.goods.code}</td>
                          <td className="py-3 font-bold">{inv.goods.name}</td>
                          <td className="py-3">{inv.goods.unit}</td>
                          <td className="py-3 font-bold text-sm">{inv.currentStock}</td>
                          <td className="py-3 text-amber-400">{inv.reservedStock}</td>
                          <td className="py-3 font-bold text-emerald-400">{inv.availableStock}</td>
                          <td className="py-3">₹{inv.averagePurchaseCost}</td>
                          <td className="py-3 text-right font-black text-[#9475F5]">{formatINR(inv.totalValue)}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* MODULE 8: REPORTS & DAILY SUMMARY */}
          {activeModule === "REPORTS" && (
            <div className="space-y-6 max-w-7xl mx-auto">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <h2 className="text-xl font-bold tracking-tight">Reports & Daily Cash Tally</h2>
                  <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                    Daily Mandi Cash Reconciliation Slip, APMC cess audits, and gross margin profit & loss.
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => showToast("Exporting Mandi Daily Report to Excel...")}
                    className={`inline-flex items-center gap-1.5 rounded-xl border px-3.5 py-2 text-xs font-semibold transition ${
                      isDark ? "border-[#30264B] bg-[#15102B] hover:border-[#9475F5]" : "border-[#E9E3F4] bg-white hover:border-[#7955DF]"
                    }`}
                  >
                    <Download className="h-3.5 w-3.5 text-[#9475F5]" />
                    <span>Export Excel</span>
                  </button>
                  <button
                    onClick={() => showToast("Generated PDF Report Document")}
                    className="inline-flex items-center gap-1.5 rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] px-3.5 py-2 text-xs font-bold text-white shadow-glow hover:brightness-110 transition"
                  >
                    <Printer className="h-3.5 w-3.5" />
                    <span>Print PDF</span>
                  </button>
                </div>
              </div>

              {/* Sub-tabs */}
              <div className="flex gap-2 border-b border-opacity-30 border-[#30264B] pb-3">
                {[
                  { id: "DAILY_SUMMARY", label: "Daily Cash Drawer Tally" },
                  { id: "SALES_REPORT", label: "Wholesale Sales Breakdown" },
                  { id: "GROSS_PROFIT", label: "Gross Profit & Loss (COGS)" },
                ].map((t) => (
                  <button
                    key={t.id}
                    onClick={() => setReportsTab(t.id as any)}
                    className={`rounded-xl px-4 py-2 text-xs font-bold transition-all ${
                      reportsTab === t.id
                        ? "bg-[#9475F5] text-white shadow-glow"
                        : isDark
                        ? "bg-[#15102B] text-[#B7ADC9] hover:text-white"
                        : "bg-white text-[#777086] hover:text-[#211936]"
                    }`}
                  >
                    {t.label}
                  </button>
                ))}
              </div>

              {/* Content */}
              {reportsTab === "DAILY_SUMMARY" && (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {/* Mandi Daily Cash Slip */}
                  <div
                    className={`rounded-2xl border p-6 ${
                      isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                    }`}
                  >
                    <div className="flex items-center justify-between pb-4 border-b border-opacity-30 border-[#30264B]">
                      <div>
                        <h4 className="font-bold text-sm">Mandi Cash Register Reconciliation</h4>
                        <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                          Physical cash opening vs day closing
                        </p>
                      </div>
                      <span className="rounded-full bg-emerald-500/20 text-emerald-400 px-2.5 py-0.5 text-xs font-bold">
                        BALANCED
                      </span>
                    </div>

                    <div className="mt-4 space-y-3 text-xs">
                      <div className="flex justify-between py-1.5 border-b border-opacity-20 border-[#30264B]">
                        <span>Yesterday Cash in Hand (Opening)</span>
                        <span className="font-bold">{formatINR(MOCK_DAILY_SUMMARY.cashInHandOpening)}</span>
                      </div>
                      <div className="flex justify-between py-1.5 border-b border-opacity-20 border-[#30264B] text-emerald-400">
                        <span>+ Total Cash Sales Collections</span>
                        <span className="font-bold">{formatINR(MOCK_DAILY_SUMMARY.cashCollected)}</span>
                      </div>
                      <div className="flex justify-between py-1.5 border-b border-opacity-20 border-[#30264B] text-rose-400">
                        <span>- Farmer Inward Cash Deductions & Pay</span>
                        <span className="font-bold">-{formatINR(MOCK_DAILY_SUMMARY.cashPaid)}</span>
                      </div>
                      <div className="flex justify-between py-2 text-sm font-black text-[#9475F5] border-t-2 border-[#9475F5]/40">
                        <span>Net Verified Cash in Hand</span>
                        <span>{formatINR(MOCK_DAILY_SUMMARY.cashInHandClosing)}</span>
                      </div>
                    </div>
                  </div>

                  {/* Volume Summary */}
                  <div
                    className={`rounded-2xl border p-6 ${
                      isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                    }`}
                  >
                    <h4 className="font-bold text-sm mb-4">Daily Volume Indicators</h4>
                    <div className="grid grid-cols-2 gap-4">
                      <div className={`p-4 rounded-xl border ${isDark ? "border-[#30264B] bg-[#0D0920]" : "border-[#E9E3F4] bg-[#F8F7FC]"}`}>
                        <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>Arrival Lots</p>
                        <p className="text-xl font-black mt-1">{MOCK_DAILY_SUMMARY.totalArrivalLots} Lots</p>
                      </div>
                      <div className={`p-4 rounded-xl border ${isDark ? "border-[#30264B] bg-[#0D0920]" : "border-[#E9E3F4] bg-[#F8F7FC]"}`}>
                        <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>Inward Packages</p>
                        <p className="text-xl font-black mt-1 text-[#9475F5]">{MOCK_DAILY_SUMMARY.totalBagsInward} Bags</p>
                      </div>
                      <div className={`p-4 rounded-xl border ${isDark ? "border-[#30264B] bg-[#0D0920]" : "border-[#E9E3F4] bg-[#F8F7FC]"}`}>
                        <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>Sales Bills Issued</p>
                        <p className="text-xl font-black mt-1 text-emerald-400">{MOCK_DAILY_SUMMARY.totalSalesBills} Bills</p>
                      </div>
                      <div className={`p-4 rounded-xl border ${isDark ? "border-[#30264B] bg-[#0D0920]" : "border-[#E9E3F4] bg-[#F8F7FC]"}`}>
                        <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>Trading Volume</p>
                        <p className="text-xl font-black mt-1 text-amber-400">{MOCK_DAILY_SUMMARY.totalSalesVolumeKg} Kg</p>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {reportsTab === "GROSS_PROFIT" && (
                <div
                  className={`rounded-2xl border p-6 ${
                    isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                  }`}
                >
                  <h4 className="font-bold text-sm mb-4">Gross Margin & Operating P&L</h4>
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                    <div className={`p-4 rounded-xl border ${isDark ? "border-[#30264B] bg-[#0D0920]" : "border-[#E9E3F4] bg-[#F8F7FC]"}`}>
                      <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>Gross Sales Turnover</p>
                      <p className="text-xl font-black mt-1 text-emerald-400">{formatINR(MOCK_PROFIT_LOSS.grossSales)}</p>
                    </div>
                    <div className={`p-4 rounded-xl border ${isDark ? "border-[#30264B] bg-[#0D0920]" : "border-[#E9E3F4] bg-[#F8F7FC]"}`}>
                      <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>Cost of Goods Sold (COGS)</p>
                      <p className="text-xl font-black mt-1 text-rose-400">-{formatINR(MOCK_PROFIT_LOSS.costOfGoodsSold)}</p>
                    </div>
                    <div className={`p-4 rounded-xl border ${isDark ? "border-[#30264B] bg-[#0D0920]" : "border-[#E9E3F4] bg-[#F8F7FC]"}`}>
                      <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>Net Operating Gross Profit</p>
                      <p className="text-xl font-black mt-1 text-[#9475F5]">{formatINR(MOCK_PROFIT_LOSS.netOperatingIncome)}</p>
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* MODULE 9: SETTINGS */}
          {activeModule === "SETTINGS" && (
            <div className="space-y-6 max-w-7xl mx-auto">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <h2 className="text-xl font-bold tracking-tight">Mandi Enterprise Settings</h2>
                  <p className={`text-xs ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}>
                    Configure shop details, APMC cess rates, staff access permissions, and WhatsApp receipt templates.
                  </p>
                </div>
              </div>

              <div
                className={`rounded-2xl border p-6 ${
                  isDark ? "border-[#30264B] bg-[#15102B]" : "border-[#E9E3F4] bg-white"
                }`}
              >
                <div className="max-w-3xl space-y-5">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs font-semibold mb-1">Mandi Business / Shop Name</label>
                      <input
                        type="text"
                        defaultValue={MOCK_BUSINESS_PROFILE.profile.businessName}
                        className={`w-full rounded-xl border p-2.5 text-xs outline-none ${
                          isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                        }`}
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold mb-1">APMC License Number</label>
                      <input
                        type="text"
                        defaultValue={MOCK_BUSINESS_PROFILE.profile.apmcLicenseNumber}
                        className={`w-full rounded-xl border p-2.5 text-xs font-mono outline-none ${
                          isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                        }`}
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold mb-1">GSTIN (Optional)</label>
                      <input
                        type="text"
                        defaultValue={MOCK_BUSINESS_PROFILE.profile.gstNumber}
                        className={`w-full rounded-xl border p-2.5 text-xs font-mono outline-none ${
                          isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                        }`}
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold mb-1">Yard Address</label>
                      <input
                        type="text"
                        defaultValue={MOCK_BUSINESS_PROFILE.profile.addressLine1}
                        className={`w-full rounded-xl border p-2.5 text-xs outline-none ${
                          isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                        }`}
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold mb-1">Default Hamali / Labour Fee (₹ per Bag)</label>
                      <input
                        type="number"
                        defaultValue={MOCK_BUSINESS_PROFILE.settings.defaultLabourPerBag}
                        className={`w-full rounded-xl border p-2.5 text-xs outline-none ${
                          isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                        }`}
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold mb-1">APMC Market Cess Fee (%)</label>
                      <input
                        type="number"
                        defaultValue={MOCK_BUSINESS_PROFILE.settings.defaultMarketCessPercent}
                        className={`w-full rounded-xl border p-2.5 text-xs outline-none ${
                          isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                        }`}
                      />
                    </div>
                  </div>

                  <div className="pt-4 border-t border-opacity-30 border-[#30264B]">
                    <button
                      onClick={() => showToast("Mandi Enterprise Settings updated successfully!")}
                      className="rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] px-5 py-2.5 text-xs font-bold text-white shadow-glow hover:brightness-110 transition"
                    >
                      Save Configuration Changes
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}
        </main>
      </div>

      {/* CREATE LOT MODAL */}
      {showCreateLotModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
          <div
            className={`w-full max-w-lg rounded-3xl border p-6 shadow-2xl ${
              isDark ? "border-[#30264B] bg-[#15102B] text-white" : "border-[#E9E3F4] bg-white text-[#211936]"
            }`}
          >
            <div className="flex items-center justify-between pb-4 border-b border-opacity-30 border-[#30264B]">
              <div className="flex items-center gap-2">
                <PackagePlus className="h-5 w-5 text-[#9475F5]" />
                <h3 className="font-bold text-sm">New Multi-Product Inward Lot</h3>
              </div>
              <button onClick={() => setShowCreateLotModal(false)} className="rounded-lg p-1">
                <X className="h-4 w-4" />
              </button>
            </div>

            <div className="mt-4 space-y-4 text-xs">
              <div>
                <label className="block font-semibold mb-1">Supplier / Farmer</label>
                <select
                  value={newLotSupplier}
                  onChange={(e) => setNewLotSupplier(e.target.value)}
                  className={`w-full rounded-xl border p-2.5 outline-none ${
                    isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                  }`}
                >
                  {sellers.map((s) => (
                    <option key={s.id} value={s.name}>
                      {s.name} ({s.villageOrCity})
                    </option>
                  ))}
                </select>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold mb-1">Crop Produce</label>
                  <select
                    value={newLotProduct}
                    onChange={(e) => setNewLotProduct(e.target.value)}
                    className={`w-full rounded-xl border p-2.5 outline-none ${
                      isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                    }`}
                  >
                    {goodsList.map((g) => (
                      <option key={g.id} value={g.name}>
                        {g.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block font-semibold mb-1">Vehicle / Lorry #</label>
                  <input
                    type="text"
                    value={newLotVehicle}
                    onChange={(e) => setNewLotVehicle(e.target.value)}
                    className={`w-full rounded-xl border p-2.5 outline-none ${
                      isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                    }`}
                  />
                </div>
              </div>

              <div className="grid grid-cols-3 gap-3">
                <div>
                  <label className="block font-semibold mb-1">Bags Count</label>
                  <input
                    type="number"
                    value={newLotBags}
                    onChange={(e) => setNewLotBags(e.target.value)}
                    className={`w-full rounded-xl border p-2.5 outline-none ${
                      isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                    }`}
                  />
                </div>
                <div>
                  <label className="block font-semibold mb-1">Gross (Kg)</label>
                  <input
                    type="number"
                    value={newLotGross}
                    onChange={(e) => setNewLotGross(e.target.value)}
                    className={`w-full rounded-xl border p-2.5 outline-none ${
                      isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                    }`}
                  />
                </div>
                <div>
                  <label className="block font-semibold mb-1">Empty Tare (Kg)</label>
                  <input
                    type="number"
                    value={newLotTare}
                    onChange={(e) => setNewLotTare(e.target.value)}
                    className={`w-full rounded-xl border p-2.5 outline-none ${
                      isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                    }`}
                  />
                </div>
              </div>

              <div className="p-3 rounded-xl bg-[#9475F5]/10 border border-[#9475F5]/20 flex justify-between items-center font-semibold">
                <span>Calculated Net Consignment Weight:</span>
                <span className="text-emerald-400 font-bold">
                  {(parseFloat(newLotGross) || 0) - (parseFloat(newLotTare) || 0)} Kg
                </span>
              </div>
            </div>

            <div className="mt-6 flex justify-end gap-2.5">
              <button
                onClick={() => setShowCreateLotModal(false)}
                className={`rounded-xl border px-4 py-2 text-xs font-semibold ${
                  isDark ? "border-[#30264B] hover:bg-[#15102B]" : "border-[#E9E3F4] hover:bg-[#F2EEFA]"
                }`}
              >
                Cancel
              </button>
              <button
                onClick={handleCreateLot}
                className="rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] px-5 py-2 text-xs font-bold text-white shadow-glow hover:brightness-110"
              >
                Save Inward Lot
              </button>
            </div>
          </div>
        </div>
      )}

      {/* CREATE SALES BILL MODAL */}
      {showCreateBillModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
          <div
            className={`w-full max-w-lg rounded-3xl border p-6 shadow-2xl ${
              isDark ? "border-[#30264B] bg-[#15102B] text-white" : "border-[#E9E3F4] bg-white text-[#211936]"
            }`}
          >
            <div className="flex items-center justify-between pb-4 border-b border-opacity-30 border-[#30264B]">
              <div className="flex items-center gap-2">
                <Receipt className="h-5 w-5 text-[#9475F5]" />
                <h3 className="font-bold text-sm">Create Wholesale Sales Bill</h3>
              </div>
              <button onClick={() => setShowCreateBillModal(false)} className="rounded-lg p-1">
                <X className="h-4 w-4" />
              </button>
            </div>

            <div className="mt-4 space-y-4 text-xs">
              <div>
                <label className="block font-semibold mb-1">Customer / Wholesale Buyer</label>
                <select
                  value={newBillBuyer}
                  onChange={(e) => setNewBillBuyer(e.target.value)}
                  className={`w-full rounded-xl border p-2.5 outline-none ${
                    isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                  }`}
                >
                  {buyers.map((b) => (
                    <option key={b.id} value={b.name}>
                      {b.name} ({b.villageOrCity})
                    </option>
                  ))}
                </select>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold mb-1">Crop Allotment</label>
                  <select
                    value={newBillProduct}
                    onChange={(e) => setNewBillProduct(e.target.value)}
                    className={`w-full rounded-xl border p-2.5 outline-none ${
                      isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                    }`}
                  >
                    {goodsList.map((g) => (
                      <option key={g.id} value={g.name}>
                        {g.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block font-semibold mb-1">Selling Rate (₹/Kg)</label>
                  <input
                    type="number"
                    value={newBillRate}
                    onChange={(e) => setNewBillRate(e.target.value)}
                    className={`w-full rounded-xl border p-2.5 outline-none font-bold text-[#9475F5] ${
                      isDark ? "border-[#30264B] bg-[#0D0920]" : "border-[#E9E3F4] bg-white"
                    }`}
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold mb-1">Weight (Kg)</label>
                  <input
                    type="number"
                    value={newBillWeight}
                    onChange={(e) => setNewBillWeight(e.target.value)}
                    className={`w-full rounded-xl border p-2.5 outline-none ${
                      isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                    }`}
                  />
                </div>
                <div>
                  <label className="block font-semibold mb-1">Bags Quantity</label>
                  <input
                    type="number"
                    value={newBillBags}
                    onChange={(e) => setNewBillBags(e.target.value)}
                    className={`w-full rounded-xl border p-2.5 outline-none ${
                      isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                    }`}
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold mb-1">Labour / Hamali (₹)</label>
                  <input
                    type="number"
                    value={newBillLabour}
                    onChange={(e) => setNewBillLabour(e.target.value)}
                    className={`w-full rounded-xl border p-2.5 outline-none ${
                      isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                    }`}
                  />
                </div>
                <div>
                  <label className="block font-semibold mb-1">Payment Method</label>
                  <select
                    value={newBillPaymentType}
                    onChange={(e: any) => setNewBillPaymentType(e.target.value)}
                    className={`w-full rounded-xl border p-2.5 outline-none ${
                      isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                    }`}
                  >
                    <option value="CASH">Counter Cash</option>
                    <option value="GPAY">UPI / GPay</option>
                    <option value="CREDIT">Wholesale Credit</option>
                  </select>
                </div>
              </div>

              <div className="p-3.5 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex justify-between items-center text-xs">
                <span>Total Invoice Value:</span>
                <span className="text-base font-black text-emerald-400">
                  {formatINR(
                    (parseFloat(newBillWeight) || 0) * (parseFloat(newBillRate) || 0) +
                      (parseFloat(newBillLabour) || 0)
                  )}
                </span>
              </div>
            </div>

            <div className="mt-6 flex justify-end gap-2.5">
              <button
                onClick={() => setShowCreateBillModal(false)}
                className={`rounded-xl border px-4 py-2 text-xs font-semibold ${
                  isDark ? "border-[#30264B] hover:bg-[#15102B]" : "border-[#E9E3F4] hover:bg-[#F2EEFA]"
                }`}
              >
                Cancel
              </button>
              <button
                onClick={handleCreateBill}
                className="rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] px-5 py-2 text-xs font-bold text-white shadow-glow hover:brightness-110"
              >
                Issue Bill & Receipt
              </button>
            </div>
          </div>
        </div>
      )}

      {/* RECEIPT / PRINT PREVIEW MODAL */}
      {showReceiptModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
          <div
            className={`w-full max-w-sm rounded-3xl border p-6 shadow-2xl font-mono text-xs ${
              isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white text-[#211936]"
            }`}
          >
            <div className="text-center pb-4 border-b border-dashed border-[#30264B]">
              <p className="font-black text-sm">SRI VINAYAKA AGRO COMMODITIES</p>
              <p className="text-[10px] opacity-70">APMC Market Yard 42, Bengaluru</p>
              <p className="text-[10px] opacity-70">Tel: +91-9845012345 • GST: 29AABCS1429B1Z5</p>
              <p className="mt-2 text-xs font-bold text-[#9475F5]">INVOICE #{showReceiptModal.billNumber}</p>
            </div>

            <div className="py-3 space-y-1.5 text-[11px] border-b border-dashed border-[#30264B]">
              <div className="flex justify-between">
                <span>Date:</span>
                <span>{new Date().toLocaleDateString()}</span>
              </div>
              <div className="flex justify-between">
                <span>Customer:</span>
                <span className="font-bold">{showReceiptModal.buyer?.name || showReceiptModal.seller?.name}</span>
              </div>
            </div>

            <div className="py-3 space-y-1.5 text-[11px] border-b border-dashed border-[#30264B]">
              <div className="flex justify-between font-bold">
                <span>Gross Produce Value:</span>
                <span>{formatINR(showReceiptModal.grossAmount)}</span>
              </div>
              <div className="flex justify-between">
                <span>Labour / Coolie Fee:</span>
                <span>₹{showReceiptModal.labourCharges || 0}</span>
              </div>
              <div className="flex justify-between">
                <span>APMC Market Cess:</span>
                <span>₹{showReceiptModal.marketCess || 0}</span>
              </div>
              <div className="flex justify-between text-xs font-black text-emerald-400 pt-1">
                <span>NET TOTAL AMOUNT:</span>
                <span>{formatINR(showReceiptModal.grandTotal)}</span>
              </div>
            </div>

            <div className="mt-4 flex gap-2">
              <button
                onClick={() => {
                  showToast("Sending thermal print command to Bluetooth 3-inch ESC/POS...");
                  window.print();
                }}
                className="flex-1 rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] py-2 text-center text-xs font-bold text-white shadow-glow"
              >
                Print Slip
              </button>
              <button
                onClick={() => {
                  showToast("PDF Bill dispatched to WhatsApp!");
                  setShowReceiptModal(null);
                }}
                className="rounded-xl bg-emerald-600 px-3 py-2 text-white hover:bg-emerald-500"
                title="Send via WhatsApp"
              >
                <Share2 className="h-4 w-4" />
              </button>
              <button
                onClick={() => setShowReceiptModal(null)}
                className={`rounded-xl border px-3 py-2 text-xs ${
                  isDark ? "border-[#30264B]" : "border-[#E9E3F4]"
                }`}
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ADD PARTNER MODAL */}
      {showAddPartnerModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
          <div
            className={`w-full max-w-md rounded-3xl border p-6 shadow-2xl ${
              isDark ? "border-[#30264B] bg-[#15102B] text-white" : "border-[#E9E3F4] bg-white text-[#211936]"
            }`}
          >
            <div className="flex items-center justify-between pb-4 border-b border-opacity-30 border-[#30264B]">
              <h3 className="font-bold text-sm">Add New Market Partner</h3>
              <button onClick={() => setShowAddPartnerModal(false)} className="rounded-lg p-1">
                <X className="h-4 w-4" />
              </button>
            </div>

            <div className="mt-4 space-y-4 text-xs">
              <div>
                <label className="block font-semibold mb-1">Partner Role</label>
                <div className="flex gap-2">
                  <button
                    type="button"
                    onClick={() => setNewPartnerType("BUYER")}
                    className={`flex-1 rounded-xl py-2 font-bold text-xs border transition ${
                      newPartnerType === "BUYER"
                        ? "bg-[#9475F5] text-white border-[#9475F5]"
                        : isDark
                        ? "border-[#30264B] bg-[#0D0920]"
                        : "border-[#E9E3F4] bg-gray-100"
                    }`}
                  >
                    Wholesale Buyer
                  </button>
                  <button
                    type="button"
                    onClick={() => setNewPartnerType("SELLER")}
                    className={`flex-1 rounded-xl py-2 font-bold text-xs border transition ${
                      newPartnerType === "SELLER"
                        ? "bg-[#9475F5] text-white border-[#9475F5]"
                        : isDark
                        ? "border-[#30264B] bg-[#0D0920]"
                        : "border-[#E9E3F4] bg-gray-100"
                    }`}
                  >
                    Farmer Supplier
                  </button>
                </div>
              </div>

              <div>
                <label className="block font-semibold mb-1">Full Legal Name</label>
                <input
                  type="text"
                  placeholder="e.g. Kaveri Wholesale Fruits"
                  value={newPartnerName}
                  onChange={(e) => setNewPartnerName(e.target.value)}
                  className={`w-full rounded-xl border p-2.5 outline-none ${
                    isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                  }`}
                />
              </div>

              <div>
                <label className="block font-semibold mb-1">Mobile Phone (WhatsApp)</label>
                <input
                  type="text"
                  placeholder="+91-9844011223"
                  value={newPartnerPhone}
                  onChange={(e) => setNewPartnerPhone(e.target.value)}
                  className={`w-full rounded-xl border p-2.5 outline-none ${
                    isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                  }`}
                />
              </div>

              <div>
                <label className="block font-semibold mb-1">Village / Market Yard Stall</label>
                <input
                  type="text"
                  placeholder="e.g. Yeshwanthpur Stall #14"
                  value={newPartnerCity}
                  onChange={(e) => setNewPartnerCity(e.target.value)}
                  className={`w-full rounded-xl border p-2.5 outline-none ${
                    isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                  }`}
                />
              </div>
            </div>

            <div className="mt-6 flex justify-end gap-2.5">
              <button
                onClick={() => setShowAddPartnerModal(false)}
                className={`rounded-xl border px-4 py-2 text-xs font-semibold ${
                  isDark ? "border-[#30264B]" : "border-[#E9E3F4]"
                }`}
              >
                Cancel
              </button>
              <button
                onClick={handleAddPartner}
                className="rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] px-5 py-2 text-xs font-bold text-white shadow-glow hover:brightness-110"
              >
                Save Partner
              </button>
            </div>
          </div>
        </div>
      )}

      {/* RECORD ADVANCE MODAL */}
      {showRecordAdvanceModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
          <div
            className={`w-full max-w-md rounded-3xl border p-6 shadow-2xl ${
              isDark ? "border-[#30264B] bg-[#15102B] text-white" : "border-[#E9E3F4] bg-white text-[#211936]"
            }`}
          >
            <div className="flex items-center justify-between pb-4 border-b border-opacity-30 border-[#30264B]">
              <h3 className="font-bold text-sm">Record Pre-Season Farmer Advance</h3>
              <button onClick={() => setShowRecordAdvanceModal(false)} className="rounded-lg p-1">
                <X className="h-4 w-4" />
              </button>
            </div>

            <div className="mt-4 space-y-4 text-xs">
              <div>
                <label className="block font-semibold mb-1">Select Farmer</label>
                <select
                  className={`w-full rounded-xl border p-2.5 outline-none ${
                    isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                  }`}
                >
                  {sellers.map((s) => (
                    <option key={s.id} value={s.id}>
                      {s.name} ({s.villageOrCity})
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block font-semibold mb-1">Advance Amount (₹)</label>
                <input
                  type="number"
                  defaultValue="20000"
                  className={`w-full rounded-xl border p-2.5 outline-none font-bold text-[#9475F5] ${
                    isDark ? "border-[#30264B] bg-[#0D0920]" : "border-[#E9E3F4] bg-white"
                  }`}
                />
              </div>

              <div>
                <label className="block font-semibold mb-1">Disbursement Mode</label>
                <select
                  className={`w-full rounded-xl border p-2.5 outline-none ${
                    isDark ? "border-[#30264B] bg-[#0D0920] text-white" : "border-[#E9E3F4] bg-white"
                  }`}
                >
                  <option value="CASH">Cash Counter</option>
                  <option value="BANK">NEFT / Bank Transfer</option>
                  <option value="CHEQUE">Bank Cheque</option>
                </select>
              </div>
            </div>

            <div className="mt-6 flex justify-end gap-2.5">
              <button
                onClick={() => setShowRecordAdvanceModal(false)}
                className={`rounded-xl border px-4 py-2 text-xs font-semibold ${
                  isDark ? "border-[#30264B]" : "border-[#E9E3F4]"
                }`}
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  const newAdv = {
                    id: `adv-${Date.now()}`,
                    advanceNumber: `ADV-2026-${Math.floor(100 + Math.random() * 900)}`,
                    advanceDate: new Date().toISOString(),
                    direction: "GIVEN",
                    seller: { name: sellers[0]?.name || "Farmer" },
                    amount: 20000,
                    settledAmount: 0,
                    outstandingAmount: 20000,
                    status: "OPEN",
                  };
                  setAdvances([newAdv, ...advances]);
                  setShowRecordAdvanceModal(false);
                  showToast("Farmer Advance registered into ACID Ledger!");
                }}
                className="rounded-xl bg-gradient-to-r from-[#9475F5] to-[#7955DF] px-5 py-2 text-xs font-bold text-white shadow-glow hover:brightness-110"
              >
                Record Advance
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
