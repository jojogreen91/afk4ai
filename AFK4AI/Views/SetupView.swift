import SwiftUI

struct SetupView: View {
    @EnvironmentObject var appState: AppState
    @State private var hasScreenPermission = false
    @State private var hasAccessibilityPermission = false
    @State private var permissionTimer: Timer?

    private var primary: Color { appState.colorTheme.primary }
    private var status: Color { appState.colorTheme.statusColor }
    private var bannerText: Color { appState.colorTheme.bannerTextColor }
    private var allPermissionsGranted: Bool { hasScreenPermission && hasAccessibilityPermission }

    var body: some View {
        ZStack {
            Theme.backgroundDark.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                    .padding(.top, 40)
                    .padding(.bottom, 32)

                VStack(spacing: 24) {
                    permissionsSection
                    targetWindowSection
                    themeSection
                }
                .padding(.horizontal, 32)

                Spacer(minLength: 0)
                    .frame(maxHeight: 32)
                activateButton
            }
        }
        .frame(width: 500, height: 680)
        .preferredColorScheme(.dark)
        .onAppear {
            appState.refreshWindowList()
            checkPermissions()
            Permissions.preauthorizeScreenCapture()
            permissionTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                checkPermissions()
            }
        }
        .onDisappear {
            permissionTimer?.invalidate()
        }
    }

    private func checkPermissions() {
        hasScreenPermission = Permissions.hasScreenRecordingPermission()
        hasAccessibilityPermission = Permissions.hasAccessibilityPermission()
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 14) {
            HStack(spacing: 0) {
                Text("AFK")
                    .foregroundColor(.white)
                Text("4")
                    .foregroundColor(primary)
                Text("AI")
                    .foregroundColor(.white)
            }
            .font(.system(size: 36, weight: .bold))

            Text("AI 작업 중 화면을 지켜줍니다")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.35))
        }
    }

    // MARK: - Permissions

    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("권한")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))

            VStack(spacing: 0) {
                permissionRow(
                    title: "화면 녹화",
                    granted: hasScreenPermission,
                    action: { Permissions.requestScreenRecordingPermission() }
                )

                Divider().background(Theme.borderDark)

                permissionRow(
                    title: "손쉬운 사용",
                    granted: hasAccessibilityPermission,
                    action: { Permissions.requestAccessibilityPermission() }
                )
            }
            .background(Theme.surfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func permissionRow(title: String, granted: Bool, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.85))

            Spacer()

            if granted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(status)
            } else {
                Button("허용") {
                    action()
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(bannerText)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(primary)
                .clipShape(Capsule())
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Target Window

    private var targetWindowSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("모니터링 대상")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))

            HStack(spacing: 8) {
                Picker("", selection: $appState.selectedWindow) {
                    Text("창을 선택하세요")
                        .tag(nil as WindowInfo?)
                    ForEach(appState.availableWindows) { window in
                        Text(window.displayName)
                            .tag(window as WindowInfo?)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)

                Button {
                    appState.refreshWindowList()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 32, height: 32)
                        .background(Theme.surfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Theme

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("테마")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))

            HStack(spacing: 10) {
                ForEach(ColorTheme.allCases) { theme in
                    ThemeButton(
                        theme: theme,
                        isSelected: appState.colorTheme == theme
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            appState.colorTheme = theme
                        }
                    }
                }
            }
        }
    }

    // MARK: - Activate Button

    private var activateButton: some View {
        VStack(spacing: 8) {
            Button {
                appState.startLock()
            } label: {
                Text("ACTIVATE")
                    .font(.system(size: 16, weight: .bold))
                    .tracking(3)
                    .foregroundColor(bannerText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(primary)
                    )
            }
            .buttonStyle(.plain)
            .disabled(appState.selectedWindow == nil || !allPermissionsGranted)
            .opacity(appState.selectedWindow == nil || !allPermissionsGranted ? 0.3 : 1.0)

            if let error = appState.lockError {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(.red.opacity(0.7))
                    .multilineTextAlignment(.center)
            } else if !allPermissionsGranted {
                Text("권한을 먼저 허용해주세요")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 28)
    }
}

// MARK: - Theme Button

struct ThemeButton: View {
    let theme: ColorTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: theme.swatchColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: isSelected ? 2 : 0)
                )
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
