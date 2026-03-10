import SwiftUI

struct AppSectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: AppLayout.space4) {
            Text(title)
                .font(AppFont.sectionTitle())
                .foregroundStyle(AppColor.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .font(AppFont.caption())
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
    }
}
