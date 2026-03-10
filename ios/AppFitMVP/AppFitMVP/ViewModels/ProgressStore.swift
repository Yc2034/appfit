import Foundation

@MainActor
final class ProgressStore: ObservableObject {
    @Published private(set) var bodyWeightEntries: [BodyWeightEntry] = []
    @Published private(set) var weeklyTrainingEntries: [WeeklyTrainingEntry] = []
    @Published var errorMessage: String?

    private let repository: ProgressRepository
    private let defaults: UserDefaults
    private var loaded = false

    private let weightKey = "appfit.progress.weight.entries"
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

        if let cachedWeight = loadWeightFromDefaults(),
           let cachedWeekly = loadWeeklyFromDefaults() {
            bodyWeightEntries = cachedWeight.sorted { $0.date < $1.date }
            weeklyTrainingEntries = cachedWeekly.sorted { $0.weekLabel < $1.weekLabel }
            loaded = true
            return
        }

        do {
            let seed = try repository.loadSeedData()
            bodyWeightEntries = seed.bodyWeightEntries.sorted { $0.date < $1.date }
            weeklyTrainingEntries = seed.weeklyTrainingEntries.sorted { $0.weekLabel < $1.weekLabel }
            persist()
            loaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addBodyWeight(date: Date, weight: Double) {
        let entry = BodyWeightEntry(
            id: UUID().uuidString,
            date: DateParsers.dayFormatter.string(from: date),
            weight: weight
        )
        bodyWeightEntries.append(entry)
        bodyWeightEntries.sort { $0.date < $1.date }
        persist()
    }

    func updateBodyWeight(id: String, date: Date, weight: Double) {
        guard let index = bodyWeightEntries.firstIndex(where: { $0.id == id }) else { return }
        bodyWeightEntries[index].date = DateParsers.dayFormatter.string(from: date)
        bodyWeightEntries[index].weight = weight
        bodyWeightEntries.sort { $0.date < $1.date }
        persist()
    }

    func deleteBodyWeight(id: String) {
        bodyWeightEntries.removeAll { $0.id == id }
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

        if let weightData = try? encoder.encode(bodyWeightEntries) {
            defaults.set(weightData, forKey: weightKey)
        }

        if let weeklyData = try? encoder.encode(weeklyTrainingEntries) {
            defaults.set(weeklyData, forKey: weeklyKey)
        }
    }

    private func loadWeightFromDefaults() -> [BodyWeightEntry]? {
        guard let data = defaults.data(forKey: weightKey) else { return nil }
        return try? JSONDecoder().decode([BodyWeightEntry].self, from: data)
    }

    private func loadWeeklyFromDefaults() -> [WeeklyTrainingEntry]? {
        guard let data = defaults.data(forKey: weeklyKey) else { return nil }
        return try? JSONDecoder().decode([WeeklyTrainingEntry].self, from: data)
    }
}
