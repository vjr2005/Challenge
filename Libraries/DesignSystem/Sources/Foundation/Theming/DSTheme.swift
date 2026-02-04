/// A design system theme combining colors, typography, spacing, dimensions, and border widths.
///
/// Use ``DSTheme/default`` for the standard theme, or create custom themes
/// by providing different ``DSColorPalette``, ``DSTypography``, ``DSSpacing``,
/// ``DSDimensions``, and ``DSBorderWidth`` implementations.
public struct DSTheme: Sendable {
	/// The color palette for this theme
	public let colors: DSColorPalette

	/// The typography for this theme
	public let typography: DSTypography

	/// The spacing values for this theme
	public let spacing: DSSpacing

	/// The dimension values for this theme
	public let dimensions: DSDimensions

	/// The border width values for this theme
	public let borderWidth: DSBorderWidth

	/// Creates a new theme with the given color palette, typography, spacing, dimensions, and border widths.
	/// - Parameters:
	///   - colors: The color palette
	///   - typography: The typography
	///   - spacing: The spacing values
	///   - dimensions: The dimension values
	///   - borderWidth: The border width values
	public init(
		colors: DSColorPalette,
		typography: DSTypography,
		spacing: DSSpacing,
		dimensions: DSDimensions,
		borderWidth: DSBorderWidth
	) {
		self.colors = colors
		self.typography = typography
		self.spacing = spacing
		self.dimensions = dimensions
		self.borderWidth = borderWidth
	}

	/// The default design system theme
	public static let `default` = Self(
		colors: DefaultColorPalette(),
		typography: DefaultTypography(),
		spacing: DefaultSpacing(),
		dimensions: DefaultDimensions(),
		borderWidth: DefaultBorderWidth()
	)
}
