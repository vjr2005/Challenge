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

	@Test("Default theme uses DefaultCornerRadius")
	func defaultThemeUsesDefaultCornerRadius() {
		let theme = DSTheme.default
		let cornerRadius = DefaultCornerRadius()

		#expect(theme.cornerRadius.sm == cornerRadius.sm)
		#expect(theme.cornerRadius.lg == cornerRadius.lg)
		#expect(theme.cornerRadius.full == cornerRadius.full)
	}

	@Test("Default theme uses DefaultOpacity")
	func defaultThemeUsesDefaultOpacity() {
		let theme = DSTheme.default
		let opacity = DefaultOpacity()

		#expect(theme.opacity.subtle == opacity.subtle)
		#expect(theme.opacity.medium == opacity.medium)
		#expect(theme.opacity.almostOpaque == opacity.almostOpaque)
	}

	@Test("Default theme uses DefaultShadow")
	func defaultThemeUsesDefaultShadow() {
		let theme = DSTheme.default
		let shadow = DefaultShadow()

		#expect(theme.shadow.zero == shadow.zero)
		#expect(theme.shadow.small == shadow.small)
		#expect(theme.shadow.large == shadow.large)
	}

	@Test("Custom theme can be created with different palette")
	func customThemeCanBeCreated() {
		let customPalette = DefaultColorPalette()
		let customTypography = DefaultTypography()
		let customSpacing = DefaultSpacing()
		let customDimensions = DefaultDimensions()
		let customBorderWidth = DefaultBorderWidth()
		let customCornerRadius = DefaultCornerRadius()
		let customOpacity = DefaultOpacity()
		let customShadow = DefaultShadow()
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

		#expect(theme.colors.accent == customPalette.accent)
		#expect(theme.typography.font(for: .body) == customTypography.font(for: .body))
		#expect(theme.spacing.lg == customSpacing.lg)
		#expect(theme.dimensions.lg == customDimensions.lg)
		#expect(theme.borderWidth.thin == customBorderWidth.thin)
		#expect(theme.cornerRadius.lg == customCornerRadius.lg)
		#expect(theme.opacity.medium == customOpacity.medium)
		#expect(theme.shadow.small == customShadow.small)
	}
}
