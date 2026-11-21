"use client";

import React from "react";
import { useTheme } from "./ThemeProvider";

interface BsgLogoProps {
  size?: "sm" | "md" | "lg" | "xl";
  variant?: "full" | "icon" | "stacked";
  className?: string;
}

export function BsgIcon({ size = 36, className = "" }: { size?: number; className?: string }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 48 48"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
    >
      <defs>
        {/* Nexi Purple & Lavender Gradients */}
        <linearGradient id="nexi-violet-primary" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#B49AFF" />
          <stop offset="100%" stopColor="#7955DF" />
        </linearGradient>
        <linearGradient id="nexi-lavender-secondary" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#F8F5FF" />
          <stop offset="100%" stopColor="#9475F5" />
        </linearGradient>
        <linearGradient id="nexi-box-top" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#E9E3F4" />
          <stop offset="100%" stopColor="#B49AFF" />
        </linearGradient>
        <linearGradient id="nexi-box-left" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#7955DF" />
          <stop offset="100%" stopColor="#30264B" />
        </linearGradient>
        <linearGradient id="nexi-box-right" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#9475F5" />
          <stop offset="100%" stopColor="#7955DF" />
        </linearGradient>
        <filter id="nexi-shadow" x="-20%" y="-20%" width="140%" height="140%">
          <feDropShadow dx="0" dy="4" stdDeviation="4" floodColor="#9475F5" floodOpacity="0.35" />
        </filter>
      </defs>

      {/* Container with Dark Violet */}
      <rect width="48" height="48" rx="14" fill="#0D0920" stroke="#30264B" strokeWidth="1.5" />

      {/* Procurement Inward Arrow */}
      <path
        d="M 11 18 A 15 15 0 0 1 35 12"
        stroke="url(#nexi-violet-primary)"
        strokeWidth="3.2"
        strokeLinecap="round"
      />
      <polygon points="36,8 40,13 34,16" fill="#9475F5" />

      {/* Sales Outward Arrow */}
      <path
        d="M 37 30 A 15 15 0 0 1 13 36"
        stroke="url(#nexi-lavender-secondary)"
        strokeWidth="3.2"
        strokeLinecap="round"
      />
      <polygon points="12,40 8,35 14,32" fill="#B49AFF" />

      {/* Center 3D Smart Goods Cube */}
      <g filter="url(#nexi-shadow)">
        <polygon points="24,14 32,18.5 24,23 16,18.5" fill="url(#nexi-box-top)" />
        <polygon points="16,18.5 24,23 24,32 16,27.5" fill="url(#nexi-box-left)" />
        <polygon points="24,23 32,18.5 32,27.5 24,32" fill="url(#nexi-box-right)" />
        <line x1="20" y1="16.25" x2="28" y2="20.75" stroke="#F8F5FF" strokeWidth="1" strokeOpacity="0.8" />
        <line x1="24" y1="23" x2="24" y2="32" stroke="#9475F5" strokeWidth="0.8" strokeOpacity="0.7" />
        <circle cx="24" cy="23" r="1.5" fill="#FFFFFF" />
      </g>
    </svg>
  );
}

export function BsgLogo({
  size = "md",
  variant = "full",
  className = "",
}: BsgLogoProps) {
  const { theme } = useTheme();
  const pixelSizes = {
    sm: 32,
    md: 40,
    lg: 48,
    xl: 60,
  };

  const px = pixelSizes[size] || 40;
  const isDark = theme === "dark";

  if (variant === "icon") {
    return <BsgIcon size={px} className={className} />;
  }

  return (
    <div className={`flex items-center gap-3 ${className}`}>
      <BsgIcon size={px} className="shrink-0 rounded-2xl shadow-glow" />
      <div className="flex flex-col">
        <div className="flex items-center gap-2">
          <span
            className={`font-black tracking-tight leading-none ${
              size === "sm"
                ? "text-lg"
                : size === "lg"
                ? "text-2xl"
                : size === "xl"
                ? "text-3xl"
                : "text-xl"
            } ${isDark ? "text-[#F8F5FF]" : "text-[#211936]"}`}
          >
            Click Smart Chart
          </span>
          <span
            className={`rounded-md px-1.5 py-0.5 text-[9px] font-extrabold tracking-wider uppercase ${
              isDark
                ? "bg-[#1E173D] text-[#B49AFF] border border-[#9475F5]/30 shadow-xs"
                : "bg-[#F2EEFA] text-[#7955DF] border border-[#E9E3F4]"
            }`}
          >
            MANDI SaaS
          </span>
        </div>
        <span
          className={`font-medium tracking-tight mt-1 leading-none ${
            size === "sm" ? "text-[10px]" : "text-[11px]"
          } ${isDark ? "text-[#B7ADC9]" : "text-[#777086]"}`}
        >
          Multi-Product Auction • Goods • Billing • Ledgers
        </span>
      </div>
    </div>
  );
}
