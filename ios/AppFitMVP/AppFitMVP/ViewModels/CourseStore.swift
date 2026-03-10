import Foundation

@MainActor
final class CourseStore: ObservableObject {
    @Published private(set) var courses: [FitnessCourse] = []
    @Published var selectedTags: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let repository: CourseRepository
    private var loaded = false

    init(repository: CourseRepository) {
        self.repository = repository
    }

    var availableTags: [String] {
        let allTags = Set(courses.flatMap(\.tags))
        return allTags.sorted { $0.localizedCompare($1) == .orderedAscending }
    }

    var filteredCourses: [FitnessCourse] {
        guard !selectedTags.isEmpty else { return courses }

        return courses.filter { course in
            !selectedTags.isDisjoint(with: Set(course.tags))
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
            selectedTags = selectedTags.intersection(Set(availableTags))
            loaded = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    func clearTagFilter() {
        selectedTags.removeAll()
    }
}
