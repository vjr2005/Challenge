/// Base protocol for cross-module navigation.
/// Each feature defines its own navigation type conforming to this protocol.
///
/// Example:
/// ```swift
/// public enum CharacterNavigation: Navigation {
///     case list
///     case detail(identifier: Int)
/// }
/// ```
public protocol Navigation: Hashable, Sendable {}
