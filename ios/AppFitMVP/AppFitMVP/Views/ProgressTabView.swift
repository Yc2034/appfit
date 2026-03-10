import SwiftUI
import Charts

struct ProgressTabView: View {
    @EnvironmentObject private var store: ProgressStore

    @State private var newWeightDate: Date = Date()
    @State private var newWeightText: String = ""
    @State private var newWeekLabel: String = ""
    @State private var newWeekMinutes: String = ""

    @State private var editingWeightEntry: BodyWeightEntry?
    @State private var editingWeekEntry: WeeklyTrainingEntry?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if let errorMessage = store.errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }

                    weightChartSection
                    weeklyChartSection
                    addWeightSection
                    addWeeklySection
                    weightListSection
                    weeklyListSection
                }
                .padding(16)
            }
            .navigationTitle("训练数据")
            .sheet(item: $editingWeightEntry) { entry in
                EditWeightSheet(entry: entry) { date, weight in
                    store.updateBodyWeight(id: entry.id, date: date, weight: weight)
                }
            }
            .sheet(item: $editingWeekEntry) { entry in
                EditWeekSheet(entry: entry) { week, minutes in
                    store.updateWeeklyTraining(id: entry.id, weekLabel: week, minutes: minutes)
                }
            }
        }
    }

    private var weightChartSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("体重变化")
                .font(.headline)

            Chart(store.bodyWeightEntries) { entry in
                LineMark(
                    x: .value("日期", entry.parsedDate),
                    y: .value("体重", entry.weight)
                )
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("日期", entry.parsedDate),
                    y: .value("体重", entry.weight)
                )
            }
            .frame(height: 220)
        }
        .cardStyle()
    }

    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("每周训练时长")
                .font(.headline)

            Chart(store.weeklyTrainingEntries) { entry in
                BarMark(
                    x: .value("周", entry.weekLabel),
                    y: .value("分钟", entry.minutes)
                )
            }
            .frame(height: 220)
        }
        .cardStyle()
    }

    private var addWeightSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("新增体重记录")
                .font(.headline)

            DatePicker("日期", selection: $newWeightDate, displayedComponents: .date)
            TextField("体重（kg）", text: $newWeightText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)

            Button("保存体重") {
                guard let weight = Double(newWeightText), weight > 0 else { return }
                store.addBodyWeight(date: newWeightDate, weight: weight)
                newWeightText = ""
            }
            .buttonStyle(.borderedProminent)
        }
        .cardStyle()
    }

    private var addWeeklySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("新增每周训练时长")
                .font(.headline)

            TextField("周标签（例如 2026-W11）", text: $newWeekLabel)
                .textFieldStyle(.roundedBorder)
            TextField("训练时长（分钟）", text: $newWeekMinutes)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)

            Button("保存周数据") {
                let trimmed = newWeekLabel.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty,
                      let minutes = Int(newWeekMinutes),
                      minutes >= 0 else { return }
                store.addWeeklyTraining(weekLabel: trimmed, minutes: minutes)
                newWeekLabel = ""
                newWeekMinutes = ""
            }
            .buttonStyle(.borderedProminent)
        }
        .cardStyle()
    }

    private var weightListSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("体重记录列表")
                .font(.headline)

            ForEach(store.bodyWeightEntries) { entry in
                HStack {
                    Text(entry.date)
                    Spacer()
                    Text(String(format: "%.1f kg", entry.weight))
                        .foregroundStyle(.secondary)
                }
                .swipeActions {
                    Button("删除", role: .destructive) {
                        store.deleteBodyWeight(id: entry.id)
                    }
                    Button("编辑") {
                        editingWeightEntry = entry
                    }
                    .tint(.blue)
                }
            }
        }
        .cardStyle()
    }

    private var weeklyListSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("每周训练时长列表")
                .font(.headline)

            ForEach(store.weeklyTrainingEntries) { entry in
                HStack {
                    Text(entry.weekLabel)
                    Spacer()
                    Text("\(entry.minutes) 分钟")
                        .foregroundStyle(.secondary)
                }
                .swipeActions {
                    Button("删除", role: .destructive) {
                        store.deleteWeeklyTraining(id: entry.id)
                    }
                    Button("编辑") {
                        editingWeekEntry = entry
                    }
                    .tint(.blue)
                }
            }
        }
        .cardStyle()
    }
}

private struct EditWeightSheet: View {
    let entry: BodyWeightEntry
    let onSave: (Date, Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var date: Date
    @State private var weightText: String

    init(entry: BodyWeightEntry, onSave: @escaping (Date, Double) -> Void) {
        self.entry = entry
        self.onSave = onSave
        _date = State(initialValue: entry.parsedDate)
        _weightText = State(initialValue: String(format: "%.1f", entry.weight))
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("日期", selection: $date, displayedComponents: .date)
                TextField("体重（kg）", text: $weightText)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("编辑体重")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        guard let weight = Double(weightText), weight > 0 else { return }
                        onSave(date, weight)
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct EditWeekSheet: View {
    let entry: WeeklyTrainingEntry
    let onSave: (String, Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var weekLabel: String
    @State private var minutesText: String

    init(entry: WeeklyTrainingEntry, onSave: @escaping (String, Int) -> Void) {
        self.entry = entry
        self.onSave = onSave
        _weekLabel = State(initialValue: entry.weekLabel)
        _minutesText = State(initialValue: "\(entry.minutes)")
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("周标签", text: $weekLabel)
                TextField("分钟", text: $minutesText)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("编辑周数据")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let trimmed = weekLabel.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty,
                              let minutes = Int(minutesText),
                              minutes >= 0 else { return }
                        onSave(trimmed, minutes)
                        dismiss()
                    }
                }
            }
        }
    }
}

private extension View {
    func cardStyle() -> some View {
        self
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemBackground))
            )
    }
}
