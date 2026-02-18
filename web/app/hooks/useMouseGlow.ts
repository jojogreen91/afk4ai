"use client";

import { useCallback, useRef } from "react";

export function useMouseGlow(color: string) {
  const glowRef = useRef<HTMLDivElement>(null);

  const handleMouseMove = useCallback(
    (e: React.MouseEvent) => {
      if (!glowRef.current) return;
      const { clientX, clientY } = e;
      glowRef.current.style.background = `radial-gradient(600px circle at ${clientX}px ${clientY}px, color-mix(in srgb, ${color} 8%, transparent), transparent 70%)`;
    },
    [color],
  );

  return { glowRef, handleMouseMove };
}
