"use client";

import { type Lang, t } from "../../i18n";
import { ScreenIcon } from "../icons";

interface SourceSelectorProps {
  thumbnail: string | null;
  hasStream: boolean;
  onSelect: () => void;
  lang: Lang;
}

export function SourceSelector({
  thumbnail,
  hasStream,
  onSelect,
  lang,
}: SourceSelectorProps) {
  return (
    <div className="space-y-3">
      <h3 className="text-sm font-bold text-white uppercase tracking-wider">
        {t.webapp.setup.selectScreen[lang]}
      </h3>
      <p className="text-sm text-white/80">
        {t.webapp.setup.selectScreenDesc[lang]}
      </p>
      <button
        onClick={onSelect}
        className="group w-full overflow-hidden rounded-xl border border-white/15 bg-white/5 transition hover:border-[var(--theme-primary)]/50 hover:bg-white/10"
      >
        {thumbnail ? (
          <div className="relative">
            <img
              src={thumbnail}
              alt="Screen preview"
              className="w-full rounded-xl"
            />
            <div className="absolute inset-0 flex items-center justify-center rounded-xl bg-black/40 opacity-0 transition group-hover:opacity-100">
              <span className="rounded-lg px-4 py-2 text-sm font-medium text-white" style={{ backgroundColor: "var(--theme-primary)" }}>
                {t.webapp.setup.clickToSelect[lang]}
              </span>
            </div>
          </div>
        ) : (
          <div className="flex flex-col items-center gap-3 py-12">
            <div className="rounded-xl bg-white/10 p-4 text-white/80 transition group-hover:text-[var(--theme-primary)]">
              <ScreenIcon />
            </div>
            <span className="text-sm font-medium text-white/80 transition group-hover:text-white">
              {t.webapp.setup.clickToSelect[lang]}
            </span>
          </div>
        )}
      </button>
      {hasStream && (
        <p className="text-xs text-[var(--theme-status)] flex items-center gap-1.5">
          <span className="inline-block h-1.5 w-1.5 rounded-full bg-[var(--theme-status)] animate-pulse-dot" />
          {t.webapp.setup.screenSelected[lang]}
        </p>
      )}
    </div>
  );
}
