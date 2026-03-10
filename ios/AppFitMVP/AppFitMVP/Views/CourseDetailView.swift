import SwiftUI

struct CourseDetailView: View {
    let course: FitnessCourse

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                LocalImageView(imageName: course.coverImageName, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                VStack(alignment: .leading, spacing: 8) {
                    Text(course.title)
                        .font(.title2.bold())
                    Text(course.subtitle)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        ForEach(course.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray6))
                                .clipShape(Capsule())
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("课程章节")
                        .font(.headline)

                    ForEach(course.sessions) { session in
                        NavigationLink {
                            SessionPlayerView(courseTitle: course.title, session: session)
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(session.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(session.goal)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                HStack(spacing: 12) {
                                    Label("\(session.steps.count) 步", systemImage: "list.number")
                                    Label("\(session.estimatedMinutes) 分钟", systemImage: "clock")
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(.secondarySystemBackground))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("课程详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
