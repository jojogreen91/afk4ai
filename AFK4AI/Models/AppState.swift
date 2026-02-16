import SwiftUI
import Combine
import LocalAuthentication
import ScreenCaptureKit

@MainActor
class AppState: ObservableObject {
    @Published var isLocked = false
    @Published var isActivating = false
    @Published var selectedWindow: WindowInfo?
    @Published var availableWindows: [WindowInfo] = []
    @Published var capturedImage: NSImage?
    @Published var bannerMessage: String = "AFK4AI"
    @Published var colorTheme: ColorTheme = .ember
    @Published var language: Language = .ko {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: "language") }
    }
    @Published var systemMetrics = SystemMetrics()
    @Published var lockError: String?
    @Published var captureError: String?

    var l: L { L(language) }

    private let windowListService = WindowListService()
    private var windowCaptureService: WindowCaptureService?
    private var inputBlocker: InputBlocker?
    private var systemMetricsService: SystemMetricsService?

    init() {
        if let raw = UserDefaults.standard.string(forKey: "language"),
           let lang = Language(rawValue: raw) {
            self.language = lang
        }
    }

    func refreshWindowList() {
        availableWindows = windowListService.getWindowList()
        if let selected = selectedWindow,
           !availableWindows.contains(where: { $0.windowID == selected.windowID }) {
            selectedWindow = nil
        }
    }

    func startLock() {
        guard let window = selectedWindow else {
            lockError = l.errorSelectWindow
            return
        }

        lockError = nil
        captureError = nil
        isActivating = true

        // 1. 잠금 화면 진입 전에 캡처 권한 확인
        Task {
            do {
                let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
                guard content.windows.contains(where: { $0.windowID == window.windowID }) else {
                    lockError = l.errorWindowNotFound
                    isActivating = false
                    return
                }
            } catch {
                lockError = l.errorScreenRecording
                isActivating = false
                return
            }

            // 2. 권한 확인됨 → 잠금 진입
            enterLock()
        }
    }

    private func enterLock() {
        // InputBlocker 시도 — 실패해도 잠금 진행
        let blocker = InputBlocker()
        blocker.onQuitAttempt = { [weak self] in
            self?.attemptUnlock { success in
                if success { NSApp.terminate(nil) }
            }
        }
        let blockingStarted = blocker.startBlocking()
        if !blockingStarted {
            print("[AppState] InputBlocker failed — proceeding without input blocking")
            lockError = l.errorInputBlocking
        }

        isLocked = true
        isActivating = false
        if blockingStarted { inputBlocker = blocker }

        startStreaming()
        systemMetricsService = SystemMetricsService()
        systemMetricsService?.startMonitoring { [weak self] metrics in
            self?.systemMetrics = metrics
        }
    }

    func attemptUnlock(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            print("[AFK4AI] LocalAuthentication not available: \(error?.localizedDescription ?? "unknown")")
            completion(false)
            return
        }

        // 1. Stop input blocking so the system auth dialog can receive input
        inputBlocker?.stopBlocking()

        // 2. Lower window level so the auth dialog is visible above the lock screen
        let window = NSApplication.shared.windows.first
        window?.level = .normal

        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: l.unlockReason
        ) { [weak self] success, authError in
            DispatchQueue.main.async {
                if success {
                    self?.stopLock()
                } else {
                    // Restore lock state: raise window level and re-enable blocking
                    window?.level = .screenSaver
                    self?.inputBlocker?.startBlocking()
                }
                completion(success)
            }
        }
    }

    func stopLock() {
        isLocked = false
        stopStreaming()
        inputBlocker?.stopBlocking()
        inputBlocker = nil
        systemMetricsService?.stopMonitoring()
        systemMetricsService = nil
        systemMetrics = SystemMetrics()
        capturedImage = nil
        captureError = nil
    }

    private func startStreaming() {
        guard let window = selectedWindow else {
            print("[AppState] startStreaming: no selectedWindow!")
            return
        }
        print("[AppState] startStreaming: windowID=\(window.windowID) name=\(window.displayName)")
        windowCaptureService = WindowCaptureService(windowID: window.windowID, language: language)
        windowCaptureService?.startStreaming(
            onFrame: { [weak self] image in
                let isFirst = self?.capturedImage == nil
                self?.capturedImage = image
                if isFirst {
                    print("[AppState] First captured image received: \(image.size)")
                }
            },
            onError: { [weak self] error in
                print("[AppState] Capture error: \(error)")
                self?.captureError = error
            }
        )
    }

    private func stopStreaming() {
        windowCaptureService?.stopStreaming()
        windowCaptureService = nil
    }
}
