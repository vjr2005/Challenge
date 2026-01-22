import Foundation
import Testing

@testable import ChallengeCore

struct DeepLinkRegistryTests {
    @Test
    func resolvesURLWithRegisteredHandler() throws {
        // Given
        let sut = DeepLinkRegistry()
        let handler = DeepLinkHandlerMock(scheme: "app", host: "test", result: TestNavigation.screen)
        sut.register(handler)
        let url = try #require(URL(string: "app://test/path"))
        let expected = TestNavigation.screen

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value as? TestNavigation == expected)
    }

    @Test
    func returnsNilForUnknownURL() throws {
        // Given
        let sut = DeepLinkRegistry()
        let url = try #require(URL(string: "app://unknown/path"))

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value == nil)
    }

    @Test
    func registerOverwritesPreviousHandler() throws {
        // Given
        let sut = DeepLinkRegistry()
        let handler1 = DeepLinkHandlerMock(scheme: "app", host: "test", result: TestNavigation.screen1)
        let handler2 = DeepLinkHandlerMock(scheme: "app", host: "test", result: TestNavigation.screen2)
        sut.register(handler1)
        sut.register(handler2)
        let url = try #require(URL(string: "app://test/path"))
        let expected = TestNavigation.screen2

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value as? TestNavigation == expected)
    }

    @Test
    func returnsNilForURLWithoutScheme() {
        // Given
        let sut = DeepLinkRegistry()
        let handler = DeepLinkHandlerMock(scheme: "app", host: "test", result: TestNavigation.screen)
        sut.register(handler)
        let url = URL(fileURLWithPath: "/test/path")

        // When
        let value = sut.resolve(url)

        // Then
        #expect(value == nil)
    }
}

// MARK: - Test Helpers

private enum TestNavigation: Navigation {
    case screen
    case screen1
    case screen2
}

private struct DeepLinkHandlerMock: DeepLinkHandler {
    let scheme: String
    let host: String
    let result: (any Navigation)?

    func resolve(_ url: URL) -> (any Navigation)? {
        result
    }
}
