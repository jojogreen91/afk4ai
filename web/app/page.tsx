"use client";

import { useState, useEffect, useCallback } from "react";
import { type Lang } from "./i18n";
import { type ThemeKey, applyTheme } from "./lib/themes";
import { useScreenCapture } from "./hooks/useScreenCapture";
import { SetupView } from "./components/setup/SetupView";
import { LockScreenView } from "./components/lock/LockScreenView";

function getDefaultLang(): Lang {
  if (typeof navigator === "undefined") return "ko";
  const browserLang = navigator.language || "";
  return browserLang.startsWith("ko") ? "ko" : "en";
}

function isChromiumBrowser(): boolean {
  if (typeof navigator === "undefined") return false;
  const ua = navigator.userAgent;
  return /Chrome/.test(ua) && !/Edg/.test(ua) || /Edg/.test(ua);
}

type View = "setup" | "locked";

export default function WebApp() {
  const [lang, setLang] = useState<Lang>("ko");
  const [theme, setTheme] = useState<ThemeKey>("ember");
  const [view, setView] = useState<View>("setup");
  const [isChromium, setIsChromium] = useState(true);
  const { stream, thumbnail, requestCapture, stopCapture } = useScreenCapture();

  useEffect(() => {
    setLang(getDefaultLang());
    setIsChromium(isChromiumBrowser());
  }, []);

  useEffect(() => {
    applyTheme(theme);
  }, [theme]);

  const handleActivate = useCallback(() => {
    if (stream) {
      setView("locked");
    }
  }, [stream]);

  const handleUnlock = useCallback(() => {
    setView("setup");
  }, []);

  if (view === "locked" && stream) {
    return (
      <LockScreenView
        stream={stream}
        lang={lang}
        onUnlock={handleUnlock}
      />
    );
  }

  return (
    <SetupView
      lang={lang}
      setLang={setLang}
      theme={theme}
      setTheme={setTheme}
      thumbnail={thumbnail}
      hasStream={!!stream}
      onSelectScreen={requestCapture}
      onActivate={handleActivate}
      isChromium={isChromium}
    />
  );
}
