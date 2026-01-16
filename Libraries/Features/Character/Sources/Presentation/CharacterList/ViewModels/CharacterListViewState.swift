import Foundation

enum CharacterListViewState: Equatable {
	case idle
	case loading
	case loaded(CharactersPage)
	case empty
	case error(String)

	static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
		case (.idle, .idle), (.loading, .loading), (.empty, .empty):
			true
		case let (.loaded(lhsPage), .loaded(rhsPage)):
			lhsPage == rhsPage
		case let (.error(lhsMessage), .error(rhsMessage)):
			lhsMessage == rhsMessage
		default:
			false
		}
	}
}
