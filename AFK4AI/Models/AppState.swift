import SwiftUI
import Combine
import LocalAuthentication

class AppState: ObservableObject {
    @Published var isLocked = false
    @Published var selectedWindow: WindowInfo?
    @Published var availableWindows: [WindowInfo] = []
    @Published var capturedImage: NSImage?
    @Published var bannerMessage: String = "AFK4AI"
    @Published var colorTheme: ColorTheme = .ember
    @Published var systemMetrics = SystemMetrics()

    private let windowListService = WindowListService()
    private var windowCaptureService: WindowCaptureService?
    private var inputBlocker: InputBlocker?
    private var systemMetricsService: SystemMetricsService?

    func refreshWindowList() {
        availableWindows = windowListService.getWindowList()
        if let selected = selectedWindow,
           !availableWindows.contains(where: { $0.windowID == selected.windowID }) {
            selectedWindow = nil
        }
    }

    func startLock() {
        guard Permissions.hasScreenRecordingPermission() else {
            print("[AFK4AI] 화면 녹화 권한이 없습니다. 잠금을 시작할 수 없습니다.")
            return
        }
        guard Permissions.hasAccessibilityPermission() else {
            print("[AFK4AI] 손쉬운 사용 권한이 없습니다. 잠금을 시작할 수 없습니다.")
            return
        }
        isLocked = true
        inputBlocker = InputBlocker()
        inputBlocker?.onQuitAttempt = { [weak self] in
            self?.attemptUnlock { success in
                if success {
                    NSApp.terminate(nil)
                }
            }
        }
        inputBlocker?.startBlocking()
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

        // Temporarily stop blocking so the system auth dialog can receive input
        inputBlocker?.stopBlocking()

        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "AFK4AI 잠금을 해제합니다"
        ) { [weak self] success, authError in
            DispatchQueue.main.async {
                if success {
                    self?.stopLock()
                } else {
                    // Re-enable blocking if auth failed
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
    }

    private func startStreaming() {
        guard let window = selectedWindow else { return }
        windowCaptureService = WindowCaptureService(windowID: window.windowID)
        windowCaptureService?.startStreaming { [weak self] image in
            self?.capturedImage = image
        }
    }

    private func stopStreaming() {
        windowCaptureService?.stopStreaming()
        windowCaptureService = nil
    }
}
