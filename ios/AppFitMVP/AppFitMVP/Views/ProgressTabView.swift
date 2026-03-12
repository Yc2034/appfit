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
            VStack(alignment: .leading, spacing: AppLayout.space16) {
                AppSectionHeader(title: "体重趋势", subtitle: "体重变化历史记录")

                if store.bodyWeightMonthlyEntries.isEmpty {
                    Text("暂无记录")
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
                        .lineStyle(StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
                        .foregroundStyle(AppGradient.hero)

                        AreaMark(
                            x: .value("月份", entry.parsedMonth),
                            y: .value("体重", entry.weight)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColor.accent.opacity(0.4), AppColor.accent.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        PointMark(
                            x: .value("月份", entry.parsedMonth),
                            y: .value("体重", entry.weight)
                        )
                        .symbolSize(120)
                        .foregroundStyle(AppColor.card)

                        PointMark(
                            x: .value("月份", entry.parsedMonth),
                            y: .value("体重", entry.weight)
                        )
                        .symbolSize(50)
                        .foregroundStyle(AppColor.accent)
                    }
                    .chartYScale(domain: .automatic(includesZero: false))
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .month)) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                                .foregroundStyle(AppColor.divider.opacity(0.4))
                            AxisValueLabel(format: .dateTime.month(.abbreviated))
                                .font(AppFont.caption())
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                                .foregroundStyle(AppColor.divider.opacity(0.4))
                            AxisValueLabel() {
                                if let weight = value.as(Double.self) {
                                    Text("\(weight, specifier: "%.1f")")
                                        .font(AppFont.caption())
                                        .foregroundStyle(AppColor.textSecondary)
                                }
                            }
                        }
                    }
                    .frame(height: 240)
                    .padding(.top, 8)
                }
            }
        }
    }

    private var monthlyTrainingChartSection: some View {
        AppFitCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppLayout.space16) {
                AppSectionHeader(title: "训练时长分布", subtitle: "各类别训练时长（分钟）")

                if trainingPoints.isEmpty {
                    Text("暂无数据")
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
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                                .foregroundStyle(AppColor.divider.opacity(0.4))
                            AxisValueLabel(format: .dateTime.month(.abbreviated))
                                .font(AppFont.caption())
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                                .foregroundStyle(AppColor.divider.opacity(0.4))
                            AxisValueLabel() {
                                if let mins = value.as(Int.self) {
                                    Text("\(mins)")
                                        .font(AppFont.caption())
                                        .foregroundStyle(AppColor.textSecondary)
                                }
                            }
                        }
                    }
                    .chartLegend(position: .bottom, alignment: .leading, spacing: AppLayout.space12)
                    .frame(height: 260)
                    .padding(.top, 8)
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
            Color.indigo,
            Color.mint,
            Color.pink,
            Color.orange,
            Color.teal
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
