import SwiftUI

struct MovementLibraryTabView: View {
    @EnvironmentObject private var store: ExerciseStore
    private let columns = [
        GridItem(.flexible(), spacing: AppLayout.space12),
        GridItem(.flexible(), spacing: AppLayout.space12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppGradient.subtleBackground
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("动作细节")
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
        } else if store.movements.isEmpty {
            ContentUnavailableView("暂无动作", systemImage: "figure.strengthtraining.traditional", description: Text("请在 ExerciseLibrary 文件夹中补充动作"))
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: AppLayout.space12) {
                    filterBar

                    if store.filteredMovements.isEmpty {
                        ContentUnavailableView(
                            "暂无匹配动作",
                            systemImage: "line.3.horizontal.decrease.circle",
                            description: Text("当前标签下没有动作")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppLayout.space20)
                    } else {
                        LazyVGrid(columns: columns, spacing: AppLayout.space12) {
                            ForEach(store.filteredMovements) { movement in
                                ZStack(alignment: .topTrailing) {
                                    NavigationLink(value: movement) {
                                        MovementGridCard(movement: movement)
                                    }
                                    .buttonStyle(.plain)

                                    Button {
                                        store.toggleFavorite(for: movement)
                                    } label: {
                                        Image(systemName: store.isFavorite(movement) ? "star.fill" : "star")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(store.isFavorite(movement) ? AppColor.accent : AppColor.textSecondary)
                                            .frame(width: 32, height: 32)
                                            .background(AppColor.card.opacity(0.92))
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.plain)
                                    .padding(AppLayout.space10)
                                    .zIndex(1)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, AppLayout.screenPadding)
                .padding(.vertical, AppLayout.space8)
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppLayout.space8) {
                MovementFilterChip(
                    title: "全部",
                    isActive: store.selectedTag == nil
                ) {
                    store.toggleTag(nil)
                }

                ForEach(store.availableTags, id: \.self) { tag in
                    MovementFilterChip(
                        title: tag,
                        isActive: store.selectedTag == tag
                    ) {
                        store.toggleTag(tag)
                    }
                }
            }
            .padding(.vertical, AppLayout.space4)
        }
    }
}

private struct MovementGridCard: View {
    let movement: ExerciseMovement

    var body: some View {
        AppFitCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppLayout.space10) {
                LocalImageView(imageName: movement.imageName, height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius14))

                Text(movement.name)
                    .font(AppFont.headline())
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(movement.category)
                    .font(AppFont.caption())
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(1)

                Text("目标：\(movement.targetArea)")
                    .font(AppFont.caption())
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(1)

                HStack(spacing: AppLayout.space8) {
                    TagView(text: movement.equipment)
                    if let firstTag = movement.tags.first {
                        TagView(text: firstTag)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct MovementDetailView: View {
    @EnvironmentObject private var store: ExerciseStore
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

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppLayout.space8) {
                                TagView(text: "器械：\(movement.equipment)")
                                ForEach(movement.tags, id: \.self) { tag in
                                    TagView(text: tag)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }

                AppFitCard {
                    VStack(alignment: .leading, spacing: AppLayout.space10) {
                        AppSectionHeader(title: "动作要领")
                        Text(movement.instruction)
                            .font(AppFont.body())
                            .foregroundStyle(AppColor.textSecondary)

                        ForEach(movement.keyPoints, id: \.self) { item in
                            HStack(alignment: .top, spacing: AppLayout.space8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppColor.success)
                                Text(item)
                                    .font(AppFont.body())
                                    .foregroundStyle(AppColor.textSecondary)
                            }
                        }
                    }
                }

                if !movement.demoImageNames.isEmpty {
                    AppFitCard {
                        VStack(alignment: .leading, spacing: AppLayout.space12) {
                            AppSectionHeader(title: "动作示例")

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppLayout.space12) {
                                    ForEach(movement.demoImageNames, id: \.self) { imageName in
                                        LocalImageView(imageName: imageName, height: 180)
                                            .frame(width: 260)
                                            .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius14))
                                    }
                                }
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.toggleFavorite(for: movement)
                } label: {
                    Image(systemName: store.isFavorite(movement) ? "star.fill" : "star")
                        .foregroundStyle(store.isFavorite(movement) ? AppColor.accent : AppColor.textPrimary)
                }
            }
        }
    }
}

private struct MovementFilterChip: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.tiny())
                .foregroundStyle(isActive ? AppColor.textOnAccent : AppColor.textSecondary)
                .padding(.horizontal, AppLayout.space10)
                .padding(.vertical, AppLayout.space8)
                .background(
                    Capsule()
                        .fill(isActive ? AnyShapeStyle(AppGradient.hero) : AnyShapeStyle(AppColor.card))
                )
                .overlay(
                    Capsule()
                        .stroke(isActive ? AppColor.accent.opacity(0.0) : AppColor.divider.opacity(0.7), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
