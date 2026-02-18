"use client";

import { useState, useEffect } from "react";
import { type Lang, t } from "../i18n";
import { CatIcon } from "../components/icons";

function getDefaultLang(): Lang {
  if (typeof navigator === "undefined") return "ko";
  const browserLang = navigator.language || "";
  return browserLang.startsWith("ko") ? "ko" : "en";
}

const WEB_APP_URL = "/";
const GITHUB_URL = "https://github.com/jojogreen91/afk4ai";

function LangToggle({ lang, setLang }: { lang: Lang; setLang: (l: Lang) => void }) {
  return (
    <button
      onClick={() => setLang(lang === "ko" ? "en" : "ko")}
      className="rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-text-secondary transition hover:border-text-secondary hover:text-text-primary"
    >
      {lang === "ko" ? "EN" : "한국어"}
    </button>
  );
}

function NavBar({ lang, setLang }: { lang: Lang; setLang: (l: Lang) => void }) {
  return (
    <nav className="fixed top-0 left-0 right-0 z-50 border-b border-border bg-surface/80 backdrop-blur-xl">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-3">
        <div className="flex items-center gap-4">
          <span className="flex items-center gap-2 text-2xl font-extrabold tracking-tight text-ember">
            <CatIcon color="#FF4D00" size={26} />
            AFK4AI
          </span>
          <span className="hidden items-center gap-3 text-xs text-text-secondary md:flex">
            <span className="text-border">|</span>
            <a href={GITHUB_URL} target="_blank" rel="noopener noreferrer" className="flex items-center gap-1 transition hover:text-text-primary">
              <GithubIcon /> GitHub
            </a>
            <a href="mailto:iawbg13@gmail.com" className="flex items-center gap-1 transition hover:text-text-primary">
              <MailIcon /> iawbg13@gmail.com
            </a>
          </span>
        </div>
        <div className="flex items-center gap-4 text-sm text-text-secondary md:gap-6">
          <a href="#features" className="hidden transition hover:text-text-primary md:block">
            {t.nav.features[lang]}
          </a>
          <a href="#how-it-works" className="hidden transition hover:text-text-primary md:block">
            {t.nav.howItWorks[lang]}
          </a>
          <LangToggle lang={lang} setLang={setLang} />
          <a
            href={WEB_APP_URL}
            className="rounded-lg bg-ember px-4 py-2 text-sm font-semibold text-white transition hover:bg-ember-light"
          >
            {t.nav.start[lang]}
          </a>
        </div>
      </div>
    </nav>
  );
}

function HeroSection({ lang }: { lang: Lang }) {
  return (
    <section className="relative flex min-h-screen flex-col items-center justify-center overflow-hidden px-6 pt-24">
      <div className="pointer-events-none absolute top-1/4 left-1/2 h-[500px] w-[500px] -translate-x-1/2 -translate-y-1/2 rounded-full bg-ember/5 blur-[120px]" />

      <div className="relative z-10 mx-auto max-w-3xl text-center">
        <div className="mb-4 inline-flex items-center gap-2 rounded-full border border-border bg-surface-light px-4 py-1.5 text-sm text-text-secondary">
          <span className="inline-block h-1.5 w-1.5 rounded-full bg-status-green animate-pulse-dot" />
          Chrome &middot; Edge &middot; Desktop &middot; {lang === "ko" ? "설치 불필요" : "No Install"}
        </div>

        <h1 className="mb-5 text-5xl leading-tight font-extrabold tracking-tight md:text-7xl md:leading-tight">
          {t.hero.title1[lang]}
          <br />
          <span className="text-ember">{t.hero.title2[lang]}</span>
        </h1>

        <p className="mx-auto mb-8 max-w-xl text-lg leading-relaxed text-text-secondary md:text-xl md:leading-relaxed">
          {t.hero.description[lang]}
          <br className="hidden md:block" />
          {t.hero.descriptionBr[lang]}
        </p>

        <div className="flex flex-col items-center gap-3 sm:flex-row sm:justify-center">
          <a
            href={WEB_APP_URL}
            className="inline-flex items-center gap-2 rounded-xl bg-ember px-8 py-4 text-lg font-bold text-white shadow-lg shadow-ember/20 transition hover:bg-ember-light hover:shadow-xl hover:shadow-ember/30"
          >
            <ArrowRightIcon />
            {t.hero.cta[lang]}
          </a>
          <a
            href="#features"
            className="inline-flex items-center gap-2 rounded-xl border border-border px-8 py-4 text-lg font-medium text-text-secondary transition hover:border-text-secondary hover:text-text-primary"
          >
            {t.hero.learnMore[lang]}
          </a>
        </div>
      </div>

      {/* Mock lock screen */}
      <div className="relative z-10 mx-auto mt-12 w-full max-w-3xl animate-float">
        <div className="overflow-hidden rounded-xl border border-border bg-[#050505] shadow-2xl shadow-black/40">

          {/* Marquee Banner */}
          <div className="relative overflow-hidden bg-ember py-2.5 shadow-lg shadow-ember/30">
            <div className="flex animate-marquee items-center whitespace-nowrap" style={{ fontFamily: "'JetBrains Mono', monospace", gap: "1.5rem" }}>
              {[...Array(20)].map((_, i) => (
                <span key={i} className="flex items-center gap-2 text-sm font-bold tracking-widest text-black md:text-base">
                  <WarningIcon /> AFK4AI
                </span>
              ))}
            </div>
          </div>

          {/* Timer Bar — matches web app (LIVE, time, elapsed, battery) */}
          <div className="border-y border-ember/30 bg-black/60 px-3 py-2.5 md:px-5" style={{ fontFamily: "'JetBrains Mono', monospace" }}>
            <div className="flex items-center justify-center gap-4 text-[10px] md:gap-5 md:text-[11px]">
              {/* Cat left */}
              <CatIcon color="#FF4D00" size={18} />

              {/* LIVE */}
              <div className="flex items-center gap-1.5">
                <span className="inline-block h-1.5 w-1.5 rounded-full bg-green-400 animate-pulse-dot" />
                <span className="text-xs font-bold text-green-400">LIVE</span>
              </div>

              <span className="text-white/20">&middot;</span>

              {/* Current time */}
              <div className="flex items-center gap-1.5">
                <span className="text-white/50">{lang === "ko" ? "현재 시간" : "NOW"}</span>
                <span className="font-bold text-white/90">14:32</span>
              </div>

              <span className="text-white/20">&middot;</span>

              {/* Elapsed */}
              <div className="flex items-center gap-1.5">
                <ClockIcon />
                <span className="text-sm font-bold text-ember md:text-base">01:23:45</span>
                <span className="text-white/50">{lang === "ko" ? "경과" : "elapsed"}</span>
              </div>

              <span className="hidden text-white/20 md:inline">&middot;</span>

              {/* Battery */}
              <div className="hidden items-center gap-1.5 md:flex">
                <BatteryIcon />
                <span className="text-white/70">87%</span>
              </div>

              {/* Cat right */}
              <CatIcon color="#FF4D00" size={18} />
            </div>
          </div>

          {/* Stream Area */}
          <div className="relative mx-4 my-4 overflow-hidden rounded-lg border border-ember/15 bg-[#0A0A0A] md:mx-5 md:my-5">
            {/* Fake captured screen content */}
            <div className="px-5 py-6 md:px-8 md:py-10">
              <div className="space-y-2.5">
                <div className="flex items-center gap-2">
                  <div className="h-1.5 w-1.5 rounded-full bg-ember" />
                  <div className="h-1.5 w-24 rounded bg-white/15" />
                </div>
                <div className="h-1.5 w-full rounded bg-white/8" />
                <div className="h-1.5 w-4/5 rounded bg-white/8" />
                <div className="h-1.5 w-3/5 rounded bg-ember/15" />
                <div className="h-1.5 w-4/5 rounded bg-white/8" />
                <div className="h-1.5 w-2/5 rounded bg-white/8" />
                <div className="mt-4 h-1.5 w-1/3 rounded bg-ember/15" />
                <div className="h-1.5 w-full rounded bg-white/8" />
                <div className="h-1.5 w-3/4 rounded bg-white/8" />
              </div>
            </div>
            {/* Scanline overlay */}
            <div className="pointer-events-none absolute inset-0" style={{
              backgroundImage: "repeating-linear-gradient(0deg, transparent, transparent 3px, rgba(0,0,0,0.25) 3px, rgba(0,0,0,0.25) 4px)",
              opacity: 0.08
            }} />
            {/* LIVE badge */}
            <div className="absolute bottom-3 right-3 flex items-center gap-1.5 rounded-full border border-white/10 bg-black/60 px-2.5 py-1">
              <span className="inline-block h-1.5 w-1.5 rounded-full bg-red-500 animate-pulse-dot" />
              <span className="text-[9px] font-bold text-red-400" style={{ fontFamily: "'JetBrains Mono', monospace" }}>LIVE</span>
            </div>
          </div>

          {/* Unlock Area — long-press style */}
          <div className="flex flex-col items-center gap-2 px-6 pb-6 pt-2">
            <div className="relative inline-flex items-center gap-2 rounded-full border border-white/15 bg-white/8 px-7 py-3">
              {/* Progress ring indicator */}
              <svg width="18" height="18" viewBox="0 0 20 20" className="text-white/50">
                <circle cx="10" cy="10" r="8" fill="none" stroke="currentColor" strokeWidth="2" opacity="0.2" />
                <circle cx="10" cy="10" r="8" fill="none" stroke="#FF4D00" strokeWidth="2" strokeDasharray="50.3" strokeDashoffset="25" strokeLinecap="round" transform="rotate(-90 10 10)" />
              </svg>
              <span className="text-sm font-bold text-white/70" style={{ fontFamily: "'JetBrains Mono', monospace" }}>
                {lang === "ko" ? "잠금 해제" : "Unlock"}
              </span>
            </div>
            <span className="text-[10px] text-white/20" style={{ fontFamily: "'JetBrains Mono', monospace" }}>
              {lang === "ko" ? "2초간 길게 누르기" : "Hold for 2 seconds"}
            </span>
          </div>
        </div>
      </div>

      <div className="mt-10 mb-6 flex flex-col items-center gap-1.5 text-text-secondary">
        <span className="text-[11px]">{t.hero.scroll[lang]}</span>
        <svg width="14" height="20" viewBox="0 0 16 24" fill="none" className="animate-bounce">
          <path d="M8 4v16m0 0l-4-4m4 4l4-4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </div>
    </section>
  );
}

function FeaturesSection({ lang }: { lang: Lang }) {
  const icons = [<WindowIcon key={0} />, <ShieldIcon key={1} />, <HoldIcon key={2} />, <ChartIcon key={3} />, <PaletteIcon key={4} />, <GlobeIcon key={5} />];

  return (
    <section id="features" className="px-6 py-20 md:py-24">
      <div className="mx-auto max-w-5xl">
        <div className="mb-12 text-center">
          <h2 className="mb-3 text-4xl font-bold tracking-tight md:text-5xl">
            {t.features.title[lang]} <span className="text-ember">AFK4AI</span>{t.features.titleEnd[lang]}
          </h2>
          <p className="mx-auto max-w-lg text-lg text-text-secondary">
            {t.features.subtitle1[lang]}
            <br />
            {t.features.subtitle2[lang]}
          </p>
        </div>

        <div className="grid gap-5 md:grid-cols-2 lg:grid-cols-3">
          {t.features.items.map((feature, i) => (
            <div
              key={i}
              className="group rounded-xl border border-border bg-surface-light p-6 transition hover:border-ember/30 hover:bg-surface-lighter"
            >
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-ember/10 text-ember transition group-hover:bg-ember/20">
                {icons[i]}
              </div>
              <h3 className="mb-2 text-xl font-bold">{feature.title[lang]}</h3>
              <p className="text-base leading-relaxed text-text-secondary">
                {feature.description[lang]}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function HowItWorksSection({ lang }: { lang: Lang }) {
  return (
    <section id="how-it-works" className="px-6 py-20 md:py-24">
      <div className="mx-auto max-w-3xl">
        <div className="mb-12 text-center">
          <h2 className="text-4xl font-bold tracking-tight md:text-5xl">
            {t.howItWorks.title1[lang]} <span className="text-ember">{t.howItWorks.title2[lang]}</span>
          </h2>
        </div>

        <div className="space-y-10">
          {t.howItWorks.steps.map((step, i) => (
            <div key={i} className="flex items-start gap-6">
              <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-xl border border-ember/30 bg-surface-light text-xl font-bold text-ember">
                {String(i + 1).padStart(2, "0")}
              </div>
              <div className="pt-1">
                <h3 className="mb-1.5 text-2xl font-bold">{step.title[lang]}</h3>
                <p className="text-lg leading-relaxed text-text-secondary">
                  {step.description[lang]}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function CtaSection({ lang }: { lang: Lang }) {
  return (
    <section className="px-6 py-20 md:py-24">
      <div className="shimmer mx-auto max-w-3xl rounded-2xl border border-border px-8 py-14 text-center md:px-16">
        <h2 className="mb-3 text-4xl font-bold tracking-tight md:text-5xl">
          {t.cta.title[lang]}
        </h2>
        <p className="mx-auto mb-8 max-w-md text-lg text-text-secondary">
          {t.cta.subtitle[lang]}
        </p>
        <a
          href={WEB_APP_URL}
          className="inline-flex items-center gap-2.5 rounded-xl bg-ember px-9 py-4.5 text-xl font-bold text-white shadow-lg shadow-ember/20 transition hover:bg-ember-light hover:shadow-xl hover:shadow-ember/30"
        >
          <ArrowRightIcon />
          {t.cta.button[lang]}
        </a>
        <p className="mt-5 text-xs text-text-secondary">
          {t.cta.footnote[lang]}
        </p>
      </div>
    </section>
  );
}

function Footer() {
  return (
    <footer className="border-t border-border px-6 py-8">
      <div className="mx-auto flex max-w-6xl flex-col items-center gap-3 text-sm text-text-secondary">
        <span className="flex items-center gap-2 text-lg font-bold text-ember">
          <CatIcon color="#FF4D00" size={22} />
          AFK4AI
        </span>
        <div className="flex items-center gap-5 text-sm">
          <a
            href={GITHUB_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-1.5 transition hover:text-text-primary"
          >
            <GithubIcon />
            GitHub
          </a>
          <a
            href="mailto:iawbg13@gmail.com"
            className="flex items-center gap-1.5 transition hover:text-text-primary"
          >
            <MailIcon />
            iawbg13@gmail.com
          </a>
        </div>
        <span className="text-xs text-text-secondary/50">Made by JoJo Green</span>
      </div>
    </footer>
  );
}

// --- Icons ---

function ArrowRightIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 20 20" fill="none">
      <path d="M4 10h12m0 0l-4-4m4 4l-4 4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

function WarningIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
      <path d="M12 2L1 21h22L12 2zm0 4l7.53 13H4.47L12 6zm-1 5v4h2v-4h-2zm0 6v2h2v-2h-2z"/>
    </svg>
  );
}

function ClockIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" className="text-ember">
      <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="1.5"/>
      <path d="M12 6v6l4 2" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
    </svg>
  );
}

function BatteryIcon() {
  return (
    <svg width="18" height="10" viewBox="0 0 20 12" fill="none">
      <rect x="0.5" y="0.5" width="16" height="11" rx="2" stroke="currentColor" strokeWidth="1" className="text-white/40" />
      <rect x="17" y="3" width="2.5" height="6" rx="1" fill="currentColor" className="text-white/40" />
      <rect x="2" y="2" width="11" height="8" rx="1" fill="#FF4D00" />
    </svg>
  );
}

function WindowIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <rect x="2" y="3" width="20" height="18" rx="2" stroke="currentColor" strokeWidth="1.5"/>
      <path d="M2 8h20" stroke="currentColor" strokeWidth="1.5"/>
      <circle cx="5.5" cy="5.5" r="0.75" fill="currentColor"/>
      <circle cx="8" cy="5.5" r="0.75" fill="currentColor"/>
      <circle cx="10.5" cy="5.5" r="0.75" fill="currentColor"/>
    </svg>
  );
}

function ShieldIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M12 2l8 4v6c0 5.25-3.5 9.74-8 11-4.5-1.26-8-5.75-8-11V6l8-4z" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round"/>
      <path d="M9 12l2 2 4-4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

function HoldIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="1.5"/>
      <circle cx="12" cy="12" r="6" stroke="currentColor" strokeWidth="1.5" strokeDasharray="37.7" strokeDashoffset="9.4" strokeLinecap="round" transform="rotate(-90 12 12)"/>
      <circle cx="12" cy="12" r="2.5" fill="currentColor"/>
    </svg>
  );
}

function ChartIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <rect x="3" y="12" width="4" height="9" rx="1" stroke="currentColor" strokeWidth="1.5"/>
      <rect x="10" y="7" width="4" height="14" rx="1" stroke="currentColor" strokeWidth="1.5"/>
      <rect x="17" y="3" width="4" height="18" rx="1" stroke="currentColor" strokeWidth="1.5"/>
    </svg>
  );
}

function PaletteIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="1.5"/>
      <circle cx="12" cy="8" r="1.5" fill="currentColor"/>
      <circle cx="8.5" cy="11" r="1.5" fill="currentColor"/>
      <circle cx="9.5" cy="15" r="1.5" fill="currentColor"/>
      <circle cx="15.5" cy="11" r="1.5" fill="currentColor"/>
    </svg>
  );
}

function GlobeIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="10" />
      <path d="M2 12h20M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z" />
    </svg>
  );
}

function MailIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <rect x="2" y="4" width="20" height="16" rx="2" />
      <path d="M22 7l-10 7L2 7" />
    </svg>
  );
}

function GithubIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 16 16" fill="currentColor">
      <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0016 8c0-4.42-3.58-8-8-8z"/>
    </svg>
  );
}

// --- Main Page ---

export default function Home() {
  const [lang, setLang] = useState<Lang>("ko");

  useEffect(() => {
    setLang(getDefaultLang());
  }, []);

  return (
    <main>
      <NavBar lang={lang} setLang={setLang} />
      <HeroSection lang={lang} />
      <FeaturesSection lang={lang} />
      <HowItWorksSection lang={lang} />
      <CtaSection lang={lang} />
      <Footer />
    </main>
  );
}
