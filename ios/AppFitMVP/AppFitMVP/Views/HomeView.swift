import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: CourseStore

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("训练课件")
                .searchable(text: $store.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索课程、标签、训练目标")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("刷新") {
                            store.loadCourses()
                        }
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = store.errorMessage {
            ContentUnavailableView("加载失败", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
        } else if store.filteredCourses.isEmpty {
            ContentUnavailableView("暂无课程", systemImage: "doc.text.image", description: Text("请在 courses.json 中添加课程内容"))
        } else {
            List(store.filteredCourses) { course in
                NavigationLink(value: course) {
                    CourseCard(course: course)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            }
            .listStyle(.plain)
        }
    }
}

private struct CourseCard: View {
    let course: FitnessCourse

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LocalImageView(imageName: course.coverImageName, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Text(course.title)
                .font(.headline)
            Text(course.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label(course.focus, systemImage: "target")
                Label("\(course.totalMinutes) 分钟", systemImage: "clock")
                Label(course.level, systemImage: "chart.bar")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
