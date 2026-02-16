import Foundation

enum Language: String, CaseIterable, Identifiable {
    case ko, en

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ko: return "한국어"
        case .en: return "English"
        }
    }
}

struct L {
    private let lang: Language

    init(_ lang: Language) { self.lang = lang }

    private func s(_ ko: String, _ en: String) -> String {
        lang == .ko ? ko : en
    }

    // MARK: - Setup

    var subtitle: String { s("AI 작업 중 화면을 지켜줍니다", "Guards your screen during AI tasks") }
    var permissions: String { s("권한", "Permissions") }
    var screenRecording: String { s("화면 녹화", "Screen Recording") }
    var accessibility: String { s("손쉬운 사용", "Accessibility") }
    var allow: String { s("허용", "Allow") }
    var monitorTarget: String { s("모니터링 대상", "Monitor Target") }
    var selectWindow: String { s("창을 선택하세요", "Select a window") }
    var theme: String { s("테마", "Theme") }
    var languageLabel: String { s("언어 / Language", "Language") }
    var grantPermissionsFirst: String { s("권한을 먼저 허용해주세요", "Please grant permissions first") }

    // MARK: - Lock Screen

    var connecting: String { s("화면 연결 중...", "Connecting...") }
    var authenticating: String { s("인증 중...", "Authenticating...") }
    var unlock: String { s("잠금 해제", "Unlock") }
    var authFailed: String { s("인증에 실패했습니다", "Authentication failed") }
    var emergencyExit: String { s("비상 탈출", "Emergency Exit") }

    // MARK: - Menu Bar

    var openSettings: String { s("설정 열기", "Open Settings") }
    var selectWindowFirst: String { s("창을 먼저 선택하세요", "Select a window first") }
    var permissionsRequired: String { s("권한 설정 필요", "Permissions required") }
    var startLock: String { s("잠금 시작", "Start Lock") }
    var screenRecordingRequired: String { s("화면 녹화 권한 필요", "Screen recording required") }
    var accessibilityRequired: String { s("손쉬운 사용 권한 필요", "Accessibility required") }
    var quit: String { s("종료", "Quit") }

    // MARK: - Errors (AppState)

    var errorSelectWindow: String { s("모니터링할 창을 선택해주세요", "Please select a window to monitor") }
    var errorScreenRecording: String { s(
        "화면 녹화 권한이 필요합니다. 시스템 설정에서 권한을 허용한 후 앱을 재시작해주세요.",
        "Screen recording permission is required. Please grant permission in System Settings and restart the app."
    ) }
    var errorWindowNotFound: String { s(
        "선택한 창을 찾을 수 없습니다. 창 목록을 새로고침해주세요.",
        "Selected window not found. Please refresh the window list."
    ) }
    func errorCapturePermission(_ detail: String) -> String { s(
        "화면 캡처 권한을 확인할 수 없습니다: \(detail)",
        "Cannot verify screen capture permission: \(detail)"
    ) }
    var errorInputBlocking: String { s(
        "입력 차단을 시작할 수 없습니다. 시스템 설정 > 개인정보 보호 및 보안 > 손쉬운 사용에서 AFK4AI를 제거 후 다시 추가해주세요.",
        "Cannot start input blocking. Please remove and re-add AFK4AI in System Settings > Privacy & Security > Accessibility."
    ) }
    var unlockReason: String { s("AFK4AI 잠금을 해제합니다", "Unlock AFK4AI") }

    // MARK: - Errors (Capture)

    func errorWindowNotFound(id: UInt32) -> String { s(
        "윈도우(ID=\(id))를 찾을 수 없습니다",
        "Window (ID=\(id)) not found"
    ) }
    func errorCaptureStart(_ detail: String) -> String { s(
        "캡처 시작 실패: \(detail)",
        "Capture failed: \(detail)"
    ) }
    func errorCaptureStopped(_ detail: String) -> String { s(
        "캡처 중단: \(detail)",
        "Capture stopped: \(detail)"
    ) }
}
