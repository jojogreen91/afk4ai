import SwiftUI

struct SetupView: View {
    @EnvironmentObject var appState: AppState

    private var primary: Color { appState.colorTheme.primary }
    private var status: Color { appState.colorTheme.statusColor }
    private var bannerText: Color { appState.colorTheme.bannerTextColor }
    private var l: L { appState.l }

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
        .overlay(alignment: .topTrailing) {
            languageToggle
                .padding(.trailing, 24)
                .padding(.top, 16)
        }
        .frame(width: 500, height: 680)
        .preferredColorScheme(.dark)
        .onAppear {
            appState.refreshWindowList()
        }
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

            Text(l.subtitle)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.35))
        }
    }

    // MARK: - Permissions

    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(l.permissions)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))

            VStack(spacing: 0) {
                settingsRow(
                    title: l.screenRecording,
                    action: { Permissions.openScreenRecordingSettings() }
                )

                Divider().background(Theme.borderDark)

                settingsRow(
                    title: l.accessibility,
                    action: { Permissions.openAccessibilitySettings() }
                )
            }
            .background(Theme.surfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func settingsRow(title: String, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.85))

            Spacer()

            Button {
                action()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "gear")
                        .font(.system(size: 11))
                    Text(l.openSettings)
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Target Window

    private var targetWindowSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(l.monitorTarget)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))

            HStack(spacing: 8) {
                Picker("", selection: $appState.selectedWindow) {
                    Text(l.selectWindow)
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
            Text(l.theme)
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

    // MARK: - Language Toggle

    private var languageToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                appState.language = appState.language == .ko ? .en : .ko
            }
        } label: {
            HStack(spacing: 0) {
                Text("한")
                    .foregroundColor(appState.language == .ko ? .white : .white.opacity(0.3))
                Text(" / ")
                    .foregroundColor(.white.opacity(0.2))
                Text("EN")
                    .foregroundColor(appState.language == .en ? .white : .white.opacity(0.3))
            }
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
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
            .disabled(appState.selectedWindow == nil)
            .opacity(appState.selectedWindow == nil ? 0.3 : 1.0)

            if let error = appState.lockError {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(.red.opacity(0.7))
                    .multilineTextAlignment(.center)
            } else if appState.selectedWindow == nil {
                Text(l.selectWindow)
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
