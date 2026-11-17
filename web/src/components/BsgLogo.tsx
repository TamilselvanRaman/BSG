import React from "react";

interface BsgLogoProps {
  size?: "sm" | "md" | "lg" | "xl";
  variant?: "full" | "icon" | "stacked";
  theme?: "light" | "dark";
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
        {/* Gradients */}
        <linearGradient id="bsg-blue-grad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#2563EB" />
          <stop offset="100%" stopColor="#1D4ED8" />
        </linearGradient>
        <linearGradient id="bsg-emerald-grad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#10B981" />
          <stop offset="100%" stopColor="#059669" />
        </linearGradient>
        <linearGradient id="bsg-box-top" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#60A5FA" />
          <stop offset="100%" stopColor="#3B82F6" />
        </linearGradient>
        <linearGradient id="bsg-box-left" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#1E40AF" />
          <stop offset="100%" stopColor="#1E3A8A" />
        </linearGradient>
        <linearGradient id="bsg-box-right" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#3B82F6" />
          <stop offset="100%" stopColor="#1D4ED8" />
        </linearGradient>
        <filter id="bsg-shadow" x="-10%" y="-10%" width="130%" height="130%">
          <feDropShadow dx="0" dy="2" stdDeviation="2.5" floodColor="#1E3A8A" floodOpacity="0.25" />
        </filter>
      </defs>

      {/* Rounded container with subtle backdrop */}
      <rect width="48" height="48" rx="12" fill="#0F172A" />

      {/* --- BUYING ARROW (Green / Inward / Procurement) --- */}
      {/* Curved arrow coming in from top-left curving clockwise */}
      <path
        d="M 10 18 A 16 16 0 0 1 36 12"
        stroke="url(#bsg-emerald-grad)"
        strokeWidth="3.2"
        strokeLinecap="round"
      />
      {/* Arrowhead on top right */}
      <polygon
        points="37,8 41,13 35,16"
        fill="#10B981"
      />

      {/* --- SELLING ARROW (Blue / Outward / Sales) --- */}
      {/* Curved arrow coming in from bottom-right curving clockwise */}
      <path
        d="M 38 30 A 16 16 0 0 1 12 36"
        stroke="url(#bsg-blue-grad)"
        strokeWidth="3.2"
        strokeLinecap="round"
      />
      {/* Arrowhead on bottom left */}
      <polygon
        points="11,40 7,35 13,32"
        fill="#3B82F6"
      />

      {/* --- CENTER PRODUCT / GOODS MANAGEMENT CUBE --- */}
      <g filter="url(#bsg-shadow)">
        {/* Isometric Cube Top Face */}
        <polygon
          points="24,14 32,18.5 24,23 16,18.5"
          fill="url(#bsg-box-top)"
        />
        {/* Isometric Cube Left Face */}
        <polygon
          points="16,18.5 24,23 24,32 16,27.5"
          fill="url(#bsg-box-left)"
        />
        {/* Isometric Cube Right Face */}
        <polygon
          points="24,23 32,18.5 32,27.5 24,32"
          fill="url(#bsg-box-right)"
        />

        {/* Goods box tape / seam lines */}
        <line x1="20" y1="16.25" x2="28" y2="20.75" stroke="#93C5FD" strokeWidth="1" strokeOpacity="0.8" />
        <line x1="24" y1="23" x2="24" y2="32" stroke="#60A5FA" strokeWidth="0.8" strokeOpacity="0.6" />

        {/* Small scale / weigh pip in center */}
        <circle cx="24" cy="23" r="1.5" fill="#34D399" />
      </g>
    </svg>
  );
}

export function BsgLogo({
  size = "md",
  variant = "full",
  theme = "light",
  className = "",
}: BsgLogoProps) {
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
      <BsgIcon size={px} className="shrink-0 shadow-sm rounded-xl" />
      <div>
        <div className="flex items-center gap-1.5 leading-none">
          <span
            className={`font-black tracking-tight ${
              size === "sm"
                ? "text-lg"
                : size === "lg"
                ? "text-2xl"
                : size === "xl"
                ? "text-3xl"
                : "text-xl"
            } ${isDark ? "text-white" : "text-slate-900"}`}
          >
            BSG
          </span>
          <span className="rounded-md bg-blue-600/10 px-1.5 py-0.5 text-[9px] font-extrabold uppercase tracking-wider text-blue-600">
            Mandi OS
          </span>
        </div>
        <p
          className={`font-medium tracking-wide mt-0.5 ${
            size === "sm" ? "text-[10px]" : "text-[11px]"
          } ${isDark ? "text-slate-400" : "text-slate-500"}`}
        >
          Buyer • Seller • Goods Platform
        </p>
      </div>
    </div>
  );
}
