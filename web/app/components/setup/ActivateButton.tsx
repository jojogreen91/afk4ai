"use client";

import { type Lang, t } from "../../i18n";
import { LockIcon } from "../icons";

interface ActivateButtonProps {
  enabled: boolean;
  onClick: () => void;
  lang: Lang;
}

export function ActivateButton({ enabled, onClick, lang }: ActivateButtonProps) {
  return (
    <div className="space-y-3">
      <button
        onClick={onClick}
        disabled={!enabled}
        className="w-full rounded-xl py-4 text-lg font-bold tracking-wider transition disabled:opacity-30 disabled:cursor-not-allowed flex items-center justify-center gap-2"
        style={{
          backgroundColor: enabled ? "var(--theme-primary)" : "rgba(255,255,255,0.1)",
          color: enabled ? "var(--theme-banner-text)" : "rgba(255,255,255,0.7)",
          boxShadow: enabled ? "0 4px 20px color-mix(in srgb, var(--theme-primary) 30%, transparent)" : "none",
        }}
      >
        <LockIcon />
        {t.webapp.setup.activate[lang]}
      </button>
      <p className="text-center text-sm text-white/70">
        {t.webapp.setup.activateDesc[lang]}
      </p>
    </div>
  );
}
