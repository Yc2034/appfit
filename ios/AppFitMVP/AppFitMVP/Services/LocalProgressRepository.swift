import Foundation

protocol ProgressRepository {
    func loadSeedData() throws -> ProgressSeedData
}

enum LocalProgressRepositoryError: LocalizedError {
    case missingBodyWeightFile
    case missingTrainingFile
    case bodyWeightDecodeFailed
    case trainingDecodeFailed

    var errorDescription: String? {
        switch self {
        case .missingBodyWeightFile:
            return "无法找到本地体重数据文件 body_weight_seed.json"
        case .missingTrainingFile:
            return "无法找到本地训练数据文件 training_seed.json"
        case .bodyWeightDecodeFailed:
            return "体重数据格式无效，请检查 body_weight_seed.json"
        case .trainingDecodeFailed:
            return "训练数据格式无效，请检查 training_seed.json"
        }
    }
}

struct LocalProgressRepository: ProgressRepository {
    func loadSeedData() throws -> ProgressSeedData {
        let bodyWeightSeed: BodyWeightSeedData = try loadJSON(
            resource: "body_weight_seed",
            missingError: .missingBodyWeightFile,
            decodeError: .bodyWeightDecodeFailed
        )
        let trainingSeed: TrainingSeedData = try loadJSON(
            resource: "training_seed",
            missingError: .missingTrainingFile,
            decodeError: .trainingDecodeFailed
        )

        return ProgressSeedData(
            schemaVersion: max(bodyWeightSeed.schemaVersion ?? 0, trainingSeed.schemaVersion ?? 0),
            bodyWeightMonthlyEntries: bodyWeightSeed.bodyWeightMonthlyEntries,
            monthlyTrainingEntries: trainingSeed.monthlyTrainingEntries
        )
    }

    private func loadJSON<T: Decodable>(
        resource: String,
        missingError: LocalProgressRepositoryError,
        decodeError: LocalProgressRepositoryError
    ) throws -> T {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            throw missingError
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()

        guard let result = try? decoder.decode(T.self, from: data) else {
            throw decodeError
        }

        return result
    }
}
