import Foundation

struct FitnessCourse: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let focus: String
    let level: String
    let totalMinutes: Int
    let tags: [String]
    let coverImageName: String
    let audioGuide: CourseAudioGuide?
    let sessions: [CourseSession]

    var sessionCount: Int {
        sessions.count
    }

    var totalStepCount: Int {
        sessions.reduce(0) { $0 + $1.steps.count }
    }
}

struct CourseAudioGuide: Codable, Hashable {
    let title: String
    let fileName: String
}

struct CourseSession: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let goal: String
    let estimatedMinutes: Int
    let steps: [CourseStep]
}

struct CourseStep: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let instruction: String
    let durationSeconds: Int
    let restSeconds: Int
    let imageName: String
}

struct CourseSessionRoute: Hashable {
    let courseID: String
    let courseTitle: String
    let session: CourseSession
}
