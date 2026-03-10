import SwiftUI
import UIKit

struct LocalImageView: View {
    let imageName: String
    var height: CGFloat = 180

    var body: some View {
        if let uiImage = UIImage(named: imageName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(height: height)
                .clipped()
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: AppLayout.radius14)
                    .fill(AppColor.backgroundSecondary)
                VStack(spacing: AppLayout.space8) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(AppFont.sectionTitle())
                        .foregroundStyle(AppColor.textSecondary)
                    Text("图片待补充")
                        .font(AppFont.caption())
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .frame(height: height)
        }
    }
}
