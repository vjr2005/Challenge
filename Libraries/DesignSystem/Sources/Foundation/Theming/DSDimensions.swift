import Foundation

/// Contract for design system dimension values.
///
/// Conforming types provide dimension values for icons and other sized elements.
/// Each property maps to a semantic size (extra-small, small, medium, large, etc.).
public protocol DSDimensions: Sendable {
	/// Extra small dimension (8pt)
	var xs: CGFloat { get }

	/// Small dimension (12pt)
	var sm: CGFloat { get }

	/// Medium dimension (16pt)
	var md: CGFloat { get }

	/// Large dimension (24pt)
	var lg: CGFloat { get }

	/// Extra large dimension (32pt)
	var xl: CGFloat { get }

	/// Extra extra large dimension (48pt)
	var xxl: CGFloat { get }

	/// Extra extra extra large dimension (56pt)
	var xxxl: CGFloat { get }
}
