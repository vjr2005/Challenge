import ChallengeCore
import ChallengeCoreMocks
import SwiftUI
import Testing

@testable import ChallengeEpisode

struct EpisodeFeatureTests {
    // MARK: - Properties

    private let navigatorMock = NavigatorMock()
    private let sut: EpisodeFeature

    // MARK: - Init

    init() {
        sut = EpisodeFeature(tracker: TrackerMock())
    }

    // MARK: - Deep Link Handler

    @Test("Deep link handler is not nil")
    func deepLinkHandlerIsNotNil() {
        #expect(sut.deepLinkHandler != nil)
    }

    // MARK: - Make Main View

    @Test("Make main view returns a view")
    func makeMainViewReturnsView() {
        // When
        let result = sut.makeMainView(navigator: navigatorMock)

        // Then
        _ = result
    }

    // MARK: - Resolve

    @Test("Resolve main navigation returns view")
    func resolveMainNavigationReturnsView() {
        // When
        let result = sut.resolve(EpisodeIncomingNavigation.main, navigator: navigatorMock)

        // Then
        #expect(result != nil)
    }

    @Test("Resolve unknown navigation returns nil")
    func resolveUnknownNavigationReturnsNil() {
        // Given
        struct UnknownNav: NavigationContract {}

        // When
        let result = sut.resolve(UnknownNav(), navigator: navigatorMock)

        // Then
        #expect(result == nil)
    }
}
