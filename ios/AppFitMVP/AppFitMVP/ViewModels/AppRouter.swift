import SwiftUI

enum AppTab: Hashable {
    case course
    case movement
    case progress
}

enum MovementRouteSource: Hashable {
    case library
    case course
}

struct MovementRoute: Hashable {
    let movement: ExerciseMovement
    let source: MovementRouteSource
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: AppTab = .course
    @Published var movementPath: [MovementRoute] = []

    private var returnTabAfterMovement: AppTab?

    func openMovementFromCourse(_ movement: ExerciseMovement) {
        returnTabAfterMovement = .course
        movementPath = [MovementRoute(movement: movement, source: .course)]
        selectedTab = .movement
    }

    func returnFromCourseLinkedMovement() {
        selectedTab = returnTabAfterMovement ?? .course
        movementPath.removeAll()
        returnTabAfterMovement = nil
    }

    func updateSelectedTab(_ tab: AppTab) {
        if selectedTab == .movement,
           tab != .movement,
           movementPath.last?.source == .course {
            movementPath.removeAll()
            returnTabAfterMovement = nil
        }

        selectedTab = tab
    }
}
