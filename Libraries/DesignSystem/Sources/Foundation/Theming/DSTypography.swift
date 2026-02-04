import SwiftUI

/// Contract for design system typography.
///
/// Conforming types provide font and default color mappings for each ``TextStyle``.
public protocol DSTypography: Sendable {
	/// Returns the SwiftUI font for the given text style.
	/// - Parameter style: The text style to resolve
	/// - Returns: The corresponding font
	func font(for style: TextStyle) -> Font

	/// Returns the default foreground color for the given text style in the given palette.
	/// - Parameters:
	///   - style: The text style to resolve
	///   - palette: The color palette to use
	/// - Returns: The corresponding default color
	func defaultColor(for style: TextStyle, in palette: DSColorPalette) -> Color
}
