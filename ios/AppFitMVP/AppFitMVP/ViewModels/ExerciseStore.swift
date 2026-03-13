import Foundation

@MainActor
final class ExerciseStore: ObservableObject {
    @Published private(set) var movements: [ExerciseMovement] = []
    @Published var selectedTag: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published private(set) var favoriteIDs: Set<String>

    private let repository: ExerciseRepository
    private var loaded = false
    private let favoritesKey = "exercise.favorite.ids"

    init(repository: ExerciseRepository) {
        self.repository = repository
        self.favoriteIDs = Set(UserDefaults.standard.stringArray(forKey: favoritesKey) ?? [])
    }

    var filteredMovements: [ExerciseMovement] {
        let tagFiltered: [ExerciseMovement]
        if let selectedTag, !selectedTag.isEmpty {
            tagFiltered = movements.filter { $0.tags.contains(selectedTag) }
        } else {
            tagFiltered = movements
        }

        return tagFiltered.sorted { lhs, rhs in
            let lhsFavorite = favoriteIDs.contains(lhs.id)
            let rhsFavorite = favoriteIDs.contains(rhs.id)
            if lhsFavorite != rhsFavorite {
                return lhsFavorite && !rhsFavorite
            }
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }

    var availableTags: [String] {
        var orderedTags: [String] = []
        for movement in movements {
            for tag in movement.tags where !orderedTags.contains(tag) {
                orderedTags.append(tag)
            }
        }
        return orderedTags
    }

    func isFavorite(_ movement: ExerciseMovement) -> Bool {
        favoriteIDs.contains(movement.id)
    }

    func toggleFavorite(for movement: ExerciseMovement) {
        if favoriteIDs.contains(movement.id) {
            favoriteIDs.remove(movement.id)
        } else {
            favoriteIDs.insert(movement.id)
        }
        UserDefaults.standard.set(Array(favoriteIDs).sorted(), forKey: favoritesKey)
    }

    func toggleTag(_ tag: String?) {
        if selectedTag == tag {
            selectedTag = nil
        } else {
            selectedTag = tag
        }
    }

    func loadMovementsIfNeeded() {
        guard !loaded else { return }
        loadMovements()
    }

    func loadMovements() {
        isLoading = true
        errorMessage = nil

        do {
            movements = try repository.loadMovements()
            if let selectedTag, !availableTags.contains(selectedTag) {
                self.selectedTag = nil
            }
            loaded = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func movement(matching step: CourseStep) -> ExerciseMovement? {
        let normalizedTitle = normalizedToken(from: step.title)
        let normalizedStepID = normalizedToken(from: step.id)

        return movements.first { movement in
            normalizedToken(from: movement.name) == normalizedTitle ||
            normalizedToken(from: movement.id) == normalizedStepID
        }
    }

    private func normalizedToken(from value: String) -> String {
        value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined()
    }
}
