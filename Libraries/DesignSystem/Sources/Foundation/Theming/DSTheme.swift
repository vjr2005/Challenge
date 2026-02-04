/// A design system theme combining colors, typography, and spacing.
///
/// Use ``DSTheme/default`` for the standard theme, or create custom themes
/// by providing different ``DSColorPalette``, ``DSTypography``, and ``DSSpacing`` implementations.
public struct DSTheme: Sendable {
	/// The color palette for this theme
	public let colors: DSColorPalette

	/// The typography for this theme
	public let typography: DSTypography

	/// The spacing values for this theme
	public let spacing: DSSpacing

	/// Creates a new theme with the given color palette, typography, and spacing.
	/// - Parameters:
	///   - colors: The color palette
	///   - typography: The typography
	///   - spacing: The spacing values
	public init(colors: DSColorPalette, typography: DSTypography, spacing: DSSpacing) {
		self.colors = colors
		self.typography = typography
		self.spacing = spacing
	}

	/// The default design system theme
	public static let `default` = DSTheme(
		colors: DefaultColorPalette(),
		typography: DefaultTypography(),
		spacing: DefaultSpacing()
	)
}
