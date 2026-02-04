import Foundation

/// Contract for design system corner radius values.
///
/// Conforming types provide corner radius values for all design system components.
/// Each property maps to a semantic size (zero, extra-small, small, medium, large, etc.).
public protocol DSCornerRadius: Sendable {
	/// No corner radius (0pt)
	var zero: CGFloat { get }

	/// Extra small corner radius (4pt)
	var xs: CGFloat { get }

	/// Small corner radius (8pt)
	var sm: CGFloat { get }

	/// Medium corner radius (12pt)
	var md: CGFloat { get }

	/// Large corner radius (16pt)
	var lg: CGFloat { get }

	/// Extra large corner radius (20pt)
	var xl: CGFloat { get }

	/// Full/circular corner radius (9999pt)
	var full: CGFloat { get }
}
