import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: "class",
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
        // Nexi Inspired Dark & Light Purple Design System
        nexi: {
          // Dark Theme Palette
          dark: {
            bg: "#080516",
            sidebar: "#0D0920",
            card: "#15102B",
            cardHover: "#1E173D",
            accent: "#9475F5",
            accentSec: "#B49AFF",
            border: "#30264B",
            borderSubtle: "#201938",
            text: "#F8F5FF",
            textSec: "#B7ADC9",
            glow: "rgba(148, 117, 245, 0.25)",
          },
          // Light Theme Palette
          light: {
            bg: "#F8F7FC",
            sidebar: "#FFFFFF",
            card: "#FFFFFF",
            cardHover: "#F2EEFA",
            accent: "#7955DF",
            accentSec: "#8C6BEA",
            border: "#E9E3F4",
            borderSubtle: "#F0EAF8",
            text: "#211936",
            textSec: "#777086",
            glow: "rgba(121, 85, 223, 0.15)",
          },
          // Shared Status
          success: "#10B981",
          warning: "#F59E0B",
          error: "#EF4444",
          info: "#3B82F6",
        },
      },
      boxShadow: {
        glow: "0 0 25px -5px rgba(148, 117, 245, 0.3)",
        "glow-lg": "0 0 50px -10px rgba(148, 117, 245, 0.4)",
        "glow-card": "0 10px 30px -10px rgba(148, 117, 245, 0.15)",
        glass: "0 8px 32px 0 rgba(0, 0, 0, 0.37)",
      },
      backgroundImage: {
        "nexi-gradient": "linear-gradient(135deg, #9475F5 0%, #7955DF 100%)",
        "nexi-gradient-hover": "linear-gradient(135deg, #A78BFA 0%, #8B5CF6 100%)",
        "nexi-gradient-subtle": "linear-gradient(135deg, rgba(148, 117, 245, 0.15) 0%, rgba(121, 85, 223, 0.05) 100%)",
        "ambient-radial": "radial-gradient(ellipse 80% 50% at 50% -20%, rgba(148, 117, 245, 0.25), transparent 70%)",
        "ambient-radial-light": "radial-gradient(ellipse 80% 50% at 50% -20%, rgba(121, 85, 223, 0.12), transparent 70%)",
      },
    },
  },
  plugins: [],
};

export default config;
