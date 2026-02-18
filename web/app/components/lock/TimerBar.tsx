"use client";

import { type Lang, t } from "../../i18n";
import { ClockIcon, CatIcon } from "../icons";
import { useClock } from "../../hooks/useClock";
import { useBattery } from "../../hooks/useBattery";

interface TimerBarProps {
  formatted: string;
  lang: Lang;
}

export function TimerBar({ formatted, lang }: TimerBarProps) {
  const clock = useClock();
  const battery = useBattery();

  return (
    <div
      className="px-5 py-4 md:px-8"
      style={{
        backgroundColor: "rgba(0,0,0,0.4)",
        fontFamily: "'JetBrains Mono', monospace",
      }}
    >
      <div className="flex items-center justify-center gap-5 text-sm md:text-base">
        {/* Left cat */}
        <span className="animate-cat-walk">
          <CatIcon color="var(--theme-primary)" size={24} />
        </span>

        {/* LIVE indicator — green */}
        <div className="flex items-center gap-1.5">
          <span className="inline-block h-1.5 w-1.5 rounded-full bg-green-400 animate-pulse-dot" />
          <span className="text-sm font-bold text-green-400">LIVE</span>
        </div>

        <span className="text-white/20">·</span>

        {/* Current time */}
        <div className="flex items-center gap-1.5">
          <span className="text-white/50">{lang === "ko" ? "현재 시간" : "NOW"}</span>
          <span className="font-bold text-white/90">{clock}</span>
        </div>

        <span className="text-white/20">·</span>

        {/* Elapsed */}
        <div className="flex items-center gap-1.5">
          <ClockIcon />
          <span className="text-xl font-bold md:text-2xl" style={{ color: "var(--theme-primary)" }}>
            {formatted}
          </span>
          <span className="text-white/50">{t.webapp.lock.elapsed[lang]}</span>
        </div>

        {/* Battery */}
        {battery.supported && (
          <>
            <span className="text-white/20">·</span>
            <div className="flex items-center gap-1.5">
              <BatteryIcon level={battery.level} charging={battery.charging} />
              <span className="text-white/70">
                {Math.round(battery.level * 100)}%
              </span>
            </div>
          </>
        )}

        {/* Right cat */}
        <span className="animate-cat-walk" style={{ animationDelay: "-0.2s" }}>
          <CatIcon color="var(--theme-primary)" size={24} />
        </span>
      </div>
    </div>
  );
}

function BatteryIcon({ level, charging }: { level: number; charging: boolean }) {
  const fill = level <= 0.2 ? "#ef4444" : "var(--theme-primary)";
  const w = Math.round(level * 12);

  return (
    <svg width="18" height="10" viewBox="0 0 20 12" fill="none">
      <rect x="0.5" y="0.5" width="16" height="11" rx="2" stroke="currentColor" strokeWidth="1" className="text-white/40" />
      <rect x="17" y="3" width="2.5" height="6" rx="1" fill="currentColor" className="text-white/40" />
      <rect x="2" y="2" width={w} height="8" rx="1" fill={fill} />
      {charging && (
        <path d="M9 1L6 6h3l-1 5 4-5H9l1-5z" fill="#FFF" opacity="0.9" />
      )}
    </svg>
  );
}
