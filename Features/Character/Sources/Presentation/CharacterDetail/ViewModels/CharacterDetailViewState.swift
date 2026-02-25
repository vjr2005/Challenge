import Foundation

enum CharacterDetailViewState: Equatable {
	case idle
	case loading
	case loaded(Character)
	case error(CharacterError)
}
