import SwiftUI
import Combine
import LocalAuthentication

@MainActor
class AppState: ObservableObject {
    @Published var isLocked = false
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
        guard selectedWindow != nil else {
            lockError = l.errorSelectWindow
            return
        }

        lockError = nil
        captureError = nil

        // InputBlocker 시도 — 실패해도 잠금 진행
        let blocker = InputBlocker()
        blocker.onQuitAttempt = { [weak self] in
            self?.attemptUnlock { success in
                if success { NSApp.terminate(nil) }
            }
        }
        let blockingStarted = blocker.startBlocking()
        if !blockingStarted {
            lockError = l.errorInputBlocking
        }

        isLocked = true
        if blockingStarted { inputBlocker = blocker }

        startCapture()
        systemMetricsService = SystemMetricsService()
        systemMetricsService?.startMonitoring { [weak self] metrics in
            self?.systemMetrics = metrics
        }
    }

    func attemptUnlock(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            completion(false)
            return
        }

        inputBlocker?.stopBlocking()

        let window = NSApplication.shared.windows.first
        window?.level = .normal

        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: l.unlockReason
        ) { [weak self] success, _ in
            DispatchQueue.main.async {
                if success {
                    self?.stopLock()
                } else {
                    window?.level = .screenSaver
                    self?.inputBlocker?.startBlocking()
                }
                completion(success)
            }
        }
    }

    func stopLock() {
        isLocked = false
        windowCaptureService?.stopCapture()
        windowCaptureService = nil
        inputBlocker?.stopBlocking()
        inputBlocker = nil
        systemMetricsService?.stopMonitoring()
        systemMetricsService = nil
        systemMetrics = SystemMetrics()
        capturedImage = nil
        captureError = nil
    }

    private func startCapture() {
        guard let window = selectedWindow else { return }
        windowCaptureService = WindowCaptureService(windowID: window.windowID)
        windowCaptureService?.startCapture(
            onFrame: { [weak self] image in
                self?.capturedImage = image
            },
            onError: { [weak self] error in
                self?.captureError = error
            }
        )
    }
}
