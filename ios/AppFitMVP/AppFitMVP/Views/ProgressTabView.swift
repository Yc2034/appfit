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

                    monthlyTrainingChartSection
                    weightChartSection
                }
                .padding(AppLayout.screenPadding)
                .padding(.bottom, AppLayout.space20)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: AppLayout.space20)
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
                        .lineStyle(StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                        .foregroundStyle(AppColor.accent.opacity(0.7))

                        AreaMark(
                            x: .value("月份", entry.parsedMonth),
                            y: .value("体重", entry.weight)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColor.accent.opacity(0.2), AppColor.accent.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
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
                    .frame(height: 160)
                    .padding(.top, 8)
                }
            }
        }
    }

    private var monthlyTrainingChartSection: some View {
        AppFitCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppLayout.space16) {
                AppSectionHeader(title: "锻炼成就", subtitle: "每月坚持挥洒汗水的时间")

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
                        
                        // Add a subtle background shading to each bar for depth
                        if let lastCategory = trainingPoints.last(where: { $0.month == point.month })?.category, point.category == lastCategory {
                            // Only add this for the top of the stack or we could use annotations
                        }
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
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                .foregroundStyle(AppColor.divider.opacity(0.3))
                            AxisValueLabel() {
                                if let mins = value.as(Int.self) {
                                    Text("\(mins) m")
                                        .font(AppFont.tiny())
                                        .foregroundStyle(AppColor.textSecondary)
                                }
                            }
                        }
                    }
                    .chartLegend(position: .top, alignment: .trailing, spacing: AppLayout.space8)
                    .frame(height: 280)
                    .padding(.top, AppLayout.space12)
                    .padding(.bottom, AppLayout.space8)
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
