import Foundation

protocol CharacterEpisodesViewModelContract: AnyObject {
	var state: CharacterEpisodesViewState { get }
	func didAppear() async
	func didTapOnRetryButton() async
	func didPullToRefresh() async
}
