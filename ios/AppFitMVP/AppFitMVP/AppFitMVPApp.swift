import SwiftUI

@main
struct AppFitMVPApp: App {
    @StateObject private var courseStore = CourseStore(repository: LocalCourseRepository())
    @StateObject private var exerciseStore = ExerciseStore(repository: LocalExerciseRepository())
    @StateObject private var progressStore = ProgressStore(repository: LocalProgressRepository())

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(courseStore)
                .environmentObject(exerciseStore)
                .environmentObject(progressStore)
                .task {
                    courseStore.loadCoursesIfNeeded()
                    exerciseStore.loadMovementsIfNeeded()
                    progressStore.loadIfNeeded()
                }
        }
    }
}
