import SwiftUI

// MARK: - Color Theme

enum ColorTheme: String, CaseIterable, Identifiable {
    case ember   // 기본 붉은색
    case mono    // 블랙 & 화이트
    case ocean   // 어두운 파란색
    case matrix  // 터미널 초록색

    var id: String { rawValue }

    var name: String {
        switch self {
        case .ember:  return "Ember"
        case .mono:   return "Mono"
        case .ocean:  return "Ocean"
        case .matrix: return "Matrix"
        }
    }

    var primary: Color {
        switch self {
        case .ember:  return Color(hex: 0xFF4D00)
        case .mono:   return Color(hex: 0xFFFFFF)
        case .ocean:  return Color(hex: 0x1E40AF)
        case .matrix: return Color(hex: 0x059669)
        }
    }

    var statusColor: Color {
        switch self {
        case .ember:  return Color(hex: 0x00FF41)
        case .mono:   return Color(hex: 0xAAAAAA)
        case .ocean:  return Color(hex: 0x0E7490)
        case .matrix: return Color(hex: 0x34D399)
        }
    }

    /// Banner text color (dark text for bright banners, white for dark)
    var bannerTextColor: Color {
        switch self {
        case .ember:  return .black
        case .mono:   return .black
        case .ocean:  return .white
        case .matrix: return .white
        }
    }

    /// Preview swatch colors for the theme picker
    var swatchColors: [Color] {
        switch self {
        case .ember:  return [Color(hex: 0xFF4D00), Color(hex: 0xFF6B2B)]
        case .mono:   return [Color(hex: 0xFFFFFF), Color(hex: 0x888888)]
        case .ocean:  return [Color(hex: 0x1E40AF), Color(hex: 0x2563EB)]
        case .matrix: return [Color(hex: 0x059669), Color(hex: 0x10B981)]
        }
    }
}

// MARK: - Theme (static helpers)

enum Theme {
    // MARK: - Base Colors (non-themed)
    static let backgroundDark = Color(hex: 0x050505)
    static let surfaceDark = Color(hex: 0x1A1A1A)
    static let borderDark = Color(hex: 0x2D2D2D)

    // MARK: - Fonts
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

// MARK: - Color hex init

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: opacity
        )
    }
}
