import Foundation

protocol ProgressRepository {
    func loadSeedData() throws -> ProgressSeedData
}

enum LocalProgressRepositoryError: LocalizedError {
    case missingFile
    case decodeFailed

    var errorDescription: String? {
        switch self {
        case .missingFile:
            return "无法找到本地进度数据文件 progress_seed.json"
        case .decodeFailed:
            return "进度数据格式无效，请检查 progress_seed.json"
        }
    }
}

struct LocalProgressRepository: ProgressRepository {
    func loadSeedData() throws -> ProgressSeedData {
        guard let url = Bundle.main.url(forResource: "progress_seed", withExtension: "json") else {
            throw LocalProgressRepositoryError.missingFile
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()

        guard let seed = try? decoder.decode(ProgressSeedData.self, from: data) else {
            throw LocalProgressRepositoryError.decodeFailed
        }

        return seed
    }
}
