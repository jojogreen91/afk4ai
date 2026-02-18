"use client";

import { type Lang, t } from "../../i18n";
import { THEMES, type ThemeKey } from "../../lib/themes";

interface ThemePickerProps {
  selected: ThemeKey;
  onSelect: (theme: ThemeKey) => void;
  lang: Lang;
}

const THEME_KEYS: ThemeKey[] = ["ember", "mono", "ocean", "matrix"];

export function ThemePicker({ selected, onSelect, lang }: ThemePickerProps) {
  return (
    <div className="space-y-3">
      <h3 className="text-sm font-bold text-white uppercase tracking-wider">
        {t.webapp.setup.selectTheme[lang]}
      </h3>
      <div className="grid grid-cols-4 gap-3">
        {THEME_KEYS.map((key) => {
          const theme = THEMES[key];
          const isSelected = key === selected;
          return (
            <button
              key={key}
              onClick={() => onSelect(key)}
              className="group relative flex flex-col items-center gap-2 rounded-2xl border p-3 transition-all duration-200 hover:scale-[1.02]"
              style={{
                borderColor: isSelected ? theme.primary : "rgba(255,255,255,0.1)",
                backgroundColor: isSelected ? `color-mix(in srgb, ${theme.primary} 10%, transparent)` : "rgba(255,255,255,0.03)",
              }}
              onMouseEnter={(e) => { e.currentTarget.style.boxShadow = `0 4px 24px color-mix(in srgb, ${theme.primary} 25%, transparent)`; }}
              onMouseLeave={(e) => { e.currentTarget.style.boxShadow = "none"; }}
            >
              {/* Gradient swatch */}
              <div
                className="h-10 w-full rounded-lg"
                style={{
                  background: `linear-gradient(135deg, ${theme.primary}, ${theme.primaryLight})`,
                }}
              />
              <span className="text-xs font-semibold capitalize" style={{ color: isSelected ? theme.primary : "rgba(255,255,255,0.9)" }}>
                {key}
              </span>
              {isSelected && (
                <div
                  className="absolute -top-1 -right-1 flex h-5 w-5 items-center justify-center rounded-full text-[10px]"
                  style={{ backgroundColor: theme.primary, color: theme.bannerText }}
                >
                  ✓
                </div>
              )}
            </button>
          );
        })}
      </div>
    </div>
  );
}
