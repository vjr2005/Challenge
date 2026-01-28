import Foundation

enum CharacterListViewState {
	case idle
	case loading
	case loaded(CharactersPage)
	case empty
	case error(CharacterError)
}
