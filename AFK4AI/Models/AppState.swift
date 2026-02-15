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

    private let windowListService = WindowListService()
    private var windowCaptureService: WindowCaptureService?
    private var inputBlocker: InputBlocker?

    func refreshWindowList() {
        availableWindows = windowListService.getWindowList()
        if let selected = selectedWindow,
           !availableWindows.contains(where: { $0.windowID == selected.windowID }) {
            selectedWindow = nil
        }
    }

    func startLock() {
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
