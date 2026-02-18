"use client";

import { useEffect } from "react";

export function useInputBlock(active: boolean) {
  useEffect(() => {
    if (!active) return;

    const blockKey = (e: KeyboardEvent) => {
      // Allow F11 for fullscreen toggle as a safety hatch
      if (e.key === "F11") return;
      e.preventDefault();
      e.stopPropagation();
    };

    const blockMouse = (e: MouseEvent) => {
      // Don't block if the event target is inside the unlock area
      const target = e.target as HTMLElement;
      if (target.closest("[data-unlock-area]")) return;
      e.preventDefault();
      e.stopPropagation();
    };

    const blockContext = (e: Event) => {
      e.preventDefault();
    };

    document.addEventListener("keydown", blockKey, true);
    document.addEventListener("keyup", blockKey, true);
    document.addEventListener("keypress", blockKey, true);
    document.addEventListener("mousedown", blockMouse, true);
    document.addEventListener("mouseup", blockMouse, true);
    document.addEventListener("click", blockMouse, true);
    document.addEventListener("contextmenu", blockContext, true);

    return () => {
      document.removeEventListener("keydown", blockKey, true);
      document.removeEventListener("keyup", blockKey, true);
      document.removeEventListener("keypress", blockKey, true);
      document.removeEventListener("mousedown", blockMouse, true);
      document.removeEventListener("mouseup", blockMouse, true);
      document.removeEventListener("click", blockMouse, true);
      document.removeEventListener("contextmenu", blockContext, true);
    };
  }, [active]);
}
