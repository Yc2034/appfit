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
            .navigationTitle("课件")
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
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: AppLayout.space12) {
                    CourseTagFilterBar(
                        tags: store.availableTags,
                        selectedTags: store.selectedTags,
                        onToggle: store.toggleTag(_:),
                        onClear: store.clearTagFilter
                    )

                    if store.filteredCourses.isEmpty {
                        ContentUnavailableView(
                            "暂无匹配课程",
                            systemImage: "line.3.horizontal.decrease.circle",
                            description: Text("请切换标签筛选条件")
                        )
                        .frame(maxWidth: .infinity, minHeight: 240)
                    } else {
                        LazyVStack(spacing: AppLayout.space12) {
                            ForEach(store.filteredCourses) { course in
                                NavigationLink(value: course) {
                                    CourseCard(course: course)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, AppLayout.screenPadding)
                .padding(.vertical, AppLayout.space8)
            }
        }
    }
}

private struct CourseTagFilterBar: View {
    let tags: [String]
    let selectedTags: Set<String>
    let onToggle: (String) -> Void
    let onClear: () -> Void

    var body: some View {
        AppFitCard {
            VStack(alignment: .leading, spacing: AppLayout.space10) {
                HStack {
                    Text("按标签筛选")
                        .font(AppFont.headline())
                        .foregroundStyle(AppColor.textPrimary)

                    Spacer()

                    if !selectedTags.isEmpty {
                        Button("清除") {
                            onClear()
                        }
                        .font(AppFont.caption())
                        .foregroundStyle(AppColor.accent)
                    }
                }

                if tags.isEmpty {
                    Text("暂无标签")
                        .font(AppFont.caption())
                        .foregroundStyle(AppColor.textSecondary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppLayout.space8) {
                            ForEach(tags, id: \.self) { tag in
                                FilterChip(
                                    text: tag,
                                    isSelected: selectedTags.contains(tag)
                                ) {
                                    onToggle(tag)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct FilterChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(AppFont.tiny())
                .foregroundStyle(isSelected ? AppColor.textOnAccent : AppColor.accent)
                .padding(.horizontal, AppLayout.space10)
                .padding(.vertical, AppLayout.space8)
                .background(
                    Capsule()
                        .fill(isSelected ? AppColor.accent : AppColor.accentSoft)
                )
        }
        .buttonStyle(.plain)
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
