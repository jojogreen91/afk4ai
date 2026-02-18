export type ThemeKey = "ember" | "mono" | "ocean" | "matrix";

export interface ThemeColors {
  primary: string;
  primaryLight: string;
  bannerText: string;
  status: string;
}

export const THEMES: Record<ThemeKey, ThemeColors> = {
  ember: {
    primary: "#FF4D00",
    primaryLight: "#FF6B2B",
    bannerText: "#000",
    status: "#00FF41",
  },
  mono: {
    primary: "#FFFFFF",
    primaryLight: "#888888",
    bannerText: "#000",
    status: "#AAAAAA",
  },
  ocean: {
    primary: "#1E40AF",
    primaryLight: "#2563EB",
    bannerText: "#FFF",
    status: "#0E7490",
  },
  matrix: {
    primary: "#059669",
    primaryLight: "#10B981",
    bannerText: "#FFF",
    status: "#34D399",
  },
};

export function applyTheme(theme: ThemeKey) {
  const colors = THEMES[theme];
  const root = document.documentElement;
  root.style.setProperty("--theme-primary", colors.primary);
  root.style.setProperty("--theme-primary-light", colors.primaryLight);
  root.style.setProperty("--theme-banner-text", colors.bannerText);
  root.style.setProperty("--theme-status", colors.status);
}
