import Foundation

/// Type-erased wrapper for NavigationContract.
/// Allows using a single `.navigationDestination(for:)` modifier for all navigation types.
public struct AnyNavigation: Hashable {
    /// The wrapped navigation value.
    public let wrapped: any NavigationContract
    /// Captures the underlying value's real equality through `AnyHashable`,
    /// since `any NavigationContract` cannot be compared directly with `==`.
    /// Unlike comparing `hashValue` (which can produce false positives on hash collisions),
    /// `AnyHashable` delegates to the concrete type's `==`, preserving semantic correctness.
    private let erased: AnyHashable

    /// Creates a new type-erased navigation wrapper.
    /// - Parameter navigation: The navigation to wrap.
    public init(_ navigation: any NavigationContract) {
        self.wrapped = navigation
        self.erased = AnyHashable(navigation)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.erased == rhs.erased
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(erased)
    }
}
