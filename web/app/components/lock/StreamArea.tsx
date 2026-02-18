"use client";

import { useEffect, useRef } from "react";
import { type Lang } from "../../i18n";
import { ScanlineOverlay } from "./ScanlineOverlay";
import { LiveBadge } from "./LiveBadge";

interface StreamAreaProps {
  stream: MediaStream;
  lang: Lang;
}

export function StreamArea({ stream, lang }: StreamAreaProps) {
  const videoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    if (videoRef.current && stream) {
      videoRef.current.srcObject = stream;
    }
  }, [stream]);

  return (
    <div
      className="relative mx-4 my-4 overflow-hidden rounded-lg border bg-[#0A0A0A] md:mx-5 md:my-5"
      style={{ borderColor: "color-mix(in srgb, var(--theme-primary) 15%, transparent)" }}
    >
      <video
        ref={videoRef}
        autoPlay
        muted
        playsInline
        className="w-full"
        style={{ maxHeight: "calc(100vh - 280px)" }}
      />
      <ScanlineOverlay />
      <LiveBadge lang={lang} />
    </div>
  );
}
