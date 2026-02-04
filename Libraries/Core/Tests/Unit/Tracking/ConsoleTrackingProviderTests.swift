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
        let event = TestEvent(name: "button_tapped", properties: ["id": "42"])

        // When / Then
        sut.track(event)
    }
}

// MARK: - Test Helpers

private struct TestEvent: TrackingEvent {
    let name: String
    var properties: [String: String] = [:]
}
