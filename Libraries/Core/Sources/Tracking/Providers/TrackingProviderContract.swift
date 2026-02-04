import Foundation

/// Protocol for analytics backend providers.
/// Inherits from `TrackerContract` and adds lifecycle management.
public protocol TrackingProviderContract: TrackerContract {
    /// Configures the provider. Called once at app startup before any tracking.
    func configure()
}

public extension TrackingProviderContract {
    func configure() {}
}
