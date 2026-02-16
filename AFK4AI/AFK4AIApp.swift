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
    private var l: L { appState.l }

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
            Label(l.openSettings, systemImage: "gear")
        }
        .keyboardShortcut(",", modifiers: .command)

        if appState.isLocked {
            Button {
                appState.attemptUnlock { _ in }
            } label: {
                Label(l.unlock, systemImage: "touchid")
            }
        } else {
            // 메뉴바에서는 동기 힌트로 CGPreflight 사용 (실제 검증은 startLock에서 async로)
            let hasScreen = CGPreflightScreenCaptureAccess()
            let hasAccessibility = Permissions.hasAccessibilityPermission()
            let canLock = appState.selectedWindow != nil && hasScreen && hasAccessibility

            Button {
                openWindow(id: "settings")
                NSApp.activate(ignoringOtherApps: true)
                if canLock {
                    Task { await appState.startLock() }
                }
            } label: {
                if appState.selectedWindow == nil {
                    Label(l.selectWindowFirst, systemImage: "macwindow")
                } else if !hasScreen || !hasAccessibility {
                    Label(l.permissionsRequired, systemImage: "exclamationmark.triangle")
                } else {
                    Label(l.startLock, systemImage: "lock.fill")
                }
            }
            .disabled(!canLock)

            if !hasScreen {
                Label(l.screenRecordingRequired, systemImage: "xmark.circle")
                    .disabled(true)
            }
            if !hasAccessibility {
                Label(l.accessibilityRequired, systemImage: "xmark.circle")
                    .disabled(true)
            }
        }

        Divider()

        if let window = appState.selectedWindow {
            Label(window.displayName, systemImage: "macwindow")
                .disabled(true)
        }

        Divider()

        Button(l.quit) {
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
