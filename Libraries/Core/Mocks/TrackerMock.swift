import ChallengeCore
import Foundation

/// Value type that stores a reduced tracking event for test assertions.
public struct TrackedEvent: Equatable, Sendable {
    /// The name of the tracked event.
    public let name: String

    /// The properties of the tracked event.
    public let properties: [String: String]

    /// Creates a new tracked event.
    /// - Parameters:
    ///   - name: The name of the tracked event.
    ///   - properties: The properties of the tracked event.
    public init(name: String, properties: [String: String]) {
        self.name = name
        self.properties = properties
    }
}

/// Mock implementation of `TrackerContract` for testing tracking.
public final class TrackerMock: TrackerContract, @unchecked Sendable {
    /// The events that have been tracked.
    public private(set) var trackedEvents: [TrackedEvent] = []

    /// Creates a new tracker mock.
    public init() {}

    /// Records the event for later assertion.
    public func track(_ event: any TrackingEvent) {
        trackedEvents.append(TrackedEvent(name: event.name, properties: event.properties))
    }
}
