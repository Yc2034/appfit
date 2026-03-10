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
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))
                VStack(spacing: 8) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                    Text("图片待补充")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: height)
        }
    }
}
