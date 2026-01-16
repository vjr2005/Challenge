import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Testing

@testable import ChallengeCharacter

struct CharacterContainerTests {
    @Test
    func makeCharacterDetailViewModelReturnsConfiguredInstance() {
        // Given
        let httpClient = HTTPClientMock()
        let router = RouterMock()
        let sut = CharacterContainer(httpClient: httpClient)

        // When
        let viewModel = sut.makeCharacterDetailViewModel(identifier: 1, router: router)

        // Then
        guard case .idle = viewModel.state else {
            Issue.record("Expected idle state")
            return
        }
    }

    @Test
    func makeCharacterDetailViewModelUsesInjectedHTTPClient() async {
        // Given
        let httpClient = HTTPClientMock(result: .success(CharacterDTO.stubJSONData()))
        let router = RouterMock()
        let sut = CharacterContainer(httpClient: httpClient)
        let viewModel = sut.makeCharacterDetailViewModel(identifier: 1, router: router)

        // When
        await viewModel.load()

        // Then
        #expect(httpClient.requestedEndpoints.count == 1)
    }

    @Test
    func multipleViewModelsShareSameRepository() async {
        // Given
        let httpClient = HTTPClientMock(result: .success(CharacterDTO.stubJSONData()))
        let router = RouterMock()
        let sut = CharacterContainer(httpClient: httpClient)

        // When
        let viewModel1 = sut.makeCharacterDetailViewModel(identifier: 1, router: router)
        let viewModel2 = sut.makeCharacterDetailViewModel(identifier: 1, router: router)

        await viewModel1.load()
        await viewModel2.load()

        // Then - Second load uses cached data from shared repository
        #expect(httpClient.requestedEndpoints.count == 1)
    }
}
