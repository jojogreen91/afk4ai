"use client";

import { useState, useCallback, useRef, useEffect } from "react";

export function useScreenCapture() {
  const [stream, setStream] = useState<MediaStream | null>(null);
  const [thumbnail, setThumbnail] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const videoRef = useRef<HTMLVideoElement | null>(null);

  const requestCapture = useCallback(async () => {
    try {
      setError(null);
      const mediaStream = await navigator.mediaDevices.getDisplayMedia({
        video: { displaySurface: "monitor" } as MediaTrackConstraints,
        audio: false,
      });

      setStream(mediaStream);

      // Generate thumbnail after stream starts
      const video = document.createElement("video");
      videoRef.current = video;
      video.srcObject = mediaStream;
      video.muted = true;
      await video.play();

      // Wait a frame for video to render
      await new Promise((r) => setTimeout(r, 200));
      const canvas = document.createElement("canvas");
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
      const ctx = canvas.getContext("2d");
      if (ctx) {
        ctx.drawImage(video, 0, 0);
        setThumbnail(canvas.toDataURL("image/png"));
      }

      // Listen for stream end (user stops sharing)
      mediaStream.getTracks().forEach((track) => {
        track.addEventListener("ended", () => {
          setStream(null);
          setThumbnail(null);
        });
      });
    } catch (err) {
      if (err instanceof DOMException && err.name === "NotAllowedError") {
        setError("Permission denied");
      } else {
        setError("Failed to capture screen");
      }
      setStream(null);
      setThumbnail(null);
    }
  }, []);

  const stopCapture = useCallback(() => {
    if (stream) {
      stream.getTracks().forEach((track) => track.stop());
      setStream(null);
      setThumbnail(null);
    }
  }, [stream]);

  useEffect(() => {
    return () => {
      stream?.getTracks().forEach((track) => track.stop());
    };
  }, [stream]);

  return { stream, thumbnail, error, requestCapture, stopCapture };
}
