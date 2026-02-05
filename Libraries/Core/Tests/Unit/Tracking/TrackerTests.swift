import Testing

@testable import ChallengeCore

struct TrackerTests {
    // MARK: - Single Provider

    @Test("Dispatches event to single provider")
    func dispatchesEventToSingleProvider() {
        // Given
        let provider = TrackingProviderMock()
        let sut = Tracker(providers: [provider])
        let event = TestTrackingEvent(name: "screen_view", properties: ["screen": "home"])

        // When
        sut.track(event)

        // Then
        #expect(provider.trackedEvents.count == 1)
        #expect(provider.trackedEvents[0].name == "screen_view")
        #expect(provider.trackedEvents[0].properties == ["screen": "home"])
    }

    // MARK: - Multiple Providers

    @Test("Dispatches event to multiple providers")
    func dispatchesEventToMultipleProviders() {
        // Given
        let providerA = TrackingProviderMock()
        let providerB = TrackingProviderMock()
        let sut = Tracker(providers: [providerA, providerB])
        let event = TestTrackingEvent(name: "button_tap", properties: ["button": "retry"])

        // When
        sut.track(event)

        // Then
        #expect(providerA.trackedEvents.count == 1)
        #expect(providerA.trackedEvents[0].name == "button_tap")
        #expect(providerB.trackedEvents.count == 1)
        #expect(providerB.trackedEvents[0].name == "button_tap")
    }

    // MARK: - Zero Providers

    @Test("Works with zero providers without crashing")
    func worksWithZeroProviders() {
        // Given
        let sut = Tracker(providers: [])
        let event = TestTrackingEvent(name: "event", properties: [:])

        // When / Then
        sut.track(event)
    }

    // MARK: - Event Forwarding

    @Test("Forwards event name and properties correctly")
    func forwardsEventNameAndPropertiesCorrectly() {
        // Given
        let provider = TrackingProviderMock()
        let sut = Tracker(providers: [provider])
        let properties = ["key1": "value1", "key2": "value2"]
        let event = TestTrackingEvent(name: "custom_event", properties: properties)

        // When
        sut.track(event)

        // Then
        #expect(provider.trackedEvents[0].name == "custom_event")
        #expect(provider.trackedEvents[0].properties == properties)
    }

    @Test("Dispatches multiple events in order")
    func dispatchesMultipleEventsInOrder() {
        // Given
        let provider = TrackingProviderMock()
        let sut = Tracker(providers: [provider])
        let firstEvent = TestTrackingEvent(name: "first", properties: [:])
        let secondEvent = TestTrackingEvent(name: "second", properties: ["key": "value"])

        // When
        sut.track(firstEvent)
        sut.track(secondEvent)

        // Then
        #expect(provider.trackedEvents.count == 2)
        #expect(provider.trackedEvents[0].name == "first")
        #expect(provider.trackedEvents[1].name == "second")
        #expect(provider.trackedEvents[1].properties == ["key": "value"])
    }
}

// MARK: - Test Helpers

private struct TestTrackingEvent: TrackingEventContract {
    let name: String
    let properties: [String: String]
}
