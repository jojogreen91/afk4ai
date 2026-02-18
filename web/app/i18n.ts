export type Lang = "ko" | "en";

export const t = {
  nav: {
    features: { ko: "기능", en: "Features" },
    howItWorks: { ko: "사용법", en: "How It Works" },
    start: { ko: "시작하기", en: "Get Started" },
    madeBy: { ko: "만든 사람", en: "Made by" },
    openSource: { ko: "오픈소스 프로젝트", en: "Open Source Project" },
  },
  hero: {
    title1: { ko: "컴퓨터는 일하는 중.", en: "Your computer is working." },
    title2: { ko: "고양이는 터치 금지.", en: "Paws off the keyboard." },
    description: {
      ko: "AI에게 작업을 맡기고 자리를 비울 때, 고양이나 지나가는 누군가가",
      en: "When you step away from your AI tasks, lock the screen so",
    },
    descriptionBr: {
      ko: "키보드를 밟아도 걱정 없도록. 화면을 잠그고 실시간으로 지켜보세요.",
      en: "curious cats and passersby can't mess things up. Monitor in real time.",
    },
    cta: { ko: "지금 시작하기", en: "Start Now" },
    learnMore: { ko: "자세히 보기", en: "Learn More" },
    scroll: { ko: "스크롤", en: "Scroll" },
  },
  features: {
    title: { ko: "", en: "" },
    titleEnd: { ko: "가 화면을 지켜줍니다", en: " guards your screen" },
    subtitle1: {
      ko: "AI 작업 돌려놓고 밖에 나가세요.",
      en: "Run your AI tasks, lock the screen, and step outside.",
    },
    subtitle2: {
      ko: "브라우저만 있으면 됩니다.",
      en: "All you need is a browser.",
    },
    items: [
      {
        title: { ko: "실시간 화면 캡처", en: "Live Screen Capture" },
        description: {
          ko: "Screen Capture API로 선택한 화면을 실시간으로 잠금 화면에 표시합니다. 돌아와서 화면만 보면 됩니다.",
          en: "Uses the Screen Capture API to display your selected screen live on the lock screen. Just come back and see.",
        },
      },
      {
        title: { ko: "풀스크린 잠금", en: "Fullscreen Lock" },
        description: {
          ko: "브라우저 전체 화면으로 잠기고, Chrome/Edge에서는 ESC 키까지 차단합니다. 고양이가 키보드를 밟아도 안전합니다.",
          en: "Locks in fullscreen mode. Chrome/Edge even blocks the ESC key. Safe from cats walking across the keyboard.",
        },
      },
      {
        title: { ko: "길게 눌러 잠금 해제", en: "Long-Press Unlock" },
        description: {
          ko: "2초간 길게 눌러야 잠금이 해제됩니다. 고양이 발이나 실수로는 절대 풀리지 않습니다.",
          en: "Hold for 2 seconds to unlock. Cat paws or accidental touches won't unlock it.",
        },
      },
      {
        title: { ko: "배터리 & 시간 모니터링", en: "Battery & Time Monitor" },
        description: {
          ko: "배터리 잔량, 현재 시간, 경과 시간을 잠금 화면에서 실시간으로 확인하세요. 돌아와서 한눈에 파악.",
          en: "Monitor battery level, current time, and elapsed time in real time on the lock screen. See everything at a glance.",
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
        title: { ko: "설치 없이 바로 사용", en: "No Installation Needed" },
        description: {
          ko: "앱 설치 없이 브라우저만으로 바로 사용할 수 있습니다. Chrome 또는 Edge를 추천합니다.",
          en: "Works right in your browser — no app installation required. Chrome or Edge recommended.",
        },
      },
    ],
  },
  howItWorks: {
    title1: { ko: "사용법은", en: "It's" },
    title2: { ko: "간단합니다", en: "simple" },
    steps: [
      {
        title: { ko: "웹사이트 접속", en: "Open the web app" },
        description: {
          ko: "브라우저에서 AFK4AI를 열어주세요. 설치할 것은 아무것도 없습니다.",
          en: "Open AFK4AI in your browser. Nothing to install.",
        },
      },
      {
        title: { ko: "화면 선택", en: "Select your screen" },
        description: {
          ko: "지켜보고 싶은 화면을 선택하세요. 브라우저가 화면 공유를 요청합니다.",
          en: "Choose the screen you want to watch. Your browser will ask to share the screen.",
        },
      },
      {
        title: { ko: "ACTIVATE", en: "ACTIVATE" },
        description: {
          ko: "ACTIVATE 버튼을 누르면 전체 화면이 잠기고, 선택한 화면이 실시간으로 미러링됩니다. 안심하고 자리를 비우세요.",
          en: "Hit ACTIVATE and the screen locks fullscreen with a live mirror. Walk away with peace of mind.",
        },
      },
      {
        title: { ko: "돌아와서 길게 누르기", en: "Come back & long-press" },
        description: {
          ko: "돌아오면 잠금 해제 버튼을 2초간 길게 눌러주세요. 그게 전부입니다.",
          en: "When you're back, hold the unlock button for 2 seconds. That's it.",
        },
      },
    ],
  },
  cta: {
    title: { ko: "지금 바로 시작하세요", en: "Get started now" },
    subtitle: {
      ko: "브라우저만 있으면 됩니다. 설치 없이 바로 시작하세요.",
      en: "All you need is a browser. Start right away, no installation.",
    },
    button: { ko: "지금 시작하기", en: "Start Now" },
    footnote: {
      ko: "Chrome · Edge 권장 · 데스크탑 브라우저 · 무료",
      en: "Chrome · Edge recommended · Desktop browser · Free",
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
