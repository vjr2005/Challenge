import Foundation
import Testing

@testable import ChallengeCore

struct URLQueryParameterTests {
    @Test
    func queryParameterReturnsValueWhenParameterExists() throws {
        // Given
        let sut = try #require(URL(string: "https://example.com?name=value"))

        // When
        let result = sut.queryParameter("name")

        // Then
        #expect(result == "value")
    }

    @Test
    func queryParameterReturnsNilWhenParameterDoesNotExist() throws {
        // Given
        let sut = try #require(URL(string: "https://example.com?other=value"))

        // When
        let result = sut.queryParameter("name")

        // Then
        #expect(result == nil)
    }

    @Test
    func queryParameterReturnsNilWhenNoQueryString() throws {
        // Given
        let sut = try #require(URL(string: "https://example.com/path"))

        // When
        let result = sut.queryParameter("name")

        // Then
        #expect(result == nil)
    }

    @Test
    func queryParameterReturnsFirstValueWhenMultipleParametersExist() throws {
        // Given
        let sut = try #require(URL(string: "https://example.com?id=123&name=test&active=true"))

        // When
        let result = sut.queryParameter("name")

        // Then
        #expect(result == "test")
    }

    @Test
    func queryParameterReturnsEmptyStringWhenParameterHasNoValue() throws {
        // Given
        let sut = try #require(URL(string: "https://example.com?name="))

        // When
        let result = sut.queryParameter("name")

        // Then
        let unwrappedResult = try #require(result)
        #expect(unwrappedResult.isEmpty)
    }

    @Test
    func queryParameterHandlesEncodedValues() throws {
        // Given
        let sut = try #require(URL(string: "https://example.com?name=hello%20world"))

        // When
        let result = sut.queryParameter("name")

        // Then
        #expect(result == "hello world")
    }

    @Test
    func queryParameterReturnsFirstOccurrenceWhenDuplicateParametersExist() throws {
        // Given
        let sut = try #require(URL(string: "https://example.com?name=first&name=second"))

        // When
        let result = sut.queryParameter("name")

        // Then
        #expect(result == "first")
    }

    @Test
    func queryParameterIsCaseSensitive() throws {
        // Given
        let sut = try #require(URL(string: "https://example.com?Name=value"))

        // When
        let result = sut.queryParameter("name")

        // Then
        #expect(result == nil)
    }
}
