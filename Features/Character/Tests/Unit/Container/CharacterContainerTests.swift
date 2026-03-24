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

	@Test("Make character list view creates CharacterListView")
	func makeCharacterListView() {
		// When
		let view = sut.makeCharacterListView(navigator: NavigatorMock())

		// Then
		let viewName = String(describing: type(of: view))
		#expect(viewName.contains("CharacterListView"))
	}

	@Test("Make character detail view creates CharacterDetailView")
	func makeCharacterDetailView() {
		// When
		let view = sut.makeCharacterDetailView(identifier: 42, navigator: NavigatorMock())

		// Then
		let viewName = String(describing: type(of: view))
		#expect(viewName.contains("CharacterDetailView"))
	}

	@Test("Make character filter view creates CharacterFilterView")
	func makeCharacterFilterView() {
		// When
		let view = sut.makeCharacterFilterView(delegate: CharacterFilterDelegateMock(), navigator: NavigatorMock())

		// Then
		let viewName = String(describing: type(of: view))
		#expect(viewName.contains("CharacterFilterView"))
	}
}
