import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: [
          "var(--font-sans)",
          "'Plus Jakarta Sans'",
          "-apple-system",
          "BlinkMacSystemFont",
          "'Segoe UI'",
          "Roboto",
          "'Helvetica Neue'",
          "Arial",
          "sans-serif",
        ],
        mono: [
          "var(--font-mono)",
          "'JetBrains Mono'",
          "ui-monospace",
          "SFMono-Regular",
          "Menlo",
          "Monaco",
          "Consolas",
          "monospace",
        ],
      },
      colors: {
        // Deep Green Enterprise Brand Tokens
        bsg: {
          forest: "#063D2E",     // Deep Forest Green
          forestSec: "#0A503B",  // Dark Section Secondary
          darkGreen: "#145A3B",  // Dark Green
          enterprise: "#087A50", // Enterprise Green (Primary Button)
          hover: "#063D2E",      // Primary Hover
          emerald: "#10A66A",    // Emerald Green
          pageBg: "#F4FAF5",     // Main Page Background
          surface: "#FFFFFF",    // Primary Surface
          surfaceSec: "#E8F5EC", // Secondary Surface
          mint: "#DDF2E4",       // Mint Surface
          textPrimary: "#123B29",// Primary Text
          textSec: "#47785C",    // Secondary Text
          textMuted: "#71917B",  // Muted Text
          darkText: "#FFFFFF",   // Text on Dark Background
          darkSecText: "#C4E2CF",// Secondary Dark Section Text
          border: "#CDE8D5",     // Default Border
          borderSubtle: "#DCEEE1", // Subtle Border
          borderActive: "#10A66A", // Active Border
          statusSuccess: "#087A50",
          statusWarning: "#B7791F",
          statusError: "#C2413B",
        },
      },
    },
  },
  plugins: [],
};

export default config;
