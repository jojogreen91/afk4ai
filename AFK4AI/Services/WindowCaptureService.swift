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
    private var callbackCount = 0

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
                print("[Capture] Querying SCShareableContent...")
                let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
                print("[Capture] SCShareableContent: \(content.windows.count) windows found")

                guard let scWindow = content.windows.first(where: { $0.windowID == self.windowID }) else {
                    let msg = self.l.errorWindowNotFound(id: self.windowID)
                    print("[Capture] ERROR: \(msg)")
                    await MainActor.run { self.onError?(msg) }
                    return
                }

                let appName = scWindow.owningApplication?.applicationName ?? "?"
                let title = scWindow.title ?? "?"
                print("[Capture] Found window: \(appName) - \(title) frame=\(scWindow.frame)")

                let filter = SCContentFilter(desktopIndependentWindow: scWindow)
                let config = SCStreamConfiguration()

                // Retina display support
                let scaleFactor = await MainActor.run { NSScreen.main?.backingScaleFactor ?? 2.0 }
                config.width = Int(CGFloat(scWindow.frame.width) * scaleFactor)
                config.height = Int(CGFloat(scWindow.frame.height) * scaleFactor)
                config.minimumFrameInterval = CMTime(value: 1, timescale: 10) // 10 FPS
                config.showsCursor = false
                config.pixelFormat = kCVPixelFormatType_32BGRA
                config.queueDepth = 5

                print("[Capture] Config: \(config.width)x\(config.height) scale=\(scaleFactor)")

                let stream = SCStream(filter: filter, configuration: config, delegate: self)
                try stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: .global(qos: .userInteractive))
                try await stream.startCapture()

                self.stream = stream
                print("[Capture] SCStream started successfully")

                // 5초 후 프레임 못 받으면 에러 표시
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                if self.frameCount == 0 && self.stream != nil {
                    print("[Capture] WARNING: No frames received after 5s, callbackCount=\(self.callbackCount)")
                    let msg = self.l.errorCaptureStart("No frames received")
                    await MainActor.run { self.onError?(msg) }
                }
            } catch {
                let msg = self.l.errorCaptureStart(error.localizedDescription)
                print("[Capture] ERROR: \(msg)")
                await MainActor.run { self.onError?(msg) }
            }
        }
    }

    // MARK: - SCStreamOutput

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        callbackCount += 1

        guard type == .screen else { return }

        // 프레임 상태 확인
        if let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: false) as? [NSDictionary],
           let attachment = attachments.first,
           let statusRaw = attachment[SCStreamFrameInfo.status] as? Int {
            if callbackCount <= 5 {
                print("[Capture] Callback #\(callbackCount): status=\(statusRaw) hasImage=\(sampleBuffer.imageBuffer != nil)")
            }
            // status 0=complete, 1=idle, 2=blank, 3=suspended, 4=started
            guard statusRaw == 0 else { return }
        }

        guard let pixelBuffer = sampleBuffer.imageBuffer else {
            if callbackCount <= 5 {
                print("[Capture] Callback #\(callbackCount): imageBuffer is nil")
            }
            return
        }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            print("[Capture] Failed to create CGImage from CIImage")
            return
        }

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
