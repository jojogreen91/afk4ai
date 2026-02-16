import Foundation
import CoreGraphics
import AppKit
import ScreenCaptureKit

enum Permissions {
    private static var lastScreenPermission: Bool?
    private static var lastAccessibilityPermission: Bool?

    static func hasScreenRecordingPermission() -> Bool {
        let result = CGPreflightScreenCaptureAccess()
        if result != lastScreenPermission {
            print("[Permissions] hasScreenRecordingPermission: \(result)")
            lastScreenPermission = result
        }
        return result
    }

    static func hasAccessibilityPermission() -> Bool {
        let testTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.flagsChanged.rawValue),
            callback: { _, _, event, _ in Unmanaged.passRetained(event) },
            userInfo: nil
        )
        let result: Bool
        if let tap = testTap {
            CFMachPortInvalidate(tap)
            result = true
        } else {
            result = AXIsProcessTrusted()
        }
        if result != lastAccessibilityPermission {
            print("[Permissions] hasAccessibilityPermission: \(result)")
            lastAccessibilityPermission = result
        }
        return result
    }

    /// Validate screen recording permission by actually querying SCShareableContent.
    /// This is the ground truth check — CGPreflightScreenCaptureAccess can lie.
    static func validateScreenRecordingPermission() async -> Bool {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
            let valid = !content.windows.isEmpty
            print("[Permissions] validateScreenRecording: windows=\(content.windows.count) valid=\(valid)")
            return valid
        } catch {
            print("[Permissions] validateScreenRecording failed: \(error.localizedDescription)")
            return false
        }
    }

    static func requestScreenRecordingPermission() {
        // Ad-hoc 서명 앱은 빌드마다 코드 해시가 바뀌어 TCC 엔트리가 stale 됨.
        // 시스템 설정에서 ON으로 보여도 실제로는 작동하지 않으므로 reset 후 재요청.
        resetTCC(service: "ScreenCapture")
        CGRequestScreenCaptureAccess()
    }

    static func requestAccessibilityPermission() {
        // Ad-hoc 서명 앱의 stale TCC 엔트리 초기화 후 재요청
        resetTCC(service: "Accessibility")
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    /// Clear stale TCC entry for ad-hoc signed builds.
    /// Only called when user explicitly requests permission (clicks "허용").
    private static func resetTCC(service: String) {
        let bundleID = Bundle.main.bundleIdentifier ?? "com.afk4ai.AFK4AI"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tccutil")
        process.arguments = ["reset", service, bundleID]
        try? process.run()
        process.waitUntilExit()
        print("[Permissions] TCC \(service) reset for \(bundleID)")
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

    /// Relaunch the app (useful after permission changes that require restart).
    static func relaunchApp() {
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = [url.path]
        try? task.run()
        NSApp.terminate(nil)
    }
}
