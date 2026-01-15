import Foundation

/// Represents the possible states of the Character view.
enum CharacterViewState {
	case idle
	case loading
	case loaded(Character)
	case error(Error)
}
