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
        // Don't rely on AXIsProcessTrusted alone - it returns stale results
        // with ad-hoc signed apps. Instead, try creating the actual event tap
        // (same type InputBlocker uses) as the ground truth test.
        let testTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.flagsChanged.rawValue),
            callback: { _, _, event, _ in Unmanaged.passRetained(event) },
            userInfo: nil
        )
        if let tap = testTap {
            CFMachPortInvalidate(tap)
            return true
        }
        // Also check AXIsProcessTrusted as a secondary signal
        return AXIsProcessTrusted()
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

    /// Reset stale TCC entry and re-request accessibility permission.
    /// Ad-hoc signed apps get a new code hash on every rebuild, so the old
    /// TCC entry becomes stale (shows ON in System Settings but doesn't work).
    static func requestAccessibilityPermission() {
        // Reset stale TCC entries for our bundle ID so macOS re-evaluates
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tccutil")
        process.arguments = ["reset", "Accessibility", Bundle.main.bundleIdentifier ?? "com.afk4ai.AFK4AI"]
        try? process.run()
        process.waitUntilExit()

        // Now request fresh permission - this will show the system prompt
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }
}
