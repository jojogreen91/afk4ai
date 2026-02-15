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
    @Published var lockError: String?

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
            lockError = "화면 녹화 권한이 필요합니다"
            return
        }

        lockError = nil

        // Try to create InputBlocker and verify event tap actually works
        let blocker = InputBlocker()
        blocker.onQuitAttempt = { [weak self] in
            self?.attemptUnlock { success in
                if success {
                    NSApp.terminate(nil)
                }
            }
        }
        let blockingStarted = blocker.startBlocking()
        if !blockingStarted {
            lockError = "입력 차단을 시작할 수 없습니다. 시스템 설정 > 개인정보 보호 및 보안 > 손쉬운 사용에서 AFK4AI를 제거 후 다시 추가해주세요."
            blocker.stopBlocking()
            return
        }

        isLocked = true
        inputBlocker = blocker
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
            localizedReason: "AFK4AI 잠금을 해제합니다"
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
