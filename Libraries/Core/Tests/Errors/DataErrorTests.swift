import Foundation
import Testing

@testable import ChallengeCore

struct DataErrorTests {
    // MARK: - Equatability

    @Test(arguments: [
        (DataError.notFound, DataError.notFound, true),
        (DataError.invalidRequest, DataError.invalidRequest, true),
        (DataError.notFound, DataError.invalidRequest, false)
    ])
    func equalityForSimpleCases(
        lhs: DataError,
        rhs: DataError,
        expectedEqual: Bool
    ) {
        // When
        let areEqual = lhs == rhs

        // Then
        #expect(areEqual == expectedEqual)
    }

    @Test
    func networkErrorsWithSameUnderlyingAreEqual() {
        // Given
        let lhs = DataError.network(underlying: "timeout")
        let rhs = DataError.network(underlying: "timeout")

        // When
        let areEqual = lhs == rhs

        // Then
        #expect(areEqual)
    }

    @Test
    func networkErrorsWithDifferentUnderlyingAreNotEqual() {
        // Given
        let lhs = DataError.network(underlying: "timeout")
        let rhs = DataError.network(underlying: "connection lost")

        // When
        let areEqual = lhs == rhs

        // Then
        #expect(!areEqual)
    }

    @Test
    func serverErrorsWithSameStatusCodeAndMessageAreEqual() {
        // Given
        let lhs = DataError.server(statusCode: 500, message: "Internal Server Error")
        let rhs = DataError.server(statusCode: 500, message: "Internal Server Error")

        // When
        let areEqual = lhs == rhs

        // Then
        #expect(areEqual)
    }

    @Test
    func serverErrorsWithDifferentStatusCodesAreNotEqual() {
        // Given
        let lhs = DataError.server(statusCode: 500, message: nil)
        let rhs = DataError.server(statusCode: 404, message: nil)

        // When
        let areEqual = lhs == rhs

        // Then
        #expect(!areEqual)
    }

    @Test
    func parsingErrorsWithSameUnderlyingAreEqual() {
        // Given
        let lhs = DataError.parsing(underlying: "invalid JSON")
        let rhs = DataError.parsing(underlying: "invalid JSON")

        // When
        let areEqual = lhs == rhs

        // Then
        #expect(areEqual)
    }

    // MARK: - LocalizedError

    @Test
    func networkErrorDescriptionWithUnderlying() {
        // Given
        let sut = DataError.network(underlying: "timeout")

        // When
        let description = sut.errorDescription

        // Then
        #expect(description == "Network error: timeout")
    }

    @Test
    func networkErrorDescriptionWithoutUnderlying() {
        // Given
        let sut = DataError.network(underlying: nil)

        // When
        let description = sut.errorDescription

        // Then
        #expect(description == "Network error")
    }

    @Test
    func serverErrorDescriptionWithMessage() {
        // Given
        let sut = DataError.server(statusCode: 500, message: "Internal Server Error")

        // When
        let description = sut.errorDescription

        // Then
        #expect(description == "Server error (500): Internal Server Error")
    }

    @Test
    func serverErrorDescriptionWithoutMessage() {
        // Given
        let sut = DataError.server(statusCode: 404, message: nil)

        // When
        let description = sut.errorDescription

        // Then
        #expect(description == "Server error (404)")
    }

    @Test
    func parsingErrorDescriptionWithUnderlying() {
        // Given
        let sut = DataError.parsing(underlying: "invalid JSON")

        // When
        let description = sut.errorDescription

        // Then
        #expect(description == "Parsing error: invalid JSON")
    }

    @Test
    func parsingErrorDescriptionWithoutUnderlying() {
        // Given
        let sut = DataError.parsing(underlying: nil)

        // When
        let description = sut.errorDescription

        // Then
        #expect(description == "Parsing error")
    }

    @Test
    func notFoundErrorDescription() {
        // Given
        let sut = DataError.notFound

        // When
        let description = sut.errorDescription

        // Then
        #expect(description == "Resource not found")
    }

    @Test
    func invalidRequestErrorDescription() {
        // Given
        let sut = DataError.invalidRequest

        // When
        let description = sut.errorDescription

        // Then
        #expect(description == "Invalid request")
    }
}
