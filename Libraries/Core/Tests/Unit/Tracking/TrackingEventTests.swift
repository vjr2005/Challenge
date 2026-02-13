import Testing

@testable import ChallengeCore

struct TrackingEventTests {
    @Test("Default properties returns empty dictionary")
    func defaultPropertiesReturnsEmptyDictionary() {
        // Given
        let sut = TestEvent(name: "screen_view")

        // When
        let result = sut.properties

        // Then
		#expect(result.isEmpty)
    }
}

// MARK: - Test Helpers

private struct TestEvent: TrackingEventContract {
    let name: String
}
