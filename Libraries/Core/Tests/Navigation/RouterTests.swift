import SwiftUI
import Testing

@testable import ChallengeCore

@Suite(.timeLimit(.minutes(1)))
struct RouterTests {
    @Test
    func initialPathIsEmpty() {
        // Given
        let sut = Router()

        // Then
        #expect(sut.path.isEmpty)
    }

    @Test
    func navigateAppendsToPath() {
        // Given
        let sut = Router()

        // When
        sut.navigate(to: TestNavigation.detail(id: 1))

        // Then
        #expect(sut.path.count == 1)
    }

    @Test
    func multipleNavigationsAppendInOrder() {
        // Given
        let sut = Router()

        // When
        sut.navigate(to: TestNavigation.detail(id: 1))
        sut.navigate(to: TestNavigation.detail(id: 2))
        sut.navigate(to: TestNavigation.detail(id: 3))

        // Then
        #expect(sut.path.count == 3)
    }

    @Test
    func goBackRemovesLastFromPath() {
        // Given
        let sut = Router()
        sut.navigate(to: TestNavigation.detail(id: 1))
        sut.navigate(to: TestNavigation.detail(id: 2))

        // When
        sut.goBack()

        // Then
        #expect(sut.path.count == 1)
    }

    @Test
    func goBackOnEmptyPathDoesNothing() {
        // Given
        let sut = Router()

        // When
        sut.goBack()

        // Then
        #expect(sut.path.isEmpty)
    }

    @Test
    func goBackMultipleTimesEmptiesPath() {
        // Given
        let sut = Router()
        sut.navigate(to: TestNavigation.detail(id: 1))
        sut.navigate(to: TestNavigation.detail(id: 2))

        // When
        sut.goBack()
        sut.goBack()

        // Then
        #expect(sut.path.isEmpty)
    }

    @Test
    func goBackBeyondEmptyPathIsSafe() {
        // Given
        let sut = Router()
        sut.navigate(to: TestNavigation.detail(id: 1))

        // When
        sut.goBack()
        sut.goBack()
        sut.goBack()

        // Then
        #expect(sut.path.isEmpty)
    }

    // MARK: - navigate(to url: URL?)

    @Test
    func navigateToURLAppendsToPathWhenHandlerIsRegistered() throws {
        // Given
        let sut = Router()
        let handler = TestDeepLinkHandler(scheme: "test", host: "router", result: TestNavigation.detail(id: 42))
        DeepLinkRegistry.shared.register(handler)
        let url = try #require(URL(string: "test://router/path"))

        // When
        sut.navigate(to: url)

        // Then
        #expect(sut.path.count == 1)
    }

    @Test
    func navigateToURLDoesNothingWhenURLIsNil() {
        // Given
        let sut = Router()

        // When
        sut.navigate(to: nil)

        // Then
        #expect(sut.path.isEmpty)
    }

    @Test
    func navigateToURLDoesNothingWhenNoHandlerIsRegistered() throws {
        // Given
        let sut = Router()
        let url = try #require(URL(string: "unknown://unregistered/path"))

        // When
        sut.navigate(to: url)

        // Then
        #expect(sut.path.isEmpty)
    }

    @Test
    func navigateToURLDoesNothingWhenHandlerReturnsNil() throws {
        // Given
        let sut = Router()
        let handler = TestDeepLinkHandler(scheme: "test", host: "nilhandler", result: nil)
        DeepLinkRegistry.shared.register(handler)
        let url = try #require(URL(string: "test://nilhandler/path"))

        // When
        sut.navigate(to: url)

        // Then
        #expect(sut.path.isEmpty)
    }
}

// MARK: - Test Helpers

private enum TestNavigation: Navigation {
    case detail(id: Int)
}

private struct TestDeepLinkHandler: DeepLinkHandler {
    let scheme: String
    let host: String
    let result: (any Navigation)?

    func resolve(_ url: URL) -> (any Navigation)? {
        result
    }
}
