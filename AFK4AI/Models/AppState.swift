import SwiftUI
import Combine
import LocalAuthentication
import ScreenCaptureKit

class AppState: ObservableObject {
    @Published var isLocked = false
    @Published var selectedWindow: WindowInfo?
    @Published var availableWindows: [WindowInfo] = []
    @Published var capturedImage: NSImage?
    @Published var bannerMessage: String = "AFK4AI"
    @Published var colorTheme: ColorTheme = .ember
    @Published var systemMetrics = SystemMetrics()
    @Published var lockError: String?
    @Published var captureError: String?

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

    func startLock() async {
        guard let window = selectedWindow else {
            lockError = "모니터링할 창을 선택해주세요"
            return
        }

        // 1. Validate screen recording permission via SCShareableContent
        let hasPermission = await Permissions.validateScreenRecordingPermission()
        guard hasPermission else {
            lockError = "화면 녹화 권한이 필요합니다. 시스템 설정에서 권한을 허용한 후 앱을 재시작해주세요."
            return
        }

        // Verify the target window exists in SCShareableContent
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
            guard content.windows.contains(where: { $0.windowID == window.windowID }) else {
                lockError = "선택한 창을 찾을 수 없습니다. 창 목록을 새로고침해주세요."
                return
            }
        } catch {
            lockError = "화면 캡처 권한을 확인할 수 없습니다: \(error.localizedDescription)"
            return
        }

        lockError = nil
        captureError = nil

        // 2. Start InputBlocker
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

        // 3. Activate lock
        isLocked = true
        inputBlocker = blocker

        // 4. Start streaming (async, in background)
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
        captureError = nil
    }

    private func startStreaming() {
        guard let window = selectedWindow else {
            print("[AppState] startStreaming: no selectedWindow!")
            return
        }
        print("[AppState] startStreaming: windowID=\(window.windowID) name=\(window.displayName)")
        windowCaptureService = WindowCaptureService(windowID: window.windowID)
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
