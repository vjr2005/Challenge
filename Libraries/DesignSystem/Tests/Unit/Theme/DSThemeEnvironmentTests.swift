import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite("DSThemeEnvironment")
struct DSThemeEnvironmentTests {
	@Test("Default theme uses DefaultColorPalette")
	func defaultThemeUsesDefaultColorPalette() {
		// Given
		let palette = DefaultColorPalette()

		// When
		let theme = DSTheme.default

		// Then
		#expect(theme.colors.accent == palette.accent)
		#expect(theme.colors.statusSuccess == palette.statusSuccess)
		#expect(theme.colors.textPrimary == palette.textPrimary)
	}

	@Test("Default theme uses DefaultTypography")
	func defaultThemeUsesDefaultTypography() {
		// Given
		let typography = DefaultTypography()

		// When
		let theme = DSTheme.default

		// Then
		#expect(theme.typography.headline == typography.headline)
		#expect(theme.typography.body == typography.body)
		#expect(theme.typography.caption2 == typography.caption2)
	}

	@Test("Default theme uses DefaultSpacing")
	func defaultThemeUsesDefaultSpacing() {
		// Given
		let spacing = DefaultSpacing()

		// When
		let theme = DSTheme.default

		// Then
		#expect(theme.spacing.sm == spacing.sm)
		#expect(theme.spacing.lg == spacing.lg)
		#expect(theme.spacing.xxl == spacing.xxl)
	}

	@Test("Default theme uses DefaultDimensions")
	func defaultThemeUsesDefaultDimensions() {
		// Given
		let dimensions = DefaultDimensions()

		// When
		let theme = DSTheme.default

		// Then
		#expect(theme.dimensions.sm == dimensions.sm)
		#expect(theme.dimensions.lg == dimensions.lg)
		#expect(theme.dimensions.xxl == dimensions.xxl)
	}

	@Test("Default theme uses DefaultBorderWidth")
	func defaultThemeUsesDefaultBorderWidth() {
		// Given
		let borderWidth = DefaultBorderWidth()

		// When
		let theme = DSTheme.default

		// Then
		#expect(theme.borderWidth.hairline == borderWidth.hairline)
		#expect(theme.borderWidth.thin == borderWidth.thin)
		#expect(theme.borderWidth.thick == borderWidth.thick)
	}

	@Test("Default theme uses DefaultCornerRadius")
	func defaultThemeUsesDefaultCornerRadius() {
		// Given
		let cornerRadius = DefaultCornerRadius()

		// When
		let theme = DSTheme.default

		// Then
		#expect(theme.cornerRadius.sm == cornerRadius.sm)
		#expect(theme.cornerRadius.lg == cornerRadius.lg)
		#expect(theme.cornerRadius.full == cornerRadius.full)
	}

	@Test("Default theme uses DefaultOpacity")
	func defaultThemeUsesDefaultOpacity() {
		// Given
		let opacity = DefaultOpacity()

		// When
		let theme = DSTheme.default

		// Then
		#expect(theme.opacity.subtle == opacity.subtle)
		#expect(theme.opacity.medium == opacity.medium)
		#expect(theme.opacity.almostOpaque == opacity.almostOpaque)
	}

	@Test("Default theme uses DefaultShadow")
	func defaultThemeUsesDefaultShadow() {
		// Given
		let shadow = DefaultShadow()

		// When
		let theme = DSTheme.default

		// Then
		#expect(theme.shadow.zero == shadow.zero)
		#expect(theme.shadow.small == shadow.small)
		#expect(theme.shadow.large == shadow.large)
	}

	@Test("dsTheme view modifier sets theme in environment")
	func dsThemeModifierSetsTheme() throws {
		// Given
		var environment = EnvironmentValues()

		// When
		environment.dsTheme = .default

		// Then
		#expect(environment.dsTheme.spacing.lg == DefaultSpacing().lg)
	}

	@Test("Custom theme can be created with different palette")
	func customThemeCanBeCreated() {
		// Given
		let customPalette = DefaultColorPalette()
		let customTypography = DefaultTypography()
		let customSpacing = DefaultSpacing()
		let customDimensions = DefaultDimensions()
		let customBorderWidth = DefaultBorderWidth()
		let customCornerRadius = DefaultCornerRadius()
		let customOpacity = DefaultOpacity()
		let customShadow = DefaultShadow()

		// When
		let theme = DSTheme(
			colors: customPalette,
			typography: customTypography,
			spacing: customSpacing,
			dimensions: customDimensions,
			borderWidth: customBorderWidth,
			cornerRadius: customCornerRadius,
			opacity: customOpacity,
			shadow: customShadow
		)

		// Then
		#expect(theme.colors.accent == customPalette.accent)
		#expect(theme.typography.body == customTypography.body)
		#expect(theme.spacing.lg == customSpacing.lg)
		#expect(theme.dimensions.lg == customDimensions.lg)
		#expect(theme.borderWidth.thin == customBorderWidth.thin)
		#expect(theme.cornerRadius.lg == customCornerRadius.lg)
		#expect(theme.opacity.medium == customOpacity.medium)
		#expect(theme.shadow.small == customShadow.small)
	}
}
