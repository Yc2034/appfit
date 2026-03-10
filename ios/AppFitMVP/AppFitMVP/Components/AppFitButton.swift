import SwiftUI

enum AppFitButtonVariant {
    case primary
    case secondary
    case destructive
}

struct AppFitButton: View {
    let title: String
    let icon: String?
    let variant: AppFitButtonVariant
    let action: () -> Void

    init(_ title: String, icon: String? = nil, variant: AppFitButtonVariant = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppLayout.space8) {
                if let icon {
                    Image(systemName: icon)
                        .font(AppFont.caption())
                }
                Text(title)
                    .font(AppFont.bodyStrong())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppLayout.space12)
            .contentShape(Rectangle())
        }
        .buttonStyle(AppFitButtonStyle(variant: variant))
    }
}

private struct AppFitButtonStyle: ButtonStyle {
    let variant: AppFitButtonVariant

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foregroundColor)
            .background(
                RoundedRectangle(cornerRadius: AppLayout.radius14)
                    .fill(backgroundColor.opacity(configuration.isPressed ? 0.8 : 1.0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.radius14)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary:
            return AppColor.textOnAccent
        case .secondary:
            return AppColor.textPrimary
        case .destructive:
            return AppColor.textOnAccent
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary:
            return AppColor.accent
        case .secondary:
            return AppColor.backgroundSecondary
        case .destructive:
            return AppColor.danger
        }
    }

    private var borderColor: Color {
        switch variant {
        case .secondary:
            return AppColor.divider
        default:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        variant == .secondary ? 1 : 0
    }
}
