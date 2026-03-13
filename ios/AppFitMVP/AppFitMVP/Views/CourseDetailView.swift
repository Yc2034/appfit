import SwiftUI

struct CourseDetailView: View {
    @EnvironmentObject private var store: CourseStore
    let course: FitnessCourse

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppLayout.space16) {
                heroSection

                HStack(spacing: AppLayout.space12) {
                    CourseInfoTile(title: "总时长", value: "\(course.totalMinutes) 分钟")
                    CourseInfoTile(title: "训练进度", value: store.progressText(for: course))
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppLayout.space8) {
                        ForEach(course.tags, id: \.self) { tag in
                            CourseDetailPill(text: tag, style: .soft)
                        }
                    }
                    .padding(.vertical, 2)
                }

                if let audioGuide = course.audioGuide {
                    CourseAudioPlayerCard(track: audioGuide)
                }

                AppSectionHeader(title: "课程章节", subtitle: "选择章节进入训练模式")

                VStack(spacing: AppLayout.space12) {
                    ForEach(course.sessions) { session in
                        NavigationLink(
                            value: CourseSessionRoute(
                                courseID: course.id,
                                courseTitle: course.title,
                                session: session
                            )
                        ) {
                            AppFitCard(style: .elevated) {
                                HStack(alignment: .top, spacing: AppLayout.space12) {
                                    VStack(alignment: .leading, spacing: AppLayout.space8) {
                                        HStack(spacing: AppLayout.space8) {
                                            Text(session.title)
                                                .font(AppFont.headline())
                                                .foregroundStyle(AppColor.textPrimary)

                                            if store.isSessionCompleted(courseID: course.id, sessionID: session.id) {
                                                CourseDetailPill(text: "已完成", style: .accent)
                                            } else if store.resumeSession(for: course)?.id == session.id {
                                                CourseDetailPill(text: "继续", style: .accent)
                                            }
                                        }

                                        Text(session.goal)
                                            .font(AppFont.body())
                                            .foregroundStyle(AppColor.textSecondary)

                                        HStack(spacing: AppLayout.space12) {
                                            Label("\(session.steps.count) 步", systemImage: "figure.strengthtraining.traditional")
                                            Label("\(session.estimatedMinutes) 分钟", systemImage: "clock")
                                        }
                                        .font(AppFont.caption())
                                        .foregroundStyle(AppColor.textSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(AppColor.textSecondary)
                                        .padding(.top, 4)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(AppLayout.screenPadding)
        }
        .background(AppGradient.subtleBackground.ignoresSafeArea())
        .navigationTitle("课程详情")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if let route = startRoute {
                NavigationLink(value: route) {
                    HStack(spacing: AppLayout.space8) {
                        Image(systemName: store.completedSessionCount(for: course) > 0 ? "play.fill" : "bolt.fill")
                        Text(store.completedSessionCount(for: course) > 0 ? "继续课程" : "开始课程")
                            .font(AppFont.bodyStrong())
                    }
                    .foregroundStyle(AppColor.textOnAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppLayout.space12)
                    .background(
                        RoundedRectangle(cornerRadius: AppLayout.radius14, style: .continuous)
                            .fill(AppGradient.hero)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AppLayout.screenPadding)
                .padding(.top, AppLayout.space8)
                .padding(.bottom, AppLayout.space12)
                .background(AppColor.background.opacity(0.94))
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.toggleFavorite(for: course)
                } label: {
                    Image(systemName: store.isFavorite(course) ? "star.fill" : "star")
                        .foregroundStyle(store.isFavorite(course) ? AppColor.accent : AppColor.textPrimary)
                }
            }
        }
        .onAppear {
            store.markCourseOpened(course)
        }
    }

    private var startRoute: CourseSessionRoute? {
        guard let session = store.resumeSession(for: course) else { return nil }
        return CourseSessionRoute(courseID: course.id, courseTitle: course.title, session: session)
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColor.accent.opacity(0.22),
                            AppColor.success.opacity(0.12),
                            Color.white.opacity(0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .fill(AppColor.accent.opacity(0.12))
                        .frame(width: 180, height: 180)
                        .blur(radius: 14)
                        .offset(x: 92, y: -88)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.34), lineWidth: 1)
                )

            LocalImageView(imageName: course.coverImageName, height: 316)
                .scaleEffect(1.03)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .padding(8)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.08),
                    Color.black.opacity(0.18),
                    Color.black.opacity(0.68)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .padding(8)

            VStack(alignment: .leading, spacing: AppLayout.space10) {
                HStack(spacing: AppLayout.space8) {
                    CourseDetailPill(text: course.focus, style: .accent)
                    CourseDetailPill(text: course.level, style: .softOnImage)
                    if store.isFavorite(course) {
                        CourseDetailPill(text: "已收藏", style: .softOnImage)
                    }
                }

                Text(course.title)
                    .font(AppFont.title())
                    .foregroundStyle(Color.white)

                Text(course.subtitle)
                    .font(AppFont.body())
                    .foregroundStyle(Color.white.opacity(0.88))
                    .lineLimit(2)

                HStack(spacing: AppLayout.space10) {
                    Label("\(course.totalMinutes) 分钟", systemImage: "clock")
                    Label("\(course.sessionCount) 节课程", systemImage: "list.bullet.rectangle")
                }
                .font(AppFont.caption())
                .foregroundStyle(Color.white.opacity(0.86))
            }
            .padding(.horizontal, AppLayout.space20)
            .padding(.bottom, AppLayout.space20)
        }
        .frame(height: 332)
        .shadow(color: AppColor.accent.opacity(0.16), radius: 26, y: 14)
    }
}

private struct CourseInfoTile: View {
    let title: String
    let value: String

    var body: some View {
        AppFitCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppLayout.space8) {
                Text(title)
                    .font(AppFont.tiny())
                    .foregroundStyle(AppColor.textSecondary)

                Text(value)
                    .font(AppFont.bodyStrong())
                    .foregroundStyle(AppColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private enum CourseDetailPillStyle {
    case accent
    case soft
    case softOnImage
}

private struct CourseDetailPill: View {
    let text: String
    let style: CourseDetailPillStyle

    var body: some View {
        Text(text)
            .font(AppFont.tiny())
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, AppLayout.space10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(backgroundStyle)
            )
    }

    private var foregroundColor: Color {
        switch style {
        case .accent:
            return AppColor.textOnAccent
        case .soft:
            return AppColor.textSecondary
        case .softOnImage:
            return Color.white.opacity(0.96)
        }
    }

    private var backgroundStyle: AnyShapeStyle {
        switch style {
        case .accent:
            return AnyShapeStyle(AppGradient.hero)
        case .soft:
            return AnyShapeStyle(AppColor.backgroundSecondary.opacity(0.92))
        case .softOnImage:
            return AnyShapeStyle(Color.white.opacity(0.14))
        }
    }
}
