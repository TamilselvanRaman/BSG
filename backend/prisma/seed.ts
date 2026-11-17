import bcrypt from "bcryptjs";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const PERMISSIONS = [
  { code: "platform:analytics:read", module: "PLATFORM", description: "View SaaS analytics & MRR" },
  { code: "platform:tenants:manage", module: "PLATFORM", description: "Manage SaaS tenant businesses" },
  { code: "platform:admins:manage", module: "PLATFORM", description: "Manage business Admin accounts" },
  { code: "platform:plans:manage", module: "PLATFORM", description: "Manage subscription plans & pricing" },
  { code: "platform:settings:manage", module: "PLATFORM", description: "Manage global platform settings" },
  { code: "platform:audit:read", module: "PLATFORM", description: "View platform audit logs" },
  { code: "business:settings:manage", module: "BUSINESS", description: "Manage business profile & customization" },
  { code: "business:users:manage", module: "BUSINESS", description: "Manage employees & permissions" },
  { code: "partners:read", module: "PARTNERS", description: "View buyers, sellers, and transporters" },
  { code: "partners:write", module: "PARTNERS", description: "Create and edit buyers & sellers" },
  { code: "goods:read", module: "GOODS", description: "View goods catalog" },
  { code: "goods:write", module: "GOODS", description: "Create and edit goods" },
  { code: "lots:read", module: "LOTS", description: "View arrival goods entries & lots" },
  { code: "lots:write", module: "LOTS", description: "Record arrival goods entries & lots" },
  { code: "smart_chart:read", module: "SMART_CHART", description: "View Smart Charts & Auctions" },
  { code: "smart_chart:write", module: "SMART_CHART", description: "Create and manage Smart Charts & Auctions" },
  { code: "purchases:read", module: "BILLING", description: "View purchase bill book" },
  { code: "purchases:write", module: "BILLING", description: "Create purchase bills" },
  { code: "purchases:cancel", module: "BILLING", description: "Cancel purchase bills" },
  { code: "sales:read", module: "BILLING", description: "View sales bill book" },
  { code: "sales:write", module: "BILLING", description: "Create sales bills" },
  { code: "sales:cancel", module: "BILLING", description: "Cancel sales bills" },
  { code: "payments:read", module: "PAYMENTS", description: "View payment receipts & history" },
  { code: "payments:write", module: "PAYMENTS", description: "Record buyer receipts & seller payments" },
  { code: "ledgers:read", module: "LEDGERS", description: "View buyer & seller ledgers" },
  { code: "ledgers:export", module: "LEDGERS", description: "Export ledger statements" },
  { code: "advances:read", module: "ADVANCES", description: "View partner advances" },
  { code: "advances:write", module: "ADVANCES", description: "Issue, receive, and adjust advances" },
  { code: "inventory:read", module: "INVENTORY", description: "View stock summary & movement" },
  { code: "inventory:adjust", module: "INVENTORY", description: "Perform manual stock adjustments" },
  { code: "reports:read", module: "REPORTS", description: "View daily summary, sales, and RMC reports" },
  { code: "reports:profit_loss", module: "REPORTS", description: "View gross profit & margin report" },
  { code: "reports:export", module: "REPORTS", description: "Export CSV and Excel reports" },
  { code: "documents:generate", module: "DOCUMENTS", description: "Generate and print PDF bills & statements" },
];

async function main() {
  console.log("Seeding BSG Multi-Tenant Goods Management SaaS Database...");

  // 1. Seed Roles
  const superAdminRole = await prisma.role.upsert({
    where: { code: "SUPER_ADMIN" },
    update: {},
    create: { code: "SUPER_ADMIN", name: "Super Admin", description: "Platform Owner & Controller" },
  });

  const adminRole = await prisma.role.upsert({
    where: { code: "ADMIN" },
    update: {},
    create: { code: "ADMIN", name: "Business Admin", description: "Registered Business Owner" },
  });

  const employeeRole = await prisma.role.upsert({
    where: { code: "BUSINESS_USER" },
    update: {},
    create: { code: "BUSINESS_USER", name: "Business User / Employee", description: "Staff Member" },
  });

  // 2. Seed Permissions & Role Mappings
  for (const p of PERMISSIONS) {
    const perm = await prisma.permission.upsert({
      where: { code: p.code },
      update: { description: p.description },
      create: p,
    });

    await prisma.rolePermission.upsert({
      where: { roleId_permissionId: { roleId: superAdminRole.id, permissionId: perm.id } },
      update: {},
      create: { roleId: superAdminRole.id, permissionId: perm.id },
    });

    if (p.module !== "PLATFORM") {
      await prisma.rolePermission.upsert({
        where: { roleId_permissionId: { roleId: adminRole.id, permissionId: perm.id } },
        update: {},
        create: { roleId: adminRole.id, permissionId: perm.id },
      });
    }

    // Default employee read/entry permissions
    if (
      [
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
      ].includes(p.code)
    ) {
      await prisma.rolePermission.upsert({
        where: { roleId_permissionId: { roleId: employeeRole.id, permissionId: perm.id } },
        update: {},
        create: { roleId: employeeRole.id, permissionId: perm.id },
      });
    }
  }

  // 3. Seed Platform Settings
  const existingSettings = await prisma.platformSetting.findFirst();
  if (!existingSettings) {
    await prisma.platformSetting.create({
      data: {
        platformName: "CLICK Smart Chart SaaS",
        primaryColor: "#0F172A",
        accentColor: "#2563EB",
        contactEmail: "support@clicksmartchart.io",
        contactPhone: "+91-800-555-0199",
      },
    });
  }

  // 4. Seed Subscription Plans
  const starterPlan = await prisma.subscriptionPlan.upsert({
    where: { code: "STARTER_MANDI" },
    update: {},
    create: {
      code: "STARTER_MANDI",
      name: "Starter Mandi Plan",
      description: "Ideal for single-counter traders with core goods, billing, and partner ledgers.",
      monthlyPrice: 1499.0,
      annualPrice: 14990.0,
      trialDays: 14,
      maxUsers: 3,
      maxGoodsRecords: 250,
      maxBuyersAndSellers: 500,
      maxStorageMb: 1024,
      enableSmartChart: true,
      enableAuctions: true,
      enableReports: true,
      enablePdfExport: true,
      enableBackup: false,
    },
  });

  const growthPlan = await prisma.subscriptionPlan.upsert({
    where: { code: "PROFESSIONAL_SAAS" },
    update: {},
    create: {
      code: "PROFESSIONAL_SAAS",
      name: "Professional Smart Chart Suite",
      description:
        "Full APMC / Wholesale Goods Management with Smart Chart, Auctions, RMC Reports, Multi-User RBAC & Offline Mobile Sync.",
      monthlyPrice: 2999.0,
      annualPrice: 29990.0,
      trialDays: 14,
      maxUsers: 15,
      maxGoodsRecords: 5000,
      maxBuyersAndSellers: 10000,
      maxStorageMb: 10240,
      enableSmartChart: true,
      enableAuctions: true,
      enableReports: true,
      enablePdfExport: true,
      enableBackup: true,
      enableApiAccess: true,
      enableWhatsApp: true,
    },
  });

  await prisma.subscriptionPlan.upsert({
    where: { code: "ENTERPRISE_MULTI" },
    update: {},
    create: {
      code: "ENTERPRISE_MULTI",
      name: "Enterprise Trade Network",
      description: "Unlimited capacity, priority SLA, automated cloud backups, and custom integrations.",
      monthlyPrice: 5999.0,
      annualPrice: 59990.0,
      trialDays: 30,
      maxUsers: 100,
      maxGoodsRecords: 100000,
      maxBuyersAndSellers: 100000,
      maxStorageMb: 51200,
      enableSmartChart: true,
      enableAuctions: true,
      enableReports: true,
      enablePdfExport: true,
      enableBackup: true,
      enableApiAccess: true,
      enableWhatsApp: true,
    },
  });

  // 5. Seed Super Admin User
  const passwordHash = await bcrypt.hash("Admin@123", 12);
  await prisma.user.upsert({
    where: { username: "superadmin" },
    update: {},
    create: {
      roleId: superAdminRole.id,
      username: "superadmin",
      email: "superadmin@clicksmartchart.io",
      phone: "+91-9000000001",
      fullName: "Platform Super Administrator",
      passwordHash,
      status: "ACTIVE",
    },
  });

  // 6. Seed Demo Tenant 1: Sri Vinayaka Agro Traders
  const tenant1 = await prisma.tenant.upsert({
    where: { code: "BIZ-100001" },
    update: {},
    create: {
      code: "BIZ-100001",
      name: "Sri Vinayaka Agro & Goods Traders",
      slug: "sri-vinayaka-agro",
      status: "ACTIVE",
      ownerEmail: "owner@vinayakaagro.in",
      ownerPhone: "+91-9845012345",
    },
  });

  await prisma.businessProfile.upsert({
    where: { tenantId: tenant1.id },
    update: {},
    create: {
      tenantId: tenant1.id,
      businessName: "Sri Vinayaka Agro & Goods Traders",
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
  });

  await prisma.businessSettings.upsert({
    where: { tenantId: tenant1.id },
    update: {},
    create: {
      tenantId: tenant1.id,
      supportedUnits: ["KG", "BAG", "QUINTAL", "CRATE"],
      defaultLabourPerBag: 6.0,
      defaultMarketCessPercent: 1.0,
    },
  });

  const admin1 = await prisma.user.upsert({
    where: { username: "vinayaka_admin" },
    update: {},
    create: {
      tenantId: tenant1.id,
      roleId: adminRole.id,
      username: "vinayaka_admin",
      email: "owner@vinayakaagro.in",
      phone: "+91-9845012345",
      fullName: "Ramesh Kumar (Business Admin)",
      passwordHash,
      status: "ACTIVE",
    },
  });

  await prisma.user.upsert({
    where: { username: "vinayaka_staff" },
    update: {},
    create: {
      tenantId: tenant1.id,
      roleId: employeeRole.id,
      username: "vinayaka_staff",
      email: "billing@vinayakaagro.in",
      phone: "+91-9845012399",
      fullName: "Suresh Babu (Billing Operator)",
      passwordHash,
      status: "ACTIVE",
    },
  });

  // Seed Subscription & SaaS Payment for Tenant 1
  const sub1 = await prisma.subscription.create({
    data: {
      tenantId: tenant1.id,
      planId: growthPlan.id,
      status: "ACTIVE",
      billingCycle: "ANNUAL",
      startDate: new Date(),
      endDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
    },
  });

  await prisma.subscriptionPayment.create({
    data: {
      tenantId: tenant1.id,
      subscriptionId: sub1.id,
      amount: 29990.0,
      status: "SUCCESS",
      gateway: "RAZORPAY",
      gatewayOrderId: "order_demo_vinayaka_01",
      gatewayPaymentId: "pay_demo_vinayaka_01",
      transactionRef: "UTR883920194",
      paidAt: new Date(),
    },
  });

  // Seed Buyers, Sellers, Goods, Lots & Bills for Tenant 1
  const buyer1 = await prisma.buyer.upsert({
    where: { tenantId_code: { tenantId: tenant1.id, code: "BYR-101" } },
    update: {},
    create: {
      tenantId: tenant1.id,
      code: "BYR-101",
      name: "Metro Fresh Mart Wholesale",
      phone: "9880112233",
      villageOrCity: "Bengaluru Central",
      gstNumber: "29AAACM9911K1Z2",
      openingBalance: 15000,
      currentBalance: 15000,
      createdBy: admin1.id,
    },
  });

  const seller1 = await prisma.seller.upsert({
    where: { tenantId_code: { tenantId: tenant1.id, code: "SLR-201" } },
    update: {},
    create: {
      tenantId: tenant1.id,
      code: "SLR-201",
      name: "Gowda Organic Farms",
      phone: "9448055667",
      villageOrCity: "Kolar",
      vehicleNumber: "KA-07-T-4490",
      openingBalance: 8500,
      currentBalance: 8500,
      createdBy: admin1.id,
    },
  });

  const catVeg = await prisma.goodsCategory.upsert({
    where: { tenantId_name: { tenantId: tenant1.id, name: "Prime Vegetables & Staples" } },
    update: {},
    create: { tenantId: tenant1.id, name: "Prime Vegetables & Staples" },
  });

  const onionGoods = await prisma.goods.upsert({
    where: { tenantId_code: { tenantId: tenant1.id, code: "GDS-ONION" } },
    update: {},
    create: {
      tenantId: tenant1.id,
      categoryId: catVeg.id,
      code: "GDS-ONION",
      name: "Nasik Red Onion (Grade A)",
      unit: "KG",
      purchasePrice: 24.0,
      sellingPrice: 31.0,
      currentStock: 2450.0,
      minimumStock: 250.0,
      createdBy: admin1.id,
    },
  });

  await prisma.goods.upsert({
    where: { tenantId_code: { tenantId: tenant1.id, code: "GDS-POTATO" } },
    update: {},
    create: {
      tenantId: tenant1.id,
      categoryId: catVeg.id,
      code: "GDS-POTATO",
      name: "Hassan Jyoti Potato",
      unit: "KG",
      purchasePrice: 18.0,
      sellingPrice: 23.5,
      currentStock: 180.0,
      minimumStock: 300.0, // Triggers Low Stock alert
      createdBy: admin1.id,
    },
  });

  await prisma.goodsLot.upsert({
    where: { tenantId_lotNumber: { tenantId: tenant1.id, lotNumber: "LOT-2026-001" } },
    update: {},
    create: {
      tenantId: tenant1.id,
      lotNumber: "LOT-2026-001",
      sellerId: seller1.id,
      goodsId: onionGoods.id,
      vehicleNumber: "KA-07-T-4490",
      bagsOrCount: 50,
      initialQuantity: 2500.0,
      soldQuantity: 800.0,
      remainingQuantity: 1700.0,
      unit: "KG",
      unitPrice: 24.0,
      totalValue: 60000.0,
      status: "PARTIAL",
    },
  });

  // 7. Seed Demo Tenant 2 (Isolated Business B for Multi-Tenant Isolation Verification)
  const tenant2 = await prisma.tenant.upsert({
    where: { code: "BIZ-200002" },
    update: {},
    create: {
      code: "BIZ-200002",
      name: "Deccan Spice & Grain Hub",
      slug: "deccan-spice-hub",
      status: "TRIAL",
      ownerEmail: "admin@deccanspice.in",
      ownerPhone: "+91-9700011223",
    },
  });

  await prisma.user.upsert({
    where: { username: "deccan_admin" },
    update: {},
    create: {
      tenantId: tenant2.id,
      roleId: adminRole.id,
      username: "deccan_admin",
      email: "admin@deccanspice.in",
      phone: "+91-9700011223",
      fullName: "Farhan Shaikh (Deccan Admin)",
      passwordHash,
      status: "ACTIVE",
    },
  });

  await prisma.subscription.create({
    data: {
      tenantId: tenant2.id,
      planId: starterPlan.id,
      status: "TRIAL",
      billingCycle: "MONTHLY",
      startDate: new Date(),
      endDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000),
    },
  });

  console.log("Seed completed! Demo accounts:");
  console.log("  Super Admin    : superadmin / Admin@123");
  console.log("  Business Admin : vinayaka_admin / Admin@123");
  console.log("  Business Staff : vinayaka_staff / Admin@123");
  console.log("  Tenant 2 Admin : deccan_admin / Admin@123");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
