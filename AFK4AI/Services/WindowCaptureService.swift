import Foundation
import AppKit
import ScreenCaptureKit
import CoreMedia

class WindowCaptureService: NSObject, SCStreamOutput {
    private let windowID: CGWindowID
    private var stream: SCStream?
    private var onFrame: ((NSImage) -> Void)?
    private var fallbackTimer: Timer?
    private var streamStarted = false

    init(windowID: CGWindowID) {
        self.windowID = windowID
        super.init()
    }

    func startStreaming(onFrame: @escaping (NSImage) -> Void) {
        self.onFrame = onFrame

        // Immediately start legacy capture as fallback
        startFallbackCapture()

        Task {
            do {
                // onScreenWindowsOnly: false — target window may be behind our fullscreen
                let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)

                guard let window = content.windows.first(where: { $0.windowID == windowID }) else {
                    print("[AFK4AI] Target window not found (ID: \(windowID))")
                    return
                }

                let filter = SCContentFilter(desktopIndependentWindow: window)

                let config = SCStreamConfiguration()
                config.width = Int(window.frame.width) * 2
                config.height = Int(window.frame.height) * 2
                config.minimumFrameInterval = CMTime(value: 1, timescale: 10)
                config.showsCursor = false
                config.pixelFormat = kCVPixelFormatType_32BGRA
                config.queueDepth = 3

                let newStream = SCStream(filter: filter, configuration: config, delegate: nil)
                try newStream.addStreamOutput(self, type: .screen, sampleHandlerQueue: .global(qos: .userInteractive))
                try await newStream.startCapture()

                self.stream = newStream
                self.streamStarted = true

                await MainActor.run {
                    self.stopFallbackCapture()
                }
            } catch {
                print("[AFK4AI] SCStream failed: \(error). Fallback capture active.")
            }
        }
    }

    func stopStreaming() {
        stopFallbackCapture()
        guard let stream = stream else {
            self.onFrame = nil
            return
        }
        Task {
            try? await stream.stopCapture()
        }
        self.stream = nil
        self.onFrame = nil
        self.streamStarted = false
    }

    // MARK: - Fallback (legacy timer-based capture)

    private func startFallbackCapture() {
        captureLegacy()
        fallbackTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.captureLegacy()
        }
    }

    private func stopFallbackCapture() {
        fallbackTimer?.invalidate()
        fallbackTimer = nil
    }

    private func captureLegacy() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self, !self.streamStarted else { return }
            guard let cgImage = CGWindowListCreateImage(
                .null,
                .optionIncludingWindow,
                self.windowID,
                [.boundsIgnoreFraming, .nominalResolution]
            ) else { return }

            let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
            DispatchQueue.main.async {
                self.onFrame?(nsImage)
            }
        }
    }

    // MARK: - SCStreamOutput

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen, let imageBuffer = sampleBuffer.imageBuffer else { return }

        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        let rect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(imageBuffer), height: CVPixelBufferGetHeight(imageBuffer))
        guard let cgImage = context.createCGImage(ciImage, from: rect) else { return }

        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width / 2, height: cgImage.height / 2))
        DispatchQueue.main.async { [weak self] in
            self?.onFrame?(nsImage)
        }
    }

    deinit {
        stopStreaming()
    }
}
