"use client";

import { useEffect, useRef, useState, useCallback } from "react";
import { type Lang, t } from "../../i18n";
import { type ThemeKey, THEMES } from "../../lib/themes";
import { SourceSelector } from "./SourceSelector";
import { ThemePicker } from "./ThemePicker";
import { ActivateButton } from "./ActivateButton";
import { GlobeIcon, CatIcon } from "../icons";
import { useMouseGlow } from "../../hooks/useMouseGlow";

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
  const themeColors = THEMES[theme];
  const { glowRef, handleMouseMove } = useMouseGlow(themeColors.primary);
  // Cat follower state
  const mousePos = useRef({ x: 0, y: 0 });
  const catPos = useRef({ x: 0, y: 0 });
  const catRef = useRef<HTMLDivElement>(null);
  const [idle, setIdle] = useState(false);
  const idleTimer = useRef<ReturnType<typeof setTimeout>>(undefined);

  const onMouseMove = useCallback(
    (e: React.MouseEvent) => {
      handleMouseMove(e);
      mousePos.current = { x: e.clientX, y: e.clientY };
      setIdle(false);
      if (idleTimer.current) clearTimeout(idleTimer.current);
      idleTimer.current = setTimeout(() => setIdle(true), 2000);
    },
    [handleMouseMove],
  );

  // Lerp animation loop for cat follower
  useEffect(() => {
    let raf: number;
    const lerp = (a: number, b: number, t: number) => a + (b - a) * t;

    const animate = () => {
      catPos.current.x = lerp(catPos.current.x, mousePos.current.x, 0.06);
      catPos.current.y = lerp(catPos.current.y, mousePos.current.y, 0.06);
      if (catRef.current) {
        catRef.current.style.transform = `translate(${catPos.current.x - 12}px, ${catPos.current.y - 12}px)`;
      }
      raf = requestAnimationFrame(animate);
    };
    raf = requestAnimationFrame(animate);
    return () => cancelAnimationFrame(raf);
  }, []);

  return (
    <div
      className="relative flex min-h-screen flex-col items-center justify-center px-4 py-8"
      onMouseMove={onMouseMove}
    >
      {/* Mouse glow */}
      <div ref={glowRef} className="mouse-glow" />

      {/* Cat follower */}
      <div
        ref={catRef}
        className="pointer-events-none fixed top-0 left-0 z-50"
        style={{ willChange: "transform" }}
      >
        <div className={idle ? "animate-blink" : ""}>
          <CatIcon color={themeColors.primary} size={24} />
        </div>
      </div>

      <div className="relative z-10 w-full max-w-md space-y-8">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1
              className="group/logo flex items-center gap-2 text-3xl font-extrabold tracking-tight leading-none"
              style={{ color: "var(--theme-primary)" }}
            >
              <span className="inline-flex items-center group-hover/logo:animate-cat-walk">
                <CatIcon color="var(--theme-primary)" size={28} />
              </span>
              AFK4AI
            </h1>
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
          <div className="rounded-2xl border border-yellow-500/20 bg-yellow-500/5 px-4 py-3">
            <p className="text-sm text-yellow-300/90">
              {t.webapp.setup.browserWarning[lang]}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
