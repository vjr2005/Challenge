import SwiftUI

/// A type-safe wrapper for accessibility identifiers that supports suffix chaining.
///
/// Use this type to create hierarchical accessibility identifiers that can be
/// propagated through the view hierarchy with descriptive suffixes.
///
/// Example:
/// ```swift
/// let base = DSAccessibilityIdentifier("characterList.row.1")
/// let nameID = base.appending("name") // "characterList.row.1.name"
/// ```
public struct DSAccessibilityIdentifier: Sendable, Equatable {
	/// The underlying string value of the identifier.
	public let rawValue: String

	/// Creates a new accessibility identifier from a string value.
	/// - Parameter rawValue: The string value for the identifier.
	public init(_ rawValue: String) {
		self.rawValue = rawValue
	}

	/// Creates a new identifier by appending a suffix to this identifier.
	/// - Parameter suffix: The suffix to append, separated by a dot.
	/// - Returns: A new identifier with the suffix appended.
	public func appending(_ suffix: String) -> Self {
		Self("\(rawValue).\(suffix)")
	}
}
