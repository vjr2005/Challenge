import Foundation

/// Contract for CharacterDetailViewModel to enable testability.
protocol CharacterDetailViewModelContract: AnyObject {
	var state: CharacterDetailViewState { get }
	func load() async
	func didTapOnBack()
}
