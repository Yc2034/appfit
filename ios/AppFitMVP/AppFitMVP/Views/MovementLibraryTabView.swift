import SwiftUI

struct MovementLibraryTabView: View {
    @EnvironmentObject private var store: ExerciseStore

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("动作细节")
                .searchable(text: $store.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索动作、类别、目标肌群")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("刷新") {
                            store.loadMovements()
                        }
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = store.errorMessage {
            ContentUnavailableView("加载失败", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
        } else if store.filteredMovements.isEmpty {
            ContentUnavailableView("暂无动作", systemImage: "figure.strengthtraining.traditional", description: Text("请在 exercise_library.json 中补充动作"))
        } else {
            List(store.filteredMovements) { movement in
                NavigationLink(value: movement) {
                    MovementRowView(movement: movement)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            }
            .listStyle(.plain)
        }
    }
}

private struct MovementRowView: View {
    let movement: ExerciseMovement

    var body: some View {
        HStack(spacing: 12) {
            LocalImageView(imageName: movement.imageName, height: 92)
                .frame(width: 110)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                Text(movement.name)
                    .font(.headline)
                Text(movement.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("目标：\(movement.targetArea) · 器械：\(movement.equipment)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct MovementDetailView: View {
    let movement: ExerciseMovement

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                LocalImageView(imageName: movement.imageName, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 8) {
                    Text(movement.name)
                        .font(.title2.bold())
                    Text("\(movement.category) · \(movement.targetArea)")
                        .foregroundStyle(.secondary)
                    Text("器械：\(movement.equipment)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("动作说明")
                        .font(.headline)
                    Text(movement.instruction)
                        .font(.body)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("常见错误")
                        .font(.headline)
                    ForEach(movement.commonMistakes, id: \.self) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundStyle(.orange)
                            Text(item)
                                .font(.body)
                        }
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("动作详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
