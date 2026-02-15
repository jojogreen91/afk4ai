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
            Button {
                let hasPermissions = Permissions.hasScreenRecordingPermission() && Permissions.hasAccessibilityPermission()
                if appState.selectedWindow != nil && hasPermissions {
                    appState.startLock()
                } else {
                    openWindow(id: "settings")
                    NSApp.activate(ignoringOtherApps: true)
                }
            } label: {
                Label(
                    appState.selectedWindow != nil ? "잠금 시작" : "창을 먼저 선택하세요",
                    systemImage: "lock.fill"
                )
            }
            .disabled(appState.selectedWindow == nil)
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
