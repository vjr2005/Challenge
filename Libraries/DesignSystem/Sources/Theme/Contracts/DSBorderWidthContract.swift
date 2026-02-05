import Foundation

/// Contract for design system border width values.
///
/// Conforming types provide border width values for all design system components.
/// Each property maps to a semantic thickness (hairline, thin, medium, thick).
public protocol DSBorderWidthContract: Sendable {
	/// Hairline border (0.5pt)
	var hairline: CGFloat { get }

	/// Thin border (1pt)
	var thin: CGFloat { get }

	/// Medium border (2pt)
	var medium: CGFloat { get }

	/// Thick border (4pt)
	var thick: CGFloat { get }
}
