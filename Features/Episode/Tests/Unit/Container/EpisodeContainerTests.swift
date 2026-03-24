import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Testing

@testable import ChallengeEpisode

struct EpisodeContainerTests {
	// MARK: - Properties

	private let sut: EpisodeContainer

	// MARK: - Initialization

	init() {
		sut = EpisodeContainer(httpClient: HTTPClientMock(), tracker: TrackerMock())
	}

	// MARK: - Tests

	@Test("Make character episodes view creates CharacterEpisodesView")
	func makeCharacterEpisodesView() {
		// When
		let view = sut.makeCharacterEpisodesView(characterIdentifier: 1, navigator: NavigatorMock())

		// Then
		let viewName = String(describing: type(of: view))
		#expect(viewName.contains("CharacterEpisodesView"))
	}
}
