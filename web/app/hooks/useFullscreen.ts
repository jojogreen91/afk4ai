"use client";

import { useState, useCallback, useEffect } from "react";

export function useFullscreen() {
  const [isFullscreen, setIsFullscreen] = useState(false);

  const enterFullscreen = useCallback(async () => {
    try {
      await document.documentElement.requestFullscreen();
      // Try keyboard lock (Chromium only)
      if ("keyboard" in navigator && "lock" in (navigator.keyboard as any)) {
        try {
          await (navigator.keyboard as any).lock([
            "Escape",
            "Tab",
            "AltLeft",
            "AltRight",
            "MetaLeft",
            "MetaRight",
          ]);
        } catch {
          // Keyboard lock not supported — that's OK
        }
      }
      setIsFullscreen(true);
    } catch {
      // Fullscreen request failed
    }
  }, []);

  const exitFullscreen = useCallback(async () => {
    try {
      if ("keyboard" in navigator && "unlock" in (navigator.keyboard as any)) {
        (navigator.keyboard as any).unlock();
      }
      if (document.fullscreenElement) {
        await document.exitFullscreen();
      }
      setIsFullscreen(false);
    } catch {
      setIsFullscreen(false);
    }
  }, []);

  useEffect(() => {
    const handler = () => {
      setIsFullscreen(!!document.fullscreenElement);
    };
    document.addEventListener("fullscreenchange", handler);
    return () => document.removeEventListener("fullscreenchange", handler);
  }, []);

  return { isFullscreen, enterFullscreen, exitFullscreen };
}
