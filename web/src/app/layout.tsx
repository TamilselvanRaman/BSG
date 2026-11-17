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
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,400;1,600&family=JetBrains+Mono:ital,wght@0,400;0,500;0,600;0,700;1,400&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="min-h-screen font-sans bg-slate-50 text-slate-900 antialiased">{children}</body>
    </html>
  );
}
