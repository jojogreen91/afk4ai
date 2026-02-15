import SwiftUI

@main
struct AFK4AIApp: App {
    @StateObject private var appState = AppState()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Window("AFK4AI", id: "settings") {
            ContentView()
                .environmentObject(appState)
        }
        .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
        } label: {
            Text("AFK")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        .terminateNow
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isLocked {
                LockScreenView()
            } else {
                SetupView()
            }
        }
    }
}

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        if appState.isLocked {
            Label("Active", systemImage: "lock.fill")
        } else {
            Label("Standby", systemImage: "circle")
        }

        Divider()

        Button {
            openWindow(id: "settings")
            NSApp.activate(ignoringOtherApps: true)
        } label: {
            Label("설정 열기", systemImage: "gear")
        }
        .keyboardShortcut(",", modifiers: .command)

        if appState.isLocked {
            Button {
                appState.attemptUnlock { _ in }
            } label: {
                Label("잠금 해제", systemImage: "touchid")
            }
        } else {
            let hasScreen = Permissions.hasScreenRecordingPermission()
            let hasAccessibility = Permissions.hasAccessibilityPermission()
            let canLock = appState.selectedWindow != nil && hasScreen && hasAccessibility

            Button {
                openWindow(id: "settings")
                NSApp.activate(ignoringOtherApps: true)
                if canLock {
                    appState.startLock()
                }
            } label: {
                if appState.selectedWindow == nil {
                    Label("창을 먼저 선택하세요", systemImage: "macwindow")
                } else if !hasScreen || !hasAccessibility {
                    Label("권한 설정 필요", systemImage: "exclamationmark.triangle")
                } else {
                    Label("잠금 시작", systemImage: "lock.fill")
                }
            }
            .disabled(!canLock)

            if !hasScreen {
                Label("화면 녹화 권한 필요", systemImage: "xmark.circle")
                    .disabled(true)
            }
            if !hasAccessibility {
                Label("손쉬운 사용 권한 필요", systemImage: "xmark.circle")
                    .disabled(true)
            }
        }

        Divider()

        if let window = appState.selectedWindow {
            Label(window.displayName, systemImage: "macwindow")
                .disabled(true)
        }

        Divider()

        Button("종료") {
            if appState.isLocked {
                appState.attemptUnlock { success in
                    if success { NSApp.terminate(nil) }
                }
            } else {
                NSApp.terminate(nil)
            }
        }
    }
}
