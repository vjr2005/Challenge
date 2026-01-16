import Foundation

/// Represents the possible states of the Character view.
enum CharacterDetailViewState {
	case idle
	case loading
	case loaded(Character)
	case error(Error)

	static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
		case (.idle, .idle), (.loading, .loading):
			true
		case let (.loaded(lhsCharacter), .loaded(rhsCharacter)):
			lhsCharacter == rhsCharacter
		case let (.error(lhsError), .error(rhsError)):
			lhsError.localizedDescription == rhsError.localizedDescription
		default:
			false
		}
	}
}
