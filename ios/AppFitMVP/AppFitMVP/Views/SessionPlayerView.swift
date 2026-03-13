import SwiftUI

struct SessionPlayerView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: CourseStore
    @EnvironmentObject private var exerciseStore: ExerciseStore
    @Environment(\.dismiss) private var dismiss

    let courseID: String
    let courseTitle: String
    let session: CourseSession

    @State private var stepIndex: Int = 0

    private var currentStep: CourseStep {
        session.steps[stepIndex]
    }

    private var progressText: String {
        "步骤 \(stepIndex + 1) / \(session.steps.count)"
    }

    private var linkedMovement: ExerciseMovement? {
        exerciseStore.movement(matching: currentStep)
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

                        if let linkedMovement {
                            Button {
                                router.openMovementFromCourse(linkedMovement)
                            } label: {
                                HStack(spacing: AppLayout.space8) {
                                    Image(systemName: "figure.strengthtraining.traditional")
                                    Text("查看动作要领")
                                        .font(AppFont.bodyStrong())
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .font(AppFont.caption())
                                }
                                .foregroundStyle(AppColor.accent)
                                .padding(.horizontal, AppLayout.space12)
                                .padding(.vertical, AppLayout.space10)
                                .background(
                                    RoundedRectangle(cornerRadius: AppLayout.radius14, style: .continuous)
                                        .fill(AppColor.accentSoft)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                HStack(spacing: AppLayout.space12) {
                    AppFitButton("上一步", icon: "chevron.left", variant: .secondary) {
                        stepIndex = max(0, stepIndex - 1)
                    }
                    .disabled(stepIndex == 0)

                    AppFitButton(
                        stepIndex == session.steps.count - 1 ? "完成" : "下一步",
                        icon: stepIndex == session.steps.count - 1 ? "checkmark" : "chevron.right"
                    ) {
                        handlePrimaryAction()
                    }
                }
            }
            .padding(AppLayout.screenPadding)
        }
        .background(AppGradient.subtleBackground.ignoresSafeArea())
        .navigationTitle("训练模式")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.markSessionStarted(courseID: courseID, sessionID: session.id)
        }
    }

    private func handlePrimaryAction() {
        if stepIndex == session.steps.count - 1 {
            store.markSessionCompleted(courseID: courseID, sessionID: session.id)
            dismiss()
        } else {
            stepIndex = min(session.steps.count - 1, stepIndex + 1)
        }
    }
}
