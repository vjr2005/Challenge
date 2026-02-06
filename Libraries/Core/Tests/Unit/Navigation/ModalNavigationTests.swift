import SwiftUI
import Testing

@testable import ChallengeCore

struct ModalNavigationTests {
    // MARK: - Detents

    @Test("Sheet detents returns configured detents")
    func sheetDetentsReturnsConfiguredDetents() {
        // Given
        let detents: Set<PresentationDetent> = [.medium, .large]
        let sut = ModalNavigation(navigation: TestNavigation.screen, style: .sheet(detents: detents))

        // Then
        #expect(sut.detents == detents)
    }

    @Test("Sheet with default detents returns large")
    func sheetWithDefaultDetentsReturnsLarge() {
        // Given
        let sut = ModalNavigation(navigation: TestNavigation.screen, style: .sheet())

        // Then
        #expect(sut.detents == [.large])
    }

    @Test("FullScreenCover detents returns empty set")
    func fullScreenCoverDetentsReturnsEmptySet() {
        // Given
        let sut = ModalNavigation(navigation: TestNavigation.screen, style: .fullScreenCover)

        // Then
        #expect(sut.detents.isEmpty)
    }

    // MARK: - Identifiable

    @Test("Each ModalNavigation has a unique id")
    func eachModalNavigationHasUniqueId() {
        // Given
        let modal1 = ModalNavigation(navigation: TestNavigation.screen, style: .sheet())
        let modal2 = ModalNavigation(navigation: TestNavigation.screen, style: .sheet())

        // Then
        #expect(modal1.id != modal2.id)
    }

    // MARK: - Navigation Wrapping

    @Test("Navigation is wrapped in AnyNavigation")
    func navigationIsWrappedInAnyNavigation() {
        // Given
        let destination = TestNavigation.screen

        // When
        let sut = ModalNavigation(navigation: destination, style: .sheet())

        // Then
        #expect(sut.navigation == AnyNavigation(destination))
    }

    @Test("Style is preserved")
    func styleIsPreserved() {
        // Given
        let sut = ModalNavigation(navigation: TestNavigation.screen, style: .fullScreenCover)

        // Then
        #expect(sut.style == .fullScreenCover)
    }
}

// MARK: - Test Helpers

private enum TestNavigation: IncomingNavigationContract {
    case screen
}
