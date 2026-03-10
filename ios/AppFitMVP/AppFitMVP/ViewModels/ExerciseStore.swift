import Foundation

@MainActor
final class ExerciseStore: ObservableObject {
    @Published private(set) var movements: [ExerciseMovement] = []
    @Published var query: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let repository: ExerciseRepository
    private var loaded = false

    init(repository: ExerciseRepository) {
        self.repository = repository
    }

    var filteredMovements: [ExerciseMovement] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return movements }

        return movements.filter { movement in
            movement.name.localizedCaseInsensitiveContains(trimmed) ||
            movement.category.localizedCaseInsensitiveContains(trimmed) ||
            movement.targetArea.localizedCaseInsensitiveContains(trimmed)
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
            loaded = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
