import SwiftUI

struct SetupView: View {
    @EnvironmentObject var appState: AppState
    @State private var hasScreenPermission = false
    @State private var hasAccessibilityPermission = false
    @State private var permissionTimer: Timer?

    private var primary: Color { appState.colorTheme.primary }
    private var status: Color { appState.colorTheme.statusColor }
    private var allPermissionsGranted: Bool { hasScreenPermission && hasAccessibilityPermission }

    var body: some View {
        ZStack {
            Theme.backgroundDark.ignoresSafeArea()

            // Dot grid
            Canvas { context, size in
                let spacing: CGFloat = 40
                for x in stride(from: 0, through: size.width, by: spacing) {
                    for y in stride(from: 0, through: size.height, by: spacing) {
                        let rect = CGRect(x: x - 0.5, y: y - 0.5, width: 1, height: 1)
                        context.fill(Path(ellipseIn: rect), with: .color(primary.opacity(0.08)))
                    }
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                    .padding(.top, 28)
                    .padding(.bottom, 20)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        permissionsSection
                        targetWindowSection
                        themeSection
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 110)
                }

                Spacer(minLength: 0)
                activateButton
            }
        }
        .frame(width: 540, height: 620)
        .onAppear {
            appState.refreshWindowList()
            checkPermissions()
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
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(primary)
                        .frame(width: 42, height: 42)
                        .shadow(color: primary.opacity(0.3), radius: 12)
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 0) {
                        Text("AFK")
                            .font(Theme.display(26, weight: .bold))
                            .foregroundColor(.white)
                        Text("4")
                            .font(Theme.display(26, weight: .bold))
                            .foregroundColor(primary)
                        Text("AI")
                            .font(Theme.display(26, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text("AI 작업 중 화면을 지켜줍니다")
                        .font(Theme.display(11, weight: .medium))
                        .foregroundColor(.white.opacity(0.35))
                }
            }

            HStack(spacing: 6) {
                GlowDot(color: allPermissionsGranted ? status : Color.yellow, size: 6, animate: true)
                Text(allPermissionsGranted ? "SYSTEM READY" : "PERMISSIONS REQUIRED")
                    .font(Theme.display(10, weight: .bold))
                    .tracking(1)
                    .foregroundColor(allPermissionsGranted ? status : .yellow)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background((allPermissionsGranted ? status : Color.yellow).opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke((allPermissionsGranted ? status : Color.yellow).opacity(0.2), lineWidth: 1)
            )
            .clipShape(Capsule())
        }
    }

    // MARK: - Permissions

    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "key.fill", title: "Required Permissions", color: primary)

            VStack(spacing: 0) {
                permissionRow(
                    icon: "record.circle",
                    title: "화면 녹화",
                    description: "선택한 창의 실시간 화면을 캡처합니다",
                    granted: hasScreenPermission,
                    action: { Permissions.openScreenRecordingSettings() }
                )

                Divider().background(Theme.borderDark)

                permissionRow(
                    icon: "hand.raised.fill",
                    title: "손쉬운 사용",
                    description: "잠금 중 키보드/마우스 입력을 차단합니다",
                    granted: hasAccessibilityPermission,
                    action: { Permissions.requestAccessibilityPermission() }
                )
            }
            .background(Theme.surfaceDark)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Theme.borderDark, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func permissionRow(icon: String, title: String, description: String, granted: Bool, action: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(primary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.display(14, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                Text(description)
                    .font(Theme.display(11))
                    .foregroundColor(.white.opacity(0.35))
            }

            Spacer()

            if granted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(status)
            } else {
                Button("허용") {
                    action()
                }
                .font(Theme.display(12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(primary)
                .clipShape(Capsule())
                .buttonStyle(.plain)
            }
        }
        .padding(14)
    }

    // MARK: - Target Window

    private var targetWindowSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "scope", title: "Target Window", color: primary)

            VStack(alignment: .leading, spacing: 12) {
                Text("모니터링할 창 선택")
                    .font(Theme.display(14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                HStack(spacing: 8) {
                    Picker("", selection: $appState.selectedWindow) {
                        Text("-- 모니터링할 창을 선택하세요 --")
                            .foregroundColor(.white.opacity(0.5))
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
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 34, height: 34)
                            .background(Theme.backgroundDark)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Theme.borderDark, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 11))
                    Text("선택한 창이 잠금 화면에 실시간 스트리밍됩니다")
                        .font(Theme.display(11))
                }
                .foregroundColor(.white.opacity(0.3))
            }
            .padding(16)
            .background(Theme.surfaceDark)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Theme.borderDark, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Theme

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "paintpalette.fill", title: "Theme", color: primary)

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
            .padding(16)
            .background(Theme.surfaceDark)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Theme.borderDark, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Activate Button

    private var activateButton: some View {
        VStack(spacing: 8) {
            Button {
                appState.startLock()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18, weight: .bold))
                    Text("ACTIVATE")
                        .font(Theme.display(18, weight: .black))
                        .tracking(4)
                }
                .foregroundColor(appState.colorTheme.bannerTextColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(primary)
                        .shadow(color: primary.opacity(0.4), radius: 20)
                )
            }
            .buttonStyle(.plain)
            .disabled(appState.selectedWindow == nil || !allPermissionsGranted)
            .opacity(appState.selectedWindow == nil || !allPermissionsGranted ? 0.35 : 1.0)

            if !allPermissionsGranted {
                Text("위 권한을 먼저 허용해주세요")
                    .font(Theme.display(10, weight: .medium))
                    .foregroundColor(.yellow.opacity(0.5))
            }
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 24)
    }
}

// MARK: - Theme Button

struct ThemeButton: View {
    let theme: ColorTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: theme.swatchColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 40)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(theme.bannerTextColor)
                    }
                }

                Text(theme.name.uppercased())
                    .font(Theme.display(10, weight: .bold))
                    .tracking(1)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(isSelected ? theme.primary.opacity(0.1) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? theme.primary.opacity(0.5) : Theme.borderDark, lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
