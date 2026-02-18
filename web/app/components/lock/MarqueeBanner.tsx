"use client";

import { WarningIcon } from "../icons";

export function MarqueeBanner() {
  return (
    <div className="relative overflow-hidden py-2.5 shadow-lg" style={{ backgroundColor: "var(--theme-primary)", boxShadow: `0 4px 14px color-mix(in srgb, var(--theme-primary) 30%, transparent)` }}>
      <div
        className="flex animate-marquee items-center gap-6 whitespace-nowrap"
        style={{ fontFamily: "'JetBrains Mono', monospace" }}
      >
        {[...Array(16)].map((_, i) => (
          <span
            key={i}
            className="flex items-center gap-2 text-sm font-bold tracking-widest md:text-base"
            style={{ color: "var(--theme-banner-text)" }}
          >
            <WarningIcon /> AFK4AI
          </span>
        ))}
      </div>
    </div>
  );
}
