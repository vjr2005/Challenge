/// A design system theme combining colors, typography, spacing, dimensions, border widths, corner radii, opacity, and shadows.
///
/// Use ``DSTheme/default`` for the standard theme, or create custom themes
/// by providing different ``DSColorPaletteContract``, ``DSTypographyContract``, ``DSSpacingContract``,
/// ``DSDimensionsContract``, ``DSBorderWidthContract``, ``DSCornerRadiusContract``, ``DSOpacityContract``, and ``DSShadowContract`` implementations.
public struct DSTheme {
	/// The color palette for this theme
	public let colors: any DSColorPaletteContract

	/// The typography for this theme
	public let typography: any DSTypographyContract

	/// The spacing values for this theme
	public let spacing: any DSSpacingContract

	/// The dimension values for this theme
	public let dimensions: any DSDimensionsContract

	/// The border width values for this theme
	public let borderWidth: any DSBorderWidthContract

	/// The corner radius values for this theme
	public let cornerRadius: any DSCornerRadiusContract

	/// The opacity values for this theme
	public let opacity: any DSOpacityContract

	/// The shadow values for this theme
	public let shadow: any DSShadowContract

	/// Creates a new theme with the given color palette, typography, spacing, dimensions, border widths, corner radii, opacity, and shadows.
	/// - Parameters:
	///   - colors: The color palette
	///   - typography: The typography
	///   - spacing: The spacing values
	///   - dimensions: The dimension values
	///   - borderWidth: The border width values
	///   - cornerRadius: The corner radius values
	///   - opacity: The opacity values
	///   - shadow: The shadow values
	public init(
		colors: any DSColorPaletteContract,
		typography: any DSTypographyContract,
		spacing: any DSSpacingContract,
		dimensions: any DSDimensionsContract,
		borderWidth: any DSBorderWidthContract,
		cornerRadius: any DSCornerRadiusContract,
		opacity: any DSOpacityContract,
		shadow: any DSShadowContract
	) {
		self.colors = colors
		self.typography = typography
		self.spacing = spacing
		self.dimensions = dimensions
		self.borderWidth = borderWidth
		self.cornerRadius = cornerRadius
		self.opacity = opacity
		self.shadow = shadow
	}

	/// The default design system theme
	public static let `default` = Self(
		colors: DefaultColorPalette(),
		typography: DefaultTypography(),
		spacing: DefaultSpacing(),
		dimensions: DefaultDimensions(),
		borderWidth: DefaultBorderWidth(),
		cornerRadius: DefaultCornerRadius(),
		opacity: DefaultOpacity(),
		shadow: DefaultShadow()
	)
}
