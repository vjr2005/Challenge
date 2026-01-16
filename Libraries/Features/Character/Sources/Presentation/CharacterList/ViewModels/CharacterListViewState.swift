import Foundation

enum CharacterListViewState: Equatable {
	case idle
	case loading
	case loaded(CharactersPage)
	case empty
	case error(String)

	static func == (lhs: CharacterListViewState, rhs: CharacterListViewState) -> Bool {
		switch (lhs, rhs) {
		case (.idle, .idle), (.loading, .loading), (.empty, .empty):
			return true
		case (.loaded(let lhsPage), .loaded(let rhsPage)):
			return lhsPage == rhsPage
		case (.error(let lhsMessage), .error(let rhsMessage)):
			return lhsMessage == rhsMessage
		default:
			return false
		}
	}
}
