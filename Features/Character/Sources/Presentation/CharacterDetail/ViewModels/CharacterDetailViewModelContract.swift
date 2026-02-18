import Foundation

protocol CharacterDetailViewModelContract: AnyObject {
	var state: CharacterDetailViewState { get }
	var imageRefreshID: UUID { get }
	func didAppear() async
	func didTapOnRetryButton() async
	func didPullToRefresh() async
	func didTapOnEpisodes()
}

