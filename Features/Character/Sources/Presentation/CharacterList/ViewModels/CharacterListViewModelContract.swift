import Foundation

protocol CharacterListViewModelContract: AnyObject {
	var state: CharacterListViewState { get }
	var searchQuery: String { get set }
	func loadIfNeeded() async
	func refresh() async
	func loadMore() async
	func didSelect(_ character: Character)
}
