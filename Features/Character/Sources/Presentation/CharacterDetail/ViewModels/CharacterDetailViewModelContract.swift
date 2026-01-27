import Foundation

protocol CharacterDetailViewModelContract: AnyObject {
	var state: CharacterDetailViewState { get }
	func load() async
	func didTapOnBack()
}
