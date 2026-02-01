/// Base protocol for cross-module navigation.
/// Each feature defines its own navigation type conforming to this protocol.
///
/// Use `IncomingNavigationContract` for destinations that can be navigated to directly.
/// Use `OutgoingNavigationContract` for destinations that require redirection to another feature.
nonisolated public protocol NavigationContract: Hashable, Sendable {}

/// Protocol for navigation destinations that can be navigated to directly.
/// These represent screens within a feature that have registered navigation destinations.
///
/// Example:
/// ```swift
/// public enum CharacterIncomingNavigation: IncomingNavigationContract {
///     case list
///     case detail(identifier: Int)
/// }
/// ```
nonisolated public protocol IncomingNavigationContract: NavigationContract {}

/// Protocol for navigation destinations that require redirection to another feature.
/// The NavigationCoordinator will redirect these to the appropriate IncomingNavigationContract.
///
/// Example:
/// ```swift
/// public enum HomeOutgoingNavigation: OutgoingNavigationContract {
///     case characters
/// }
/// ```
nonisolated public protocol OutgoingNavigationContract: NavigationContract {}
