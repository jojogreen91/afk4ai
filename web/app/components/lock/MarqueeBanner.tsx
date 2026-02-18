"use client";

import { WarningIcon } from "../icons";

const ITEMS = 20;

export function MarqueeBanner() {
  const segment = Array.from({ length: ITEMS }, (_, i) => (
    <span
      key={i}
      className="flex items-center gap-2.5 text-base font-bold tracking-widest md:text-lg"
      style={{ color: "var(--theme-banner-text)" }}
    >
      <WarningIcon /> AFK4AI
    </span>
  ));

  return (
    <div
      className="relative overflow-hidden py-3"
      style={{
        backgroundColor: "var(--theme-primary)",
        boxShadow: `0 4px 14px color-mix(in srgb, var(--theme-primary) 30%, transparent)`,
      }}
    >
      <div
        className="flex items-center gap-6 whitespace-nowrap"
        style={{
          fontFamily: "'JetBrains Mono', monospace",
          animation: "marquee 30s linear infinite",
          width: "max-content",
        }}
      >
        {/* First copy */}
        <div className="flex items-center gap-6">{segment}</div>
        {/* Duplicate copy for seamless loop */}
        <div className="flex items-center gap-6">{segment}</div>
      </div>
    </div>
  );
}
