import { AuthUser } from "@/types";

export function createMockUser(role: "SUPER_ADMIN" | "ADMIN" | "BUSINESS_USER", usernameInput?: string): {
  user: AuthUser;
  accessToken: string;
  refreshToken: string;
  redirectTo: string;
} {
  const isSuper = role === "SUPER_ADMIN";
  const isSubAdmin = role === "ADMIN";

  const user: AuthUser = {
    id: isSuper ? "usr_mock_superadmin" : isSubAdmin ? "usr_mock_vinayaka_admin" : "usr_mock_vinayaka_staff",
    username: usernameInput || (isSuper ? "superadmin" : isSubAdmin ? "vinayaka_admin" : "vinayaka_staff"),
    fullName: isSuper
      ? "Platform Super Administrator"
      : isSubAdmin
      ? "Ramesh Kumar (Store Sub Admin)"
      : "Suresh Babu (Cashier / Staff)",
    email: isSuper ? "superadmin@clicksmartchart.io" : "admin@vinayakaagro.in",
    phone: "+91-9845012345",
    role: role,
    tenantId: isSuper ? null : "biz_mock_vinayaka",
    tenantName: isSuper ? null : "Sri Vinayaka Agro Commodities Pvt Ltd",
    permissions: isSuper
      ? [
          "platform:analytics:read",
          "platform:tenants:manage",
          "platform:admins:manage",
          "platform:plans:manage",
          "platform:settings:manage",
          "platform:audit:read",
        ]
      : [
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
          "purchases:cancel",
          "sales:read",
          "sales:write",
          "sales:cancel",
          "payments:read",
          "payments:write",
          "ledgers:read",
          "ledgers:export",
          "advances:read",
          "advances:write",
          "inventory:read",
          "inventory:adjust",
          "reports:read",
          "reports:profit_loss",
          "reports:export",
          "documents:generate",
          "business:settings:manage",
          "business:users:manage",
        ],
  };

  const redirectTo = isSuper
    ? "/super-admin/dashboard"
    : isSubAdmin
    ? "/admin/dashboard"
    : "/workspace/dashboard";

  return {
    user,
    accessToken: "mock_jwt_access_token_demo_mode",
    refreshToken: "mock_jwt_refresh_token_demo_mode",
    redirectTo,
  };
}

export const MOCK_BUSINESS_DASHBOARD = {
  metrics: {
    totalGoods: 18,
    totalBuyers: 34,
    totalSellers: 28,
    activeLots: 6,
    totalPurchasesAmount: 1845200,
    totalPurchasesCount: 42,
    totalSalesAmount: 2196400,
    totalSalesCount: 56,
    totalInventoryValue: 742500,
    totalReceivables: 325400,
    totalPayables: 189200,
    pendingSalesCollection: 145000,
    pendingPurchasePayable: 92000,
    lowStockCount: 2,
  },
  lowStockItems: [
    { id: "g-01", name: "Grade-A Bangalore Tomato", code: "GDS-TOM-01", currentStock: 18, minimumStock: 50, unit: "CRATE" },
    { id: "g-02", name: "Kashmiri Garlic Medium", code: "GDS-GAR-03", currentStock: 12, minimumStock: 30, unit: "BAG" },
  ],
  recentPurchases: [
    { id: "p-01", billNumber: "PB-2026-0042", billDate: new Date().toISOString(), seller: { name: "Marappa Reddy & Sons" }, grandTotal: 64500, status: "POSTED" },
    { id: "p-02", billNumber: "PB-2026-0041", billDate: new Date().toISOString(), seller: { name: "Govindappa Farmers Group" }, grandTotal: 48200, status: "POSTED" },
  ],
  recentSales: [
    { id: "s-01", billNumber: "SB-2026-0089", billDate: new Date().toISOString(), buyer: { name: "Apex Fresh Mart Wholesale" }, grandTotal: 92400, status: "POSTED" },
    { id: "s-02", billNumber: "SB-2026-0088", billDate: new Date().toISOString(), buyer: { name: "Kaveri Retailers Mysore" }, grandTotal: 51300, status: "POSTED" },
  ],
  recentPayments: [
    { id: "pm-01", paymentNumber: "RCPT-901", paymentDate: new Date().toISOString(), paymentType: "BUYER_RECEIPT", buyer: { name: "Apex Fresh Mart Wholesale" }, amount: 50000, paymentMethod: "NEFT" },
  ],
  subscription: {
    status: "ACTIVE",
    plan: { name: "Professional Smart Chart Suite", maxUsers: 3 },
  },
};

export const MOCK_BUYERS = [
  { id: "byr-01", code: "BYR-101", name: "Apex Fresh Mart Wholesale", phone: "+91-9844011223", villageOrCity: "Bengaluru City Yard", category: "WHOLESALER", openingBalance: 25000, currentBalance: 42400, isActive: true },
  { id: "byr-02", code: "BYR-102", name: "Kaveri Retailers Mysore", phone: "+91-9844055667", villageOrCity: "Mysuru APMC", category: "RETAILER", openingBalance: 10000, currentBalance: 18500, isActive: true },
  { id: "byr-03", code: "BYR-103", name: "Metro Greens Supply Co", phone: "+91-9844099881", villageOrCity: "Yeshwanthpur", category: "COMMISSION_AGENT", openingBalance: 0, currentBalance: 65000, isActive: true },
];

export const MOCK_SELLERS = [
  { id: "slr-01", code: "SLR-201", name: "Marappa Reddy & Sons", phone: "+91-9731011223", villageOrCity: "Kolar Field Yard", category: "FARMER", openingBalance: 0, currentBalance: 58000, isActive: true },
  { id: "slr-02", code: "SLR-202", name: "Govindappa Farmers Group", phone: "+91-9731044556", villageOrCity: "Chintamani APMC", category: "FARMER_GROUP", openingBalance: 15000, currentBalance: 32000, isActive: true },
  { id: "slr-03", code: "SLR-203", name: "Sri Laxmi Organic FPO", phone: "+91-9731077889", villageOrCity: "Hoskote Road", category: "FPO", openingBalance: 0, currentBalance: 99200, isActive: true },
];

export const MOCK_GOODS = [
  { id: "gds-01", code: "GDS-TOM-01", name: "Grade-A Hybrid Tomato", unit: "CRATE", purchasePrice: 380, sellingPrice: 460, currentStock: 140, minimumStock: 40 },
  { id: "gds-02", code: "GDS-ONI-02", name: "Nashik Red Onion 50kg", unit: "BAG", purchasePrice: 1150, sellingPrice: 1320, currentStock: 220, minimumStock: 50 },
  { id: "gds-03", code: "GDS-POT-03", name: "Hassan Chip Potato", unit: "BAG", purchasePrice: 850, sellingPrice: 980, currentStock: 310, minimumStock: 60 },
  { id: "gds-04", code: "GDS-GAR-04", name: "Ooty Mountain Garlic", unit: "BAG", purchasePrice: 4200, sellingPrice: 4850, currentStock: 45, minimumStock: 15 },
];

export const MOCK_GOODS_LOTS = [
  {
    id: "lot-01",
    lotNumber: "LOT-2026-0881",
    seller: { name: "Marappa Reddy & Sons" },
    vehicleNumber: "KA-04-E-8821",
    arrivalDate: new Date().toISOString(),
    totalBags: 80,
    grossWeight: 4120,
    tareWeight: 80,
    netWeight: 4040,
    soldBags: 60,
    soldWeight: 3030,
    remainingBags: 20,
    remainingWeight: 1010,
    status: "OPEN",
    items: [
      { id: "li-01", goods: { name: "Grade-A Hybrid Tomato" }, bagsCount: 40, grossWeight: 2060, tareWeight: 40, netWeight: 2020 },
      { id: "li-02", goods: { name: "Hassan Chip Potato" }, bagsCount: 40, grossWeight: 2060, tareWeight: 40, netWeight: 2020 },
    ],
  },
  {
    id: "lot-02",
    lotNumber: "LOT-2026-0880",
    seller: { name: "Govindappa Farmers Group" },
    vehicleNumber: "KA-07-T-4433",
    arrivalDate: new Date(Date.now() - 3600000).toISOString(),
    totalBags: 120,
    grossWeight: 6180,
    tareWeight: 120,
    netWeight: 6060,
    soldBags: 120,
    soldWeight: 6060,
    remainingBags: 0,
    remainingWeight: 0,
    status: "CLOSED",
    items: [
      { id: "li-03", goods: { name: "Nashik Red Onion 50kg" }, bagsCount: 120, grossWeight: 6180, tareWeight: 120, netWeight: 6060 },
    ],
  },
];

export const MOCK_GOODS_ENTRIES = [
  {
    id: "entry-01",
    entryNumber: "ENT-2026-0914",
    entryDate: new Date().toISOString(),
    seller: { name: "Marappa Reddy & Sons" },
    goods: { name: "Grade-A Hybrid Tomato" },
    vehicleNumber: "KA-04-E-8821",
    bagsCount: 80,
    grossWeight: 4120,
    tareWeight: 80,
    netWeight: 4040,
    ratePerUnit: 420,
    totalAmount: 33600,
    status: "ARRIVED",
  },
];

export const MOCK_SMART_CHARTS = [
  {
    id: "sc-01",
    chartNumber: "SC-2026-031",
    lot: { lotNumber: "LOT-2026-0881" },
    buyer: { name: "Apex Fresh Mart Wholesale" },
    auctionDate: new Date().toISOString(),
    bidRate: 460,
    allottedBags: 40,
    totalWeight: 2020,
    totalAmount: 92920,
    status: "ALLOTTED",
  },
];

export const MOCK_PURCHASES = [
  {
    id: "pur-01",
    billNumber: "PB-2026-0042",
    billDate: new Date().toISOString(),
    seller: { name: "Marappa Reddy & Sons", code: "SLR-201" },
    grossAmount: 64500,
    labourCharges: 480,
    marketCess: 645,
    commissionAmount: 1290,
    grandTotal: 62085,
    paidAmount: 50000,
    outstandingAmount: 12085,
    status: "POSTED",
  },
];

export const MOCK_SALES = [
  {
    id: "sal-01",
    billNumber: "SB-2026-0089",
    billDate: new Date().toISOString(),
    buyer: { name: "Apex Fresh Mart Wholesale", code: "BYR-101" },
    grossAmount: 92400,
    labourCharges: 360,
    marketCess: 924,
    commissionAmount: 0,
    grandTotal: 93684,
    receivedAmount: 50000,
    outstandingAmount: 43684,
    status: "POSTED",
  },
];

export const MOCK_PAYMENTS = [
  {
    id: "pay-01",
    paymentNumber: "RCPT-901",
    paymentDate: new Date().toISOString(),
    paymentType: "BUYER_RECEIPT",
    buyer: { name: "Apex Fresh Mart Wholesale" },
    amount: 50000,
    paymentMethod: "CASH",
    referenceNumber: "CASH-COUNTER-01",
    notes: "Settled on spot for SB-2026-0089",
  },
];

export const MOCK_ADVANCES = [
  {
    id: "adv-01",
    advanceNumber: "ADV-2026-012",
    advanceDate: new Date().toISOString(),
    direction: "GIVEN",
    seller: { name: "Marappa Reddy & Sons" },
    amount: 25000,
    settledAmount: 10000,
    outstandingAmount: 15000,
    status: "PARTIALLY_SETTLED",
  },
];

export const MOCK_INVENTORY = [
  { id: "inv-01", goods: { name: "Grade-A Hybrid Tomato", code: "GDS-TOM-01", unit: "CRATE" }, currentStock: 140, reservedStock: 20, availableStock: 120, averagePurchaseCost: 380, totalValue: 53200 },
  { id: "inv-02", goods: { name: "Nashik Red Onion 50kg", code: "GDS-ONI-02", unit: "BAG" }, currentStock: 220, reservedStock: 0, availableStock: 220, averagePurchaseCost: 1150, totalValue: 253000 },
  { id: "inv-03", goods: { name: "Hassan Chip Potato", code: "GDS-POT-03", unit: "BAG" }, currentStock: 310, reservedStock: 40, availableStock: 270, averagePurchaseCost: 850, totalValue: 263500 },
];

export const MOCK_DAILY_SUMMARY = {
  date: new Date().toISOString(),
  cashInHandOpening: 45000,
  cashCollected: 92500,
  cashPaid: 65000,
  cashInHandClosing: 72500,
  totalArrivalLots: 6,
  totalBagsInward: 380,
  totalSalesBills: 14,
  totalSalesVolumeKg: 18400,
};

export const MOCK_PROFIT_LOSS = {
  grossSales: 2196400,
  costOfGoodsSold: 1845200,
  grossProfit: 351200,
  commissionEarned: 88400,
  labourCollected: 14500,
  netOperatingIncome: 454100,
};

export const MOCK_EMPLOYEES = {
  users: [
    {
      id: "u-01",
      username: "vinayaka_admin",
      fullName: "Ramesh Kumar (Store Sub Admin)",
      designation: "Sub Admin / Store Manager",
      status: "ACTIVE",
      role: { code: "ADMIN", name: "Sub Admin (All 10 Features)" },
    },
    {
      id: "u-02",
      username: "vinayaka_staff",
      fullName: "Suresh Babu (Billing Operator)",
      designation: "Cashier / Staff",
      status: "ACTIVE",
      role: { code: "BUSINESS_USER", name: "Staff / Cashier" },
    },
  ],
  availablePermissions: [],
  maxUsers: 3,
  licenseKey: "BSG-LIC-TRIAL-3SEATS-ACTIVE",
  trialEndsAt: new Date(Date.now() + 28 * 24 * 3600 * 1000).toISOString(),
  activeSessionsCount: 2,
};

export const MOCK_BUSINESS_PROFILE = {
  profile: {
    businessName: "Sri Vinayaka Agro Commodities Pvt Ltd",
    legalName: "Sri Vinayaka Agro Commodities Pvt Ltd",
    addressLine1: "Plot 42, APMC Market Yard, Yeshwanthpur",
    city: "Bengaluru",
    state: "Karnataka",
    postalCode: "560022",
    phone: "+91-9845012345",
    email: "owner@vinayakaagro.in",
    gstNumber: "29AABCS1429B1Z5",
    apmcLicenseNumber: "APMC/BLR/2026/8841",
  },
  settings: {
    supportedUnits: ["KG", "BAG", "QUINTAL", "CRATE"],
    defaultLabourPerBag: 6.0,
    defaultMarketCessPercent: 1.0,
    enableWhatsApp: true,
  },
  tenant: {
    name: "Sri Vinayaka Agro Commodities Pvt Ltd",
    licenseKey: "BSG-LIC-TRIAL-3SEATS-ACTIVE",
    maxUsers: 3,
    status: "ACTIVE",
    trialEndsAt: new Date(Date.now() + 28 * 24 * 3600 * 1000).toISOString(),
  },
};

// ==========================================
// SUPER ADMIN MOCK DATA
// ==========================================
export const MOCK_SUPER_ADMIN_DASHBOARD = {
  mrr: 184500,
  activeTenants: 14,
  trialTenants: 9,
  totalUsers: 48,
  activeSessions: 32,
  planDistribution: [
    { name: "Starter Mandi Plan", count: 8 },
    { name: "Professional Smart Chart Suite", count: 12 },
    { name: "Enterprise Multi-Branch", count: 3 },
  ],
};

export const MOCK_SUPER_BUSINESSES = [
  {
    id: "biz-01",
    name: "Sri Vinayaka Agro Commodities Pvt Ltd",
    code: "BIZ-100001",
    ownerEmail: "owner@vinayakaagro.in",
    ownerPhone: "+91-9845012345",
    status: "ACTIVE",
    licenseKey: "BSG-LIC-TRIAL-3SEATS-ACTIVE",
    maxUsers: 3,
    trialEndsAt: new Date(Date.now() + 28 * 24 * 3600 * 1000).toISOString(),
    createdAt: new Date().toISOString(),
    enabledFeatures: [
      "MULTI_PRODUCT_LOTS",
      "MULTI_PRODUCT_BILLING",
      "BAG_WEIGHMENT_SCALE",
      "DAILY_CASH_TALLY",
      "SMART_CHART_AUCTION",
      "PARTNER_LEDGERS",
      "CUSTOMER_ADVANCES",
      "FINANCIAL_REPORTS",
      "WHATSAPP_INVOICES",
      "MOBILE_APP_SYNC",
    ],
    _count: { users: 2, buyers: 34, sellers: 28, goodsEntries: 142 },
  },
  {
    id: "biz-02",
    name: "Kisan Mandi Traders Salem",
    code: "BIZ-100002",
    ownerEmail: "salem@kisanmandi.in",
    ownerPhone: "+91-9443011223",
    status: "ACTIVE",
    licenseKey: "BSG-LIC-TRIAL-SALEM-3SEAT",
    maxUsers: 3,
    trialEndsAt: new Date(Date.now() + 18 * 24 * 3600 * 1000).toISOString(),
    createdAt: new Date().toISOString(),
    enabledFeatures: [
      "MULTI_PRODUCT_LOTS",
      "MULTI_PRODUCT_BILLING",
      "BAG_WEIGHMENT_SCALE",
      "DAILY_CASH_TALLY",
      "SMART_CHART_AUCTION",
      "PARTNER_LEDGERS",
    ],
    _count: { users: 3, buyers: 42, sellers: 51, goodsEntries: 210 },
  },
];

export const MOCK_SUPER_ADMINS = [
  {
    id: "adm-01",
    username: "superadmin",
    fullName: "Platform Super Administrator",
    email: "superadmin@clicksmartchart.io",
    status: "ACTIVE",
    createdAt: new Date().toISOString(),
    role: { code: "SUPER_ADMIN", name: "Super Admin" },
  },
  {
    id: "adm-02",
    username: "vinayaka_admin",
    fullName: "Ramesh Kumar (Store Sub Admin)",
    email: "admin@vinayakaagro.in",
    status: "ACTIVE",
    createdAt: new Date().toISOString(),
    role: { code: "ADMIN", name: "Sub Admin" },
    tenant: { name: "Sri Vinayaka Agro Commodities Pvt Ltd" },
  },
];

export const MOCK_SUPER_PLANS = [
  {
    id: "plan-01",
    code: "STARTER_MANDI",
    name: "Starter Mandi Plan",
    description: "Ideal for single-counter traders with core goods, billing, and partner ledgers.",
    monthlyPrice: 1499,
    annualPrice: 14990,
    trialDays: 14,
    maxUsers: 3,
    maxGoodsRecords: 500,
    maxBuyersAndSellers: 1000,
    enableSmartChart: true,
    enableAuctions: true,
    enableReports: true,
    enablePdfExport: true,
    isActive: true,
  },
  {
    id: "plan-02",
    code: "PROFESSIONAL_SAAS",
    name: "Professional Smart Chart Suite",
    description: "Full APMC / Wholesale Goods Management with Smart Chart, Auctions, RMC Reports, Multi-User RBAC & Offline Mobile Sync.",
    monthlyPrice: 2999,
    annualPrice: 29990,
    trialDays: 30,
    maxUsers: 3,
    maxGoodsRecords: 5000,
    maxBuyersAndSellers: 10000,
    enableSmartChart: true,
    enableAuctions: true,
    enableReports: true,
    enablePdfExport: true,
    isActive: true,
  },
];

export const MOCK_SUPER_SUBSCRIPTIONS = [
  {
    id: "sub-01",
    tenant: { name: "Sri Vinayaka Agro Commodities Pvt Ltd" },
    plan: { name: "Professional Smart Chart Suite" },
    status: "ACTIVE",
    billingCycle: "ANNUAL",
    startDate: new Date().toISOString(),
    endDate: new Date(Date.now() + 365 * 24 * 3600 * 1000).toISOString(),
  },
];

export const MOCK_SUPER_PAYMENTS = [
  {
    id: "pay-sub-01",
    tenant: { name: "Sri Vinayaka Agro Commodities Pvt Ltd" },
    amount: 29990,
    gateway: "RAZORPAY",
    status: "SUCCESS",
    transactionRef: "UTR99281726",
    paidAt: new Date().toISOString(),
  },
];

export const MOCK_SUPER_SETTINGS = {
  platformName: "CLICK Smart Chart Cloud Mandi SaaS",
  supportEmail: "support@clicksmartchart.io",
  supportPhone: "+91-9000000001",
  currency: "INR",
  defaultTrialDays: 30,
  maxUsersPerTenant: 3,
};

export const MOCK_SUPER_AUDIT_LOGS = [
  {
    id: "aud-01",
    action: "TENANT_CREATED",
    entityType: "Tenant",
    entityId: "BIZ-100001",
    createdAt: new Date().toISOString(),
    user: { fullName: "Platform Super Administrator" },
  },
  {
    id: "aud-02",
    action: "ALL_FEATURES_UNLOCKED",
    entityType: "TenantLicense",
    entityId: "BSG-LIC-TRIAL-3SEATS-ACTIVE",
    createdAt: new Date().toISOString(),
    user: { fullName: "Platform Super Administrator" },
  },
];

export function getMockFallbackData<T = any>(endpoint: string, options: RequestInit = {}): T {
  const method = (options.method || "GET").toUpperCase();
  const cleanEndpoint = endpoint.split("?")[0];

  // Auth / Login
  if (cleanEndpoint === "/auth/login") {
    let username = "vinayaka_admin";
    if (typeof options.body === "string") {
      try {
        const parsed = JSON.parse(options.body);
        if (parsed.username) username = parsed.username;
      } catch {}
    }
    const role =
      username.toLowerCase().includes("super")
        ? "SUPER_ADMIN"
        : username.toLowerCase().includes("staff") || username.toLowerCase().includes("emp")
        ? "BUSINESS_USER"
        : "ADMIN";

    return createMockUser(role, username) as unknown as T;
  }

  // Business Dashboard & Features
  if (cleanEndpoint === "/business/dashboard") return MOCK_BUSINESS_DASHBOARD as unknown as T;
  if (cleanEndpoint === "/buyers") return MOCK_BUYERS as unknown as T;
  if (cleanEndpoint === "/sellers") return MOCK_SELLERS as unknown as T;
  if (cleanEndpoint === "/goods") return MOCK_GOODS as unknown as T;
  if (cleanEndpoint === "/goods-lots") return MOCK_GOODS_LOTS as unknown as T;
  if (cleanEndpoint === "/goods-entries") return MOCK_GOODS_ENTRIES as unknown as T;
  if (cleanEndpoint === "/smart-charts") return MOCK_SMART_CHARTS as unknown as T;
  if (cleanEndpoint === "/auctions") return [] as unknown as T;
  if (cleanEndpoint === "/purchases") return MOCK_PURCHASES as unknown as T;
  if (cleanEndpoint === "/sales") return MOCK_SALES as unknown as T;
  if (cleanEndpoint === "/payments") return MOCK_PAYMENTS as unknown as T;
  if (cleanEndpoint === "/advances") return MOCK_ADVANCES as unknown as T;
  if (cleanEndpoint === "/inventory") return MOCK_INVENTORY as unknown as T;
  if (cleanEndpoint === "/reports/daily-summary") return MOCK_DAILY_SUMMARY as unknown as T;
  if (cleanEndpoint === "/reports/profit-loss") return MOCK_PROFIT_LOSS as unknown as T;
  if (cleanEndpoint === "/business/users") return MOCK_EMPLOYEES as unknown as T;
  if (cleanEndpoint === "/business/profile") return MOCK_BUSINESS_PROFILE as unknown as T;
  if (cleanEndpoint.startsWith("/business/search")) {
    return {
      buyers: MOCK_BUYERS,
      sellers: MOCK_SELLERS,
      lots: MOCK_GOODS_LOTS,
      salesBills: MOCK_SALES,
      purchaseBills: MOCK_PURCHASES,
    } as unknown as T;
  }

  // Super Admin Endpoints
  if (cleanEndpoint === "/super-admin/dashboard") return MOCK_SUPER_ADMIN_DASHBOARD as unknown as T;
  if (cleanEndpoint === "/super-admin/businesses") return MOCK_SUPER_BUSINESSES as unknown as T;
  if (cleanEndpoint === "/super-admin/admins") return MOCK_SUPER_ADMINS as unknown as T;
  if (cleanEndpoint === "/super-admin/plans") return MOCK_SUPER_PLANS as unknown as T;
  if (cleanEndpoint === "/super-admin/subscriptions") return MOCK_SUPER_SUBSCRIPTIONS as unknown as T;
  if (cleanEndpoint === "/super-admin/payments") return MOCK_SUPER_PAYMENTS as unknown as T;
  if (cleanEndpoint === "/super-admin/settings") return MOCK_SUPER_SETTINGS as unknown as T;
  if (cleanEndpoint === "/super-admin/audit-logs") return MOCK_SUPER_AUDIT_LOGS as unknown as T;

  if (cleanEndpoint.includes("/license-certificate")) {
    return {
      licenseKey: "BSG-LIC-TRIAL-3SEATS-ACTIVE",
      tenantName: "Sri Vinayaka Agro Commodities Pvt Ltd",
      maxUsers: 3,
      status: "ACTIVE",
      trialEndsAt: new Date(Date.now() + 28 * 24 * 3600 * 1000).toISOString(),
      qrCodeData: "https://clicksmartchart.io/verify/BSG-LIC-TRIAL-3SEATS-ACTIVE",
    } as unknown as T;
  }

  if (cleanEndpoint.includes("/active-sessions")) {
    return [
      { id: "sess-01", user: { fullName: "Ramesh Kumar (Store Sub Admin)", username: "vinayaka_admin" }, deviceInfo: "Chrome 132 on Windows", lastActiveAt: new Date().toISOString() },
      { id: "sess-02", user: { fullName: "Suresh Babu (Cashier / Staff)", username: "vinayaka_staff" }, deviceInfo: "Android Mobile Mandi App", lastActiveAt: new Date().toISOString() },
    ] as unknown as T;
  }

  // Default success response for mutations (POST, PATCH, DELETE)
  return { success: true, message: "Action recorded successfully." } as unknown as T;
}
