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

	@Test("Make character episodes view model creates CharacterEpisodesViewModel")
	func makeCharacterEpisodesViewModel() {
		// When
		let viewModel = sut.makeCharacterEpisodesViewModel(characterIdentifier: 1, navigator: NavigatorMock())

		// Then
		#expect(viewModel is CharacterEpisodesViewModel)
	}
}
