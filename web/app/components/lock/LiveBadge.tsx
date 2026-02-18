"use client";

import { type Lang, t } from "../../i18n";

interface LiveBadgeProps {
  lang: Lang;
}

export function LiveBadge({ lang }: LiveBadgeProps) {
  return (
    <div className="absolute bottom-3 right-3 flex items-center gap-1.5 rounded-full border border-white/10 bg-black/60 px-2.5 py-1">
      <span className="inline-block h-1.5 w-1.5 rounded-full bg-red-500 animate-pulse-dot" />
      <span
        className="text-[9px] font-bold text-red-400"
        style={{ fontFamily: "'JetBrains Mono', monospace" }}
      >
        {t.webapp.lock.live[lang]}
      </span>
    </div>
  );
}
