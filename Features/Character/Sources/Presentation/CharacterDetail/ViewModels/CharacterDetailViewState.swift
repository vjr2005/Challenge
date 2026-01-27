import Foundation

enum CharacterDetailViewState {
	case idle
	case loading
	case loaded(Character)
	case error(Error)
}
