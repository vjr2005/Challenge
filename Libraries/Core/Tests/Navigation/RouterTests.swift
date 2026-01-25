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
}

// MARK: - Test Helpers

private enum TestNavigation: Navigation {
    case detail(id: Int)
}
