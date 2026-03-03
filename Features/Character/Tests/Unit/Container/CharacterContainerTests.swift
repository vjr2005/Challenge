import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Testing

@testable import ChallengeCharacter

struct CharacterContainerTests {
	// MARK: - Properties

	private let sut: CharacterContainer

	// MARK: - Initialization

	init() {
		sut = CharacterContainer(
			httpClient: HTTPClientMock(),
			tracker: TrackerMock(),
			imageLoader: ImageLoaderMock(cachedImage: nil, asyncImage: nil)
		)
	}

	// MARK: - Tests

	@Test("Make character list view model creates CharacterListViewModel")
	func makeCharacterListViewModel() {
		// When
		let viewModel = sut.makeCharacterListViewModel(navigator: NavigatorMock())

		// Then
		#expect(viewModel is CharacterListViewModel)
	}

	@Test("Make character detail view model creates CharacterDetailViewModel")
	func makeCharacterDetailViewModel() {
		// When
		let viewModel = sut.makeCharacterDetailViewModel(identifier: 42, navigator: NavigatorMock())

		// Then
		#expect(viewModel is CharacterDetailViewModel)
	}

	@Test("Make character filter view model creates CharacterFilterViewModel")
	func makeCharacterFilterViewModel() {
		// When
		let viewModel = sut.makeCharacterFilterViewModel(delegate: CharacterFilterDelegateMock(), navigator: NavigatorMock())

		// Then
		#expect(viewModel is CharacterFilterViewModel)
	}
}
