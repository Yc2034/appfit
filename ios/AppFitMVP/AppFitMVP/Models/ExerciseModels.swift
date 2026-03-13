import Foundation

struct ExerciseMovement: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let targetArea: String
    let equipment: String
    let instruction: String
    let tags: [String]
    let keyPoints: [String]
    let imageName: String
    let demoImageNames: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case targetArea
        case equipment
        case instruction
        case tags
        case keyPoints
        case commonMistakes
        case imageName
        case demoImageNames
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        targetArea = try container.decode(String.self, forKey: .targetArea)
        equipment = try container.decode(String.self, forKey: .equipment)
        instruction = try container.decode(String.self, forKey: .instruction)
        imageName = try container.decode(String.self, forKey: .imageName)
        demoImageNames = try container.decodeIfPresent([String].self, forKey: .demoImageNames) ?? []

        let decodedTags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        tags = decodedTags.isEmpty ? [category] : decodedTags

        if let decodedKeyPoints = try container.decodeIfPresent([String].self, forKey: .keyPoints),
           !decodedKeyPoints.isEmpty {
            keyPoints = decodedKeyPoints
        } else {
            keyPoints = try container.decodeIfPresent([String].self, forKey: .commonMistakes) ?? []
        }
    }
}
