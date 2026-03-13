import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        TabView(selection: Binding(
            get: { router.selectedTab },
            set: { router.updateSelectedTab($0) }
        )) {
            CourseSearchTabView()
                .tag(AppTab.course)
                .tabItem {
                    Label("课件", systemImage: "square.grid.2x2")
                }

            MovementLibraryTabView()
                .tag(AppTab.movement)
                .tabItem {
                    Label("动作", systemImage: "figure.strengthtraining.traditional")
                }

            ProgressTabView()
                .tag(AppTab.progress)
                .tabItem {
                    Label("数据", systemImage: "chart.bar.xaxis")
                }
        }
        .tint(AppColor.accent)
        .background(AppGradient.subtleBackground.ignoresSafeArea())
    }
}
