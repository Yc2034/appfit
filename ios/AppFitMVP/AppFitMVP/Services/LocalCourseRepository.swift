import Foundation

protocol CourseRepository {
    func loadCourses() throws -> [FitnessCourse]
}

enum LocalCourseRepositoryError: LocalizedError {
    case missingFile
    case decodeFailed

    var errorDescription: String? {
        switch self {
        case .missingFile:
            return "无法找到本地课程数据文件 courses.json"
        case .decodeFailed:
            return "课程数据格式无效，请检查 courses.json"
        }
    }
}

struct LocalCourseRepository: CourseRepository {
    func loadCourses() throws -> [FitnessCourse] {
        guard let url = Bundle.main.url(forResource: "courses", withExtension: "json") else {
            throw LocalCourseRepositoryError.missingFile
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()

        guard let courses = try? decoder.decode([FitnessCourse].self, from: data) else {
            throw LocalCourseRepositoryError.decodeFailed
        }

        return courses
    }
}
