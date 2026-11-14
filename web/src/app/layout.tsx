import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "CLICK Smart Chart — Multi-Tenant Goods Management SaaS Platform",
  description:
    "Enterprise SaaS Goods, Arrival Lot, Smart Chart, Auction, Purchase & Sales Billing, Partner Ledgers, and Inventory Platform.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-slate-50 text-slate-900">{children}</body>
    </html>
  );
}
