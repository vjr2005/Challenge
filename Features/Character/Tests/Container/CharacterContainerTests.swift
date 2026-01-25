import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
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
        let routerMock = RouterMock()
        let sut = CharacterContainer(httpClient: httpClientMock)

        // When
        let viewModel = sut.makeCharacterListViewModel(router: routerMock)

        // Then
        #expect(viewModel.state == .idle)
    }

    @Test
    func makeCharacterDetailViewModelReturnsConfiguredInstance() {
        // Given
        let httpClientMock = HTTPClientMock()
        let routerMock = RouterMock()
        let sut = CharacterContainer(httpClient: httpClientMock)

        // When
        let viewModel = sut.makeCharacterDetailViewModel(identifier: 42, router: routerMock)

        // Then
        #expect(viewModel.state == .idle)
    }
}
