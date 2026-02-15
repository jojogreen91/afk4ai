import Foundation
import AppKit

class WindowCaptureService {
    private let windowID: CGWindowID
    private var task: Task<Void, Never>?

    init(windowID: CGWindowID) {
        self.windowID = windowID
    }

    func startStreaming(onFrame: @escaping (NSImage) -> Void) {
        task = Task {
            while !Task.isCancelled {
                if let cgImage = CGWindowListCreateImage(
                    .null,
                    .optionIncludingWindow,
                    windowID,
                    [.boundsIgnoreFraming, .nominalResolution]
                ) {
                    let nsImage = NSImage(
                        cgImage: cgImage,
                        size: NSSize(width: cgImage.width, height: cgImage.height)
                    )
                    await MainActor.run { onFrame(nsImage) }
                }
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }

    func stopStreaming() {
        task?.cancel()
        task = nil
    }
}
