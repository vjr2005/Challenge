import Foundation

enum CharacterListViewState {
	case idle
	case loading
	case loaded(CharactersPage)
	case empty
	case error(Error)

	static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
		case (.idle, .idle), (.loading, .loading), (.empty, .empty):
			true
		case let (.loaded(lhsPage), .loaded(rhsPage)):
			lhsPage == rhsPage
		case let (.error(lhsError), .error(rhsError)):
			lhsError.localizedDescription == rhsError.localizedDescription
		default:
			false
		}
	}
}
