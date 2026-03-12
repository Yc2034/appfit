import Foundation

struct ProgressSeedData: Codable {
    let schemaVersion: Int?
    let bodyWeightMonthlyEntries: [BodyWeightMonthlyEntry]
    let monthlyTrainingEntries: [MonthlyTrainingEntry]

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case bodyWeightMonthlyEntries
        case bodyWeightEntries
        case monthlyTrainingEntries
        case weeklyTrainingEntries
    }

    init(
        schemaVersion: Int? = nil,
        bodyWeightMonthlyEntries: [BodyWeightMonthlyEntry],
        monthlyTrainingEntries: [MonthlyTrainingEntry]
    ) {
        self.schemaVersion = schemaVersion
        self.bodyWeightMonthlyEntries = bodyWeightMonthlyEntries
        self.monthlyTrainingEntries = monthlyTrainingEntries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion)

        if let monthlyEntries = try container.decodeIfPresent([BodyWeightMonthlyEntry].self, forKey: .bodyWeightMonthlyEntries),
           !monthlyEntries.isEmpty {
            bodyWeightMonthlyEntries = monthlyEntries
        } else {
            let legacyEntries = try container.decodeIfPresent([LegacyBodyWeightEntry].self, forKey: .bodyWeightEntries) ?? []
            bodyWeightMonthlyEntries = LegacyBodyWeightEntry.migrateToMonthly(legacyEntries)
        }

        if let monthlyTraining = try container.decodeIfPresent([MonthlyTrainingEntry].self, forKey: .monthlyTrainingEntries),
           !monthlyTraining.isEmpty {
            monthlyTrainingEntries = monthlyTraining.sorted { $0.month < $1.month }
        } else {
            let legacyWeekly = try container.decodeIfPresent([LegacyWeeklyTrainingEntry].self, forKey: .weeklyTrainingEntries) ?? []
            monthlyTrainingEntries = LegacyWeeklyTrainingEntry.migrateToMonthly(legacyWeekly)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(schemaVersion, forKey: .schemaVersion)
        try container.encode(bodyWeightMonthlyEntries, forKey: .bodyWeightMonthlyEntries)
        try container.encode(monthlyTrainingEntries, forKey: .monthlyTrainingEntries)
    }
}

struct BodyWeightMonthlyEntry: Codable, Identifiable, Hashable {
    let id: String
    var month: String
    var weight: Double
    var updatedAt: String?

    var parsedMonth: Date {
        DateParsers.monthFormatter.date(from: month) ?? Date()
    }

    var monthLabel: String {
        DateParsers.monthLabelFormatter.string(from: parsedMonth)
    }
}

struct LegacyBodyWeightEntry: Codable, Identifiable, Hashable {
    let id: String
    var date: String
    var weight: Double

    var parsedDate: Date {
        DateParsers.dayFormatter.date(from: date) ?? Date()
    }

    var month: String {
        DateParsers.monthFormatter.string(from: parsedDate)
    }

    static func migrateToMonthly(_ entries: [LegacyBodyWeightEntry]) -> [BodyWeightMonthlyEntry] {
        guard !entries.isEmpty else { return [] }

        var latestByMonth: [String: LegacyBodyWeightEntry] = [:]
        for entry in entries {
            if let existing = latestByMonth[entry.month] {
                if entry.parsedDate >= existing.parsedDate {
                    latestByMonth[entry.month] = entry
                }
            } else {
                latestByMonth[entry.month] = entry
            }
        }

        return latestByMonth
            .map { month, entry in
                BodyWeightMonthlyEntry(
                    id: "bwm-\(month)",
                    month: month,
                    weight: entry.weight,
                    updatedAt: nil
                )
            }
            .sorted { $0.month < $1.month }
    }
}

struct MonthlyTrainingEntry: Codable, Identifiable, Hashable {
    let id: String
    var month: String
    var categories: [TrainingCategoryMinutes]

    var parsedMonth: Date {
        DateParsers.monthFormatter.date(from: month) ?? Date()
    }

    var monthLabel: String {
        DateParsers.monthLabelFormatter.string(from: parsedMonth)
    }

    var totalMinutes: Int {
        categories.reduce(0) { $0 + $1.minutes }
    }
}

struct TrainingCategoryMinutes: Codable, Hashable {
    var category: String
    var minutes: Int
}

struct LegacyWeeklyTrainingEntry: Codable, Identifiable, Hashable {
    let id: String
    var weekLabel: String
    var minutes: Int

    private var month: String? {
        let parts = weekLabel.split(separator: "-W")
        guard parts.count == 2,
              let year = Int(parts[0]),
              let week = Int(parts[1]) else { return nil }

        var components = DateComponents()
        components.yearForWeekOfYear = year
        components.weekOfYear = week
        components.weekday = 2

        let calendar = Calendar(identifier: .iso8601)
        guard let date = calendar.date(from: components) else { return nil }
        return DateParsers.monthFormatter.string(from: date)
    }

    static func migrateToMonthly(_ entries: [LegacyWeeklyTrainingEntry]) -> [MonthlyTrainingEntry] {
        guard !entries.isEmpty else { return [] }

        var totalsByMonth: [String: Int] = [:]
        for entry in entries {
            guard let month = entry.month else { continue }
            totalsByMonth[month, default: 0] += entry.minutes
        }

        return totalsByMonth
            .map { month, total in
                MonthlyTrainingEntry(
                    id: "mt-\(month)",
                    month: month,
                    categories: [
                        TrainingCategoryMinutes(category: "综合训练", minutes: total)
                    ]
                )
            }
            .sorted { $0.month < $1.month }
    }
}

enum DateParsers {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()

    static let monthLabelFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月"
        return formatter
    }()

    static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
