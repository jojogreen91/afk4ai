export type Lang = "ko" | "en";

export const t = {
  nav: {
    features: { ko: "기능", en: "Features" },
    howItWorks: { ko: "사용법", en: "How It Works" },
    download: { ko: "다운로드", en: "Download" },
    madeBy: { ko: "만든 사람", en: "Made by" },
    openSource: { ko: "오픈소스 프로젝트", en: "Open Source Project" },
  },
  hero: {
    title1: { ko: "컴퓨터는 일하는 중.", en: "Your Mac is working." },
    title2: { ko: "고양이는 터치 금지.", en: "Paws off the keyboard." },
    description: {
      ko: "AI에게 작업을 맡기고 자리를 비울 때, 고양이나 지나가는 누군가가",
      en: "When you leave your Mac running AI tasks, lock the screen so",
    },
    descriptionBr: {
      ko: "키보드를 밟아도 걱정 없도록. 화면을 잠그고 실시간으로 지켜보세요.",
      en: "curious cats and passersby can't mess things up. Monitor in real time.",
    },
    cta: { ko: "무료 다운로드", en: "Free Download" },
    learnMore: { ko: "자세히 보기", en: "Learn More" },
    scroll: { ko: "스크롤", en: "Scroll" },
  },
  features: {
    title: { ko: "", en: "" },
    titleEnd: { ko: "가 맥북을 지켜줍니다", en: " guards your Mac" },
    subtitle1: {
      ko: "AI 작업 돌려놓고 밖에 나가세요.",
      en: "Run your AI tasks, lock the screen, and step outside.",
    },
    subtitle2: {
      ko: "화면 잠그고 실시간으로 확인하면 됩니다.",
      en: "Monitor everything in real time.",
    },
    items: [
      {
        title: { ko: "실시간 윈도우 미러링", en: "Live Window Mirroring" },
        description: {
          ko: "잠금 화면에서 작업 중인 윈도우를 실시간으로 볼 수 있습니다. 밖에서 폰으로 확인할 필요 없이, 돌아와서 화면만 보면 됩니다.",
          en: "Watch your working window in real time on the lock screen. No need to check your phone — just come back and see.",
        },
      },
      {
        title: { ko: "완벽한 입력 차단", en: "Complete Input Blocking" },
        description: {
          ko: "키보드와 마우스 입력을 시스템 레벨에서 차단합니다. 고양이가 키보드 위를 걸어다녀도, 아이가 마우스를 잡아도 안전합니다.",
          en: "Blocks all keyboard and mouse input at the system level. Safe from cats walking on the keyboard or kids grabbing the mouse.",
        },
      },
      {
        title: { ko: "Touch ID 잠금 해제", en: "Touch ID Unlock" },
        description: {
          ko: "Touch ID 또는 비밀번호로 안전하게 잠금을 해제하세요. 본인만이 잠금을 풀 수 있습니다.",
          en: "Unlock securely with Touch ID or password. Only you can unlock it.",
        },
      },
      {
        title: { ko: "시스템 메트릭스", en: "System Metrics" },
        description: {
          ko: "CPU, GPU, 메모리, 네트워크 사용량을 잠금 화면에서 실시간으로 확인하세요. 돌아와서 한눈에 상태를 파악할 수 있습니다.",
          en: "Monitor CPU, GPU, memory, and network usage in real time on the lock screen. See the status at a glance when you return.",
        },
      },
      {
        title: { ko: "4가지 테마", en: "4 Themes" },
        description: {
          ko: "Ember, Mono, Ocean, Matrix — 취향에 맞는 테마를 골라 잠금 화면을 꾸미세요.",
          en: "Ember, Mono, Ocean, Matrix — pick a theme that fits your style.",
        },
      },
      {
        title: { ko: "메뉴바 상주", en: "Menu Bar App" },
        description: {
          ko: "메뉴바에서 빠르게 잠금을 걸고 해제할 수 있습니다. 한 클릭이면 충분합니다.",
          en: "Lock and unlock quickly from the menu bar. One click is all it takes.",
        },
      },
    ],
  },
  howItWorks: {
    title1: { ko: "사용법은", en: "It's" },
    title2: { ko: "간단합니다", en: "simple" },
    steps: [
      {
        title: { ko: "윈도우 선택", en: "Select a window" },
        description: {
          ko: "지켜보고 싶은 윈도우를 선택하세요. 실행 중인 모든 앱의 윈도우 목록이 표시됩니다.",
          en: "Choose the window you want to watch. All running app windows are listed.",
        },
      },
      {
        title: { ko: "잠금 & 자리 비우기", en: "Lock & walk away" },
        description: {
          ko: "Lock 버튼을 누르면 전체 화면이 잠기고, 선택한 윈도우가 실시간으로 미러링됩니다. 이제 안심하고 자리를 비우세요.",
          en: "Hit Lock and the screen locks with a live mirror of your selected window. Walk away with peace of mind.",
        },
      },
      {
        title: { ko: "돌아와서 Touch ID", en: "Come back & Touch ID" },
        description: {
          ko: "돌아오면 Touch ID 또는 비밀번호로 잠금을 해제하세요. 그게 전부입니다.",
          en: "When you're back, unlock with Touch ID or password. That's it.",
        },
      },
    ],
  },
  cta: {
    title: { ko: "지금 바로 시작하세요", en: "Get started now" },
    subtitle: {
      ko: "무료로 다운로드하고 안심하고 자리를 비우세요.",
      en: "Download for free and leave your desk worry-free.",
    },
    button: { ko: "Download for macOS", en: "Download for macOS" },
    footnote: {
      ko: "macOS 14.0 (Sonoma) 이상 · Apple Silicon & Intel 지원 · 무료",
      en: "macOS 14.0 (Sonoma) or later · Apple Silicon & Intel · Free",
    },
  },
  webapp: {
    setup: {
      title: { ko: "화면 잠금 설정", en: "Lock Screen Setup" },
      selectScreen: { ko: "화면 선택", en: "Select Screen" },
      selectScreenDesc: {
        ko: "잠금 화면에 미러링할 화면을 선택하세요.",
        en: "Choose the screen to mirror on the lock screen.",
      },
      selectScreenTip: {
        ko: "💡 다른 데스크탑의 창도 보려면 \"전체 화면\"을 선택하세요.",
        en: "💡 Select \"Entire Screen\" to capture windows across all desktops.",
      },
      selectTheme: { ko: "테마 선택", en: "Select Theme" },
      activate: { ko: "ACTIVATE", en: "ACTIVATE" },
      activateDesc: {
        ko: "화면을 잠그고 모니터링을 시작합니다.",
        en: "Lock the screen and start monitoring.",
      },
      browserWarning: {
        ko: "Chrome/Edge에서만 ESC 키 차단이 가능합니다. 다른 브라우저에서는 ESC로 풀스크린이 해제될 수 있습니다.",
        en: "ESC key blocking only works in Chrome/Edge. In other browsers, ESC may exit fullscreen.",
      },
      clickToSelect: {
        ko: "클릭하여 화면 선택",
        en: "Click to select screen",
      },
      screenSelected: {
        ko: "화면이 선택되었습니다",
        en: "Screen selected",
      },
      landing: { ko: "사용 방법", en: "How to Use" },
    },
    lock: {
      elapsed: { ko: "경과 시간", en: "Elapsed" },
      unlockHint: {
        ko: "잠금 해제하려면 2초간 길게 누르세요",
        en: "Hold for 2 seconds to unlock",
      },
      unlocking: { ko: "해제 중...", en: "Unlocking..." },
      live: { ko: "LIVE", en: "LIVE" },
    },
  },
} as const;
