import Foundation

struct ExerciseMovement: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let targetArea: String
    let equipment: String
    let instruction: String
    let commonMistakes: [String]
    let imageName: String
}
