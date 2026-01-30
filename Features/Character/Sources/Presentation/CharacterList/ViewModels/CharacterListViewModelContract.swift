import Foundation

protocol CharacterListViewModelContract: AnyObject {
	var state: CharacterListViewState { get }
	var searchQuery: String { get set }
	func load() async
	func loadMore() async
	func didSelect(_ character: Character)
}
