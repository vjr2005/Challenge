@testable import ChallengeEpisode

final class CharacterEpisodesNavigatorMock: CharacterEpisodesNavigatorContract {
	private(set) var navigateToCharacterDetailCallCount = 0
	private(set) var lastNavigateToCharacterDetailIdentifier: Int?

	func navigateToCharacterDetail(identifier: Int) {
		navigateToCharacterDetailCallCount += 1
		lastNavigateToCharacterDetailIdentifier = identifier
	}
}
