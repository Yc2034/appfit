import SwiftUI
import Charts

struct ProgressTabView: View {
    @EnvironmentObject private var store: ProgressStore

    @State private var newWeekLabel: String = ""
    @State private var newWeekMinutes: String = ""

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
                    addWeeklySection
                    weeklyListSection
                }
                .padding(AppLayout.screenPadding)
            }
            .background(AppGradient.subtleBackground.ignoresSafeArea())
            .navigationTitle("训练数据")
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
                AppSectionHeader(title: "月度体重趋势", subtitle: "按月份追踪体重变化")

                Group {
                    if store.bodyWeightMonthlyEntries.isEmpty {
                        Text("暂无月度体重记录，先新增一条数据吧。")
                            .font(AppFont.body())
                            .foregroundStyle(AppColor.textSecondary)
                            .padding(.vertical, AppLayout.space12)
                    } else {
                        Chart(store.bodyWeightMonthlyEntries) { entry in
                            LineMark(
                                x: .value("月份", entry.parsedMonth),
                                y: .value("体重", entry.weight)
                            )
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                            .foregroundStyle(AppColor.accent)

                            AreaMark(
                                x: .value("月份", entry.parsedMonth),
                                y: .value("体重", entry.weight)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(AppColor.accent.opacity(0.12))

                            PointMark(
                                x: .value("月份", entry.parsedMonth),
                                y: .value("体重", entry.weight)
                            )
                            .symbolSize(36)
                            .foregroundStyle(AppColor.accentDeep)
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .month)) { value in
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.6))
                                    .foregroundStyle(AppColor.divider.opacity(0.5))
                                AxisTick()
                                AxisValueLabel(format: .dateTime.year().month(.twoDigits))
                            }
                        }
                        .chartYAxis {
                            AxisMarks { value in
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.6))
                                    .foregroundStyle(AppColor.divider.opacity(0.5))
                                AxisTick()
                                AxisValueLabel()
                            }
                        }
                    }
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

                            Button {
                                editingWeekEntry = entry
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AppColor.accent)
                            }
                            .buttonStyle(.plain)

                            Button(role: .destructive) {
                                store.deleteWeeklyTraining(id: entry.id)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .buttonStyle(.plain)
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
