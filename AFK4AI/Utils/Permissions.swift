import Foundation
import CoreGraphics
import AppKit

enum Permissions {
    static func hasScreenRecordingPermission() -> Bool {
        // CGPreflightScreenCaptureAccess can return stale results on some macOS versions
        if CGPreflightScreenCaptureAccess() {
            return true
        }
        // Fallback: check if we can actually see windows from other processes
        guard let windowList = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as? [[String: Any]] else {
            return false
        }
        let myPID = ProcessInfo.processInfo.processIdentifier
        return windowList.contains { info in
            guard let pid = info[kCGWindowOwnerPID as String] as? Int32,
                  let name = info[kCGWindowOwnerName as String] as? String else { return false }
            return pid != myPID && name != "Window Server"
        }
    }

    static func hasAccessibilityPermission() -> Bool {
        AXIsProcessTrusted()
    }

    static func requestScreenRecordingPermission() {
        CGRequestScreenCaptureAccess()
    }

    static func openScreenRecordingSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }

    static func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    static func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }
}
