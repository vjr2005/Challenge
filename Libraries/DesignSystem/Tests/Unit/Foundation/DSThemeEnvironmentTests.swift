import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite("DSThemeEnvironment")
struct DSThemeEnvironmentTests {
	@Test("Default theme uses DefaultColorPalette")
	func defaultThemeUsesDefaultColorPalette() {
		let theme = DSTheme.default
		let palette = DefaultColorPalette()

		#expect(theme.colors.accent == palette.accent)
		#expect(theme.colors.statusSuccess == palette.statusSuccess)
		#expect(theme.colors.textPrimary == palette.textPrimary)
	}

	@Test("Default theme uses DefaultTypography")
	func defaultThemeUsesDefaultTypography() {
		let theme = DSTheme.default
		let typography = DefaultTypography()

		#expect(theme.typography.font(for: .headline) == typography.font(for: .headline))
		#expect(theme.typography.font(for: .body) == typography.font(for: .body))
		#expect(theme.typography.font(for: .caption2) == typography.font(for: .caption2))
	}

	@Test("Default theme uses DefaultSpacing")
	func defaultThemeUsesDefaultSpacing() {
		let theme = DSTheme.default
		let spacing = DefaultSpacing()

		#expect(theme.spacing.sm == spacing.sm)
		#expect(theme.spacing.lg == spacing.lg)
		#expect(theme.spacing.xxl == spacing.xxl)
	}

	@Test("Default theme uses DefaultDimensions")
	func defaultThemeUsesDefaultDimensions() {
		let theme = DSTheme.default
		let dimensions = DefaultDimensions()

		#expect(theme.dimensions.sm == dimensions.sm)
		#expect(theme.dimensions.lg == dimensions.lg)
		#expect(theme.dimensions.xxl == dimensions.xxl)
	}

	@Test("Default theme uses DefaultBorderWidth")
	func defaultThemeUsesDefaultBorderWidth() {
		let theme = DSTheme.default
		let borderWidth = DefaultBorderWidth()

		#expect(theme.borderWidth.hairline == borderWidth.hairline)
		#expect(theme.borderWidth.thin == borderWidth.thin)
		#expect(theme.borderWidth.thick == borderWidth.thick)
	}

	@Test("Custom theme can be created with different palette")
	func customThemeCanBeCreated() {
		let customPalette = DefaultColorPalette()
		let customTypography = DefaultTypography()
		let customSpacing = DefaultSpacing()
		let customDimensions = DefaultDimensions()
		let customBorderWidth = DefaultBorderWidth()
		let theme = DSTheme(
			colors: customPalette,
			typography: customTypography,
			spacing: customSpacing,
			dimensions: customDimensions,
			borderWidth: customBorderWidth
		)

		#expect(theme.colors.accent == customPalette.accent)
		#expect(theme.typography.font(for: .body) == customTypography.font(for: .body))
		#expect(theme.spacing.lg == customSpacing.lg)
		#expect(theme.dimensions.lg == customDimensions.lg)
		#expect(theme.borderWidth.thin == customBorderWidth.thin)
	}
}
