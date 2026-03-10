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
        VStack(alignment: .leading, spacing: 14) {
            Text(courseTitle)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(session.title)
                .font(.title3.bold())

            ProgressView(value: Double(stepIndex + 1), total: Double(session.steps.count))
            Text(progressText)
                .font(.caption)
                .foregroundStyle(.secondary)

            LocalImageView(imageName: currentStep.imageName, height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 8) {
                Text(currentStep.title)
                    .font(.headline)
                Text(currentStep.instruction)
                    .font(.body)
                HStack(spacing: 14) {
                    Label("动作 \(currentStep.durationSeconds) 秒", systemImage: "figure.walk")
                    Label("休息 \(currentStep.restSeconds) 秒", systemImage: "pause.circle")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemBackground))
            )

            HStack(spacing: 12) {
                Button {
                    stepIndex = max(0, stepIndex - 1)
                } label: {
                    Label("上一步", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(stepIndex == 0)

                Button {
                    stepIndex = min(session.steps.count - 1, stepIndex + 1)
                } label: {
                    Label(stepIndex == session.steps.count - 1 ? "完成" : "下一步", systemImage: "chevron.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .navigationTitle("训练模式")
        .navigationBarTitleDisplayMode(.inline)
    }
}
