import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "AFK4AI — 컴퓨터는 일하는 중. 고양이는 터치 금지.",
  description:
    "AI에게 작업을 맡기고 자리를 비울 때, 고양이나 누군가가 건드리지 못하도록 화면을 잠그고 실시간으로 모니터링하세요. 설치 없이 브라우저에서 바로.",
  openGraph: {
    title: "AFK4AI — 컴퓨터는 일하는 중. 고양이는 터치 금지.",
    description:
      "AI 작업 중 자리를 비울 때 화면을 잠그고 실시간 모니터링. 설치 없이 브라우저에서.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko">
      <head>
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500;600;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body
        className="antialiased"
        style={{ fontFamily: "'Inter', system-ui, sans-serif" }}
      >
        {children}
      </body>
    </html>
  );
}
