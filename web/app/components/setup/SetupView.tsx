"use client";

import { type Lang, t } from "../../i18n";
import { type ThemeKey } from "../../lib/themes";
import { SourceSelector } from "./SourceSelector";
import { ThemePicker } from "./ThemePicker";
import { ActivateButton } from "./ActivateButton";
import { GlobeIcon } from "../icons";

interface SetupViewProps {
  lang: Lang;
  setLang: (l: Lang) => void;
  theme: ThemeKey;
  setTheme: (t: ThemeKey) => void;
  thumbnail: string | null;
  hasStream: boolean;
  onSelectScreen: () => void;
  onActivate: () => void;
  isChromium: boolean;
}

export function SetupView({
  lang,
  setLang,
  theme,
  setTheme,
  thumbnail,
  hasStream,
  onSelectScreen,
  onActivate,
  isChromium,
}: SetupViewProps) {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center px-4 py-8">
      <div className="w-full max-w-md space-y-8">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-extrabold tracking-tight" style={{ color: "var(--theme-primary)" }}>
              AFK4AI
            </h1>
            <p className="mt-1 text-sm text-white/90">
              {t.webapp.setup.title[lang]}
            </p>
          </div>
          <div className="flex items-center gap-3">
            <a
              href="/landing"
              className="text-xs text-white/70 transition hover:text-white"
            >
              {t.webapp.setup.landing[lang]}
            </a>
            <button
              onClick={() => setLang(lang === "ko" ? "en" : "ko")}
              className="flex items-center gap-1.5 rounded-lg border border-white/30 px-3 py-1.5 text-xs font-medium text-white/90 transition hover:border-white/50 hover:text-white"
            >
              <GlobeIcon />
              {lang === "ko" ? "EN" : "한국어"}
            </button>
          </div>
        </div>

        {/* Source Selector */}
        <SourceSelector
          thumbnail={thumbnail}
          hasStream={hasStream}
          onSelect={onSelectScreen}
          lang={lang}
        />

        {/* Theme Picker */}
        <ThemePicker selected={theme} onSelect={setTheme} lang={lang} />

        {/* Activate Button */}
        <ActivateButton
          enabled={hasStream}
          onClick={onActivate}
          lang={lang}
        />

        {/* Browser Warning */}
        {!isChromium && (
          <div className="rounded-lg border border-yellow-500/20 bg-yellow-500/5 px-4 py-3">
            <p className="text-sm text-yellow-300/90">
              ⚠ {t.webapp.setup.browserWarning[lang]}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
