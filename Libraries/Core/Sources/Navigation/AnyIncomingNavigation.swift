import Foundation

/// Type-erased wrapper for IncomingNavigation.
/// Allows using a single `.navigationDestination(for:)` modifier for all navigation types.
public final class AnyIncomingNavigation: Hashable, @unchecked Sendable {
    /// The wrapped navigation value.
    public let wrapped: any IncomingNavigation

    /// Creates a new type-erased navigation wrapper.
    /// - Parameter navigation: The navigation to wrap.
    public init(_ navigation: any IncomingNavigation) {
        self.wrapped = navigation
    }

    public static func == (lhs: AnyIncomingNavigation, rhs: AnyIncomingNavigation) -> Bool {
        lhs.wrapped.hashValue == rhs.wrapped.hashValue &&
            type(of: lhs.wrapped) == type(of: rhs.wrapped)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type(of: wrapped)))
        hasher.combine(wrapped)
    }
}
