import Foundation
import AppKit

class WindowCaptureService {
    private let windowID: CGWindowID
    private var task: Task<Void, Never>?
    private var frameCount = 0
    private var nilCount = 0

    init(windowID: CGWindowID) {
        self.windowID = windowID
        print("[Capture] init windowID=\(windowID)")
    }

    func startStreaming(onFrame: @escaping (NSImage) -> Void) {
        print("[Capture] startStreaming called for windowID=\(windowID)")
        print("[Capture] CGPreflightScreenCaptureAccess=\(CGPreflightScreenCaptureAccess())")

        // 시작 전 해당 윈도우가 존재하는지 확인
        if let windowList = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]] {
            let match = windowList.first { ($0[kCGWindowNumber as String] as? CGWindowID) == windowID }
            if let match = match {
                let owner = match[kCGWindowOwnerName as String] as? String ?? "?"
                let name = match[kCGWindowName as String] as? String ?? "?"
                let bounds = match[kCGWindowBounds as String]
                print("[Capture] Window found: owner=\(owner) name=\(name) bounds=\(bounds ?? "nil")")
            } else {
                print("[Capture] WARNING: windowID=\(windowID) NOT found in CGWindowList! Total windows: \(windowList.count)")
                // 존재하는 윈도우 ID 목록 출력 (처음 10개)
                let ids = windowList.compactMap { $0[kCGWindowNumber as String] as? CGWindowID }.prefix(10)
                print("[Capture] Available window IDs (first 10): \(Array(ids))")
            }
        } else {
            print("[Capture] WARNING: CGWindowListCopyWindowInfo returned nil!")
        }

        task = Task {
            print("[Capture] Task loop started")
            while !Task.isCancelled {
                let cgImage = CGWindowListCreateImage(
                    .null,
                    .optionIncludingWindow,
                    windowID,
                    [.boundsIgnoreFraming, .nominalResolution]
                )

                if let cgImage = cgImage {
                    frameCount += 1
                    if frameCount <= 3 || frameCount % 100 == 0 {
                        print("[Capture] Frame #\(frameCount): \(cgImage.width)x\(cgImage.height)")
                    }
                    let nsImage = NSImage(
                        cgImage: cgImage,
                        size: NSSize(width: cgImage.width, height: cgImage.height)
                    )
                    await MainActor.run { onFrame(nsImage) }
                } else {
                    nilCount += 1
                    if nilCount <= 5 || nilCount % 50 == 0 {
                        print("[Capture] CGWindowListCreateImage returned nil (#\(nilCount)) for windowID=\(windowID)")
                    }
                }
                try? await Task.sleep(for: .milliseconds(100))
            }
            print("[Capture] Task loop ended (cancelled=\(Task.isCancelled))")
        }
    }

    func stopStreaming() {
        print("[Capture] stopStreaming called, frames=\(frameCount) nils=\(nilCount)")
        task?.cancel()
        task = nil
    }
}
