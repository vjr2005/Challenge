import Foundation

/// Contract for design system opacity values.
///
/// Conforming types provide opacity values for all design system components.
/// Each property maps to a semantic opacity level from subtle to almost opaque.
public protocol DSOpacityContract: Sendable {
	/// Subtle opacity (0.1)
	var subtle: Double { get }

	/// Light opacity (0.15)
	var light: Double { get }

	/// Medium opacity (0.4)
	var medium: Double { get }

	/// Heavy opacity (0.6)
	var heavy: Double { get }

	/// Almost opaque (0.8)
	var almostOpaque: Double { get }
}
