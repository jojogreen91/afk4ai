"use client";

import { useState, useRef, useCallback, useEffect } from "react";

const LONG_PRESS_DURATION = 1500; // 1.5 seconds
const PROGRESS_INTERVAL = 16; // ~60fps

export function useLongPress(onComplete: () => void) {
  const [progress, setProgress] = useState(0); // 0 to 1
  const [pressing, setPressing] = useState(false);
  const startTimeRef = useRef<number>(0);
  const intervalRef = useRef<ReturnType<typeof setInterval>>(0 as unknown as ReturnType<typeof setInterval>);
  const completedRef = useRef(false);

  const reset = useCallback(() => {
    setPressing(false);
    setProgress(0);
    clearInterval(intervalRef.current);
    completedRef.current = false;
  }, []);

  const startPress = useCallback(() => {
    completedRef.current = false;
    setPressing(true);
    startTimeRef.current = Date.now();

    intervalRef.current = setInterval(() => {
      const elapsed = Date.now() - startTimeRef.current;
      const p = Math.min(elapsed / LONG_PRESS_DURATION, 1);
      setProgress(p);

      if (p >= 1 && !completedRef.current) {
        completedRef.current = true;
        clearInterval(intervalRef.current);
        onComplete();
      }
    }, PROGRESS_INTERVAL);
  }, [onComplete]);

  const endPress = useCallback(() => {
    if (!completedRef.current) {
      reset();
    }
  }, [reset]);

  useEffect(() => {
    return () => clearInterval(intervalRef.current);
  }, []);

  return {
    progress,
    pressing,
    handlers: {
      onMouseDown: startPress,
      onMouseUp: endPress,
      onMouseLeave: endPress,
      onTouchStart: startPress,
      onTouchEnd: endPress,
      onTouchCancel: endPress,
    },
  };
}
