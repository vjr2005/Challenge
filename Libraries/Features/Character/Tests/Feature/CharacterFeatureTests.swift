import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterFeatureTests {
    private let testBundle = Bundle(for: BundleToken.self)

    // MARK: - CharacterListViewModel

    @Test
    func makeCharacterListViewModelReturnsConfiguredInstance() {
        // Given
        let httpClientMock = HTTPClientMock()
        let routerMock = RouterMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let viewModel = sut.makeCharacterListViewModel(router: routerMock)

        // Then
        #expect(viewModel.state == .idle)
    }

    @Test
    func makeCharacterListViewModelUsesInjectedHTTPClient() async throws {
        // Given
        let jsonData = try testBundle.loadJSONData("characters_response")
        let httpClientMock = HTTPClientMock(result: .success(jsonData))
        let routerMock = RouterMock()
        let sut = CharacterFeature(httpClient: httpClientMock)
        let viewModel = sut.makeCharacterListViewModel(router: routerMock)

        // When
        await viewModel.load()

        // Then
        #expect(httpClientMock.requestedEndpoints.count == 1)
    }

    // MARK: - CharacterDetailViewModel

    @Test
    func makeCharacterDetailViewModelReturnsConfiguredInstance() {
        // Given
        let httpClientMock = HTTPClientMock()
        let routerMock = RouterMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let viewModel = sut.makeCharacterDetailViewModel(identifier: 1, router: routerMock)

        // Then
        #expect(viewModel.state == .idle)
    }

    @Test
    func makeCharacterDetailViewModelUsesInjectedHTTPClient() async throws {
        // Given
        let jsonData = try testBundle.loadJSONData("character")
        let httpClientMock = HTTPClientMock(result: .success(jsonData))
        let routerMock = RouterMock()
        let sut = CharacterFeature(httpClient: httpClientMock)
        let viewModel = sut.makeCharacterDetailViewModel(identifier: 1, router: routerMock)

        // When
        await viewModel.load()

        // Then
        #expect(httpClientMock.requestedEndpoints.count == 1)
    }

    // MARK: - Shared Repository

    @Test
    func multipleDetailViewModelsShareSameRepository() async throws {
        // Given
        let jsonData = try testBundle.loadJSONData("character")
        let httpClientMock = HTTPClientMock(result: .success(jsonData))
        let routerMock = RouterMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let viewModel1 = sut.makeCharacterDetailViewModel(identifier: 1, router: routerMock)
        let viewModel2 = sut.makeCharacterDetailViewModel(identifier: 1, router: routerMock)

        await viewModel1.load()
        await viewModel2.load()

        // Then - Second load uses cached data from shared repository
        #expect(httpClientMock.requestedEndpoints.count == 1)
    }

    @Test
    func listAndDetailViewModelsShareSameRepository() async throws {
        // Given
        let jsonData = try testBundle.loadJSONData("characters_response")
        let httpClientMock = HTTPClientMock(result: .success(jsonData))
        let routerMock = RouterMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When - Load characters via list, then get one character via detail
        let listViewModel = sut.makeCharacterListViewModel(router: routerMock)
        await listViewModel.load()

        let detailViewModel = sut.makeCharacterDetailViewModel(identifier: 1, router: routerMock)
        await detailViewModel.load()

        // Then - Detail should use cached character from list response (only 1 HTTP call total)
        #expect(httpClientMock.requestedEndpoints.count == 1)
    }
}

private final class BundleToken {}
