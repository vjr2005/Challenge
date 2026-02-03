import Foundation

protocol CharacterListViewModelContract: AnyObject {
	var state: CharacterListViewState { get }
	var searchQuery: String { get set }
	func didAppear() async
	func didTapOnRetryButton() async
	func didPullToRefresh() async
	func didTapOnLoadMoreButton() async
	func didSelect(_ character: Character)
}
