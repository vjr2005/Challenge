import Foundation

enum CharacterListViewState {
	case idle
	case loading
	case loaded(CharactersPage)
	case empty
	case emptySearch
	case error(CharacterError)

	var isSearchAvailable: Bool {
		switch self {
		case .loaded, .emptySearch: return true
		case .idle, .loading, .empty, .error: return false
		}
	}
}
