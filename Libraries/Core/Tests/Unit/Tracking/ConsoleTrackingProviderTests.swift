import Testing

@testable import ChallengeCore

struct ConsoleTrackingProviderTests {
    // MARK: - Properties

    private let sut = ConsoleTrackingProvider()

    // MARK: - Tests

    @Test("Configures without crashing")
    func configuresWithoutCrashing() {
        // When / Then
        sut.configure()
    }

    @Test("Tracks event without properties without crashing")
    func tracksEventWithoutProperties() {
        // Given
        let event = TestEvent(name: "screen_viewed")

        // When / Then
        sut.track(event)
    }

    @Test("Tracks event with properties without crashing")
    func tracksEventWithProperties() {
        // Given
        let event = TestEvent(name: "button_tapped", properties: ["id": "42", "screen": "home"])

        // When / Then
        sut.track(event)
    }

    // MARK: - Formatting

    @Test("Formats properties as key-value pairs sorted by key", arguments: [
        (["id": "42"], "id: 42"),
        (["screen": "home", "id": "42"], "id: 42, screen: home"),
        (["b": "2", "c": "3", "a": "1"], "a: 1, b: 2, c: 3")
    ])
    func formatsPropertiesSortedByKey(properties: [String: String], expected: String) {
        // When
        let result = ConsoleTrackingProvider.formatted(properties)

        // Then
        #expect(result == expected)
    }
}

// MARK: - Test Helpers

private struct TestEvent: TrackingEventContract {
    let name: String
    var properties: [String: String] = [:]
}
