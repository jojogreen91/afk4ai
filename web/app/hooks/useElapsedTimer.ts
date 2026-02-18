"use client";

import { useState, useEffect, useRef } from "react";

function pad(n: number): string {
  return n.toString().padStart(2, "0");
}

export function useElapsedTimer(active: boolean) {
  const [elapsed, setElapsed] = useState(0);
  const startRef = useRef<number>(0);
  const rafRef = useRef<number>(0);

  useEffect(() => {
    if (!active) {
      setElapsed(0);
      return;
    }

    startRef.current = Date.now();

    const tick = () => {
      setElapsed(Math.floor((Date.now() - startRef.current) / 1000));
      rafRef.current = requestAnimationFrame(tick);
    };

    rafRef.current = requestAnimationFrame(tick);

    return () => {
      cancelAnimationFrame(rafRef.current);
    };
  }, [active]);

  const hours = Math.floor(elapsed / 3600);
  const minutes = Math.floor((elapsed % 3600) / 60);
  const seconds = elapsed % 60;
  const formatted = `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;

  return { elapsed, formatted };
}
