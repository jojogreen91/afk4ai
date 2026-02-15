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

            VStack(spacing: 0) {
                // Marquee banner
                bannerWithTime

                // System metrics bar (top, prominent)
                MetricsBarView(
                    metrics: appState.systemMetrics,
                    primary: primary
                )

                // Stream area takes maximum space
                streamArea
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                // Compact unlock area
                unlockArea
                    .padding(.bottom, 12)
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

    // MARK: - Banner with Elapsed Time (compact)

    private var bannerWithTime: some View {
        ZStack {
            // Scrolling marquee background
            MarqueeBanner(text: "AFK4AI", textColor: bannerText)

            // Elapsed time overlay (right side)
            HStack {
                Spacer()

                HStack(spacing: 6) {
                    GlowDot(color: bannerText, size: 5, animate: true)
                    Text(formattedElapsed)
                        .font(Theme.mono(13, weight: .bold))
                        .foregroundColor(bannerText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(bannerText.opacity(0.2), lineWidth: 1)
                )
                .padding(.trailing, 12)
            }
        }
        .frame(height: 44)
        .background(primary)
        .shadow(color: primary.opacity(0.3), radius: 15, y: 3)
    }

    // MARK: - Stream Area (maximized)

    private var streamArea: some View {
        ZStack {
            Color(hex: 0x0A0A0A)

            if let image = appState.capturedImage {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .controlSize(.large)
                        .tint(primary)
                    Text("화면 연결 중...")
                        .font(Theme.mono(14))
                        .foregroundColor(.white.opacity(0.3))
                }
            }

            // Subtle scanline
            ScanlineOverlay(opacity: 0.08)

            // Compact status badge
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(status)
                            .frame(width: 5, height: 5)
                        Text("LIVE")
                            .font(Theme.mono(9, weight: .bold))
                            .foregroundColor(status)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Capsule())
                    .padding(10)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(primary.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Unlock Area (compact)

    private var unlockArea: some View {
        VStack(spacing: 6) {
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
                            .font(.system(size: 16))
                    }
                    Text(isAuthenticating ? "인증 중..." : "잠금 해제")
                        .font(Theme.display(13, weight: .bold))
                }
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
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
                Text("인증에 실패했습니다")
                    .font(Theme.display(10))
                    .foregroundColor(.red.opacity(0.7))
            }

            Text("AFK4AI")
                .font(Theme.display(8, weight: .bold))
                .tracking(4)
                .foregroundColor(.white.opacity(0.1))
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
            if let window = NSApplication.shared.windows.first {
                window.toggleFullScreen(nil)
                window.level = .screenSaver
                window.collectionBehavior = [.fullScreenPrimary, .canJoinAllSpaces]
                window.styleMask.remove(.closable)
                window.styleMask.remove(.miniaturizable)
            }
        }
    }

    private func exitFullScreen() {
        if let window = NSApplication.shared.windows.first {
            window.level = .normal
            window.collectionBehavior = [.fullScreenPrimary]
            window.styleMask.insert(.closable)
            window.styleMask.insert(.miniaturizable)
            if window.styleMask.contains(.fullScreen) {
                window.toggleFullScreen(nil)
            }
        }
    }
}
