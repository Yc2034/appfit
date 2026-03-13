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
            .navigationDestination(for: CourseSessionRoute.self) { route in
                SessionPlayerView(
                    courseID: route.courseID,
                    courseTitle: route.courseTitle,
                    session: route.session
                )
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
                VStack(alignment: .leading, spacing: AppLayout.space16) {
                    if let continueContext = store.continueContext {
                        NavigationLink(
                            value: CourseSessionRoute(
                                courseID: continueContext.course.id,
                                courseTitle: continueContext.course.title,
                                session: continueContext.session
                            )
                        ) {
                            ContinueCourseCard(context: continueContext)
                        }
                        .buttonStyle(CourseCardButtonStyle())
                    }

                    CourseTagFilterBar(tags: store.availableTags, selectedTag: store.selectedTag) { tag in
                        store.toggleTag(tag)
                    }

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
                                ZStack(alignment: .topTrailing) {
                                    NavigationLink(value: course) {
                                        CourseCard(
                                            course: course,
                                            statusText: store.statusText(for: course),
                                            progressText: store.progressText(for: course),
                                            progressValue: store.progress(for: course)
                                        )
                                    }
                                    .buttonStyle(CourseCardButtonStyle())

                                    Button {
                                        store.toggleFavorite(for: course)
                                    } label: {
                                        Image(systemName: store.isFavorite(course) ? "star.fill" : "star")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(store.isFavorite(course) ? AppColor.textOnAccent : AppColor.textSecondary)
                                            .frame(width: 34, height: 34)
                                            .background(
                                                Circle()
                                                    .fill(
                                                        store.isFavorite(course)
                                                        ? AnyShapeStyle(AppGradient.hero)
                                                        : AnyShapeStyle(AppColor.card.opacity(0.94))
                                                    )
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(AppColor.divider.opacity(store.isFavorite(course) ? 0.0 : 0.5), lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(CoursePressableButtonStyle(pressedScale: 0.9))
                                    .padding(AppLayout.space10)
                                    .shadow(
                                        color: store.isFavorite(course) ? AppColor.accent.opacity(0.24) : Color.black.opacity(0.05),
                                        radius: store.isFavorite(course) ? 12 : 6,
                                        y: store.isFavorite(course) ? 8 : 4
                                    )
                                    .animation(.spring(response: 0.28, dampingFraction: 0.8), value: store.isFavorite(course))
                                    .zIndex(1)
                                }
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
    let selectedTag: String?
    let onToggle: (String?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppLayout.space8) {
                CourseFilterChip(title: "全部", isActive: selectedTag == nil) {
                    onToggle(nil)
                }

                ForEach(tags, id: \.self) { tag in
                    CourseFilterChip(title: tag, isActive: selectedTag == tag) {
                        onToggle(tag)
                    }
                }
            }
            .padding(.vertical, AppLayout.space4)
        }
    }
}

private struct ContinueCourseCard: View {
    let context: CourseContinueContext

    var body: some View {
        AppFitCard(style: .elevated) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: AppLayout.radius18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColor.accent.opacity(0.16),
                                AppColor.success.opacity(0.12),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Circle()
                            .fill(AppColor.accent.opacity(0.14))
                            .frame(width: 160, height: 160)
                            .blur(radius: 16)
                            .offset(x: 108, y: -74)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppLayout.radius18, style: .continuous)
                            .stroke(Color.white.opacity(0.34), lineWidth: 1)
                    )

                HStack(spacing: AppLayout.space12) {
                    VStack(alignment: .leading, spacing: AppLayout.space10) {
                        Text("继续上次课程")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColor.accent)

                        Text(context.course.title)
                            .font(AppFont.title())
                            .foregroundStyle(AppColor.textPrimary)
                            .lineLimit(2)

                        Text(context.session.title)
                            .font(AppFont.body())
                            .foregroundStyle(AppColor.textSecondary)
                            .lineLimit(1)

                        ProgressView(value: context.progressValue)
                            .tint(AppColor.accent)

                        HStack(spacing: AppLayout.space10) {
                            CourseMetaPill(text: "\(context.completedSessions)/\(context.course.sessionCount) 节", style: .soft)
                            CourseMetaPill(text: "\(Int(context.progressValue * 100))%", style: .soft)
                        }
                    }

                    Spacer(minLength: 0)

                    VStack(spacing: AppLayout.space8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(AppColor.textOnAccent)
                            .frame(width: 52, height: 52)
                            .background(AppGradient.hero, in: Circle())

                        Text("继续")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
                .padding(AppLayout.space16)
            }
        }
        .shadow(color: AppColor.accent.opacity(0.12), radius: 16, y: 8)
    }
}

private struct CourseFilterChip: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppLayout.space8) {
                Circle()
                    .fill(isActive ? AnyShapeStyle(Color.white.opacity(0.92)) : AnyShapeStyle(AppColor.accent.opacity(0.18)))
                    .frame(width: 6, height: 6)

                Text(title)
                    .font(AppFont.tiny())
            }
            .foregroundStyle(isActive ? AppColor.textOnAccent : AppColor.textSecondary)
            .padding(.horizontal, AppLayout.space12)
            .padding(.vertical, AppLayout.space10)
            .background(
                Capsule()
                    .fill(isActive ? AnyShapeStyle(AppGradient.hero) : AnyShapeStyle(AppColor.card.opacity(0.94)))
            )
            .overlay(
                Capsule()
                    .stroke(isActive ? AppColor.accent.opacity(0.0) : AppColor.divider.opacity(0.65), lineWidth: 1)
            )
            .scaleEffect(isActive ? 1.0 : 0.97)
        }
        .buttonStyle(CoursePressableButtonStyle(pressedScale: 0.96))
        .shadow(color: isActive ? AppColor.accent.opacity(0.22) : Color.black.opacity(0.04), radius: isActive ? 12 : 6, y: isActive ? 8 : 4)
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isActive)
    }
}

private struct CourseCard: View {
    let course: FitnessCourse
    let statusText: String?
    let progressText: String
    let progressValue: Double

    var body: some View {
        AppFitCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppLayout.space12) {
                ZStack(alignment: .bottomLeading) {
                    LocalImageView(imageName: course.coverImageName, height: 182)
                        .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius14))

                    LinearGradient(
                        colors: [Color.black.opacity(0.0), Color.black.opacity(0.46)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius14))

                    VStack(alignment: .leading, spacing: AppLayout.space8) {
                        if let statusText {
                            CourseMetaPill(text: statusText, style: .accent)
                        }

                        Text(course.focus)
                            .font(AppFont.caption())
                            .foregroundStyle(Color.white.opacity(0.88))
                    }
                    .padding(AppLayout.space12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }

                Text(course.title)
                    .font(AppFont.sectionTitle())
                    .foregroundStyle(AppColor.textPrimary)

                Text(course.subtitle)
                    .font(AppFont.body())
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(2)

                HStack(spacing: AppLayout.space8) {
                    CourseInfoTag(text: "\(course.totalMinutes) 分钟", systemImage: "clock")
                    CourseInfoTag(text: "\(course.sessionCount) 节", systemImage: "list.bullet.rectangle")
                    CourseInfoTag(text: course.level, systemImage: "figure.run")
                }

                VStack(alignment: .leading, spacing: AppLayout.space8) {
                    HStack {
                        Text(progressText)
                            .font(AppFont.caption())
                            .foregroundStyle(AppColor.textSecondary)
                        Spacer()
                        Text("\(Int(progressValue * 100))%")
                            .font(AppFont.caption())
                            .foregroundStyle(AppColor.textSecondary)
                    }

                    ProgressView(value: progressValue)
                        .tint(AppColor.accent)
                }

                HStack(spacing: AppLayout.space8) {
                    ForEach(Array(course.tags.prefix(3)), id: \.self) { tag in
                        CourseMetaPill(text: tag, style: .soft)
                    }
                }
            }
        }
        .shadow(color: Color.black.opacity(0.08), radius: 14, y: 8)
    }
}

private struct CourseInfoTag: View {
    let text: String
    let systemImage: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(AppFont.caption())
            .foregroundStyle(AppColor.textSecondary)
    }
}

private enum CourseMetaPillStyle {
    case accent
    case soft
}

private struct CourseMetaPill: View {
    let text: String
    let style: CourseMetaPillStyle

    var body: some View {
        Text(text)
            .font(AppFont.tiny())
            .foregroundStyle(style == .accent ? AppColor.textOnAccent : AppColor.textSecondary)
            .padding(.horizontal, AppLayout.space10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(style == .accent ? AnyShapeStyle(AppGradient.hero) : AnyShapeStyle(AppColor.backgroundSecondary.opacity(0.92)))
            )
    }
}

private struct CourseCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .opacity(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}

private struct CoursePressableButtonStyle: ButtonStyle {
    let pressedScale: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}
