# AFK4AI

**AI 작업 중 화면을 지켜주는 macOS 풀스크린 잠금 앱**

AI가 코딩하는 동안 실수로 키보드나 마우스를 건드리는 것을 방지합니다. 선택한 창을 실시간 스트리밍하며, 생체 인증(Touch ID)으로만 잠금을 해제할 수 있습니다.

## 주요 기능

### 1. 풀스크린 잠금
- 화면 전체를 잠금 화면으로 덮어 실수 입력을 차단
- 윈도우 레벨을 `screenSaver`로 설정하여 다른 앱 위에 항상 표시
- 닫기/최소화 버튼 제거, ESC 키 차단

### 2. 실시간 윈도우 미러링
- 선택한 창의 화면을 잠금 화면에 라이브 스트리밍
- "LIVE" 상태 배지로 스트리밍 상태 표시
- 경과 시간 타이머 (HH:MM:SS)

### 3. 키보드/마우스 입력 차단
- 잠금 중 모든 키보드 입력 차단
- 모든 마우스 이벤트 (클릭, 이동, 스크롤) 차단
- Cmd+Q 시도 시 종료 대신 생체 인증 유도
- Cmd+W, Cmd+H, Cmd+M, Cmd+Tab 차단
- Cmd+Option+Esc (강제 종료)는 macOS 정책상 허용

### 4. 생체 인증 잠금 해제
- Touch ID / 비밀번호를 통한 잠금 해제
- 인증 다이얼로그 표시 중 일시적으로 입력 차단 해제
- 인증 실패 시 자동으로 입력 차단 재활성화

### 5. 커스텀 테마
| 테마 | Primary | Status | 특징 |
|------|---------|--------|------|
| **Ember** | `#FF4D00` (오렌지) | `#00FF41` (초록) | 기본 테마 |
| **Mono** | `#FFFFFF` (흰색) | `#AAAAAA` (회색) | 하이 콘트라스트 |
| **Ocean** | `#3B82F6` (파랑) | `#22D3EE` (시안) | 차분한 느낌 |
| **Matrix** | `#22C55E` (초록) | `#00FF41` (초록) | 해커 감성 |

### 6. 메뉴바 통합
- 시스템 메뉴바에 "AFK" 아이콘 상시 표시
- 잠금 상태 표시 (Active / Standby)
- 메뉴바에서 직접 잠금 시작/해제, 설정 열기

## 시스템 요구사항

| 항목 | 요구 사항 |
|------|-----------|
| macOS | 14.0 (Sonoma) 이상 |
| Xcode | 16.0 이상 |
| Swift | 5.9 |

### 필수 권한
- **화면 녹화** — 선택한 창의 실시간 캡처에 필요
- **손쉬운 사용 (Accessibility)** — 키보드/마우스 입력 차단에 필요

## 프로젝트 구조

```
AFK4AI/
├── AFK4AIApp.swift              # 앱 진입점, ContentView 라우팅, 메뉴바
├── Theme.swift                  # 컬러 테마 정의, 폰트 헬퍼
├── Info.plist                   # 권한 설명 문자열
├── AFK4AI.entitlements          # 보안 엔타이틀먼트
├── Assets.xcassets/             # 앱 아이콘
├── Models/
│   ├── AppState.swift           # 중앙 상태 관리 (ObservableObject)
│   └── WindowInfo.swift         # 윈도우 데이터 모델
├── Services/
│   ├── WindowListService.swift  # 화면 위 윈도우 목록 조회
│   ├── InputBlocker.swift       # CGEvent 탭 기반 입력 차단
│   └── WindowCaptureService.swift # ScreenCaptureKit 기반 화면 캡처
├── Views/
│   ├── SetupView.swift          # 설정 화면 (권한, 창 선택, 테마)
│   ├── LockScreenView.swift     # 풀스크린 잠금 화면
│   └── Components/
│       └── HazardPattern.swift  # 재사용 UI 컴포넌트
└── Utils/
    └── Permissions.swift        # 시스템 권한 확인/요청
```

## 아키텍처

### 패턴: MVVM + Reactive State

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
   │ (설정 화면) │   │ (잠금 화면)   │
   └────────────┘   └──────────────┘
```

### 상태 흐름

```
[SetupView] ──ACTIVATE──▶ AppState.startLock()
                              │
                              ├─ isLocked = true
                              ├─ InputBlocker 생성 → startBlocking()
                              └─ WindowCaptureService 생성 → startStreaming()
                                      │
                                      ▼
                              [LockScreenView 표시]
                              (풀스크린 + 입력 차단)
                                      │
                              잠금 해제 버튼 클릭
                                      │
                                      ▼
                              AppState.attemptUnlock()
                              │
                              ├─ InputBlocker 일시 중단
                              ├─ Touch ID 인증 요청
                              │
                              ├─ 성공 → stopLock() → SetupView 복귀
                              └─ 실패 → InputBlocker 재활성화
```

### 핵심 컴포넌트 설계

#### AppState (중앙 상태 관리)
- `ObservableObject`로 모든 뷰에 상태 전파
- 서비스 생명주기 관리 (잠금 시 생성, 해제 시 소멸)
- `@Published` 프로퍼티를 통한 반응형 UI 업데이트

#### WindowCaptureService (이중 캡처 전략)
1. **Primary**: `ScreenCaptureKit` (SCStream) — 10 FPS, 2x 해상도 캡처 후 스케일 다운
2. **Fallback**: `CGWindowListCreateImage` 타이머 — 0.5초 간격, 레거시 방식
- 앱 시작 시 Fallback을 먼저 가동하고, ScreenCaptureKit 준비 완료 시 자동 전환

#### InputBlocker (CGEvent 탭)
- `CGEvent.tapCreate()`로 시스템 레벨 이벤트 가로채기
- `CFRunLoop`에 mach port 등록
- 인증 다이얼로그 표시 시 일시 정지 → 인증 후 재시작

#### Permissions (권한 관리)
- `CGWindowListCreateImage` 테스트 호출로 화면 녹화 권한 확인
- `AXIsProcessTrusted()`로 손쉬운 사용 권한 확인
- `x-apple.systempreferences:` URL 스킴으로 설정 앱 직접 열기

## 사용되는 프레임워크

| 프레임워크 | 용도 |
|-----------|------|
| SwiftUI | UI 구성 |
| Combine | 반응형 상태 관리 |
| ScreenCaptureKit | 화면 캡처 스트리밍 |
| CoreGraphics | 윈도우 목록 조회, 레거시 캡처 |
| LocalAuthentication | Touch ID / 비밀번호 인증 |
| AppKit | 윈도우 레벨 제어, 풀스크린 |

외부 라이브러리 의존성 없음 (순수 Apple 프레임워크만 사용)

## 빌드

[XcodeGen](https://github.com/yonaskolb/XcodeGen)으로 프로젝트 파일을 생성합니다.

```bash
# XcodeGen 설치 (미설치 시)
brew install xcodegen

# Xcode 프로젝트 생성
xcodegen generate

# Xcode에서 열기
open AFK4AI.xcodeproj
```

## 보안 참고사항

- App Sandbox가 비활성화되어 있음 (CGEvent 탭, 윈도우 캡처 등 저수준 API 접근 필요)
- Hardened Runtime 활성화
- `Cmd+Option+Esc` (강제 종료)는 macOS에서 차단 불가 — 의도적 허용
