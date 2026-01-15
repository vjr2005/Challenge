import SwiftUI

/// Router that manages navigation for the Character feature.
@MainActor
@Observable
final class CharacterRouter {
	var path = NavigationPath()

	enum Destination: Hashable {
		case detail(Character)
	}

	func navigate(to destination: Destination) {
		path.append(destination)
	}

	func pop() {
		guard !path.isEmpty else { return }
		path.removeLast()
	}

	func popToRoot() {
		path.removeLast(path.count)
	}
}
