# Database Schema — MySQL 8+ & Prisma ORM

The normalized database schema is defined in `backend/click-smart-chart-api/prisma/schema.prisma`.

## Platform Tables
1. `roles` (`SUPER_ADMIN`, `ADMIN`, `BUSINESS_USER`)
2. `permissions` (34 granular module permission codes)
3. `role_permissions`
4. `user_permissions` (per-employee permission overrides)
5. `tenants`
6. `users`
7. `tenant_users`
8. `refresh_tokens`
9. `password_reset_tokens`
10. `subscription_plans`
11. `plan_features`
12. `subscriptions`
13. `subscription_payments`
14. `subscription_invoices`
15. `platform_settings`
16. `notifications`
17. `audit_logs`
18. `support_tickets`

## Business Tenant Tables
19. `business_profiles`
20. `business_settings`
21. `buyers`
22. `sellers`
23. `goods_categories`
24. `goods`
25. `goods_lots`
26. `goods_entries`
27. `smart_charts`
28. `smart_chart_items`
29. `auctions`
30. `auction_items`
31. `purchase_bills`
32. `purchase_bill_items`
33. `sales_bills`
34. `sales_bill_items`
35. `payments`
36. `buyer_ledger_entries`
37. `seller_ledger_entries`
38. `advances`
39. `advance_adjustments`
40. `inventory_transactions`
41. `business_documents`
