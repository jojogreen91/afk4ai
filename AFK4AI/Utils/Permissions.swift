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
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false] as CFDictionary
        if AXIsProcessTrustedWithOptions(options) {
            return true
        }
        // Fallback: AXIsProcessTrusted can return stale false on ad-hoc signed apps
        // after rebuild (DerivedData path changes). Try creating a minimal event tap
        // to verify actual permission.
        let testTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: CGEventMask(1 << CGEventType.flagsChanged.rawValue),
            callback: { _, _, event, _ in Unmanaged.passRetained(event) },
            userInfo: nil
        )
        if let tap = testTap {
            CFMachPortInvalidate(tap)
            return true
        }
        return false
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
        // Also open settings directly in case the prompt doesn't appear
        // (can happen when Input Monitoring is granted but not Accessibility)
        openAccessibilitySettings()
    }
}
