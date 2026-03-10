import Foundation

protocol ExerciseRepository {
    func loadMovements() throws -> [ExerciseMovement]
}

enum LocalExerciseRepositoryError: LocalizedError {
    case missingFile
    case decodeFailed

    var errorDescription: String? {
        switch self {
        case .missingFile:
            return "无法找到本地动作数据文件 exercise_library.json"
        case .decodeFailed:
            return "动作数据格式无效，请检查 exercise_library.json"
        }
    }
}

struct LocalExerciseRepository: ExerciseRepository {
    func loadMovements() throws -> [ExerciseMovement] {
        guard let url = Bundle.main.url(forResource: "exercise_library", withExtension: "json") else {
            throw LocalExerciseRepositoryError.missingFile
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()

        guard let movements = try? decoder.decode([ExerciseMovement].self, from: data) else {
            throw LocalExerciseRepositoryError.decodeFailed
        }

        return movements
    }
}
