import Foundation

struct ProgressSeedData: Codable {
    let bodyWeightEntries: [BodyWeightEntry]
    let weeklyTrainingEntries: [WeeklyTrainingEntry]
}

struct BodyWeightEntry: Codable, Identifiable, Hashable {
    let id: String
    var date: String
    var weight: Double

    var parsedDate: Date {
        DateParsers.dayFormatter.date(from: date) ?? Date()
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
}
