import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Testing

@testable import ChallengeCharacter

struct CharacterContainerTests {
    @Test
    func initWithHTTPClientDoesNotCrash() {
        // Given
        let httpClientMock = HTTPClientMock()

        // When
        let sut = CharacterContainer(httpClient: httpClientMock)

        // Then
        _ = sut
    }

    @Test
    func makeCharacterListViewModelReturnsConfiguredInstance() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterContainer(httpClient: httpClientMock)

        // When
        let viewModel = sut.makeCharacterListViewModel(navigator: navigatorMock)

        // Then
        #expect(viewModel.state == .idle)
    }

    @Test
    func makeCharacterDetailViewModelReturnsConfiguredInstance() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterContainer(httpClient: httpClientMock)

        // When
        let viewModel = sut.makeCharacterDetailViewModel(identifier: 42, navigator: navigatorMock)

        // Then
        #expect(viewModel.state == .idle)
    }
}
