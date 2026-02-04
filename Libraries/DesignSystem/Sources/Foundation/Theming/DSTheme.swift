/// A design system theme combining colors, typography, spacing, and dimensions.
///
/// Use ``DSTheme/default`` for the standard theme, or create custom themes
/// by providing different ``DSColorPalette``, ``DSTypography``, ``DSSpacing``,
/// and ``DSDimensions`` implementations.
public struct DSTheme: Sendable {
	/// The color palette for this theme
	public let colors: DSColorPalette

	/// The typography for this theme
	public let typography: DSTypography

	/// The spacing values for this theme
	public let spacing: DSSpacing

	/// The dimension values for this theme
	public let dimensions: DSDimensions

	/// Creates a new theme with the given color palette, typography, spacing, and dimensions.
	/// - Parameters:
	///   - colors: The color palette
	///   - typography: The typography
	///   - spacing: The spacing values
	///   - dimensions: The dimension values
	public init(
		colors: DSColorPalette,
		typography: DSTypography,
		spacing: DSSpacing,
		dimensions: DSDimensions
	) {
		self.colors = colors
		self.typography = typography
		self.spacing = spacing
		self.dimensions = dimensions
	}

	/// The default design system theme
	public static let `default` = DSTheme(
		colors: DefaultColorPalette(),
		typography: DefaultTypography(),
		spacing: DefaultSpacing(),
		dimensions: DefaultDimensions()
	)
}
