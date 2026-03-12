import Foundation

struct ProgressSeedData: Codable {
    let schemaVersion: Int?
    let bodyWeightMonthlyEntries: [BodyWeightMonthlyEntry]
    let weeklyTrainingEntries: [WeeklyTrainingEntry]

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case bodyWeightMonthlyEntries
        case bodyWeightEntries
        case weeklyTrainingEntries
    }

    init(
        schemaVersion: Int? = nil,
        bodyWeightMonthlyEntries: [BodyWeightMonthlyEntry],
        weeklyTrainingEntries: [WeeklyTrainingEntry]
    ) {
        self.schemaVersion = schemaVersion
        self.bodyWeightMonthlyEntries = bodyWeightMonthlyEntries
        self.weeklyTrainingEntries = weeklyTrainingEntries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion)
        weeklyTrainingEntries = try container.decodeIfPresent([WeeklyTrainingEntry].self, forKey: .weeklyTrainingEntries) ?? []

        if let monthlyEntries = try container.decodeIfPresent([BodyWeightMonthlyEntry].self, forKey: .bodyWeightMonthlyEntries),
           !monthlyEntries.isEmpty {
            bodyWeightMonthlyEntries = monthlyEntries
            return
        }

        let legacyEntries = try container.decodeIfPresent([LegacyBodyWeightEntry].self, forKey: .bodyWeightEntries) ?? []
        bodyWeightMonthlyEntries = LegacyBodyWeightEntry.migrateToMonthly(legacyEntries)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(schemaVersion, forKey: .schemaVersion)
        try container.encode(bodyWeightMonthlyEntries, forKey: .bodyWeightMonthlyEntries)
        try container.encode(weeklyTrainingEntries, forKey: .weeklyTrainingEntries)
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

struct WeeklyTrainingEntry: Codable, Identifiable, Hashable {
    let id: String
    var weekLabel: String
    var minutes: Int
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
