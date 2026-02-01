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
        sut = CharacterContainer(httpClient: httpClientMock)
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
}
