"use client";

import { useEffect, useRef } from "react";
import { type Lang } from "../../i18n";
import { ScanlineOverlay } from "./ScanlineOverlay";

interface StreamAreaProps {
  stream: MediaStream;
}

export function StreamArea({ stream }: StreamAreaProps) {
  const videoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    if (videoRef.current && stream) {
      videoRef.current.srcObject = stream;
    }
  }, [stream]);

  return (
    <div
      className="relative mx-5 overflow-hidden rounded-2xl bg-[#0A0A0A] md:mx-8"
    >
      <video
        ref={videoRef}
        autoPlay
        muted
        playsInline
        className="w-full"
        style={{ maxHeight: "calc(100vh - 340px)" }}
      />
      <ScanlineOverlay />
    </div>
  );
}
