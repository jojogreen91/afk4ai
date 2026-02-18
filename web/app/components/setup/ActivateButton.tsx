"use client";

import { useState } from "react";
import { type Lang, t } from "../../i18n";
import { LockIcon, CatIcon } from "../icons";

interface ActivateButtonProps {
  enabled: boolean;
  onClick: () => void;
  lang: Lang;
}

export function ActivateButton({ enabled, onClick, lang }: ActivateButtonProps) {
  const [hovered, setHovered] = useState(false);

  return (
    <div className="space-y-3">
      <button
        onClick={onClick}
        disabled={!enabled}
        onMouseEnter={() => setHovered(true)}
        onMouseLeave={() => setHovered(false)}
        className="w-full rounded-2xl py-4 text-lg font-bold tracking-wider transition-all duration-200 disabled:opacity-30 disabled:cursor-not-allowed flex items-center justify-center gap-2 hover:scale-[1.02]"
        style={{
          backgroundColor: enabled ? "var(--theme-primary)" : "rgba(255,255,255,0.1)",
          color: enabled ? "var(--theme-banner-text)" : "rgba(255,255,255,0.7)",
          boxShadow: enabled && hovered
            ? "0 8px 32px color-mix(in srgb, var(--theme-primary) 40%, transparent)"
            : enabled
              ? "0 4px 20px color-mix(in srgb, var(--theme-primary) 30%, transparent)"
              : "none",
        }}
      >
        <LockIcon />
        {t.webapp.setup.activate[lang]}
        {enabled && (
          <span className={hovered ? "animate-wiggle" : ""}>
            <CatIcon color="var(--theme-banner-text)" size={20} />
          </span>
        )}
      </button>
      <p className="text-center text-sm text-white/70">
        {t.webapp.setup.activateDesc[lang]}
      </p>
    </div>
  );
}
