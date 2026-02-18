"use client";

import { useEffect } from "react";
import { type Lang } from "../../i18n";
import { useFullscreen } from "../../hooks/useFullscreen";
import { useInputBlock } from "../../hooks/useInputBlock";
import { useElapsedTimer } from "../../hooks/useElapsedTimer";
import { useMouseGlow } from "../../hooks/useMouseGlow";
import { MarqueeBanner } from "./MarqueeBanner";
import { TimerBar } from "./TimerBar";
import { StreamArea } from "./StreamArea";
import { UnlockArea } from "./UnlockArea";
import { CatIcon } from "../icons";

interface LockScreenViewProps {
  stream: MediaStream;
  lang: Lang;
  onUnlock: () => void;
}

const FLOATING_CATS = Array.from({ length: 8 }, (_, i) => ({
  id: i,
  left: `${5 + ((i * 13) % 85)}%`,
  top: `${8 + ((i * 17) % 75)}%`,
  duration: `${18 + (i % 4) * 5}s`,
  delay: `${i * -3}s`,
  size: 16 + (i % 3) * 4,
}));

export function LockScreenView({ stream, lang, onUnlock }: LockScreenViewProps) {
  const { isFullscreen, enterFullscreen, exitFullscreen } = useFullscreen();
  const { formatted } = useElapsedTimer(true);
  const { glowRef, handleMouseMove } = useMouseGlow("var(--theme-primary)");
  useInputBlock(true);

  useEffect(() => {
    enterFullscreen();
  }, [enterFullscreen]);

  const handleUnlock = async () => {
    await exitFullscreen();
    onUnlock();
  };

  return (
    <div
      className="fixed inset-0 z-[9999] flex flex-col bg-[#050505]"
      onMouseMove={handleMouseMove}
    >
      {/* Mouse glow */}
      <div ref={glowRef} className="mouse-glow" />

      {/* Floating cats */}
      {FLOATING_CATS.map((cat) => (
        <div
          key={cat.id}
          className="pointer-events-none absolute z-[1] animate-float-cat"
          style={{
            left: cat.left,
            top: cat.top,
            "--float-duration": cat.duration,
            "--float-delay": cat.delay,
            opacity: 0.06,
          } as React.CSSProperties}
        >
          <CatIcon color="var(--theme-primary)" size={cat.size} />
        </div>
      ))}

      <div className="relative z-10 flex flex-1 flex-col">
        <MarqueeBanner />
        <div className="py-4 md:py-5">
          <TimerBar formatted={formatted} lang={lang} />
        </div>
        <div className="flex-1 overflow-hidden">
          <StreamArea stream={stream} />
        </div>
        <div className="flex items-center justify-center pb-8 md:pb-10">
          <UnlockArea onUnlock={handleUnlock} lang={lang} />
        </div>
      </div>
    </div>
  );
}
