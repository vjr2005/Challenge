import Foundation

protocol CharacterDetailViewModelContract: AnyObject {
	var state: CharacterDetailViewState { get }
	func didAppear() async
	func didTapOnRetryButton() async
	func didPullToRefresh() async
	func didTapOnEpisodes()
}

