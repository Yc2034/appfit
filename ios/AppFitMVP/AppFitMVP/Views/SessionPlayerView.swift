import SwiftUI

struct SessionPlayerView: View {
    let courseTitle: String
    let session: CourseSession

    @State private var stepIndex: Int = 0

    private var currentStep: CourseStep {
        session.steps[stepIndex]
    }

    private var progressText: String {
        "步骤 \(stepIndex + 1) / \(session.steps.count)"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppLayout.space16) {
                AppFitCard(style: .elevated) {
                    VStack(alignment: .leading, spacing: AppLayout.space8) {
                        Text(courseTitle)
                            .font(AppFont.caption())
                            .foregroundStyle(AppColor.textSecondary)

                        Text(session.title)
                            .font(AppFont.title())
                            .foregroundStyle(AppColor.textPrimary)

                        ProgressView(value: Double(stepIndex + 1), total: Double(session.steps.count))
                            .tint(AppColor.accent)

                        Text(progressText)
                            .font(AppFont.caption())
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }

                LocalImageView(imageName: currentStep.imageName, height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius18))

                AppFitCard {
                    VStack(alignment: .leading, spacing: AppLayout.space8) {
                        Text(currentStep.title)
                            .font(AppFont.sectionTitle())
                            .foregroundStyle(AppColor.textPrimary)

                        Text(currentStep.instruction)
                            .font(AppFont.body())
                            .foregroundStyle(AppColor.textSecondary)

                        HStack(spacing: AppLayout.space12) {
                            TagView(text: "动作 \(currentStep.durationSeconds) 秒")
                            TagView(text: "休息 \(currentStep.restSeconds) 秒")
                        }
                    }
                }

                HStack(spacing: AppLayout.space12) {
                    AppFitButton("上一步", icon: "chevron.left", variant: .secondary) {
                        stepIndex = max(0, stepIndex - 1)
                    }
                    .disabled(stepIndex == 0)

                    AppFitButton(stepIndex == session.steps.count - 1 ? "完成" : "下一步", icon: "chevron.right") {
                        stepIndex = min(session.steps.count - 1, stepIndex + 1)
                    }
                }
            }
            .padding(AppLayout.screenPadding)
        }
        .background(AppGradient.subtleBackground.ignoresSafeArea())
        .navigationTitle("训练模式")
        .navigationBarTitleDisplayMode(.inline)
    }
}
