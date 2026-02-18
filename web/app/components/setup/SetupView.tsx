"use client";

import { useEffect, useRef, useState, useCallback, useMemo } from "react";
import { type Lang, t } from "../../i18n";
import { type ThemeKey, THEMES } from "../../lib/themes";
import { SourceSelector } from "./SourceSelector";
import { ThemePicker } from "./ThemePicker";
import { ActivateButton } from "./ActivateButton";
import { GlobeIcon, CatIcon } from "../icons";
import { useMouseGlow } from "../../hooks/useMouseGlow";

function buildCatPatternSvg(color: string) {
  // Tiny inline SVG cat face for tiling — matches CatIcon shape
  return encodeURIComponent(
    `<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64"><g fill="${color}" opacity="0.04"><rect x="18" y="16" width="2" height="2"/><rect x="18" y="18" width="2" height="2"/><rect x="20" y="18" width="2" height="2"/><rect x="38" y="16" width="2" height="2"/><rect x="38" y="18" width="2" height="2"/><rect x="36" y="18" width="2" height="2"/><rect x="22" y="20" width="16" height="2"/><rect x="18" y="22" width="22" height="2"/><rect x="18" y="24" width="22" height="2"/><rect x="18" y="26" width="22" height="2"/><rect x="18" y="28" width="22" height="2"/><rect x="18" y="30" width="22" height="2"/><rect x="18" y="32" width="22" height="2"/><rect x="18" y="34" width="22" height="2"/><rect x="20" y="36" width="18" height="2"/><rect x="22" y="38" width="14" height="2"/><rect x="22" y="24" width="4" height="4" fill="black" opacity="0.5"/><rect x="32" y="24" width="4" height="4" fill="black" opacity="0.5"/><rect x="27" y="32" width="4" height="2" fill="black" opacity="0.3"/></g></svg>`,
  );
}

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
  const catPattern = useMemo(() => buildCatPatternSvg(themeColors.primary), [themeColors.primary]);

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
      {/* Cat pattern background */}
      <div
        className="pointer-events-none fixed inset-0 z-0"
        style={{
          backgroundImage: `url("data:image/svg+xml,${catPattern}")`,
          backgroundSize: "64px 64px",
        }}
      />

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
              <span className="inline-flex items-end overflow-hidden group-hover/logo:animate-cat-walk" style={{ height: "1em" }}>
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
