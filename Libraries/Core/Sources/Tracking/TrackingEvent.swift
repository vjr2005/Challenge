import Foundation

/// Protocol that defines a tracking event.
/// Each feature creates enums conforming to this protocol.
public protocol TrackingEvent: Sendable {
    /// The name of the event.
    var name: String { get }

    /// The properties associated with the event. Defaults to an empty dictionary.
    var properties: [String: String] { get }
}

public extension TrackingEvent {
    var properties: [String: String] { [:] }
}
