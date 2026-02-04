/// A design system theme combining colors and typography.
///
/// Use ``DSTheme/default`` for the standard theme, or create custom themes
/// by providing different ``DSColorPalette`` and ``DSTypography`` implementations.
public struct DSTheme: Sendable {
	/// The color palette for this theme
	public let colors: DSColorPalette

	/// The typography for this theme
	public let typography: DSTypography

	/// Creates a new theme with the given color palette and typography.
	/// - Parameters:
	///   - colors: The color palette
	///   - typography: The typography
	public init(colors: DSColorPalette, typography: DSTypography) {
		self.colors = colors
		self.typography = typography
	}

	/// The default design system theme
	public static let `default` = DSTheme(
		colors: DefaultColorPalette(),
		typography: DefaultTypography()
	)
}
