import SwiftUI
import Charts

struct ProgressTabView: View {
    @EnvironmentObject private var store: ProgressStore

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
                    monthlyTrainingChartSection
                }
                .padding(AppLayout.screenPadding)
            }
            .background(AppGradient.subtleBackground.ignoresSafeArea())
            .navigationTitle("训练数据")
        }
    }

    private var weightChartSection: some View {
        AppFitCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppLayout.space12) {
                AppSectionHeader(title: "月度体重趋势", subtitle: "按月份追踪体重变化")

                if store.bodyWeightMonthlyEntries.isEmpty {
                    Text("暂无月度体重记录")
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
                        AxisMarks(values: .stride(by: .month)) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.6))
                                .foregroundStyle(AppColor.divider.opacity(0.5))
                            AxisTick()
                            AxisValueLabel(format: .dateTime.year().month(.twoDigits))
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.6))
                                .foregroundStyle(AppColor.divider.opacity(0.5))
                            AxisTick()
                            AxisValueLabel()
                        }
                    }
                    .frame(height: 220)
                }
            }
        }
    }

    private var monthlyTrainingChartSection: some View {
        AppFitCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppLayout.space12) {
                AppSectionHeader(title: "月度训练时长", subtitle: "分类累加柱状图（分钟）")

                if trainingPoints.isEmpty {
                    Text("暂无月度训练数据")
                        .font(AppFont.body())
                        .foregroundStyle(AppColor.textSecondary)
                        .padding(.vertical, AppLayout.space12)
                } else {
                    Chart(trainingPoints) { point in
                        BarMark(
                            x: .value("月份", point.parsedMonth),
                            y: .value("分钟", point.minutes)
                        )
                        .foregroundStyle(by: .value("类别", point.category))
                        .cornerRadius(AppLayout.radius10)
                    }
                    .chartForegroundStyleScale(domain: categoryDomain, range: categoryRange)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .month)) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.6))
                                .foregroundStyle(AppColor.divider.opacity(0.5))
                            AxisTick()
                            AxisValueLabel(format: .dateTime.year().month(.twoDigits))
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.6))
                                .foregroundStyle(AppColor.divider.opacity(0.5))
                            AxisTick()
                            AxisValueLabel()
                        }
                    }
                    .chartLegend(position: .bottom, alignment: .leading, spacing: AppLayout.space8)
                    .frame(height: 280)
                }
            }
        }
    }

    private var trainingPoints: [MonthlyTrainingChartPoint] {
        store.monthlyTrainingEntries.flatMap { monthly in
            monthly.categories.map { category in
                MonthlyTrainingChartPoint(
                    month: monthly.month,
                    category: category.category,
                    minutes: category.minutes
                )
            }
        }
    }

    private var categoryDomain: [String] {
        var ordered: [String] = []
        for point in trainingPoints where !ordered.contains(point.category) {
            ordered.append(point.category)
        }
        return ordered
    }

    private var categoryRange: [Color] {
        let palette: [Color] = [
            AppColor.accent,
            AppColor.success,
            AppColor.warning,
            AppColor.accentDeep,
            AppColor.textSecondary
        ]
        return categoryDomain.enumerated().map { index, _ in
            palette[index % palette.count]
        }
    }
}

private struct MonthlyTrainingChartPoint: Identifiable {
    let id: String
    let month: String
    let category: String
    let minutes: Int

    init(month: String, category: String, minutes: Int) {
        self.id = "\(month)-\(category)"
        self.month = month
        self.category = category
        self.minutes = minutes
    }

    var parsedMonth: Date {
        DateParsers.monthFormatter.date(from: month) ?? Date()
    }
}
