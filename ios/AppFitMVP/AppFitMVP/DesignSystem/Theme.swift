import SwiftUI
import UIKit

enum AppColor {
    static let background = Color(light: 0xF4F7FB, dark: 0x0D1117)
    static let backgroundSecondary = Color(light: 0xECF2F8, dark: 0x141A22)
    static let card = Color(light: 0xFFFFFF, dark: 0x1A212B)
    static let cardElevated = Color(light: 0xFFFFFF, dark: 0x202936)

    static let textPrimary = Color(light: 0x101828, dark: 0xE6EDF3)
    static let textSecondary = Color(light: 0x475467, dark: 0x9AA7B6)
    static let textOnAccent = Color(light: 0xFFFFFF, dark: 0xFFFFFF)

    static let accent = Color(light: 0xFF5A36, dark: 0xFF7B5C)
    static let accentDeep = Color(light: 0xDB2F0B, dark: 0xFF5A36)
    static let accentSoft = Color(light: 0xFFE8E2, dark: 0x3B231D)

    static let success = Color(light: 0x14B37D, dark: 0x39D3A0)
    static let warning = Color(light: 0xF59E0B, dark: 0xF7B955)
    static let danger = Color(light: 0xE74C3C, dark: 0xFF7D73)

    static let divider = Color(light: 0xD0D9E5, dark: 0x2B3442)
}

enum AppGradient {
    static let hero = LinearGradient(
        colors: [AppColor.accent, AppColor.accentDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let subtleBackground = LinearGradient(
        colors: [AppColor.background, AppColor.backgroundSecondary],
        startPoint: .top,
        endPoint: .bottom
    )
}

enum AppFont {
    static func heroTitle() -> Font {
        .system(size: 30, weight: .bold, design: .rounded)
    }

    static func title() -> Font {
        .system(size: 22, weight: .bold, design: .rounded)
    }

    static func sectionTitle() -> Font {
        .system(size: 18, weight: .semibold, design: .rounded)
    }

    static func headline() -> Font {
        .system(size: 16, weight: .semibold, design: .rounded)
    }

    static func body() -> Font {
        .system(size: 15, weight: .regular, design: .rounded)
    }

    static func bodyStrong() -> Font {
        .system(size: 15, weight: .semibold, design: .rounded)
    }

    static func caption() -> Font {
        .system(size: 13, weight: .medium, design: .rounded)
    }

    static func tiny() -> Font {
        .system(size: 12, weight: .medium, design: .rounded)
    }
}

enum AppLayout {
    static let space4: CGFloat = 4
    static let space8: CGFloat = 8
    static let space10: CGFloat = 10
    static let space12: CGFloat = 12
    static let space16: CGFloat = 16
    static let space20: CGFloat = 20

    static let radius10: CGFloat = 10
    static let radius14: CGFloat = 14
    static let radius18: CGFloat = 18

    static let cardPadding: CGFloat = 14
    static let screenPadding: CGFloat = 16
}

private extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }

    static func dynamic(light: Int, dark: Int) -> UIColor {
        UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(hex: dark)
            }
            return UIColor(hex: light)
        }
    }
}

private extension Color {
    init(light: Int, dark: Int) {
        self.init(uiColor: UIColor.dynamic(light: light, dark: dark))
    }
}
