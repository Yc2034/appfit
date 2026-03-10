import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            CourseSearchTabView()
                .tabItem {
                    Label("课件", systemImage: "square.grid.2x2")
                }

            MovementLibraryTabView()
                .tabItem {
                    Label("动作", systemImage: "figure.strengthtraining.traditional")
                }

            ProgressTabView()
                .tabItem {
                    Label("数据", systemImage: "chart.bar.xaxis")
                }
        }
        .tint(AppColor.accent)
        .background(AppGradient.subtleBackground.ignoresSafeArea())
    }
}
