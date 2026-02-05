/// A design system theme combining colors, typography, spacing, dimensions, border widths, corner radii, opacity, and shadows.
///
/// Use ``DSTheme/default`` for the standard theme, or create custom themes
/// by providing different ``DSColorPaletteContract``, ``DSTypographyContract``, ``DSSpacingContract``,
/// ``DSDimensionsContract``, ``DSBorderWidthContract``, ``DSCornerRadiusContract``, ``DSOpacityContract``, and ``DSShadowContract`` implementations.
public struct DSTheme: Sendable {
	/// The color palette for this theme
	public let colors: DSColorPaletteContract

	/// The typography for this theme
	public let typography: DSTypographyContract

	/// The spacing values for this theme
	public let spacing: DSSpacingContract

	/// The dimension values for this theme
	public let dimensions: DSDimensionsContract

	/// The border width values for this theme
	public let borderWidth: DSBorderWidthContract

	/// The corner radius values for this theme
	public let cornerRadius: DSCornerRadiusContract

	/// The opacity values for this theme
	public let opacity: DSOpacityContract

	/// The shadow values for this theme
	public let shadow: DSShadowContract

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
		colors: DSColorPaletteContract,
		typography: DSTypographyContract,
		spacing: DSSpacingContract,
		dimensions: DSDimensionsContract,
		borderWidth: DSBorderWidthContract,
		cornerRadius: DSCornerRadiusContract,
		opacity: DSOpacityContract,
		shadow: DSShadowContract
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
