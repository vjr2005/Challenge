import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Foundation
import SwiftUI
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterFeatureTests {
    // MARK: - Init

    @Test
    func initWithHTTPClientDoesNotCrash() {
        // Given
        let httpClientMock = HTTPClientMock()

        // When
        let sut = CharacterFeature(httpClient: httpClientMock)

        // Then - Feature initializes without crashing
        _ = sut
    }

    // MARK: - Feature Protocol

    @Test
    func applyNavigationDestinationReturnsView() {
        // Given
        let httpClientMock = HTTPClientMock()
        let routerMock = RouterMock()
        let sut = CharacterFeature(httpClient: httpClientMock)
        let baseView = EmptyView()

        // When
        let result = sut.applyNavigationDestination(to: baseView, router: routerMock)

        // Then - Method completes without crashing and returns a view
        _ = result
    }

    @Test
    func registerDeepLinksRegistersCharacterHandler() throws {
        // Given
        let httpClientMock = HTTPClientMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        sut.registerDeepLinks()

        // Then - Deep link is registered (verify by resolving a known URL)
        let url = try #require(URL(string: "challenge://character/list"))
        let navigation = DeepLinkRegistry.shared.resolve(url)
        #expect(navigation != nil)
    }

    @Test
    func registerDeepLinksRegistersDetailPath() throws {
        // Given
        let httpClientMock = HTTPClientMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        sut.registerDeepLinks()

        // Then
        let url = try #require(URL(string: "challenge://character/detail?id=42"))
        let navigation = DeepLinkRegistry.shared.resolve(url)
        #expect(navigation != nil)
    }

    // MARK: - View Factory

    @Test
    func viewForListNavigationReturnsCharacterListView() {
        // Given
        let httpClientMock = HTTPClientMock()
        let routerMock = RouterMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.view(for: .list, router: routerMock)

        // Then
        let viewName = String(describing: type(of: result))
        #expect(viewName.contains("CharacterListView"))
    }

    @Test
    func viewForDetailNavigationReturnsCharacterDetailView() {
        // Given
        let httpClientMock = HTTPClientMock()
        let routerMock = RouterMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.view(for: .detail(identifier: 42), router: routerMock)

        // Then
        let viewName = String(describing: type(of: result))
        #expect(viewName.contains("CharacterDetailView"))
    }
}
