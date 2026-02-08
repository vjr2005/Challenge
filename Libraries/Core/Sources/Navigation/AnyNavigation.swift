import Foundation

/// Type-erased wrapper for NavigationContract.
/// Allows using a single `.navigationDestination(for:)` modifier for all navigation types.
public struct AnyNavigation: Hashable {
    /// The wrapped navigation value.
    public let wrapped: any NavigationContract

    /// Creates a new type-erased navigation wrapper.
    /// - Parameter navigation: The navigation to wrap.
    public init(_ navigation: any NavigationContract) {
        self.wrapped = navigation
    }

    public static func == (lhs: AnyNavigation, rhs: AnyNavigation) -> Bool {
        lhs.wrapped.hashValue == rhs.wrapped.hashValue &&
            type(of: lhs.wrapped) == type(of: rhs.wrapped)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type(of: wrapped)))
        hasher.combine(wrapped)
    }
}
