# AFK4AI

**AI 작업 중 화면을 지켜주는 macOS 화면 잠금 앱 + 웹 버전**

AI가 코딩하는 동안 실수로 키보드나 마우스를 건드리는 것을 방지합니다.
선택한 창을 실시간 스트리밍하며, 생체 인증(Touch ID)으로만 잠금을 해제할 수 있습니다.

> macOS 네이티브 앱과 브라우저 기반 웹 버전을 모두 지원합니다.

## 주요 기능

### 1. 풀스크린 잠금
- 화면 전체를 잠금 화면으로 덮어 실수 입력을 차단
- macOS: 윈도우 레벨을 `screenSaver`로 설정하여 다른 앱 위에 항상 표시
- 웹: Fullscreen API + Keyboard Lock API 활용

### 2. 실시간 윈도우 미러링
- 선택한 창/화면을 잠금 화면에 라이브 스트리밍
- "LIVE" 상태 배지로 스트리밍 상태 표시
- 경과 시간 타이머 (HH:MM:SS)

### 3. 키보드/마우스 입력 차단
- macOS: `CGEvent` 탭으로 시스템 레벨 이벤트 가로채기
- 웹: `Keyboard.lock()` + `contextmenu`/`beforeunload` 차단
- Cmd+Q, Cmd+W, Cmd+Tab 등 단축키 차단

### 4. 잠금 해제
- macOS: Touch ID / 비밀번호를 통한 생체 인증
- 웹: 2초 길게 누르기로 잠금 해제

### 5. 커스텀 테마

| 테마 | Primary | 특징 |
|------|---------|------|
| **Ember** | `#FF4D00` (오렌지) | 기본 테마 |
| **Mono** | `#FFFFFF` (흰색) | 하이 콘트라스트 |
| **Ocean** | `#1E40AF` (파랑) | 차분한 느낌 |
| **Matrix** | `#059669` (초록) | 해커 감성 |

### 6. 메뉴바 통합 (macOS)
- 시스템 메뉴바에 "AFK" 아이콘 상시 표시
- 메뉴바에서 직접 잠금 시작/해제

## 시스템 요구사항

### macOS 네이티브 앱

| 항목 | 요구 사항 |
|------|-----------|
| macOS | 14.0 (Sonoma) 이상 |
| Xcode | 16.0 이상 |
| Swift | 5.9 |

**필수 권한:**
- **화면 녹화** — 선택한 창의 실시간 캡처에 필요
- **손쉬운 사용 (Accessibility)** — 키보드/마우스 입력 차단에 필요

### 웹 버전

| 항목 | 요구 사항 |
|------|-----------|
| 브라우저 | Chrome / Edge 권장 (ESC 키 차단 지원) |
| 기능 | Screen Capture API, Fullscreen API |

## 프로젝트 구조

```
AFK4AI/
├── README.md
├── project.yml                    # XcodeGen 설정
│
├── AFK4AI/                        # macOS 네이티브 앱 (SwiftUI)
│   ├── AFK4AIApp.swift            # 앱 진입점, 메뉴바
│   ├── Theme.swift                # 컬러 테마 정의
│   ├── Info.plist
│   ├── AFK4AI.entitlements
│   ├── Assets.xcassets/
│   ├── Models/
│   │   ├── AppState.swift         # 중앙 상태 관리
│   │   ├── Language.swift         # 다국어 (ko/en)
│   │   ├── SystemMetrics.swift    # 시스템 메트릭 모델
│   │   └── WindowInfo.swift       # 윈도우 데이터 모델
│   ├── Services/
│   │   ├── WindowListService.swift      # 윈도우 목록 조회
│   │   ├── InputBlocker.swift           # CGEvent 탭 입력 차단
│   │   ├── WindowCaptureService.swift   # ScreenCaptureKit 화면 캡처
│   │   └── SystemMetricsService.swift   # 시스템 모니터링
│   ├── Views/
│   │   ├── SetupView.swift              # 설정 화면
│   │   ├── LockScreenView.swift         # 잠금 화면
│   │   └── Components/
│   │       ├── MetricsBarView.swift     # 시스템 메트릭 바
│   │       ├── LiveBadge.swift          # LIVE 표시
│   │       ├── HazardPattern.swift      # UI 패턴
│   │       └── WindowPreviewView.swift  # 윈도우 프리뷰
│   └── Utils/
│       └── Permissions.swift            # 권한 확인/요청
│
└── web/                           # 웹 버전 (Next.js)
    ├── package.json
    ├── tsconfig.json
    ├── next.config.ts
    └── app/
        ├── page.tsx               # 메인 페이지 (설정 → 잠금 전환)
        ├── layout.tsx             # 루트 레이아웃
        ├── globals.css            # 글로벌 스타일 + 애니메이션
        ├── i18n.ts                # 다국어 (ko/en)
        ├── landing/
        │   └── page.tsx           # 랜딩 페이지
        ├── lib/
        │   └── themes.ts          # 테마 정의 + CSS 변수 적용
        ├── hooks/
        │   ├── useScreenCapture.ts  # Screen Capture API 래퍼
        │   ├── useFullscreen.ts     # Fullscreen API 래퍼
        │   ├── useInputBlock.ts     # 키보드 잠금
        │   ├── useElapsedTimer.ts   # 경과 시간
        │   ├── useClock.ts          # 현재 시각
        │   ├── useBattery.ts        # 배터리 상태
        │   ├── useMouseGlow.ts      # 마우스 글로우 효과
        │   └── useLongPress.ts      # 길게 누르기 감지
        └── components/
            ├── icons.tsx            # SVG 아이콘 (도트 고양이 등)
            ├── setup/
            │   ├── SetupView.tsx        # 설정 화면
            │   ├── SourceSelector.tsx   # 화면 선택
            │   ├── ThemePicker.tsx      # 테마 선택
            │   └── ActivateButton.tsx   # 잠금 시작 버튼
            └── lock/
                ├── LockScreenView.tsx   # 잠금 화면
                ├── StreamArea.tsx       # 스트리밍 영역
                ├── TimerBar.tsx         # 시간 + 배터리 메트릭
                ├── MarqueeBanner.tsx    # 상단 무한 스크롤 배너
                ├── UnlockArea.tsx       # 잠금 해제 버튼
                └── ScanlineOverlay.tsx  # CRT 스캔라인 효과
```

## 아키텍처

### macOS 네이티브 — MVVM + Reactive State

```
┌─────────────────────────────────────────────────┐
│                   AFK4AIApp                     │
│         (Window Scene + MenuBarExtra)           │
└──────────────────┬──────────────────────────────┘
                   │ @StateObject
                   ▼
┌─────────────────────────────────────────────────┐
│                  AppState                       │
│            (ObservableObject)                   │
│                                                 │
│  @Published isLocked                            │
│  @Published selectedWindow                      │
│  @Published capturedImage                       │
│  @Published colorTheme                          │
│                                                 │
│  ┌──────────────┐ ┌───────────┐ ┌────────────┐ │
│  │WindowCapture │ │InputBlocker│ │WindowList  │ │
│  │Service       │ │           │ │Service     │ │
│  └──────────────┘ └───────────┘ └────────────┘ │
└──────────────────┬──────────────────────────────┘
                   │ @EnvironmentObject
          ┌────────┴────────┐
          ▼                 ▼
   ┌────────────┐   ┌──────────────┐
   │ SetupView  │   │LockScreenView│
   └────────────┘   └──────────────┘
```

### 웹 버전 — React Hooks + Component Composition

```
┌───────────────────────────────────────────────┐
│                  page.tsx                      │
│          (상태: setup | locked)                │
│                                               │
│  useScreenCapture()  — MediaStream 관리       │
│  useState(theme)     — 테마 상태              │
│  useState(lang)      — 언어 상태              │
└──────────┬──────────────────┬─────────────────┘
           │                  │
           ▼                  ▼
    ┌────────────┐    ┌──────────────┐
    │ SetupView  │    │LockScreenView│
    │            │    │              │
    │ Source     │    │ MarqueeBanner│
    │ Selector   │    │ TimerBar     │
    │ ThemePicker│    │ StreamArea   │
    │ Activate   │    │ UnlockArea   │
    │ Button     │    │              │
    └────────────┘    └──────────────┘
```

### 상태 흐름

```
[SetupView] ──ACTIVATE──▶ startLock()
                              │
                              ├─ isLocked = true
                              ├─ 입력 차단 시작
                              └─ 화면 캡처 스트리밍 시작
                                      │
                                      ▼
                              [LockScreenView 표시]
                              (풀스크린 + 입력 차단)
                                      │
                              잠금 해제 요청
                                      │
                              ├─ macOS: Touch ID 인증
                              └─ 웹: 2초 길게 누르기
                                      │
                              ├─ 성공 → SetupView 복귀
                              └─ 실패 → 잠금 유지
```

## 사용 기술

### macOS 네이티브

| 프레임워크 | 용도 |
|-----------|------|
| SwiftUI | UI 구성 |
| Combine | 반응형 상태 관리 |
| ScreenCaptureKit | 화면 캡처 스트리밍 |
| CoreGraphics | 윈도우 목록, 레거시 캡처 |
| LocalAuthentication | Touch ID / 비밀번호 인증 |
| AppKit | 윈도우 레벨, 풀스크린 |

외부 라이브러리 의존성 없음 (순수 Apple 프레임워크만 사용)

### 웹 버전

| 패키지 | 버전 | 용도 |
|--------|------|------|
| Next.js | 15.1 | App Router 기반 프레임워크 |
| React | 19.0 | UI 라이브러리 |
| Tailwind CSS | 4.0 | 유틸리티 CSS |
| TypeScript | 5.7 | 타입 안전성 |

외부 UI 라이브러리 의존성 없음

## 빌드

### macOS 네이티브

```bash
# XcodeGen 설치 (미설치 시)
brew install xcodegen

# Xcode 프로젝트 생성
xcodegen generate

# Xcode에서 열기
open AFK4AI.xcodeproj
```

### 웹 버전

```bash
cd web

# 의존성 설치
npm install

# 개발 서버
npm run dev

# 프로덕션 빌드
npm run build
npm start
```

## 보안 참고사항

- macOS 앱: App Sandbox 비활성화 (CGEvent 탭, 윈도우 캡처 등 저수준 API 필요)
- macOS 앱: Hardened Runtime 활성화
- `Cmd+Option+Esc` (강제 종료)는 macOS에서 차단 불가 — 의도적 허용
- 웹 버전: ESC 키 차단은 Chrome/Edge에서만 지원

## 라이선스

MIT
