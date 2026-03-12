import Foundation

@MainActor
final class ProgressStore: ObservableObject {
    @Published private(set) var bodyWeightMonthlyEntries: [BodyWeightMonthlyEntry] = []
    @Published private(set) var weeklyTrainingEntries: [WeeklyTrainingEntry] = []
    @Published var errorMessage: String?

    private let repository: ProgressRepository
    private let defaults: UserDefaults
    private var loaded = false

    private let weeklyKey = "appfit.progress.weekly.entries"

    init(repository: ProgressRepository, defaults: UserDefaults = .standard) {
        self.repository = repository
        self.defaults = defaults
    }

    func loadIfNeeded() {
        guard !loaded else { return }
        load()
    }

    func load() {
        errorMessage = nil

        do {
            let seed = try repository.loadSeedData()
            bodyWeightMonthlyEntries = sortedMonthlyEntries(seed.bodyWeightMonthlyEntries)

            if let cachedWeekly = loadWeeklyFromDefaults() {
                weeklyTrainingEntries = cachedWeekly.sorted { $0.weekLabel < $1.weekLabel }
            } else {
                weeklyTrainingEntries = seed.weeklyTrainingEntries.sorted { $0.weekLabel < $1.weekLabel }
                persist()
            }

            loaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addBodyWeight(month: Date, weight: Double) {
        let monthKey = DateParsers.monthFormatter.string(from: month)
        let normalizedWeight = normalizedWeightValue(weight)

        if let index = bodyWeightMonthlyEntries.firstIndex(where: { $0.month == monthKey }) {
            bodyWeightMonthlyEntries[index].weight = normalizedWeight
            bodyWeightMonthlyEntries[index].updatedAt = DateParsers.iso8601Formatter.string(from: Date())
        } else {
            let entry = BodyWeightMonthlyEntry(
                id: UUID().uuidString,
                month: monthKey,
                weight: normalizedWeight,
                updatedAt: DateParsers.iso8601Formatter.string(from: Date())
            )
            bodyWeightMonthlyEntries.append(entry)
        }

        bodyWeightMonthlyEntries = sortedMonthlyEntries(bodyWeightMonthlyEntries)
        persist()
    }

    func updateBodyWeight(id: String, month: Date, weight: Double) {
        guard let index = bodyWeightMonthlyEntries.firstIndex(where: { $0.id == id }) else { return }

        let monthKey = DateParsers.monthFormatter.string(from: month)
        let normalizedWeight = normalizedWeightValue(weight)

        if let duplicateIndex = bodyWeightMonthlyEntries.firstIndex(where: { $0.month == monthKey && $0.id != id }) {
            bodyWeightMonthlyEntries[duplicateIndex].weight = normalizedWeight
            bodyWeightMonthlyEntries[duplicateIndex].updatedAt = DateParsers.iso8601Formatter.string(from: Date())
            bodyWeightMonthlyEntries.remove(at: index)
        } else {
            bodyWeightMonthlyEntries[index].month = monthKey
            bodyWeightMonthlyEntries[index].weight = normalizedWeight
            bodyWeightMonthlyEntries[index].updatedAt = DateParsers.iso8601Formatter.string(from: Date())
        }

        bodyWeightMonthlyEntries = sortedMonthlyEntries(bodyWeightMonthlyEntries)
        persist()
    }

    func deleteBodyWeight(id: String) {
        bodyWeightMonthlyEntries.removeAll { $0.id == id }
        persist()
    }

    func addWeeklyTraining(weekLabel: String, minutes: Int) {
        let entry = WeeklyTrainingEntry(
            id: UUID().uuidString,
            weekLabel: weekLabel,
            minutes: minutes
        )
        weeklyTrainingEntries.append(entry)
        weeklyTrainingEntries.sort { $0.weekLabel < $1.weekLabel }
        persist()
    }

    func updateWeeklyTraining(id: String, weekLabel: String, minutes: Int) {
        guard let index = weeklyTrainingEntries.firstIndex(where: { $0.id == id }) else { return }
        weeklyTrainingEntries[index].weekLabel = weekLabel
        weeklyTrainingEntries[index].minutes = minutes
        weeklyTrainingEntries.sort { $0.weekLabel < $1.weekLabel }
        persist()
    }

    func deleteWeeklyTraining(id: String) {
        weeklyTrainingEntries.removeAll { $0.id == id }
        persist()
    }

    private func persist() {
        let encoder = JSONEncoder()

        if let weeklyData = try? encoder.encode(weeklyTrainingEntries) {
            defaults.set(weeklyData, forKey: weeklyKey)
        }
    }

    private func loadWeeklyFromDefaults() -> [WeeklyTrainingEntry]? {
        guard let data = defaults.data(forKey: weeklyKey) else { return nil }
        return try? JSONDecoder().decode([WeeklyTrainingEntry].self, from: data)
    }

    private func sortedMonthlyEntries(_ entries: [BodyWeightMonthlyEntry]) -> [BodyWeightMonthlyEntry] {
        entries.sorted { $0.month < $1.month }
    }

    private func normalizedWeightValue(_ weight: Double) -> Double {
        (weight * 10).rounded() / 10
    }
}
