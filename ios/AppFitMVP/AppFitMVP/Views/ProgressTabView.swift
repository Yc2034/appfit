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
                VStack(alignment: .leading, spacing: AppLayout.space16) {
                    if let errorMessage = store.errorMessage {
                        AppFitCard {
                            Text(errorMessage)
                                .font(AppFont.body())
                                .foregroundStyle(AppColor.danger)
                        }
                    }

                    weightChartSection
                    weeklyChartSection
                    addWeightSection
                    addWeeklySection
                    weightListSection
                    weeklyListSection
                }
                .padding(AppLayout.screenPadding)
            }
            .background(AppGradient.subtleBackground.ignoresSafeArea())
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
        AppFitCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppLayout.space12) {
                AppSectionHeader(title: "体重变化", subtitle: "最近记录趋势")

                Chart(store.bodyWeightEntries) { entry in
                    LineMark(
                        x: .value("日期", entry.parsedDate),
                        y: .value("体重", entry.weight)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(AppColor.accent)

                    PointMark(
                        x: .value("日期", entry.parsedDate),
                        y: .value("体重", entry.weight)
                    )
                    .foregroundStyle(AppColor.accentDeep)
                }
                .frame(height: 220)
            }
        }
    }

    private var weeklyChartSection: some View {
        AppFitCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppLayout.space12) {
                AppSectionHeader(title: "每周训练时长", subtitle: "按周累计分钟数")

                Chart(store.weeklyTrainingEntries) { entry in
                    BarMark(
                        x: .value("周", entry.weekLabel),
                        y: .value("分钟", entry.minutes)
                    )
                    .foregroundStyle(AppColor.accent)
                    .cornerRadius(AppLayout.radius10)
                }
                .frame(height: 220)
            }
        }
    }

    private var addWeightSection: some View {
        AppFitCard {
            VStack(alignment: .leading, spacing: AppLayout.space12) {
                AppSectionHeader(title: "新增体重记录")

                DatePicker("日期", selection: $newWeightDate, displayedComponents: .date)
                    .font(AppFont.body())

                TextField("体重（kg）", text: $newWeightText)
                    .font(AppFont.body())
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)

                AppFitButton("保存体重", icon: "plus") {
                    guard let weight = Double(newWeightText), weight > 0 else { return }
                    store.addBodyWeight(date: newWeightDate, weight: weight)
                    newWeightText = ""
                }
            }
        }
    }

    private var addWeeklySection: some View {
        AppFitCard {
            VStack(alignment: .leading, spacing: AppLayout.space12) {
                AppSectionHeader(title: "新增每周训练时长")

                TextField("周标签（例如 2026-W11）", text: $newWeekLabel)
                    .font(AppFont.body())
                    .textFieldStyle(.roundedBorder)

                TextField("训练时长（分钟）", text: $newWeekMinutes)
                    .font(AppFont.body())
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                AppFitButton("保存周数据", icon: "plus") {
                    let trimmed = newWeekLabel.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty,
                          let minutes = Int(newWeekMinutes),
                          minutes >= 0 else { return }
                    store.addWeeklyTraining(weekLabel: trimmed, minutes: minutes)
                    newWeekLabel = ""
                    newWeekMinutes = ""
                }
            }
        }
    }

    private var weightListSection: some View {
        AppFitCard {
            VStack(alignment: .leading, spacing: AppLayout.space10) {
                AppSectionHeader(title: "体重记录列表")

                if store.bodyWeightEntries.isEmpty {
                    Text("暂无体重记录")
                        .font(AppFont.body())
                        .foregroundStyle(AppColor.textSecondary)
                } else {
                    ForEach(store.bodyWeightEntries) { entry in
                        HStack {
                            Text(entry.date)
                                .font(AppFont.body())
                                .foregroundStyle(AppColor.textPrimary)

                            Spacer()

                            Text(String(format: "%.1f kg", entry.weight))
                                .font(AppFont.bodyStrong())
                                .foregroundStyle(AppColor.textSecondary)
                        }
                        .padding(.vertical, AppLayout.space4)
                        .swipeActions {
                            Button("删除", role: .destructive) {
                                store.deleteBodyWeight(id: entry.id)
                            }
                            Button("编辑") {
                                editingWeightEntry = entry
                            }
                            .tint(AppColor.accent)
                        }

                        if entry.id != store.bodyWeightEntries.last?.id {
                            Divider()
                                .overlay(AppColor.divider)
                        }
                    }
                }
            }
        }
    }

    private var weeklyListSection: some View {
        AppFitCard {
            VStack(alignment: .leading, spacing: AppLayout.space10) {
                AppSectionHeader(title: "每周训练时长列表")

                if store.weeklyTrainingEntries.isEmpty {
                    Text("暂无周训练记录")
                        .font(AppFont.body())
                        .foregroundStyle(AppColor.textSecondary)
                } else {
                    ForEach(store.weeklyTrainingEntries) { entry in
                        HStack {
                            Text(entry.weekLabel)
                                .font(AppFont.body())
                                .foregroundStyle(AppColor.textPrimary)

                            Spacer()

                            Text("\(entry.minutes) 分钟")
                                .font(AppFont.bodyStrong())
                                .foregroundStyle(AppColor.textSecondary)
                        }
                        .padding(.vertical, AppLayout.space4)
                        .swipeActions {
                            Button("删除", role: .destructive) {
                                store.deleteWeeklyTraining(id: entry.id)
                            }
                            Button("编辑") {
                                editingWeekEntry = entry
                            }
                            .tint(AppColor.accent)
                        }

                        if entry.id != store.weeklyTrainingEntries.last?.id {
                            Divider()
                                .overlay(AppColor.divider)
                        }
                    }
                }
            }
        }
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
                    .font(AppFont.body())

                TextField("体重（kg）", text: $weightText)
                    .font(AppFont.body())
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("编辑体重")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .font(AppFont.body())
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        guard let weight = Double(weightText), weight > 0 else { return }
                        onSave(date, weight)
                        dismiss()
                    }
                    .font(AppFont.bodyStrong())
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
                    .font(AppFont.body())

                TextField("分钟", text: $minutesText)
                    .font(AppFont.body())
                    .keyboardType(.numberPad)
            }
            .navigationTitle("编辑周数据")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .font(AppFont.body())
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
                    .font(AppFont.bodyStrong())
                }
            }
        }
    }
}
