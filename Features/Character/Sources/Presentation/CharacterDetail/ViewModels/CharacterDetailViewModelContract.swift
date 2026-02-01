import Foundation

protocol CharacterDetailViewModelContract: AnyObject {
	var state: CharacterDetailViewState { get }
	func loadIfNeeded() async
	func refresh() async
	func didTapOnBack()
}

