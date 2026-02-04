import Foundation

/// Concrete tracker that dispatches events to multiple providers.
public final class Tracker: TrackerContract, Sendable {
    private let providers: [any TrackingProviderContract]

    /// Creates a tracker with the given providers.
    public init(providers: [any TrackingProviderContract]) {
        self.providers = providers
    }

    /// Dispatches the event to all registered providers.
    public func track(_ event: any TrackingEvent) {
        for provider in providers {
            provider.track(event)
        }
    }
}
