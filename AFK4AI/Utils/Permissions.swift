import Foundation
import CoreGraphics
import AppKit
import ScreenCaptureKit

enum Permissions {
    private static var lastAccessibilityPermission: Bool?
    private static var accessibilityCheckCount = 0

    // MARK: - Screen Recording (SCShareableContent 기반)

    /// SCShareableContent로 화면 녹화 권한을 검증한다.
    /// macOS 15에서 CGPreflightScreenCaptureAccess()는 신뢰할 수 없으므로
    /// 실제 SCShareableContent 호출 결과를 ground truth로 사용.
    static func checkScreenRecordingPermission() async -> Bool {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
            let granted = !content.windows.isEmpty
            print("[Permissions] screenCheck: SCShareableContent windows=\(content.windows.count) → granted=\(granted)")
            return granted
        } catch {
            print("[Permissions] screenCheck: SCShareableContent error=\(error.localizedDescription) → denied")
            return false
        }
    }

    /// 화면 녹화 권한을 요청한다.
    /// macOS 15에서는 SCShareableContent 호출이 시스템 다이얼로그를 트리거한다.
    /// 이미 거부된 경우 다이얼로그가 안 뜨므로 시스템 설정을 연다.
    static func requestScreenRecordingPermission() async {
        print("[Permissions] requestScreenRecording: trying SCShareableContent...")
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
            if !content.windows.isEmpty {
                print("[Permissions] requestScreenRecording: already granted! windows=\(content.windows.count)")
                return
            }
            // 빈 윈도우 목록 = 권한 거부됨, 시스템 설정으로 이동
            print("[Permissions] requestScreenRecording: empty windows, opening System Settings...")
            openScreenRecordingSettings()
        } catch {
            // 에러 = 권한 거부 또는 최초 요청 시 다이얼로그 표시됨
            // macOS가 다이얼로그를 띄운 경우 에러로 반환하므로 잠시 대기 후 재확인
            print("[Permissions] requestScreenRecording: SCShareableContent threw error=\(error.localizedDescription)")
            print("[Permissions] requestScreenRecording: opening System Settings as fallback...")
            openScreenRecordingSettings()
        }
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

        if result != lastAccessibilityPermission || accessibilityCheckCount % 5 == 1 {
            print("[Permissions] accessibilityCheck #\(accessibilityCheckCount): AXTrusted=\(axTrusted) tapWorks=\(tapWorks) → \(result)")
            lastAccessibilityPermission = result
        }
        return result
    }

    static func requestAccessibilityPermission() {
        print("[Permissions] requestAccessibility START")
        // Ad-hoc 서명 앱의 stale TCC 엔트리 초기화
        resetTCC(service: "Accessibility")
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let result = AXIsProcessTrustedWithOptions(options)
        print("[Permissions] requestAccessibility: AXIsProcessTrustedWithOptions=\(result)")
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
