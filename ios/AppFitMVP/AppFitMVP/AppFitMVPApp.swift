import SwiftUI

@main
struct AppFitMVPApp: App {
    @StateObject private var store = CourseStore(repository: LocalCourseRepository())

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
                .task {
                    store.loadCoursesIfNeeded()
                }
        }
    }
}
