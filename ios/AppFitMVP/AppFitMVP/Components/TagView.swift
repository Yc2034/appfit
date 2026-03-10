import SwiftUI

struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(AppFont.tiny())
            .foregroundStyle(AppColor.accent)
            .padding(.horizontal, AppLayout.space8)
            .padding(.vertical, AppLayout.space4)
            .background(
                Capsule()
                    .fill(AppColor.accentSoft)
            )
    }
}
