import Foundation
import AppKit
import ScreenCaptureKit
import CoreMedia

class WindowCaptureService: NSObject, SCStreamOutput, SCStreamDelegate {
    private let windowID: CGWindowID
    private let l: L
    private var stream: SCStream?
    private var onFrame: ((NSImage) -> Void)?
    private var onError: ((String) -> Void)?
    private let ciContext = CIContext()
    private var frameCount = 0

    init(windowID: CGWindowID, language: Language) {
        self.windowID = windowID
        self.l = L(language)
        super.init()
        print("[Capture] init windowID=\(windowID)")
    }

    func startStreaming(onFrame: @escaping (NSImage) -> Void, onError: ((String) -> Void)? = nil) {
        self.onFrame = onFrame
        self.onError = onError

        Task {
            do {
                let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)

                guard let scWindow = content.windows.first(where: { $0.windowID == self.windowID }) else {
                    let msg = self.l.errorWindowNotFound(id: self.windowID)
                    print("[Capture] ERROR: \(msg)")
                    await MainActor.run { self.onError?(msg) }
                    return
                }

                print("[Capture] Found window: \(scWindow.owningApplication?.applicationName ?? "?") - \(scWindow.title ?? "?")")

                let filter = SCContentFilter(desktopIndependentWindow: scWindow)
                let config = SCStreamConfiguration()

                // Retina display support
                let scaleFactor = NSScreen.main?.backingScaleFactor ?? 2.0
                config.width = Int(CGFloat(scWindow.frame.width) * scaleFactor)
                config.height = Int(CGFloat(scWindow.frame.height) * scaleFactor)
                config.minimumFrameInterval = CMTime(value: 1, timescale: 10) // 10 FPS
                config.showsCursor = false
                config.pixelFormat = kCVPixelFormatType_32BGRA

                let stream = SCStream(filter: filter, configuration: config, delegate: self)
                try stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: .global(qos: .userInteractive))
                try await stream.startCapture()

                self.stream = stream
                print("[Capture] SCStream started successfully")
            } catch {
                let msg = self.l.errorCaptureStart(error.localizedDescription)
                print("[Capture] ERROR: \(msg)")
                await MainActor.run { self.onError?(msg) }
            }
        }
    }

    // MARK: - SCStreamOutput

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen else { return }
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return }

        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))

        frameCount += 1
        if frameCount <= 3 || frameCount % 300 == 0 {
            print("[Capture] Frame #\(frameCount): \(cgImage.width)x\(cgImage.height)")
        }

        DispatchQueue.main.async { [weak self] in
            self?.onFrame?(nsImage)
        }
    }

    // MARK: - SCStreamDelegate

    func stream(_ stream: SCStream, didStopWithError error: Error) {
        print("[Capture] Stream stopped with error: \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
            self?.onError?(self?.l.errorCaptureStopped(error.localizedDescription) ?? error.localizedDescription)
        }
    }

    func stopStreaming() {
        print("[Capture] stopStreaming called, frames=\(frameCount)")
        guard let stream = stream else { return }
        self.stream = nil
        Task {
            try? await stream.stopCapture()
        }
    }
}
