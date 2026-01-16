import SwiftUI

/// Router that manages navigation for the Character feature.
@Observable
final class CharacterRouter {
	enum Destination: Hashable {
        case detail(identifier: Int)
	}

    var path = NavigationPath()

	func navigate(to destination: Destination) {
		path.append(destination)
	}

	func pop() {
        guard !path.isEmpty else {
            return
        }
		path.removeLast()
	}

	func popToRoot() {
		path.removeLast(path.count)
	}
}
