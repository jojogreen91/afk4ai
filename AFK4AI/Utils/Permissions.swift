import Foundation
import CoreGraphics
import AppKit
import ScreenCaptureKit

enum Permissions {
    private static var lastScreenPermission: Bool?
    private static var lastAccessibilityPermission: Bool?
    private static var screenCheckCount = 0
    private static var accessibilityCheckCount = 0

    // MARK: - Screen Recording

    /// 폴링용 동기 체크. 다이얼로그를 트리거하지 않는다.
    static func hasScreenRecordingPermission() -> Bool {
        screenCheckCount += 1
        let result = CGPreflightScreenCaptureAccess()
        if result != lastScreenPermission || screenCheckCount % 10 == 1 {
            print("[Permissions] screenCheck #\(screenCheckCount): CGPreflight=\(result)")
            lastScreenPermission = result
        }
        return result
    }

    /// 잠금 진입 전 실제 검증. SCShareableContent로 ground truth 확인.
    static func validateScreenRecordingPermission() async -> Bool {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
            let valid = !content.windows.isEmpty
            print("[Permissions] validateScreen: windows=\(content.windows.count) → \(valid)")
            return valid
        } catch {
            print("[Permissions] validateScreen: error=\(error.localizedDescription)")
            return false
        }
    }

    /// "허용" 버튼 클릭 시 호출. stale TCC 초기화 후 권한 요청.
    static func requestScreenRecordingPermission() {
        print("[Permissions] requestScreen: resetting stale TCC then requesting...")
        resetTCC(service: "ScreenCapture")
        // SCShareableContent가 아닌 CGRequestScreenCaptureAccess 사용하지 않음 (macOS 15에서 무반응)
        // tccutil reset 후 시스템 설정을 열어서 사용자가 직접 토글
        openScreenRecordingSettings()
    }

    // MARK: - Accessibility

    static func hasAccessibilityPermission() -> Bool {
        accessibilityCheckCount += 1
        let axTrusted = AXIsProcessTrusted()
        let testTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.flagsChanged.rawValue),
            callback: { _, _, event, _ in Unmanaged.passRetained(event) },
            userInfo: nil
        )
        let tapWorks: Bool
        if let tap = testTap {
            CFMachPortInvalidate(tap)
            tapWorks = true
        } else {
            tapWorks = false
        }
        let result = tapWorks || axTrusted

        if result != lastAccessibilityPermission || accessibilityCheckCount % 10 == 1 {
            print("[Permissions] accessibilityCheck #\(accessibilityCheckCount): AXTrusted=\(axTrusted) tapWorks=\(tapWorks) → \(result)")
            lastAccessibilityPermission = result
        }
        return result
    }

    static func requestAccessibilityPermission() {
        print("[Permissions] requestAccessibility: resetting stale TCC then requesting...")
        resetTCC(service: "Accessibility")
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    // MARK: - Helpers

    private static func resetTCC(service: String) {
        let bundleID = Bundle.main.bundleIdentifier ?? "com.afk4ai.AFK4AI"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tccutil")
        process.arguments = ["reset", service, bundleID]
        try? process.run()
        process.waitUntilExit()
        print("[Permissions] tccutil reset \(service) done")
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
