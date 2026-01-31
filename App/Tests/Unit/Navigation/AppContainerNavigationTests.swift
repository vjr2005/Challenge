import ChallengeCharacter
import ChallengeCore
import ChallengeCoreMocks
import ChallengeHome
import ChallengeNetworkingMocks
import ChallengeSystem
import Testing

@testable import Challenge

struct AppContainerNavigationTests {
    // MARK: - Home Navigation

    @Test
    func resolveHomeNavigationReturnsView() {
        // Given
        let sut = AppContainer(httpClient: HTTPClientMock())
        let navigator = NavigatorMock()

        // When
        let result = sut.resolve(HomeIncomingNavigation.main, navigator: navigator)

        // Then
        let viewName = String(describing: result)
        #expect(viewName.contains("HomeView"))
    }

    // MARK: - Character Navigation

    @Test
    func resolveCharacterListNavigationReturnsView() {
        // Given
        let sut = AppContainer(httpClient: HTTPClientMock())
        let navigator = NavigatorMock()

        // When
        let result = sut.resolve(CharacterIncomingNavigation.list, navigator: navigator)

        // Then
        let viewName = String(describing: result)
        #expect(viewName.contains("CharacterListView"))
    }

    @Test
    func resolveCharacterDetailNavigationReturnsView() {
        // Given
        let sut = AppContainer(httpClient: HTTPClientMock())
        let navigator = NavigatorMock()

        // When
        let result = sut.resolve(CharacterIncomingNavigation.detail(identifier: 42), navigator: navigator)

        // Then
        let viewName = String(describing: result)
        #expect(viewName.contains("CharacterDetailView"))
    }

    // MARK: - System Navigation

    @Test
    func resolveUnknownNavigationReturnsNotFoundView() {
        // Given
        let sut = AppContainer(httpClient: HTTPClientMock())
        let navigator = NavigatorMock()

        // When
        let result = sut.resolve(UnknownNavigation.notFound, navigator: navigator)

        // Then
        let viewName = String(describing: result)
        #expect(viewName.contains("NotFoundView"))
    }

    // MARK: - Fallback

    @Test
    func resolveUnknownTypeReturnsNotFoundView() {
        // Given
        let sut = AppContainer(httpClient: HTTPClientMock())
        let navigator = NavigatorMock()

        // When
        let result = sut.resolve(TestNavigation.unknown, navigator: navigator)

        // Then
        let viewName = String(describing: result)
        #expect(viewName.contains("NotFoundView"))
    }
}

// MARK: - Test Helpers

private enum TestNavigation: Navigation {
    case unknown
}
