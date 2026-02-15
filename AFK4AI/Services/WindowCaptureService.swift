import Foundation
import AppKit

class WindowCaptureService {
    private let windowID: CGWindowID
    private var timer: Timer?
    private var onFrame: ((NSImage) -> Void)?

    init(windowID: CGWindowID) {
        self.windowID = windowID
    }

    func startStreaming(onFrame: @escaping (NSImage) -> Void) {
        self.onFrame = onFrame
        captureFrame()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.captureFrame()
        }
    }

    func stopStreaming() {
        timer?.invalidate()
        timer = nil
        onFrame = nil
    }

    private func captureFrame() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            guard let cgImage = CGWindowListCreateImage(
                .null,
                .optionIncludingWindow,
                self.windowID,
                [.boundsIgnoreFraming, .nominalResolution]
            ) else { return }

            let nsImage = NSImage(
                cgImage: cgImage,
                size: NSSize(width: cgImage.width, height: cgImage.height)
            )
            DispatchQueue.main.async {
                self.onFrame?(nsImage)
            }
        }
    }

    deinit {
        stopStreaming()
    }
}
