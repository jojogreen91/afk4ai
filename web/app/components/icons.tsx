export function WarningIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
      <path d="M12 2L1 21h22L12 2zm0 4l7.53 13H4.47L12 6zm-1 5v4h2v-4h-2zm0 6v2h2v-2h-2z" />
    </svg>
  );
}

export function ClockIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" className="text-[var(--theme-primary)]">
      <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="1.5" />
      <path d="M12 6v6l4 2" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

export function WindowIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <rect x="2" y="3" width="20" height="18" rx="2" stroke="currentColor" strokeWidth="1.5" />
      <path d="M2 8h20" stroke="currentColor" strokeWidth="1.5" />
      <circle cx="5.5" cy="5.5" r="0.75" fill="currentColor" />
      <circle cx="8" cy="5.5" r="0.75" fill="currentColor" />
      <circle cx="10.5" cy="5.5" r="0.75" fill="currentColor" />
    </svg>
  );
}

export function ShieldIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M12 2l8 4v6c0 5.25-3.5 9.74-8 11-4.5-1.26-8-5.75-8-11V6l8-4z" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round" />
      <path d="M9 12l2 2 4-4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export function PaletteIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="1.5" />
      <circle cx="12" cy="8" r="1.5" fill="currentColor" />
      <circle cx="8.5" cy="11" r="1.5" fill="currentColor" />
      <circle cx="9.5" cy="15" r="1.5" fill="currentColor" />
      <circle cx="15.5" cy="11" r="1.5" fill="currentColor" />
    </svg>
  );
}

export function ScreenIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <rect x="2" y="3" width="20" height="14" rx="2" stroke="currentColor" strokeWidth="1.5" />
      <path d="M8 21h8M12 17v4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

export function LockIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
      <rect x="3" y="11" width="18" height="11" rx="2" stroke="currentColor" strokeWidth="1.5" />
      <path d="M7 11V7a5 5 0 0110 0v4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

export function UnlockIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
      <rect x="3" y="11" width="18" height="11" rx="2" stroke="currentColor" strokeWidth="1.5" />
      <path d="M7 11V7a5 5 0 019.9-1" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

export function GlobeIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="10" />
      <path d="M2 12h20M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z" />
    </svg>
  );
}

export function GithubIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 16 16" fill="currentColor">
      <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0016 8c0-4.42-3.58-8-8-8z" />
    </svg>
  );
}

export function MailIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
      <rect x="2" y="4" width="20" height="16" rx="2" />
      <path d="M22 7l-10 7L2 7" />
    </svg>
  );
}

// Shared pixel data for CatIcon — reused by pattern generator
const CAT_PIXELS: [number, number][] = [
  // left ear (tall triangle)
  [2,0],
  [2,1],[3,1],
  [2,2],[3,2],[4,2],
  // right ear (tall triangle)
  [13,0],
  [12,1],[13,1],
  [11,2],[12,2],[13,2],
  // head top
  [5,2],[6,2],[7,2],[8,2],[9,2],[10,2],
  // head body
  [2,3],[3,3],[4,3],[5,3],[6,3],[7,3],[8,3],[9,3],[10,3],[11,3],[12,3],[13,3],
  [2,4],[3,4],[4,4],[5,4],[6,4],[7,4],[8,4],[9,4],[10,4],[11,4],[12,4],[13,4],
  [2,5],[3,5],[4,5],[5,5],[6,5],[7,5],[8,5],[9,5],[10,5],[11,5],[12,5],[13,5],
  [2,6],[3,6],[4,6],[5,6],[6,6],[7,6],[8,6],[9,6],[10,6],[11,6],[12,6],[13,6],
  [2,7],[3,7],[4,7],[5,7],[6,7],[7,7],[8,7],[9,7],[10,7],[11,7],[12,7],[13,7],
  [2,8],[3,8],[4,8],[5,8],[6,8],[7,8],[8,8],[9,8],[10,8],[11,8],[12,8],[13,8],
  [2,9],[3,9],[4,9],[5,9],[6,9],[7,9],[8,9],[9,9],[10,9],[11,9],[12,9],[13,9],
  [3,10],[4,10],[5,10],[6,10],[7,10],[8,10],[9,10],[10,10],[11,10],[12,10],
  // chin
  [4,11],[5,11],[6,11],[7,11],[8,11],[9,11],[10,11],[11,11],
  // whiskers left (3, spaced)
  [0,6],[1,6],
  [0,8],[1,8],
  [0,10],[1,10],
  // whiskers right (3, spaced)
  [14,6],[15,6],
  [14,8],[15,8],
  [14,10],[15,10],
];

/** Build an inline SVG data URI of the CatIcon for CSS background tiling */
export function buildCatPatternSvg(color: string, tileSize = 128) {
  const p = tileSize / 16;
  const rects = CAT_PIXELS.map(
    ([x, y]) => `<rect x="${x * p}" y="${y * p}" width="${p}" height="${p}" rx="${p * 0.15}" fill="${color}"/>`,
  ).join("");
  const raw = `<svg xmlns="http://www.w3.org/2000/svg" width="${tileSize}" height="${tileSize}" viewBox="0 0 ${tileSize} ${tileSize}"><g opacity="0.04">${rects}</g></svg>`;
  return `url("data:image/svg+xml,${encodeURIComponent(raw)}")`;
}

export function CatIcon({ color = "currentColor", size = 24, className }: { color?: string; size?: number; className?: string }) {
  // Grid is 16 wide x 12 tall (rows 0-11 used), scale to fit
  const px = size / 16;
  const h = size * (12 / 16);
  const p = px;

  const eyes: [number, number][] = [
    [4,5],[5,5],[4,6],[5,6],
    [10,5],[11,5],[10,6],[11,6],
  ];
  const sparkle: [number, number][] = [[5,5],[11,5]];
  const nose: [number, number][] = [[7,8],[8,8]];
  const innerEar: [number, number][] = [[3,1],[3,2],[12,1],[12,2]];

  return (
    <svg width={size} height={h} viewBox={`0 0 ${size} ${h}`} fill="none" className={className}>
      {CAT_PIXELS.map(([x, y], i) => (
        <rect key={i} x={x * p} y={y * p} width={p} height={p} rx={p * 0.15} fill={color} />
      ))}
      {innerEar.map(([x, y], i) => (
        <rect key={`ie${i}`} x={x * p} y={y * p} width={p} height={p} fill="black" opacity="0.2" />
      ))}
      {eyes.map(([x, y], i) => (
        <rect key={`e${i}`} x={x * p} y={y * p} width={p} height={p} fill="black" opacity="0.7" />
      ))}
      {sparkle.map(([x, y], i) => (
        <rect key={`s${i}`} x={x * p} y={y * p} width={p} height={p} fill="white" opacity="0.9" />
      ))}
      {nose.map(([x, y], i) => (
        <rect key={`n${i}`} x={x * p} y={y * p} width={p} height={p} rx={p * 0.3} fill="black" opacity="0.4" />
      ))}
    </svg>
  );
}
