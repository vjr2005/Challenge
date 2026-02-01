import SwiftUI
import Testing

@testable import ChallengeCore

struct FeatureTests {
    // MARK: - Default Implementation

    @Test("Deep link handler returns nil by default")
    func deepLinkHandlerReturnsNilByDefault() {
        // Given
        let sut = TestFeature()

        // When
        let handler = sut.deepLinkHandler

        // Then
        #expect(handler == nil)
    }
}

// MARK: - Test Helpers

private struct TestFeature: FeatureContract {
    func makeMainView(navigator: any NavigatorContract) -> AnyView {
        AnyView(EmptyView())
    }

    func resolve(_ navigation: any NavigationContract, navigator: any NavigatorContract) -> AnyView? {
        nil
    }
}
