import SwiftUI
import Charts

struct ProgressTabView: View {
    @EnvironmentObject private var store: ProgressStore
    @State private var selectedTrainingDetail: SelectedTrainingDetail?
    @State private var selectedWeightEntry: BodyWeightMonthlyEntry?

    private let visiblePointCount = 6
    private let weightChartDomain: ClosedRange<Double> = 65...90
    private let weightChartHeight: CGFloat = 132
    private let trainingChartHeight: CGFloat = 280
    private let chartEdgePadding: CGFloat = 20

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
                AppSectionHeader(title: "体重趋势")

                if store.bodyWeightMonthlyEntries.isEmpty {
                    Text("暂无记录")
                        .font(AppFont.body())
                        .foregroundStyle(AppColor.textSecondary)
                        .padding(.vertical, AppLayout.space12)
                } else {
                    selectedWeightSummary

                    GeometryReader { geometry in
                        ScrollView(.horizontal, showsIndicators: false) {
                            Chart(store.bodyWeightMonthlyEntries) { entry in
                                LineMark(
                                    x: .value("月份", entry.parsedMonth),
                                    y: .value("体重", entry.weight)
                                )
                                .interpolationMethod(.catmullRom)
                                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                                .foregroundStyle(AppColor.accent.opacity(0.8))

                                AreaMark(
                                    x: .value("月份", entry.parsedMonth),
                                    yStart: .value("基线", weightChartDomain.lowerBound),
                                    yEnd: .value("体重", entry.weight)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppColor.accent.opacity(0.18), AppColor.accent.opacity(0.0)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )

                                PointMark(
                                    x: .value("月份", entry.parsedMonth),
                                    y: .value("体重", entry.weight)
                                )
                                .symbolSize(28)
                                .foregroundStyle(AppColor.accent)

                                if selectedWeightEntry?.id == entry.id {
                                    PointMark(
                                        x: .value("月份", entry.parsedMonth),
                                        y: .value("体重", entry.weight)
                                    )
                                    .symbolSize(110)
                                    .foregroundStyle(AppColor.accent)
                                }
                            }
                            .chartXScale(range: .plotDimension(startPadding: chartEdgePadding, endPadding: chartEdgePadding))
                            .chartYScale(domain: weightChartDomain)
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
                                            Text("\(weight, specifier: "%.0f")kg")
                                                .font(AppFont.caption())
                                                .foregroundStyle(AppColor.textSecondary)
                                        }
                                    }
                                }
                            }
                            .chartPlotStyle { plotArea in
                                plotArea
                                    .background(AppColor.backgroundSecondary.opacity(0.22))
                                    .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius14))
                            }
                            .chartOverlay { proxy in
                                GeometryReader { chartGeometry in
                                    Rectangle()
                                        .fill(Color.clear)
                                        .contentShape(Rectangle())
                                        .gesture(
                                            SpatialTapGesture()
                                                .onEnded { value in
                                                    updateSelectedWeight(
                                                        at: value.location,
                                                        proxy: proxy,
                                                        geometry: chartGeometry
                                                    )
                                                }
                                        )
                                }
                            }
                            .frame(
                                width: chartWidth(
                                    pointCount: store.bodyWeightMonthlyEntries.count,
                                    containerWidth: geometry.size.width
                                ),
                                height: weightChartHeight
                            )
                            .padding(.top, 8)
                        }
                    }
                    .frame(height: weightChartHeight + AppLayout.space16)
                }
            }
        }
    }

    private var selectedWeightSummary: some View {
        Group {
            if let entry = selectedWeightEntry {
                HStack(spacing: AppLayout.space10) {
                    Circle()
                        .fill(AppColor.accent)
                        .frame(width: 10, height: 10)

                    Text("\(formattedMonthLabel(for: entry.month)) · \(entry.weight, specifier: "%.1f")kg")
                        .font(AppFont.bodyStrong())
                        .foregroundStyle(AppColor.textPrimary)

                    Spacer()
                }
                .padding(.horizontal, AppLayout.space12)
                .padding(.vertical, AppLayout.space10)
                .background(AppColor.backgroundSecondary.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius14))
            }
        }
    }

    private var monthlyTrainingChartSection: some View {
        AppFitCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppLayout.space16) {
                AppSectionHeader(title: "锻炼成就")

                if trainingPoints.isEmpty {
                    Text("暂无数据")
                        .font(AppFont.body())
                        .foregroundStyle(AppColor.textSecondary)
                        .padding(.vertical, AppLayout.space12)
                } else {
                    selectedTrainingSummary

                    GeometryReader { geometry in
                        ScrollView(.horizontal, showsIndicators: false) {
                            Chart(trainingPoints) { point in
                                BarMark(
                                    x: .value("月份", point.parsedMonth),
                                    y: .value("分钟", point.minutes)
                                )
                                .foregroundStyle(by: .value("类别", point.category))
                                .cornerRadius(AppLayout.radius10)
                            }
                            .chartXScale(range: .plotDimension(startPadding: chartEdgePadding, endPadding: chartEdgePadding))
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
                                        if let mins = value.as(Double.self) {
                                            Text("\(Int(mins.rounded()))m")
                                                .font(AppFont.tiny())
                                                .foregroundStyle(AppColor.textSecondary)
                                        }
                                    }
                                }
                            }
                            .chartLegend(position: .top, alignment: .leading, spacing: AppLayout.space8)
                            .chartPlotStyle { plotArea in
                                plotArea
                                    .background(AppColor.backgroundSecondary.opacity(0.22))
                                    .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius14))
                            }
                            .chartOverlay { proxy in
                                GeometryReader { chartGeometry in
                                    Rectangle()
                                        .fill(Color.clear)
                                        .contentShape(Rectangle())
                                        .gesture(
                                            SpatialTapGesture()
                                                .onEnded { value in
                                                    updateSelectedTraining(
                                                        at: value.location,
                                                        proxy: proxy,
                                                        geometry: chartGeometry
                                                    )
                                                }
                                        )
                                }
                            }
                            .frame(
                                width: chartWidth(
                                    pointCount: store.monthlyTrainingEntries.count,
                                    containerWidth: geometry.size.width
                                ),
                                height: trainingChartHeight
                            )
                            .padding(.top, AppLayout.space12)
                            .padding(.bottom, AppLayout.space8)
                        }
                    }
                    .frame(height: trainingChartHeight + AppLayout.space20)
                }
            }
        }
    }

    private var selectedTrainingSummary: some View {
        Group {
            if let detail = selectedTrainingDetail {
                HStack(spacing: AppLayout.space10) {
                    Circle()
                        .fill(color(for: detail.category))
                        .frame(width: 10, height: 10)

                    Text("\(detail.monthLabel) · \(detail.category) · \(detail.minutes) 分钟")
                        .font(AppFont.bodyStrong())
                        .foregroundStyle(AppColor.textPrimary)

                    Spacer()
                }
                .padding(.horizontal, AppLayout.space12)
                .padding(.vertical, AppLayout.space10)
                .background(AppColor.backgroundSecondary.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius14))
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

    private func color(for category: String) -> Color {
        guard let index = categoryDomain.firstIndex(of: category) else {
            return AppColor.accent
        }
        return categoryRange[index]
    }

    private func chartWidth(pointCount: Int, containerWidth: CGFloat) -> CGFloat {
        let baseWidth = max(containerWidth, 240)
        guard pointCount > visiblePointCount else { return baseWidth }
        return baseWidth * CGFloat(pointCount) / CGFloat(visiblePointCount)
    }

    private func updateSelectedTraining(
        at location: CGPoint,
        proxy: ChartProxy,
        geometry: GeometryProxy
    ) {
        guard let plotFrame = proxy.plotFrame.map({ geometry[$0] }) else {
            selectedTrainingDetail = nil
            return
        }
        let relativeX = location.x - plotFrame.origin.x
        let relativeY = location.y - plotFrame.origin.y

        guard relativeX >= 0,
              relativeX <= plotFrame.size.width,
              relativeY >= 0,
              relativeY <= plotFrame.size.height else {
            selectedTrainingDetail = nil
            return
        }

        guard let tappedMonthDate = proxy.value(atX: relativeX, as: Date.self),
              let tappedMinutes = proxy.value(atY: relativeY, as: Double.self),
              let monthlyEntry = nearestTrainingEntry(to: tappedMonthDate),
              let selectedCategory = categoryHit(in: monthlyEntry, tappedMinutes: tappedMinutes) else {
            selectedTrainingDetail = nil
            return
        }

        selectedTrainingDetail = SelectedTrainingDetail(
            month: monthlyEntry.month,
            category: selectedCategory.category,
            minutes: selectedCategory.minutes
        )
    }

    private func updateSelectedWeight(
        at location: CGPoint,
        proxy: ChartProxy,
        geometry: GeometryProxy
    ) {
        guard let plotFrame = proxy.plotFrame.map({ geometry[$0] }) else {
            selectedWeightEntry = nil
            return
        }
        let relativeX = location.x - plotFrame.origin.x
        let relativeY = location.y - plotFrame.origin.y

        guard relativeX >= 0,
              relativeX <= plotFrame.size.width,
              relativeY >= 0,
              relativeY <= plotFrame.size.height else {
            selectedWeightEntry = nil
            return
        }

        guard let tappedMonthDate = proxy.value(atX: relativeX, as: Date.self) else {
            selectedWeightEntry = nil
            return
        }

        selectedWeightEntry = nearestWeightEntry(to: tappedMonthDate)
    }

    private func nearestTrainingEntry(to date: Date) -> MonthlyTrainingEntry? {
        store.monthlyTrainingEntries.min {
            abs($0.parsedMonth.timeIntervalSince(date)) < abs($1.parsedMonth.timeIntervalSince(date))
        }
    }

    private func nearestWeightEntry(to date: Date) -> BodyWeightMonthlyEntry? {
        store.bodyWeightMonthlyEntries.min {
            abs($0.parsedMonth.timeIntervalSince(date)) < abs($1.parsedMonth.timeIntervalSince(date))
        }
    }

    private func categoryHit(
        in entry: MonthlyTrainingEntry,
        tappedMinutes: Double
    ) -> TrainingCategoryMinutes? {
        guard tappedMinutes > 0 else { return nil }

        var lowerBound = 0.0
        for category in entry.categories {
            let upperBound = lowerBound + Double(category.minutes)
            if tappedMinutes >= lowerBound && tappedMinutes <= upperBound {
                return category
            }
            lowerBound = upperBound
        }

        return nil
    }

    private func formattedMonthLabel(for month: String) -> String {
        let date = DateParsers.monthFormatter.date(from: month) ?? Date()
        return DateParsers.monthLabelFormatter.string(from: date)
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

private struct SelectedTrainingDetail: Identifiable {
    let month: String
    let category: String
    let minutes: Int

    var id: String {
        "\(month)-\(category)"
    }

    var monthLabel: String {
        let date = DateParsers.monthFormatter.date(from: month) ?? Date()
        return DateParsers.monthLabelFormatter.string(from: date)
    }
}
