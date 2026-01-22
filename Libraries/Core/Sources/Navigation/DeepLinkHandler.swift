import Foundation

/// Protocol for feature-specific deep link handlers.
public protocol DeepLinkHandler: Sendable {
    /// URL scheme this handler responds to (e.g., "challenge").
    var scheme: String { get }

    /// URL host this handler responds to (e.g., "character").
    var host: String { get }

    /// Resolves a URL to a Navigation destination.
    func resolve(_ url: URL) -> (any Navigation)?
}
