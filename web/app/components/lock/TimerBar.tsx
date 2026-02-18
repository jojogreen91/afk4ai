"use client";

import { type Lang, t } from "../../i18n";
import { ClockIcon } from "../icons";
import { useClock } from "../../hooks/useClock";
import { useBattery } from "../../hooks/useBattery";
import { useNetwork } from "../../hooks/useNetwork";

interface TimerBarProps {
  formatted: string;
  lang: Lang;
}

export function TimerBar({ formatted, lang }: TimerBarProps) {
  const clock = useClock();
  const battery = useBattery();
  const network = useNetwork();

  return (
    <div
      className="border-y px-4 py-3 md:px-6"
      style={{
        borderColor: "color-mix(in srgb, var(--theme-primary) 30%, transparent)",
        backgroundColor: "rgba(0,0,0,0.6)",
        fontFamily: "'JetBrains Mono', monospace",
      }}
    >
      <div className="flex items-center justify-between gap-4 text-xs md:text-sm">
        {/* Current time */}
        <div className="flex items-center gap-1.5">
          <span className="text-white/50">{lang === "ko" ? "현재" : "NOW"}</span>
          <span className="font-bold text-white/90">{clock}</span>
        </div>

        {/* Elapsed */}
        <div className="flex items-center gap-1.5">
          <ClockIcon />
          <span className="text-lg font-bold md:text-xl" style={{ color: "var(--theme-primary)" }}>
            {formatted}
          </span>
          <span className="text-white/50">{t.webapp.lock.elapsed[lang]}</span>
        </div>

        {/* Network + Battery */}
        <div className="flex items-center gap-3">
          {/* Network */}
          <div className="flex items-center gap-1.5">
            <span
              className="inline-block h-1.5 w-1.5 rounded-full"
              style={{ backgroundColor: network.online ? "var(--theme-status)" : "#ef4444" }}
            />
            <span className={network.online ? "text-white/70" : "text-red-400 font-bold"}>
              {network.online
                ? (network.downlink ? `${network.downlink} Mbps` : network.type.toUpperCase())
                : "OFFLINE"}
            </span>
          </div>

          <div className="h-3 w-px bg-white/15" />

          {/* Battery */}
          {battery.supported && (
            <div className="flex items-center gap-1.5">
              <BatteryIcon level={battery.level} charging={battery.charging} />
              <span className="text-white/70">
                {Math.round(battery.level * 100)}%
              </span>
            </div>
          )}
        </div>
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
