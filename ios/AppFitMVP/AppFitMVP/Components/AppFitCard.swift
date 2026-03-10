import SwiftUI

enum AppFitCardStyle {
    case standard
    case elevated
}

struct AppFitCard<Content: View>: View {
    let style: AppFitCardStyle
    let content: Content

    init(style: AppFitCardStyle = .standard, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppLayout.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppLayout.radius18)
                    .fill(style == .elevated ? AppColor.cardElevated : AppColor.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppLayout.radius18)
                            .stroke(AppColor.divider.opacity(0.35), lineWidth: 1)
                    )
            )
    }
}
