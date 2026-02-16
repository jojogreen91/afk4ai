import SwiftUI

struct LockScreenView: View {
    @EnvironmentObject var appState: AppState
    @State private var isAuthenticating = false
    @State private var authFailed = false
    @State private var elapsedSeconds: Int = 0
    @State private var elapsedTimer: Timer?

    private var primary: Color { appState.colorTheme.primary }
    private var status: Color { appState.colorTheme.statusColor }
    private var bannerText: Color { appState.colorTheme.bannerTextColor }
    private var l: L { appState.l }

    var body: some View {
        ZStack {
            Theme.backgroundDark.ignoresSafeArea()

            // Ambient glow
            Circle()
                .fill(primary.opacity(0.03))
                .frame(width: 500, height: 500)
                .blur(radius: 150)
                .offset(x: -250, y: -200)

            Circle()
                .fill(primary.opacity(0.03))
                .frame(width: 500, height: 500)
                .blur(radius: 150)
                .offset(x: 250, y: 200)

            VStack(spacing: 12) {
                // Marquee banner
                marqueeBanner

                // System metrics bar with elapsed time
                MetricsBarView(
                    metrics: appState.systemMetrics,
                    primary: primary,
                    elapsedTime: formattedElapsed
                )

                // Stream area
                streamArea
                    .padding(.horizontal, 16)

                // Unlock area
                unlockArea
                    .padding(.vertical, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            enterFullScreen()
            startElapsedTimer()
        }
        .onDisappear {
            exitFullScreen()
            stopElapsedTimer()
        }
    }

    // MARK: - Marquee Banner

    private var marqueeBanner: some View {
        MarqueeBanner(text: "AFK4AI", textColor: bannerText)
            .frame(height: 56)
            .background(primary)
            .shadow(color: primary.opacity(0.3), radius: 15, y: 3)
    }

    // MARK: - Stream Area

    private var streamArea: some View {
        ZStack {
            Color(hex: 0x0A0A0A)

            if let image = appState.capturedImage {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if let error = appState.captureError {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 32))
                        .foregroundColor(.red.opacity(0.6))
                    Text(error)
                        .font(Theme.mono(12))
                        .foregroundColor(.red.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .controlSize(.large)
                        .tint(primary)
                    Text(l.connecting)
                        .font(Theme.mono(14))
                        .foregroundColor(.white.opacity(0.3))
                }
            }

            // Subtle scanline
            ScanlineOverlay(opacity: 0.08)

            // Compact status badge
            VStack {
                HStack {
                    LiveBadge(color: status)
                        .padding(10)
                    Spacer()
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Unlock Area

    private var unlockArea: some View {
        VStack(spacing: 10) {
            Button {
                guard !isAuthenticating else { return }
                isAuthenticating = true
                authFailed = false

                appState.attemptUnlock { success in
                    isAuthenticating = false
                    if !success {
                        authFailed = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            authFailed = false
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if isAuthenticating {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    } else {
                        Image(systemName: "touchid")
                            .font(.system(size: 18))
                    }
                    Text(isAuthenticating ? l.authenticating : l.unlock)
                        .font(Theme.display(14, weight: .bold))
                }
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .disabled(isAuthenticating)

            if authFailed {
                Text(l.authFailed)
                    .font(Theme.display(11))
                    .foregroundColor(.red.opacity(0.7))
            }

            Button {
                appState.stopLock()
            } label: {
                Text(l.emergencyExit)
                    .font(Theme.display(10, weight: .medium))
                    .foregroundColor(.white.opacity(0.2))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
    }

    // MARK: - Helpers

    private var formattedElapsed: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func startElapsedTimer() {
        elapsedSeconds = 0
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    private func stopElapsedTimer() {
        elapsedTimer?.invalidate()
        elapsedTimer = nil
    }

    private func enterFullScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let window = NSApp.keyWindow ?? NSApplication.shared.windows.first(where: { $0.isVisible && !$0.className.contains("StatusBar") }),
                  let screen = window.screen ?? NSScreen.main else { return }

            // Don't use toggleFullScreen — it creates a new Space,
            // isolating the target window and breaking screen capture.
            window.styleMask = [.borderless]
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .stationary]
            window.setFrame(screen.frame, display: true)
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            NSApp.presentationOptions = [.hideDock, .hideMenuBar]
        }
    }

    private func exitFullScreen() {
        guard let window = NSApp.keyWindow ?? NSApplication.shared.windows.first(where: { $0.isVisible && !$0.className.contains("StatusBar") }) else { return }

        NSApp.presentationOptions = []
        window.level = .normal
        window.collectionBehavior = []
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setFrame(NSRect(x: 200, y: 200, width: 540, height: 740), display: true)
        window.center()
    }
}
