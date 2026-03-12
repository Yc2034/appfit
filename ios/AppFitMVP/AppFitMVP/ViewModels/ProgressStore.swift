import Foundation

@MainActor
final class ProgressStore: ObservableObject {
    @Published private(set) var bodyWeightMonthlyEntries: [BodyWeightMonthlyEntry] = []
    @Published private(set) var monthlyTrainingEntries: [MonthlyTrainingEntry] = []
    @Published var errorMessage: String?

    private let repository: ProgressRepository
    private var loaded = false

    init(repository: ProgressRepository) {
        self.repository = repository
    }

    func loadIfNeeded() {
        guard !loaded else { return }
        load()
    }

    func load() {
        errorMessage = nil

        do {
            let seed = try repository.loadSeedData()
            bodyWeightMonthlyEntries = seed.bodyWeightMonthlyEntries.sorted { $0.month < $1.month }
            monthlyTrainingEntries = seed.monthlyTrainingEntries.sorted { $0.month < $1.month }
            loaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
