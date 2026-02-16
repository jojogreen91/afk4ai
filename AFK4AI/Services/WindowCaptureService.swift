import Foundation
import AppKit

class WindowCaptureService {
    private let windowID: CGWindowID
    private var timer: Timer?
    private var onFrame: ((NSImage) -> Void)?
    private var onError: ((String) -> Void)?
    private var frameCount = 0

    init(windowID: CGWindowID) {
        self.windowID = windowID
    }

    func startCapture(onFrame: @escaping (NSImage) -> Void, onError: ((String) -> Void)? = nil) {
        self.onFrame = onFrame
        self.onError = onError
        frameCount = 0

        // 10 FPS 폴링
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.captureFrame()
        }
    }

    func stopCapture() {
        timer?.invalidate()
        timer = nil
    }

    private func captureFrame() {
        guard let cgImage = CGWindowListCreateImage(
            .null,
            .optionIncludingWindow,
            windowID,
            [.boundsIgnoreFraming, .nominalResolution]
        ) else {
            if frameCount == 0 {
                onError?("캡처 실패: 창을 찾을 수 없거나 화면 녹화 권한이 없습니다")
            }
            return
        }

        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        frameCount += 1
        onFrame?(nsImage)
    }
}
