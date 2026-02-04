import Foundation

/// Protocol that ViewModels use to track events.
public protocol TrackerContract: Sendable {
    /// Tracks the given event.
    func track(_ event: any TrackingEvent)
}
