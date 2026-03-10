import SwiftUI

struct CourseDetailView: View {
    let course: FitnessCourse

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppLayout.space16) {
                LocalImageView(imageName: course.coverImageName, height: 230)
                    .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius18))

                AppFitCard(style: .elevated) {
                    VStack(alignment: .leading, spacing: AppLayout.space8) {
                        Text(course.title)
                            .font(AppFont.title())
                            .foregroundStyle(AppColor.textPrimary)

                        Text(course.subtitle)
                            .font(AppFont.body())
                            .foregroundStyle(AppColor.textSecondary)

                        HStack(spacing: AppLayout.space8) {
                            ForEach(course.tags, id: \.self) { tag in
                                TagView(text: tag)
                            }
                        }
                    }
                }

                if let audioGuide = course.audioGuide {
                    CourseAudioPlayerCard(track: audioGuide)
                }

                AppSectionHeader(title: "课程章节", subtitle: "点击章节进入训练模式")

                VStack(spacing: AppLayout.space12) {
                    ForEach(course.sessions) { session in
                        NavigationLink {
                            SessionPlayerView(courseTitle: course.title, session: session)
                        } label: {
                            AppFitCard {
                                VStack(alignment: .leading, spacing: AppLayout.space8) {
                                    Text(session.title)
                                        .font(AppFont.headline())
                                        .foregroundStyle(AppColor.textPrimary)

                                    Text(session.goal)
                                        .font(AppFont.body())
                                        .foregroundStyle(AppColor.textSecondary)

                                    HStack(spacing: AppLayout.space12) {
                                        Text("\(session.steps.count) 步")
                                        Text("\(session.estimatedMinutes) 分钟")
                                    }
                                    .font(AppFont.caption())
                                    .foregroundStyle(AppColor.textSecondary)
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
    }
}
