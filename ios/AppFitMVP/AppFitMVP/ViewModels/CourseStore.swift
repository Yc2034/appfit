import Foundation

struct CourseContinueContext {
    let course: FitnessCourse
    let session: CourseSession
    let completedSessions: Int
    let progressValue: Double
}

@MainActor
final class CourseStore: ObservableObject {
    @Published private(set) var courses: [FitnessCourse] = []
    @Published var selectedTag: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published private(set) var favoriteCourseIDs: Set<String>
    @Published private(set) var lastViewedCourseID: String?
    @Published private(set) var lastViewedSessionID: String?
    @Published private(set) var completedSessionIDs: Set<String>

    private let repository: CourseRepository
    private var loaded = false
    private let defaults = UserDefaults.standard

    private enum DefaultsKey {
        static let favoriteCourseIDs = "course.favorite.ids"
        static let lastViewedCourseID = "course.last_viewed.id"
        static let lastViewedSessionID = "course.last_viewed_session.id"
        static let completedSessionIDs = "course.completed_session.ids"
    }

    init(repository: CourseRepository) {
        self.repository = repository
        self.favoriteCourseIDs = Set(defaults.stringArray(forKey: DefaultsKey.favoriteCourseIDs) ?? [])
        self.lastViewedCourseID = defaults.string(forKey: DefaultsKey.lastViewedCourseID)
        self.lastViewedSessionID = defaults.string(forKey: DefaultsKey.lastViewedSessionID)
        self.completedSessionIDs = Set(defaults.stringArray(forKey: DefaultsKey.completedSessionIDs) ?? [])
    }

    var availableTags: [String] {
        let allTags = Set(courses.flatMap(\.tags))
        return allTags.sorted { $0.localizedCompare($1) == .orderedAscending }
    }

    var filteredCourses: [FitnessCourse] {
        let scopedCourses: [FitnessCourse]
        if let selectedTag {
            scopedCourses = courses.filter { $0.tags.contains(selectedTag) }
        } else {
            scopedCourses = courses
        }

        return scopedCourses.sorted(by: compareCourses)
    }

    var continueContext: CourseContinueContext? {
        let candidateCourse =
            lastViewedCourseID.flatMap { courseID in
                courses.first { $0.id == courseID }
            } ??
            filteredCourses.first(where: isCourseInProgress(_:))

        guard let course = candidateCourse,
              let session = resumeSession(for: course) else {
            return nil
        }

        return CourseContinueContext(
            course: course,
            session: session,
            completedSessions: completedSessionCount(for: course),
            progressValue: progress(for: course)
        )
    }

    func loadCoursesIfNeeded() {
        guard !loaded else { return }
        loadCourses()
    }

    func loadCourses() {
        isLoading = true
        errorMessage = nil

        do {
            courses = try repository.loadCourses()
            if let selectedTag, !availableTags.contains(selectedTag) {
                self.selectedTag = nil
            }
            loaded = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func toggleTag(_ tag: String?) {
        if selectedTag == tag {
            selectedTag = nil
        } else {
            selectedTag = tag
        }
    }

    func clearTagFilter() {
        selectedTag = nil
    }

    func isFavorite(_ course: FitnessCourse) -> Bool {
        favoriteCourseIDs.contains(course.id)
    }

    func toggleFavorite(for course: FitnessCourse) {
        if favoriteCourseIDs.contains(course.id) {
            favoriteCourseIDs.remove(course.id)
        } else {
            favoriteCourseIDs.insert(course.id)
        }
        defaults.set(Array(favoriteCourseIDs), forKey: DefaultsKey.favoriteCourseIDs)
    }

    func markCourseOpened(_ course: FitnessCourse) {
        lastViewedCourseID = course.id
        defaults.set(course.id, forKey: DefaultsKey.lastViewedCourseID)
    }

    func markSessionStarted(courseID: String, sessionID: String) {
        lastViewedCourseID = courseID
        lastViewedSessionID = sessionID
        defaults.set(courseID, forKey: DefaultsKey.lastViewedCourseID)
        defaults.set(sessionID, forKey: DefaultsKey.lastViewedSessionID)
    }

    func markSessionCompleted(courseID: String, sessionID: String) {
        completedSessionIDs.insert(progressSessionKey(courseID: courseID, sessionID: sessionID))
        defaults.set(Array(completedSessionIDs), forKey: DefaultsKey.completedSessionIDs)
        markSessionStarted(courseID: courseID, sessionID: sessionID)
    }

    func progress(for course: FitnessCourse) -> Double {
        guard course.sessionCount > 0 else { return 0 }
        return Double(completedSessionCount(for: course)) / Double(course.sessionCount)
    }

    func progressText(for course: FitnessCourse) -> String {
        "\(completedSessionCount(for: course))/\(course.sessionCount) 节完成"
    }

    func statusText(for course: FitnessCourse) -> String? {
        if isCourseCompleted(course) {
            return "已完成"
        }
        if lastViewedCourseID == course.id {
            return "继续训练"
        }
        if isFavorite(course) {
            return "收藏"
        }
        if course.level.localizedCaseInsensitiveContains("beginner") {
            return "推荐"
        }
        return nil
    }

    func isCourseCompleted(_ course: FitnessCourse) -> Bool {
        course.sessionCount > 0 && completedSessionCount(for: course) == course.sessionCount
    }

    func isCourseInProgress(_ course: FitnessCourse) -> Bool {
        let completed = completedSessionCount(for: course)
        return (completed > 0 && completed < course.sessionCount) || lastViewedCourseID == course.id
    }

    func completedSessionCount(for course: FitnessCourse) -> Int {
        course.sessions.filter { session in
            isSessionCompleted(courseID: course.id, sessionID: session.id)
        }.count
    }

    func isSessionCompleted(courseID: String, sessionID: String) -> Bool {
        completedSessionIDs.contains(progressSessionKey(courseID: courseID, sessionID: sessionID))
    }

    func resumeSession(for course: FitnessCourse) -> CourseSession? {
        if let lastViewedSessionID,
           let lastViewedSession = course.sessions.first(where: { $0.id == lastViewedSessionID }),
           !isSessionCompleted(courseID: course.id, sessionID: lastViewedSession.id) {
            return lastViewedSession
        }

        if let firstIncomplete = course.sessions.first(where: { session in
            !isSessionCompleted(courseID: course.id, sessionID: session.id)
        }) {
            return firstIncomplete
        }

        return course.sessions.last
    }

    private func compareCourses(_ lhs: FitnessCourse, _ rhs: FitnessCourse) -> Bool {
        let lhsRank = ranking(for: lhs)
        let rhsRank = ranking(for: rhs)

        if lhsRank != rhsRank {
            return lhsRank > rhsRank
        }

        return lhs.title.localizedCompare(rhs.title) == .orderedAscending
    }

    private func ranking(for course: FitnessCourse) -> Int {
        var score = 0

        if isFavorite(course) {
            score += 8
        }
        if lastViewedCourseID == course.id {
            score += 6
        }
        if isCourseInProgress(course) {
            score += 4
        }
        if course.level.localizedCaseInsensitiveContains("beginner") {
            score += 2
        }
        if isCourseCompleted(course) {
            score -= 3
        }

        return score
    }

    private func progressSessionKey(courseID: String, sessionID: String) -> String {
        "\(courseID)::\(sessionID)"
    }
}
