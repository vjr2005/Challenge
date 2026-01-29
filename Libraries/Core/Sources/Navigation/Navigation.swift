/// Base protocol for cross-module navigation.
/// Each feature defines its own navigation type conforming to this protocol.
///
/// Use `IncomingNavigation` for destinations that can be navigated to directly.
/// Use `OutgoingNavigation` for destinations that require redirection to another feature.
nonisolated public protocol Navigation: Hashable, Sendable {}

/// Protocol for navigation destinations that can be navigated to directly.
/// These represent screens within a feature that have registered navigation destinations.
///
/// Example:
/// ```swift
/// public enum CharacterIncomingNavigation: IncomingNavigation {
///     case list
///     case detail(identifier: Int)
/// }
/// ```
nonisolated public protocol IncomingNavigation: Navigation {}

/// Protocol for navigation destinations that require redirection to another feature.
/// The NavigationCoordinator will redirect these to the appropriate IncomingNavigation.
///
/// Example:
/// ```swift
/// public enum HomeOutgoingNavigation: OutgoingNavigation {
///     case characters
/// }
/// ```
nonisolated public protocol OutgoingNavigation: Navigation {}
