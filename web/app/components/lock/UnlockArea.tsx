"use client";

import { type Lang, t } from "../../i18n";
import { useLongPress } from "../../hooks/useLongPress";

interface UnlockAreaProps {
  onUnlock: () => void;
  lang: Lang;
}

const SIZE = 96;
const STROKE = 3;
const RADIUS = (SIZE - STROKE) / 2;
const CIRCUMFERENCE = 2 * Math.PI * RADIUS;

export function UnlockArea({ onUnlock, lang }: UnlockAreaProps) {
  const { progress, pressing, handlers } = useLongPress(onUnlock);
  const dashoffset = CIRCUMFERENCE * (1 - progress);

  return (
    <div
      data-unlock-area
      className="flex flex-col items-center gap-4 px-6 py-6"
    >
      <button
        className="relative flex items-center justify-center select-none"
        style={{
          width: SIZE,
          height: SIZE,
          cursor: "pointer",
          WebkitUserSelect: "none",
          userSelect: "none",
        }}
        {...handlers}
      >
        {/* SVG progress ring — same size as button */}
        <svg
          width={SIZE}
          height={SIZE}
          viewBox={`0 0 ${SIZE} ${SIZE}`}
          className="absolute inset-0"
          style={{ transform: "rotate(-90deg)" }}
        >
          <circle
            cx={SIZE / 2}
            cy={SIZE / 2}
            r={RADIUS}
            fill="none"
            stroke="rgba(255,255,255,0.1)"
            strokeWidth={STROKE}
          />
          <circle
            cx={SIZE / 2}
            cy={SIZE / 2}
            r={RADIUS}
            fill="none"
            stroke="var(--theme-primary)"
            strokeWidth={STROKE}
            strokeLinecap="round"
            strokeDasharray={CIRCUMFERENCE}
            strokeDashoffset={dashoffset}
            style={{ transition: pressing ? "none" : "stroke-dashoffset 0.15s ease-out" }}
          />
        </svg>
        {/* Inner circle + icon */}
        <div className="relative z-10 flex h-[82px] w-[82px] items-center justify-center rounded-full border border-white/25 bg-white/10">
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" className="text-white/90">
            <rect x="3" y="11" width="18" height="11" rx="2" stroke="currentColor" strokeWidth="1.5" />
            <path d="M7 11V7a5 5 0 019.9-1" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
          </svg>
        </div>
      </button>
      <span
        className="text-xs text-white/60 select-none"
        style={{ fontFamily: "'JetBrains Mono', monospace" }}
      >
        {pressing
          ? `${Math.round(progress * 100)}%`
          : t.webapp.lock.unlockHint[lang]}
      </span>
    </div>
  );
}
