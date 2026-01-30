import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Foundation
import SwiftUI
import Testing

@testable import ChallengeCharacter

struct CharacterFeatureTests {
    // MARK: - Feature Protocol

    @Test
    func applyNavigationDestinationReturnsView() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterFeature(httpClient: httpClientMock)
        let baseView = EmptyView()

        // When
        let result = sut.applyNavigationDestination(to: baseView, navigator: navigatorMock)

        // Then
        let typeName = String(describing: type(of: result))
        #expect(typeName == "AnyView")
    }

    // MARK: - View Factory

    @Test
    func viewForListNavigationReturnsCharacterListView() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.view(for: .list, navigator: navigatorMock)

        // Then
        let viewName = String(describing: type(of: result))
        #expect(viewName.contains("CharacterListView"))
    }

    @Test
    func viewForDetailNavigationReturnsCharacterDetailView() {
        // Given
        let httpClientMock = HTTPClientMock()
        let navigatorMock = NavigatorMock()
        let sut = CharacterFeature(httpClient: httpClientMock)

        // When
        let result = sut.view(for: .detail(identifier: 42), navigator: navigatorMock)

        // Then
        let viewName = String(describing: type(of: result))
        #expect(viewName.contains("CharacterDetailView"))
    }
}
