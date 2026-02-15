"use client";

import { useState, useEffect } from "react";
import { type Lang, t } from "./i18n";

function getDefaultLang(): Lang {
  if (typeof navigator === "undefined") return "ko";
  const browserLang = navigator.language || "";
  return browserLang.startsWith("ko") ? "ko" : "en";
}

const GITHUB_RELEASE_URL =
  "https://github.com/jojogreen91/afk4ai/releases/latest";

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
      <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
        <span className="text-2xl font-extrabold tracking-tight text-ember">AFK4AI</span>
        <div className="flex items-center gap-6 text-sm text-text-secondary md:gap-8">
          <a href="#features" className="hidden transition hover:text-text-primary md:block">
            {t.nav.features[lang]}
          </a>
          <a href="#how-it-works" className="hidden transition hover:text-text-primary md:block">
            {t.nav.howItWorks[lang]}
          </a>
          <LangToggle lang={lang} setLang={setLang} />
          <a
            href={GITHUB_RELEASE_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="rounded-lg bg-ember px-4 py-2 text-sm font-semibold text-white transition hover:bg-ember-light"
          >
            {t.nav.download[lang]}
          </a>
        </div>
      </div>
    </nav>
  );
}

function HeroSection({ lang }: { lang: Lang }) {
  return (
    <section className="relative flex min-h-screen flex-col items-center justify-center overflow-hidden px-6 pt-20">
      <div className="pointer-events-none absolute top-1/4 left-1/2 h-[600px] w-[600px] -translate-x-1/2 -translate-y-1/2 rounded-full bg-ember/5 blur-[150px]" />

      <div className="relative z-10 mx-auto max-w-4xl text-center">
        <div className="mb-8 inline-flex items-center gap-2 rounded-full border border-border bg-surface-light px-4 py-2 text-sm text-text-secondary">
          <span className="inline-block h-2 w-2 rounded-full bg-status-green animate-pulse-dot" />
          macOS 14.0+ &middot; Apple Silicon &amp; Intel
        </div>

        <h1 className="mb-6 text-5xl leading-tight font-extrabold tracking-tight md:text-7xl md:leading-tight">
          {t.hero.title1[lang]}
          <br />
          <span className="text-ember">{t.hero.title2[lang]}</span>
        </h1>

        <p className="mx-auto mb-10 max-w-2xl text-lg leading-relaxed text-text-secondary md:text-xl md:leading-relaxed">
          {t.hero.description[lang]}
          <br className="hidden md:block" />
          {t.hero.descriptionBr[lang]}
        </p>

        <div className="flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
          <a
            href={GITHUB_RELEASE_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 rounded-xl bg-ember px-8 py-4 text-lg font-bold text-white shadow-lg shadow-ember/20 transition hover:bg-ember-light hover:shadow-xl hover:shadow-ember/30"
          >
            <DownloadIcon />
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
      <div className="relative z-10 mx-auto mt-16 w-full max-w-4xl animate-float">
        <div className="overflow-hidden rounded-2xl border border-border bg-surface-light shadow-2xl shadow-black/50">
          <div className="flex items-center justify-between border-b border-border px-5 py-3">
            <div className="flex items-center gap-2">
              <div className="h-3 w-3 rounded-full bg-red-500/60" />
              <div className="h-3 w-3 rounded-full bg-yellow-500/60" />
              <div className="h-3 w-3 rounded-full bg-green-500/60" />
            </div>
            <span className="text-xs text-text-secondary" style={{ fontFamily: "'JetBrains Mono', monospace" }}>
              AFK4AI
            </span>
            <div className="w-12" />
          </div>

          <div className="relative flex flex-col items-center justify-center py-20 px-8">
            <div className="absolute top-0 left-0 right-0 h-2" style={{
              background: "repeating-linear-gradient(135deg, #FF4D00 0px, #FF4D00 10px, transparent 10px, transparent 20px)"
            }} />

            <div className="mb-6 flex items-center gap-3">
              <LockIcon />
              <span className="text-2xl font-bold tracking-wide md:text-3xl">LOCKED</span>
            </div>

            <div className="mb-8 flex items-center gap-2 text-sm text-text-secondary" style={{ fontFamily: "'JetBrains Mono', monospace" }}>
              <span className="inline-block h-2 w-2 rounded-full bg-status-green animate-pulse-dot" />
              <span className="text-status-green">LIVE</span>
              <span className="mx-2 text-border">|</span>
              <span>01:23:45</span>
            </div>

            <div className="w-full max-w-lg rounded-lg border border-border bg-surface p-4">
              <div className="mb-3 flex items-center gap-2">
                <div className="h-2 w-2 rounded-full bg-ember" />
                <div className="h-2 w-24 rounded bg-border" />
              </div>
              <div className="space-y-2">
                <div className="h-2 w-full rounded bg-border" />
                <div className="h-2 w-4/5 rounded bg-border" />
                <div className="h-2 w-3/5 rounded bg-ember/20" />
                <div className="h-2 w-4/5 rounded bg-border" />
                <div className="h-2 w-2/5 rounded bg-border" />
              </div>
            </div>

            <div className="mt-8 flex flex-wrap items-center justify-center gap-6 text-xs text-text-secondary" style={{ fontFamily: "'JetBrains Mono', monospace" }}>
              <span>CPU <span className="text-ember font-semibold">34%</span></span>
              <span>GPU <span className="text-ember font-semibold">62%</span></span>
              <span>MEM <span className="text-ember font-semibold">12.4/16 GB</span></span>
              <span>&uarr; <span className="text-ember font-semibold">1.2 MB/s</span> &darr; <span className="text-ember font-semibold">4.8 MB/s</span></span>
            </div>

            <div className="absolute bottom-0 left-0 right-0 h-2" style={{
              background: "repeating-linear-gradient(135deg, #FF4D00 0px, #FF4D00 10px, transparent 10px, transparent 20px)"
            }} />
          </div>
        </div>
      </div>

      <div className="mt-12 mb-8 flex flex-col items-center gap-2 text-text-secondary">
        <span className="text-xs">{t.hero.scroll[lang]}</span>
        <svg width="16" height="24" viewBox="0 0 16 24" fill="none" className="animate-bounce">
          <path d="M8 4v16m0 0l-4-4m4 4l4-4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </div>
    </section>
  );
}

function FeaturesSection({ lang }: { lang: Lang }) {
  const icons = [<WindowIcon key={0} />, <ShieldIcon key={1} />, <FingerprintIcon key={2} />, <ChartIcon key={3} />, <PaletteIcon key={4} />, <MenuBarIcon key={5} />];

  return (
    <section id="features" className="px-6 py-32">
      <div className="mx-auto max-w-6xl">
        <div className="mb-16 text-center">
          <h2 className="mb-4 text-4xl font-bold tracking-tight md:text-5xl">
            {t.features.title[lang]} <span className="text-ember">AFK4AI</span>{t.features.titleEnd[lang]}
          </h2>
          <p className="mx-auto max-w-xl text-lg text-text-secondary">
            {t.features.subtitle[lang]}
          </p>
        </div>

        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {t.features.items.map((feature, i) => (
            <div
              key={i}
              className="group rounded-2xl border border-border bg-surface-light p-8 transition hover:border-ember/30 hover:bg-surface-lighter"
            >
              <div className="mb-5 flex h-12 w-12 items-center justify-center rounded-xl bg-ember/10 text-ember transition group-hover:bg-ember/20">
                {icons[i]}
              </div>
              <h3 className="mb-3 text-xl font-bold">{feature.title[lang]}</h3>
              <p className="leading-relaxed text-text-secondary">
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
    <section id="how-it-works" className="px-6 py-32">
      <div className="mx-auto max-w-4xl">
        <div className="mb-16 text-center">
          <h2 className="mb-4 text-4xl font-bold tracking-tight md:text-5xl">
            {t.howItWorks.title1[lang]} <span className="text-ember">{t.howItWorks.title2[lang]}</span>
          </h2>
        </div>

        <div>
          <div className="space-y-16">
            {t.howItWorks.steps.map((step, i) => (
              <div key={i} className="relative flex items-start gap-8">
                <div className="relative z-10 flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl border border-ember/30 bg-surface-light text-2xl font-bold text-ember">
                  {String(i + 1).padStart(2, "0")}
                </div>

                <div className="pt-3">
                  <h3 className="mb-2 text-2xl font-bold">{step.title[lang]}</h3>
                  <p className="text-lg leading-relaxed text-text-secondary">
                    {step.description[lang]}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

function AuthorBanner({ lang }: { lang: Lang }) {
  return (
    <section className="px-6 py-16">
      <div className="mx-auto flex max-w-4xl flex-col items-center justify-center gap-4 rounded-2xl border border-border bg-surface-light px-8 py-8 sm:flex-row sm:gap-8">
        <div className="text-center sm:text-left">
          <p className="mb-1 text-xs text-text-secondary uppercase tracking-widest">
            {t.nav.madeBy[lang]}
          </p>
          <p className="text-xl font-bold">JoJo Green</p>
        </div>
        <div className="h-px w-16 bg-border sm:h-10 sm:w-px" />
        <div className="flex flex-wrap items-center justify-center gap-4 text-sm text-text-secondary">
          <a
            href="https://github.com/jojogreen91"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-2 transition hover:text-text-primary"
          >
            <GithubIcon />
            jojogreen91
          </a>
          <a
            href="mailto:iawbg13@gmail.com"
            className="flex items-center gap-2 transition hover:text-text-primary"
          >
            <MailIcon />
            iawbg13@gmail.com
          </a>
        </div>
        <div className="h-px w-16 bg-border sm:h-10 sm:w-px" />
        <a
          href="https://github.com/jojogreen91/afk4ai"
          target="_blank"
          rel="noopener noreferrer"
          className="flex items-center gap-2 rounded-lg border border-ember/30 px-4 py-2 text-sm font-medium text-ember transition hover:bg-ember/10"
        >
          <GithubIcon />
          {t.nav.openSource[lang]}
        </a>
      </div>
    </section>
  );
}

function CtaSection({ lang }: { lang: Lang }) {
  return (
    <section className="px-6 py-32">
      <div className="shimmer mx-auto max-w-4xl rounded-3xl border border-border p-16 text-center">
        <h2 className="mb-4 text-4xl font-bold tracking-tight md:text-5xl">
          {t.cta.title[lang]}
        </h2>
        <p className="mx-auto mb-10 max-w-xl text-lg text-text-secondary">
          {t.cta.subtitle[lang]}
        </p>
        <a
          href={GITHUB_RELEASE_URL}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center gap-3 rounded-xl bg-ember px-10 py-5 text-xl font-bold text-white shadow-lg shadow-ember/20 transition hover:bg-ember-light hover:shadow-xl hover:shadow-ember/30"
        >
          <DownloadIcon />
          {t.cta.button[lang]}
        </a>
        <p className="mt-6 text-sm text-text-secondary">
          {t.cta.footnote[lang]}
        </p>
      </div>
    </section>
  );
}

function Footer() {
  return (
    <footer className="border-t border-border px-6 py-10">
      <div className="mx-auto flex max-w-6xl flex-col items-center gap-4 text-sm text-text-secondary">
        <span className="text-ember font-bold">AFK4AI</span>
        <div className="flex items-center gap-6">
          <a
            href="https://github.com/jojogreen91"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-2 transition hover:text-text-primary"
          >
            <GithubIcon />
            jojogreen91
          </a>
          <a
            href="mailto:iawbg13@gmail.com"
            className="flex items-center gap-2 transition hover:text-text-primary"
          >
            <MailIcon />
            iawbg13@gmail.com
          </a>
        </div>
        <span className="text-xs text-text-secondary/60">Made by JoJo Green</span>
      </div>
    </footer>
  );
}

// --- Icons ---

function DownloadIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
      <path d="M10 3v10m0 0l-3.5-3.5M10 13l3.5-3.5M3 15v1a2 2 0 002 2h10a2 2 0 002-2v-1" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

function LockIcon() {
  return (
    <svg width="32" height="32" viewBox="0 0 24 24" fill="none" className="text-ember">
      <rect x="3" y="11" width="18" height="11" rx="2" stroke="currentColor" strokeWidth="1.5"/>
      <path d="M7 11V7a5 5 0 0110 0v4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
      <circle cx="12" cy="16" r="1.5" fill="currentColor"/>
    </svg>
  );
}

function WindowIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
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
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
      <path d="M12 2l8 4v6c0 5.25-3.5 9.74-8 11-4.5-1.26-8-5.75-8-11V6l8-4z" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round"/>
      <path d="M9 12l2 2 4-4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

function FingerprintIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
      <path d="M12 10a2 2 0 012 2c0 1.02-.1 2.01-.3 2.96" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
      <path d="M6.72 16A10.97 10.97 0 016 12a6 6 0 0112 0c0 .83-.05 1.64-.15 2.43" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
      <path d="M17.64 7.96A7.97 7.97 0 0020 12c0 .85-.06 1.68-.18 2.49" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
      <path d="M4 12a8 8 0 0116 0" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
      <path d="M12 12v4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
    </svg>
  );
}

function ChartIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
      <rect x="3" y="12" width="4" height="9" rx="1" stroke="currentColor" strokeWidth="1.5"/>
      <rect x="10" y="7" width="4" height="14" rx="1" stroke="currentColor" strokeWidth="1.5"/>
      <rect x="17" y="3" width="4" height="18" rx="1" stroke="currentColor" strokeWidth="1.5"/>
    </svg>
  );
}

function PaletteIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="1.5"/>
      <circle cx="12" cy="8" r="1.5" fill="currentColor"/>
      <circle cx="8.5" cy="11" r="1.5" fill="currentColor"/>
      <circle cx="9.5" cy="15" r="1.5" fill="currentColor"/>
      <circle cx="15.5" cy="11" r="1.5" fill="currentColor"/>
    </svg>
  );
}

function MenuBarIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
      <rect x="2" y="3" width="20" height="5" rx="1.5" stroke="currentColor" strokeWidth="1.5"/>
      <circle cx="18" cy="5.5" r="1" fill="currentColor"/>
      <circle cx="15" cy="5.5" r="1" fill="currentColor"/>
      <rect x="2" y="11" width="20" height="10" rx="1.5" stroke="currentColor" strokeWidth="1.5"/>
    </svg>
  );
}

function MailIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <rect x="2" y="4" width="20" height="16" rx="2" />
      <path d="M22 7l-10 7L2 7" />
    </svg>
  );
}

function GithubIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
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
      <AuthorBanner lang={lang} />
      <FeaturesSection lang={lang} />
      <HowItWorksSection lang={lang} />
      <CtaSection lang={lang} />
      <Footer />
    </main>
  );
}
