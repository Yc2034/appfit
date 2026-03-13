import Foundation

protocol ExerciseRepository {
    func loadMovements() throws -> [ExerciseMovement]
}

enum LocalExerciseRepositoryError: LocalizedError {
    case missingFiles
    case decodeFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingFiles:
            return "无法找到本地动作数据文件，请检查 ExerciseLibrary 文件夹"
        case .decodeFailed(let fileName):
            return "动作数据格式无效，请检查 \(fileName)"
        }
    }
}

struct LocalExerciseRepository: ExerciseRepository {
    func loadMovements() throws -> [ExerciseMovement] {
        let urls = (Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? [])
            .filter { $0.deletingPathExtension().lastPathComponent.hasPrefix("movement_") }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        guard !urls.isEmpty else {
            throw LocalExerciseRepositoryError.missingFiles
        }

        let decoder = JSONDecoder()
        return try urls.map { url in
            let data = try Data(contentsOf: url)
            guard let movement = try? decoder.decode(ExerciseMovement.self, from: data) else {
                throw LocalExerciseRepositoryError.decodeFailed(url.lastPathComponent)
            }
            return movement
        }
    }
}
