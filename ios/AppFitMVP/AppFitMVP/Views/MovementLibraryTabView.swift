import SwiftUI

struct MovementLibraryTabView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: ExerciseStore
    private let columns = [
        GridItem(.flexible(), spacing: AppLayout.space12),
        GridItem(.flexible(), spacing: AppLayout.space12)
    ]

    var body: some View {
        NavigationStack(path: $router.movementPath) {
            ZStack {
                AppGradient.subtleBackground
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("动作细节")
            .navigationDestination(for: MovementRoute.self) { route in
                MovementDetailView(movement: route.movement, source: route.source)
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
                                    NavigationLink(value: MovementRoute(movement: movement, source: .library)) {
                                        MovementGridCard(movement: movement)
                                    }
                                    .buttonStyle(MovementCardButtonStyle())

                                    Button {
                                        store.toggleFavorite(for: movement)
                                    } label: {
                                        Image(systemName: store.isFavorite(movement) ? "star.fill" : "star")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(store.isFavorite(movement) ? AppColor.textOnAccent : AppColor.textSecondary)
                                            .frame(width: 34, height: 34)
                                            .background(
                                                Circle()
                                                    .fill(
                                                        store.isFavorite(movement)
                                                        ? AnyShapeStyle(AppGradient.hero)
                                                        : AnyShapeStyle(AppColor.card.opacity(0.94))
                                                    )
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(AppColor.divider.opacity(store.isFavorite(movement) ? 0.0 : 0.5), lineWidth: 1)
                                            )
                                            .clipShape(Circle())
                                            .scaleEffect(store.isFavorite(movement) ? 1.0 : 0.96)
                                    }
                                    .buttonStyle(MovementPressableButtonStyle(pressedScale: 0.9))
                                    .padding(AppLayout.space10)
                                    .shadow(
                                        color: store.isFavorite(movement) ? AppColor.accent.opacity(0.24) : Color.black.opacity(0.05),
                                        radius: store.isFavorite(movement) ? 12 : 6,
                                        y: store.isFavorite(movement) ? 8 : 4
                                    )
                                    .animation(.spring(response: 0.28, dampingFraction: 0.8), value: store.isFavorite(movement))
                                    .zIndex(1)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, AppLayout.screenPadding)
                .padding(.vertical, AppLayout.space12)
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
            VStack(alignment: .leading, spacing: AppLayout.space12) {
                ZStack(alignment: .bottomLeading) {
                    LocalImageView(imageName: movement.imageName, height: 128)
                        .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius14))

                    LinearGradient(
                        colors: [Color.black.opacity(0.0), Color.black.opacity(0.42)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius14))

                    MovementMetaPill(text: movement.category, style: .accent)
                        .padding(AppLayout.space10)
                }

                Text(movement.name)
                    .font(AppFont.headline())
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: AppLayout.space8) {
                    Label(movement.targetArea, systemImage: "scope")
                        .font(AppFont.caption())
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(1)

                    Label(movement.equipment, systemImage: "dumbbell.fill")
                        .font(AppFont.caption())
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(1)
                }

                HStack(spacing: AppLayout.space8) {
                    ForEach(Array(movement.tags.prefix(2)), id: \.self) { tag in
                        MovementMetaPill(text: tag, style: .soft)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .shadow(color: Color.black.opacity(0.08), radius: 14, y: 8)
    }
}

struct MovementDetailView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: ExerciseStore
    let movement: ExerciseMovement
    let source: MovementRouteSource

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppLayout.space16) {
                heroSection

                HStack(spacing: AppLayout.space12) {
                    MovementInfoTile(title: "目标区域", value: movement.targetArea)
                    MovementInfoTile(title: "所需器械", value: movement.equipment)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppLayout.space8) {
                        ForEach(movement.tags, id: \.self) { tag in
                            MovementMetaPill(text: tag, style: .soft)
                        }
                    }
                    .padding(.vertical, 2)
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
                                        ZStack(alignment: .bottomLeading) {
                                            LocalImageView(imageName: imageName, height: 190)
                                                .frame(width: 272)
                                                .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius14))

                                            LinearGradient(
                                                colors: [Color.black.opacity(0.0), Color.black.opacity(0.34)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: AppLayout.radius14))

                                            Text("示例")
                                                .font(AppFont.caption())
                                                .foregroundStyle(Color.white)
                                                .padding(.horizontal, AppLayout.space10)
                                                .padding(.vertical, AppLayout.space8)
                                        }
                                        .shadow(color: Color.black.opacity(0.08), radius: 12, y: 8)
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
        .navigationBarBackButtonHidden(source == .course)
        .toolbar {
            if source == .course {
                ToolbarItem(placement: .topBarLeading) {
                    Button("返回课程") {
                        router.returnFromCourseLinkedMovement()
                    }
                    .foregroundStyle(AppColor.textPrimary)
                }
            }

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

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColor.accent.opacity(0.22),
                            AppColor.success.opacity(0.12),
                            Color.white.opacity(0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .fill(AppColor.accent.opacity(0.12))
                        .frame(width: 180, height: 180)
                        .blur(radius: 14)
                        .offset(x: 88, y: -84)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.34), lineWidth: 1)
                )

            LocalImageView(imageName: movement.imageName, height: 316)
                .scaleEffect(1.03)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .padding(8)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.08),
                    Color.black.opacity(0.18),
                    Color.black.opacity(0.68)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .padding(8)

            VStack(alignment: .leading, spacing: AppLayout.space10) {
                HStack(spacing: AppLayout.space8) {
                    MovementMetaPill(text: movement.category, style: .accent)

                    if store.isFavorite(movement) {
                        Label("已收藏", systemImage: "star.fill")
                            .font(AppFont.tiny())
                            .foregroundStyle(Color.white.opacity(0.96))
                            .padding(.horizontal, AppLayout.space10)
                            .padding(.vertical, 6)
                            .background(.white.opacity(0.14), in: Capsule())
                    }
                }

                Text(movement.name)
                    .font(AppFont.title())
                    .foregroundStyle(Color.white)

                HStack(spacing: AppLayout.space10) {
                    Label(movement.targetArea, systemImage: "scope")
                    Label(movement.equipment, systemImage: "dumbbell.fill")
                }
                .font(AppFont.caption())
                .foregroundStyle(Color.white.opacity(0.86))
            }
            .padding(.horizontal, AppLayout.space20)
            .padding(.bottom, AppLayout.space20)
        }
        .frame(height: 332)
        .shadow(color: AppColor.accent.opacity(0.16), radius: 26, y: 14)
    }
}

private struct MovementFilterChip: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppLayout.space8) {
                Circle()
                    .fill(isActive ? AnyShapeStyle(Color.white.opacity(0.92)) : AnyShapeStyle(AppColor.accent.opacity(0.18)))
                    .frame(width: 6, height: 6)

                Text(title)
                    .font(AppFont.tiny())
            }
            .foregroundStyle(isActive ? AppColor.textOnAccent : AppColor.textSecondary)
            .padding(.horizontal, AppLayout.space12)
            .padding(.vertical, AppLayout.space10)
            .background(
                Capsule()
                    .fill(isActive ? AnyShapeStyle(AppGradient.hero) : AnyShapeStyle(AppColor.card.opacity(0.94)))
            )
            .overlay(
                Capsule()
                    .stroke(isActive ? AppColor.accent.opacity(0.0) : AppColor.divider.opacity(0.65), lineWidth: 1)
            )
            .scaleEffect(isActive ? 1.0 : 0.97)
        }
        .buttonStyle(MovementPressableButtonStyle(pressedScale: 0.96))
        .shadow(color: isActive ? AppColor.accent.opacity(0.22) : Color.black.opacity(0.04), radius: isActive ? 12 : 6, y: isActive ? 8 : 4)
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isActive)
    }
}

private struct MovementInfoTile: View {
    let title: String
    let value: String

    var body: some View {
        AppFitCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppLayout.space8) {
                Text(title)
                    .font(AppFont.tiny())
                    .foregroundStyle(AppColor.textSecondary)

                Text(value)
                    .font(AppFont.bodyStrong())
                    .foregroundStyle(AppColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private enum MovementMetaPillStyle {
    case accent
    case soft
}

private struct MovementMetaPill: View {
    let text: String
    let style: MovementMetaPillStyle

    var body: some View {
        Text(text)
            .font(AppFont.tiny())
            .foregroundStyle(style == .accent ? AppColor.textOnAccent : AppColor.textSecondary)
            .padding(.horizontal, AppLayout.space10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(style == .accent ? AnyShapeStyle(AppGradient.hero) : AnyShapeStyle(AppColor.backgroundSecondary.opacity(0.92)))
            )
    }
}

private struct MovementCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .opacity(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}

private struct MovementPressableButtonStyle: ButtonStyle {
    let pressedScale: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}
