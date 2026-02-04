import Foundation

/// Contract for design system spacing values.
///
/// Conforming types provide spacing values for all design system components.
/// Each property maps to a semantic size (extra-small, small, medium, large, etc.).
public protocol DSSpacing: Sendable {
	/// Extra extra small spacing (2pt)
	var xxs: CGFloat { get }

	/// Extra small spacing (4pt)
	var xs: CGFloat { get }

	/// Small spacing (8pt)
	var sm: CGFloat { get }

	/// Medium spacing (12pt)
	var md: CGFloat { get }

	/// Large spacing (16pt)
	var lg: CGFloat { get }

	/// Extra large spacing (20pt)
	var xl: CGFloat { get }

	/// Extra extra large spacing (24pt)
	var xxl: CGFloat { get }

	/// Extra extra extra large spacing (32pt)
	var xxxl: CGFloat { get }
}
