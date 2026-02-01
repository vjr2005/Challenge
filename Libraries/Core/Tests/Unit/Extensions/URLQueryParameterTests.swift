import Foundation
import Testing

@testable import ChallengeCore

struct URLQueryParameterTests {
    @Test("Returns value when query parameter exists")
    func queryParameterReturnsValueWhenParameterExists() throws {
        // Given
        let sut = try #require(URL(string: "https://example.com?name=value"))

        // When
        let result = sut.queryParameter("name")

        // Then
        #expect(result == "value")
    }

    @Test("Returns nil when query parameter does not exist")
    func queryParameterReturnsNilWhenParameterDoesNotExist() throws {
        // Given
        let sut = try #require(URL(string: "https://example.com?other=value"))

        // When
        let result = sut.queryParameter("name")

        // Then
        #expect(result == nil)
    }

    @Test("Returns nil when URL has no query string")
    func queryParameterReturnsNilWhenNoQueryString() throws {
        // Given
        let sut = try #require(URL(string: "https://example.com/path"))

        // When
        let result = sut.queryParameter("name")

        // Then
        #expect(result == nil)
    }

    @Test("Returns first value when multiple parameters exist")
    func queryParameterReturnsFirstValueWhenMultipleParametersExist() throws {
        // Given
        let sut = try #require(URL(string: "https://example.com?id=123&name=test&active=true"))

        // When
        let result = sut.queryParameter("name")

        // Then
        #expect(result == "test")
    }

    @Test("Returns empty string when parameter has no value")
    func queryParameterReturnsEmptyStringWhenParameterHasNoValue() throws {
        // Given
        let sut = try #require(URL(string: "https://example.com?name="))

        // When
        let result = sut.queryParameter("name")

        // Then
        let unwrappedResult = try #require(result)
        #expect(unwrappedResult.isEmpty)
    }

    @Test("Handles URL-encoded values correctly")
    func queryParameterHandlesEncodedValues() throws {
        // Given
        let sut = try #require(URL(string: "https://example.com?name=hello%20world"))

        // When
        let result = sut.queryParameter("name")

        // Then
        #expect(result == "hello world")
    }

    @Test("Returns first occurrence when duplicate parameters exist")
    func queryParameterReturnsFirstOccurrenceWhenDuplicateParametersExist() throws {
        // Given
        let sut = try #require(URL(string: "https://example.com?name=first&name=second"))

        // When
        let result = sut.queryParameter("name")

        // Then
        #expect(result == "first")
    }

    @Test("Query parameter matching is case sensitive")
    func queryParameterIsCaseSensitive() throws {
        // Given
        let sut = try #require(URL(string: "https://example.com?Name=value"))

        // When
        let result = sut.queryParameter("name")

        // Then
        #expect(result == nil)
    }
}
