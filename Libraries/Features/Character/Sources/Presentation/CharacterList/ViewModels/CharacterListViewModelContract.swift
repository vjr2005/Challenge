import Foundation

/// Contract for CharacterListViewModel to enable testability.
protocol CharacterListViewModelContract: AnyObject {
	var state: CharacterListViewState { get }
	func load() async
	func loadMore() async
	func didSelect(_ character: Character)
}
