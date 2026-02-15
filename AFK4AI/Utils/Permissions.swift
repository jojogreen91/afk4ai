import Foundation
import CoreGraphics
import AppKit
import ScreenCaptureKit

enum Permissions {
    static func hasScreenRecordingPermission() -> Bool {
        // On macOS 14+, CGWindowListCopyWindowInfo returns metadata even without
        // screen recording permission, but CGWindowListCreateImage returns nil.
        // Use CGPreflightScreenCaptureAccess as the sole check to avoid false positives.
        let result = CGPreflightScreenCaptureAccess()
        print("[Permissions] hasScreenRecordingPermission: CGPreflight=\(result)")
        return result
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
        // Reset stale TCC entry for ad-hoc signed apps (same reason as accessibility)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tccutil")
        process.arguments = ["reset", "ScreenCapture", Bundle.main.bundleIdentifier ?? "com.afk4ai.AFK4AI"]
        try? process.run()
        process.waitUntilExit()
        print("[Permissions] TCC ScreenCapture reset, requesting access...")
        CGRequestScreenCaptureAccess()
    }

    /// Pre-trigger screen recording permission dialog via SCShareableContent.
    /// This must be called during setup so the dialog appears before lock activation.
    static func preauthorizeScreenCapture() {
        Task {
            _ = try? await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
        }
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
