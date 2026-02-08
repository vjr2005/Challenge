import Foundation

protocol CharacterListViewModelContract: AnyObject {
	var state: CharacterListViewState { get }
	var searchQuery: String { get set }
	var recentSearches: [String] { get }
	var activeFilterCount: Int { get }
	func didAppear() async
	func didTapOnRetryButton() async
	func didPullToRefresh() async
	func didTapOnLoadMoreButton() async
	func didSelect(_ character: Character)
	func didSelectRecentSearch(_ query: String) async
	func didDeleteRecentSearch(_ query: String)
	func didTapAdvancedSearchButton()
}
