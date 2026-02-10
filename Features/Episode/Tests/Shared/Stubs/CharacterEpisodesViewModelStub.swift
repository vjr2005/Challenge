@testable import ChallengeEpisode

final class CharacterEpisodesViewModelStub: CharacterEpisodesViewModelContract {
	var state: CharacterEpisodesViewState = .idle
	func didAppear() async {}
	func didTapOnRetryButton() async {}
	func didPullToRefresh() async {}
}
