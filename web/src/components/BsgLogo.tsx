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
        {/* Enterprise Green & Emerald Gradients */}
        <linearGradient id="bsg-emerald-primary" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#10A66A" />
          <stop offset="100%" stopColor="#087A50" />
        </linearGradient>
        <linearGradient id="bsg-mint-secondary" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#DDF2E4" />
          <stop offset="100%" stopColor="#10A66A" />
        </linearGradient>
        <linearGradient id="bsg-box-top" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#DDF2E4" />
          <stop offset="100%" stopColor="#A8E2BD" />
        </linearGradient>
        <linearGradient id="bsg-box-left" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#087A50" />
          <stop offset="100%" stopColor="#063D2E" />
        </linearGradient>
        <linearGradient id="bsg-box-right" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#10A66A" />
          <stop offset="100%" stopColor="#087A50" />
        </linearGradient>
        <filter id="bsg-shadow" x="-10%" y="-10%" width="130%" height="130%">
          <feDropShadow dx="0" dy="2" stdDeviation="2.5" floodColor="#063D2E" floodOpacity="0.4" />
        </filter>
      </defs>

      {/* Rounded container with Deep Forest Green */}
      <rect width="48" height="48" rx="12" fill="#063D2E" />

      {/* BUYING ARROW (Procurement / Inward) */}
      <path
        d="M 10 18 A 16 16 0 0 1 36 12"
        stroke="url(#bsg-emerald-primary)"
        strokeWidth="3.2"
        strokeLinecap="round"
      />
      <polygon
        points="37,8 41,13 35,16"
        fill="#10A66A"
      />

      {/* SELLING ARROW (Sales / Outflow) */}
      <path
        d="M 38 30 A 16 16 0 0 1 12 36"
        stroke="url(#bsg-mint-secondary)"
        strokeWidth="3.2"
        strokeLinecap="round"
      />
      <polygon
        points="11,40 7,35 13,32"
        fill="#10A66A"
      />

      {/* CENTER GOODS MANAGEMENT CUBE */}
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

        {/* Seam lines */}
        <line x1="20" y1="16.25" x2="28" y2="20.75" stroke="#CDE8D5" strokeWidth="1" strokeOpacity="0.9" />
        <line x1="24" y1="23" x2="24" y2="32" stroke="#10A66A" strokeWidth="0.8" strokeOpacity="0.7" />

        {/* Center node */}
        <circle cx="24" cy="23" r="1.5" fill="#FFFFFF" />
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
            } ${isDark ? "text-white" : "text-[#063D2E]"}`}
          >
            BSG
          </span>
          <span
            className={`rounded-md px-1.5 py-0.5 text-[9px] font-black tracking-wider uppercase ${
              isDark
                ? "bg-[#0A503B] text-[#A8E2BD] border border-[#10A66A]/40"
                : "bg-[#E8F5EC] text-[#087A50] border border-[#CDE8D5]"
            }`}
          >
            MANDI OS
          </span>
        </div>
        <span
          className={`font-medium tracking-tight mt-1 leading-none ${
            size === "sm" ? "text-[10px]" : "text-[11px]"
          } ${isDark ? "text-[#C4E2CF]" : "text-[#47785C]"}`}
        >
          Buyer • Seller • Goods Platform
        </span>
      </div>
    </div>
  );
}
