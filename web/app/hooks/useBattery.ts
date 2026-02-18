"use client";

import { useState, useEffect } from "react";

interface BatteryState {
  level: number; // 0~1
  charging: boolean;
  supported: boolean;
}

export function useBattery(): BatteryState {
  const [state, setState] = useState<BatteryState>({
    level: 1,
    charging: false,
    supported: false,
  });

  useEffect(() => {
    if (!("getBattery" in navigator)) return;

    let battery: any = null;

    const update = () => {
      if (!battery) return;
      setState({
        level: battery.level,
        charging: battery.charging,
        supported: true,
      });
    };

    (navigator as any).getBattery().then((b: any) => {
      battery = b;
      update();
      b.addEventListener("levelchange", update);
      b.addEventListener("chargingchange", update);
    });

    return () => {
      if (battery) {
        battery.removeEventListener("levelchange", update);
        battery.removeEventListener("chargingchange", update);
      }
    };
  }, []);

  return state;
}
