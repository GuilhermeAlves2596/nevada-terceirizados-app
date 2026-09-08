import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        // Alinhado ao primário do app mobile (AppColors.primary = 0xFF1D4F91).
        brand: {
          DEFAULT: "#1D4F91",
          dark: "#163d70",
          soft: "#E8EEF6",
        },
      },
    },
  },
  plugins: [],
};

export default config;
