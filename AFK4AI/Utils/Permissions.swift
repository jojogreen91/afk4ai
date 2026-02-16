import Foundation
import CoreGraphics
import AppKit
import ScreenCaptureKit

enum Permissions {

    // MARK: - Runtime Validation (ACTIVATE 시 1회 호출)

    /// 화면 녹화 권한이 실제로 작동하는지 검증. ACTIVATE 시에만 호출.
    static func validateScreenRecording() async -> Bool {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
            let valid = !content.windows.isEmpty
            print("[Permissions] validateScreen: windows=\(content.windows.count) → \(valid)")
            return valid
        } catch {
            print("[Permissions] validateScreen: \(error.localizedDescription)")
            return false
        }
    }

    /// 손쉬운 사용 권한이 실제로 작동하는지 검증. InputBlocker 시작 실패 시 에러로 처리.
    static func validateAccessibility() -> Bool {
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
        return AXIsProcessTrusted()
    }

    // MARK: - Open Settings

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
}
