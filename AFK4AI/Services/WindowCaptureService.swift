import Foundation
import AppKit
import ScreenCaptureKit
import CoreMedia

class WindowCaptureService: NSObject, SCStreamOutput, SCStreamDelegate {
    private let windowID: CGWindowID
    private var stream: SCStream?
    private var onFrame: ((NSImage) -> Void)?
    private var fallbackTimer: Timer?
    private var scFrameReceived = false
    private var watchdogTimer: Timer?
    private let ciContext = CIContext()

    init(windowID: CGWindowID) {
        self.windowID = windowID
        super.init()
    }

    func startStreaming(onFrame: @escaping (NSImage) -> Void) {
        self.onFrame = onFrame

        // Legacy capture runs immediately for fast first frame
        startFallbackCapture()

        // SCStream starts in background (higher quality, 10 FPS)
        Task {
            await startSCStream()
        }
    }

    func stopStreaming() {
        stopFallbackCapture()
        stopWatchdog()
        if let stream = stream {
            Task { try? await stream.stopCapture() }
        }
        stream = nil
        onFrame = nil
        scFrameReceived = false
    }

    // MARK: - SCStream

    private func startSCStream() async {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)

            guard let window = content.windows.first(where: { $0.windowID == windowID }) else {
                print("[AFK4AI] Target window not found in SCShareableContent (ID: \(windowID)).")
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

            let newStream = SCStream(filter: filter, configuration: config, delegate: self)
            try newStream.addStreamOutput(self, type: .screen, sampleHandlerQueue: .global(qos: .userInteractive))
            try await newStream.startCapture()

            self.stream = newStream

            await MainActor.run {
                self.startWatchdog()
            }
        } catch {
            print("[AFK4AI] SCStream failed: \(error). Fallback capture remains active.")
        }
    }

    // MARK: - Watchdog

    private func startWatchdog() {
        watchdogTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if !self.scFrameReceived {
                print("[AFK4AI] SCStream: no frames after 3s, keeping fallback.")
            }
        }
    }

    private func stopWatchdog() {
        watchdogTimer?.invalidate()
        watchdogTimer = nil
    }

    // MARK: - Legacy Fallback

    private func startFallbackCapture() {
        captureLegacy()
        fallbackTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.captureLegacy()
        }
    }

    private func stopFallbackCapture() {
        fallbackTimer?.invalidate()
        fallbackTimer = nil
    }

    private func captureLegacy() {
        guard !scFrameReceived else {
            stopFallbackCapture()
            return
        }
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
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
        let rect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(imageBuffer), height: CVPixelBufferGetHeight(imageBuffer))
        guard let cgImage = ciContext.createCGImage(ciImage, from: rect) else { return }

        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width / 2, height: cgImage.height / 2))
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !self.scFrameReceived {
                self.scFrameReceived = true
                self.stopWatchdog()
                self.stopFallbackCapture()
                print("[AFK4AI] SCStream delivering frames, fallback stopped.")
            }
            self.onFrame?(nsImage)
        }
    }

    // MARK: - SCStreamDelegate

    func stream(_ stream: SCStream, didStopWithError error: Error) {
        print("[AFK4AI] SCStream stopped: \(error). Restarting fallback.")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.stream = nil
            self.scFrameReceived = false
            self.startFallbackCapture()
        }
    }

    deinit {
        stopStreaming()
    }
}
