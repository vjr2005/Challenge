import Foundation

enum CharacterListViewState: Equatable {
	case idle
	case loading
	case loaded(CharactersPage)
	case empty
	case emptySearch
	case error(CharactersPageError)

	var isSearchAvailable: Bool {
		switch self {
		case .loaded, .emptySearch: return true
		case .idle, .loading, .empty, .error: return false
		}
	}
}
