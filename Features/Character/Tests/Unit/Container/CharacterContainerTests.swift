import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Testing

@testable import ChallengeCharacter

struct CharacterContainerTests {
	// MARK: - Properties

	private let httpClientMock = HTTPClientMock()
	private let sut: CharacterContainer

	// MARK: - Initialization

	init() {
		sut = CharacterContainer(httpClient: httpClientMock, tracker: TrackerMock())
	}

	// MARK: - Tests

	@Test("Make character list view model returns configured instance")
	func makeCharacterListViewModelReturnsConfiguredInstance() {
		// Given
		let navigatorMock = NavigatorMock()

		// When
		let viewModel = sut.makeCharacterListViewModel(navigator: navigatorMock)

		// Then
		#expect(viewModel.state == .idle)
	}

	@Test("Make character detail view model returns configured instance")
	func makeCharacterDetailViewModelReturnsConfiguredInstance() {
		// Given
		let navigatorMock = NavigatorMock()

		// When
		let viewModel = sut.makeCharacterDetailViewModel(identifier: 42, navigator: navigatorMock)

		// Then
		#expect(viewModel.state == .idle)
	}

	@Test("Make character filter view model returns configured instance")
	func makeCharacterFilterViewModelReturnsConfiguredInstance() {
		// Given
		let navigatorMock = NavigatorMock()
		let delegateMock = CharacterFilterDelegateMock()

		// When
		let viewModel = sut.makeCharacterFilterViewModel(delegate: delegateMock, navigator: navigatorMock)

		// Then
		#expect(!viewModel.hasActiveFilters)
	}

	@Test("Make character filter view model initializes filter from delegate")
	func makeCharacterFilterViewModelInitializesFilterFromDelegate() {
		// Given
		let navigatorMock = NavigatorMock()
		let delegateMock = CharacterFilterDelegateMock()
		delegateMock.currentFilter = CharacterFilter(status: .alive, gender: .male)

		// When
		let viewModel = sut.makeCharacterFilterViewModel(delegate: delegateMock, navigator: navigatorMock)

		// Then
		#expect(viewModel.filter.status == .alive)
		#expect(viewModel.filter.gender == .male)
	}
}
