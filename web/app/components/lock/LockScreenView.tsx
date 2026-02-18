"use client";

import { useEffect } from "react";
import { type Lang } from "../../i18n";
import { useFullscreen } from "../../hooks/useFullscreen";
import { useInputBlock } from "../../hooks/useInputBlock";
import { useElapsedTimer } from "../../hooks/useElapsedTimer";
import { MarqueeBanner } from "./MarqueeBanner";
import { TimerBar } from "./TimerBar";
import { StreamArea } from "./StreamArea";
import { UnlockArea } from "./UnlockArea";

interface LockScreenViewProps {
  stream: MediaStream;
  lang: Lang;
  onUnlock: () => void;
}

export function LockScreenView({ stream, lang, onUnlock }: LockScreenViewProps) {
  const { isFullscreen, enterFullscreen, exitFullscreen } = useFullscreen();
  const { formatted } = useElapsedTimer(true);
  useInputBlock(true);

  useEffect(() => {
    enterFullscreen();
  }, [enterFullscreen]);

  const handleUnlock = async () => {
    await exitFullscreen();
    onUnlock();
  };

  return (
    <div className="fixed inset-0 z-[9999] flex flex-col bg-[#050505]">
      <MarqueeBanner />
      <TimerBar formatted={formatted} lang={lang} />
      <div className="flex-1 overflow-hidden py-2">
        <StreamArea stream={stream} lang={lang} />
      </div>
      <UnlockArea onUnlock={handleUnlock} lang={lang} />
    </div>
  );
}
