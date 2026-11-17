import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "BSG — Buyer Seller Goods Management & Mandi SaaS Platform",
  description:
    "Enterprise Cloud SaaS Platform for Goods Inward Lots, Digital Weighment, Live Auctions, Multi-Product Billing, Partner Ledgers, and Cash Drawer Management.",
  icons: {
    icon: "/bsg-icon.svg",
  },
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
