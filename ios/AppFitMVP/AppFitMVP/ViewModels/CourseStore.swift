import Foundation

@MainActor
final class CourseStore: ObservableObject {
    @Published private(set) var courses: [FitnessCourse] = []
    @Published var query: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let repository: CourseRepository
    private var loaded = false

    init(repository: CourseRepository) {
        self.repository = repository
    }

    var filteredCourses: [FitnessCourse] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return courses }

        return courses.filter { course in
            course.title.localizedCaseInsensitiveContains(trimmed) ||
            course.focus.localizedCaseInsensitiveContains(trimmed) ||
            course.tags.contains(where: { $0.localizedCaseInsensitiveContains(trimmed) })
        }
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
            loaded = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
