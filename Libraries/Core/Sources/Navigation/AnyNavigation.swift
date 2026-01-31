import Foundation

/// Type-erased wrapper for Navigation.
/// Allows using a single `.navigationDestination(for:)` modifier for all navigation types.
public final class AnyNavigation: Hashable, @unchecked Sendable {
    /// The wrapped navigation value.
    public let wrapped: any Navigation

    /// Creates a new type-erased navigation wrapper.
    /// - Parameter navigation: The navigation to wrap.
    public init(_ navigation: any Navigation) {
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
