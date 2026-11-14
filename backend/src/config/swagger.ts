export const openApiSpec = {
  openapi: "3.0.3",
  info: {
    title: "CLICK Smart Chart — Multi-Tenant Goods Management SaaS API",
    version: "1.0.0",
    description:
      "Production REST API for Super Admin, Business Admin, and Business Employees across Next.js Web and Flutter Mobile applications.",
  },
  servers: [{ url: "/api/v1", description: "Version 1 REST API" }],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: "http",
        scheme: "bearer",
        bearerFormat: "JWT",
      },
    },
  },
  security: [{ bearerAuth: [] }],
  paths: {
    "/auth/login": {
      post: {
        tags: ["Authentication"],
        summary: "Authenticate with username and password",
        responses: { "200": { description: "Returns accessToken, refreshToken, and role-based redirectTo" } },
      },
    },
    "/auth/register-business": {
      post: {
        tags: ["Authentication"],
        summary: "Register a new multi-tenant business and Admin account",
        responses: { "201": { description: "Tenant and trial subscription provisioned" } },
      },
    },
    "/super-admin/dashboard": {
      get: {
        tags: ["Super Admin"],
        summary: "Platform-wide SaaS metrics, MRR, active/suspended tenants, and conversion rate",
        responses: { "200": { description: "Super Admin dashboard telemetry" } },
      },
    },
    "/business/dashboard": {
      get: {
        tags: ["Business Workspace"],
        summary: "Tenant-scoped business overview, receivables, payables, stock valuation, and recent activity",
        responses: { "200": { description: "Business dashboard metrics" } },
      },
    },
    "/buyers": {
      get: { tags: ["Partners"], summary: "List tenant buyers", responses: { "200": { description: "OK" } } },
      post: { tags: ["Partners"], summary: "Create tenant buyer", responses: { "201": { description: "Created" } } },
    },
    "/sellers": {
      get: { tags: ["Partners"], summary: "List tenant sellers", responses: { "200": { description: "OK" } } },
      post: { tags: ["Partners"], summary: "Create tenant seller", responses: { "201": { description: "Created" } } },
    },
    "/goods": {
      get: { tags: ["Goods & Inventory"], summary: "List goods catalog", responses: { "200": { description: "OK" } } },
      post: { tags: ["Goods & Inventory"], summary: "Create goods item", responses: { "201": { description: "Created" } } },
    },
    "/goods-lots": {
      get: { tags: ["Goods & Inventory"], summary: "List arrival lots", responses: { "200": { description: "OK" } } },
      post: { tags: ["Goods & Inventory"], summary: "Create goods lot", responses: { "201": { description: "Created" } } },
    },
    "/smart-charts": {
      get: { tags: ["Smart Chart & Auctions"], summary: "List Smart Charts", responses: { "200": { description: "OK" } } },
      post: { tags: ["Smart Chart & Auctions"], summary: "Create Smart Chart", responses: { "201": { description: "Created" } } },
    },
    "/purchases": {
      get: { tags: ["Billing"], summary: "List purchase bills", responses: { "200": { description: "OK" } } },
      post: { tags: ["Billing"], summary: "Create purchase bill with ACID stock & ledger update", responses: { "201": { description: "Created" } } },
    },
    "/sales": {
      get: { tags: ["Billing"], summary: "List sales bills", responses: { "200": { description: "OK" } } },
      post: { tags: ["Billing"], summary: "Create sales bill with ACID stock & ledger update", responses: { "201": { description: "Created" } } },
    },
    "/payments": {
      get: { tags: ["Payments & Ledgers"], summary: "List payments", responses: { "200": { description: "OK" } } },
      post: { tags: ["Payments & Ledgers"], summary: "Record buyer receipt or seller payout", responses: { "201": { description: "Created" } } },
    },
    "/reports/daily-summary": {
      get: { tags: ["Reports"], summary: "Daily summary report with vehicle numbers and totals", responses: { "200": { description: "OK" } } },
    },
    "/documents/pdf": {
      post: { tags: ["Documents"], summary: "Generate branded PDF for bills, receipts, and ledgers", responses: { "201": { description: "PDF Generated" } } },
    },
  },
};
