import SwiftUI

struct MovementLibraryTabView: View {
    @EnvironmentObject private var store: ExerciseStore

    var body: some View {
        NavigationStack {
            ZStack {
                AppGradient.subtleBackground
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("动作细节")
            .searchable(text: $store.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索动作、类别、目标肌群")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("刷新") {
                        store.loadMovements()
                    }
                    .font(AppFont.caption())
                }
            }
            .navigationDestination(for: ExerciseMovement.self) { movement in
                MovementDetailView(movement: movement)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if store.isLoading {
            ProgressView("加载动作中...")
                .font(AppFont.body())
                .tint(AppColor.accent)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = store.errorMessage {
            ContentUnavailableView("加载失败", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
        } else if store.filteredMovements.isEmpty {
            ContentUnavailableView("暂无动作", systemImage: "figure.strengthtraining.traditional", description: Text("请在 exercise_library.json 中补充动作"))
        } else {
            List(store.filteredMovements) { movement in
                NavigationLink(value: movement) {
                    MovementRowView(movement: movement)
                        .padding(.vertical, AppLayout.space4)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: AppLayout.space4, leading: AppLayout.screenPadding, bottom: AppLayout.space4, trailing: AppLayout.screenPadding))
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        }
    }
}

private struct MovementRowView: View {
    let movement: ExerciseMovement

    var body: some View {
        AppFitCard(style: .elevated) {
            HStack(spacing: AppLayout.space12) {
                LocalImageView(imageName: movement.imageName, height: 96)
                    .frame(width: 110)
                    .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius14))

                VStack(alignment: .leading, spacing: AppLayout.space8) {
                    Text(movement.name)
                        .font(AppFont.headline())
                        .foregroundStyle(AppColor.textPrimary)

                    Text(movement.category)
                        .font(AppFont.caption())
                        .foregroundStyle(AppColor.textSecondary)

                    Text("目标：\(movement.targetArea)")
                        .font(AppFont.caption())
                        .foregroundStyle(AppColor.textSecondary)

                    Text("器械：\(movement.equipment)")
                        .font(AppFont.caption())
                        .foregroundStyle(AppColor.textSecondary)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

struct MovementDetailView: View {
    let movement: ExerciseMovement

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppLayout.space16) {
                LocalImageView(imageName: movement.imageName, height: 230)
                    .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius18))

                AppFitCard(style: .elevated) {
                    VStack(alignment: .leading, spacing: AppLayout.space8) {
                        Text(movement.name)
                            .font(AppFont.title())
                            .foregroundStyle(AppColor.textPrimary)

                        Text("\(movement.category) · \(movement.targetArea)")
                            .font(AppFont.body())
                            .foregroundStyle(AppColor.textSecondary)

                        TagView(text: "器械：\(movement.equipment)")
                    }
                }

                AppFitCard {
                    VStack(alignment: .leading, spacing: AppLayout.space8) {
                        AppSectionHeader(title: "动作说明")
                        Text(movement.instruction)
                            .font(AppFont.body())
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }

                AppFitCard {
                    VStack(alignment: .leading, spacing: AppLayout.space10) {
                        AppSectionHeader(title: "常见错误")
                        ForEach(movement.commonMistakes, id: \.self) { item in
                            HStack(alignment: .top, spacing: AppLayout.space8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(AppColor.warning)
                                Text(item)
                                    .font(AppFont.body())
                                    .foregroundStyle(AppColor.textSecondary)
                            }
                        }
                    }
                }
            }
            .padding(AppLayout.screenPadding)
        }
        .background(AppGradient.subtleBackground.ignoresSafeArea())
        .navigationTitle("动作详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
