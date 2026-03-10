import SwiftUI

struct CourseSearchTabView: View {
    @EnvironmentObject private var store: CourseStore

    var body: some View {
        NavigationStack {
            ZStack {
                AppGradient.subtleBackground
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("搜索课件")
            .searchable(text: $store.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索课程、标签、训练目标")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("刷新") {
                        store.loadCourses()
                    }
                    .font(AppFont.caption())
                }
            }
            .navigationDestination(for: FitnessCourse.self) { course in
                CourseDetailView(course: course)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if store.isLoading {
            ProgressView("加载课程中...")
                .font(AppFont.body())
                .tint(AppColor.accent)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = store.errorMessage {
            ContentUnavailableView("加载失败", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
        } else if store.filteredCourses.isEmpty {
            ContentUnavailableView("暂无课程", systemImage: "doc.text.image", description: Text("请在 courses.json 中添加课程内容"))
        } else {
            List(store.filteredCourses) { course in
                NavigationLink(value: course) {
                    CourseCard(course: course)
                        .padding(.vertical, AppLayout.space4)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: AppLayout.space4, leading: AppLayout.screenPadding, bottom: AppLayout.space4, trailing: AppLayout.screenPadding))
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        }
    }
}

private struct CourseCard: View {
    let course: FitnessCourse

    var body: some View {
        AppFitCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppLayout.space12) {
                LocalImageView(imageName: course.coverImageName, height: 168)
                    .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius14))

                Text(course.title)
                    .font(AppFont.sectionTitle())
                    .foregroundStyle(AppColor.textPrimary)

                Text(course.subtitle)
                    .font(AppFont.body())
                    .foregroundStyle(AppColor.textSecondary)

                HStack(spacing: AppLayout.space8) {
                    TagView(text: course.focus)
                    TagView(text: "\(course.totalMinutes) 分钟")
                    TagView(text: course.level)
                }
            }
        }
    }
}
