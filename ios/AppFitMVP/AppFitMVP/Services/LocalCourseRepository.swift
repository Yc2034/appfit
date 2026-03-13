import Foundation

protocol CourseRepository {
    func loadCourses() throws -> [FitnessCourse]
}

enum LocalCourseRepositoryError: LocalizedError {
    case missingFiles
    case decodeFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingFiles:
            return "无法找到本地课程数据文件，请检查 CourseLibrary 文件夹"
        case .decodeFailed(let fileName):
            return "课程数据格式无效，请检查 \(fileName)"
        }
    }
}

struct LocalCourseRepository: CourseRepository {
    func loadCourses() throws -> [FitnessCourse] {
        let urls = (Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? [])
            .filter { $0.deletingPathExtension().lastPathComponent.hasPrefix("course_") }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        guard !urls.isEmpty else {
            throw LocalCourseRepositoryError.missingFiles
        }

        let decoder = JSONDecoder()
        return try urls.map { url in
            let data = try Data(contentsOf: url)
            guard let course = try? decoder.decode(FitnessCourse.self, from: data) else {
                throw LocalCourseRepositoryError.decodeFailed(url.lastPathComponent)
            }
            return course
        }
    }
}
