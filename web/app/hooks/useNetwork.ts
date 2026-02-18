"use client";

import { useState, useEffect } from "react";

interface NetworkState {
  online: boolean;
  type: string; // "wifi", "cellular", "ethernet", "unknown"
  downlink: number | null; // Mbps
}

export function useNetwork(): NetworkState {
  const [state, setState] = useState<NetworkState>({
    online: true,
    type: "unknown",
    downlink: null,
  });

  useEffect(() => {
    const update = () => {
      const conn = (navigator as any).connection;
      setState({
        online: navigator.onLine,
        type: conn?.effectiveType ?? conn?.type ?? "unknown",
        downlink: conn?.downlink ?? null,
      });
    };

    update();

    window.addEventListener("online", update);
    window.addEventListener("offline", update);

    const conn = (navigator as any).connection;
    if (conn) {
      conn.addEventListener("change", update);
    }

    return () => {
      window.removeEventListener("online", update);
      window.removeEventListener("offline", update);
      if (conn) {
        conn.removeEventListener("change", update);
      }
    };
  }, []);

  return state;
}
