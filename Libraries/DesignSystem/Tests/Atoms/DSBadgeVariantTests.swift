import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite("DSBadgeVariant")
struct DSBadgeVariantTests {
	// MARK: - Foreground Colors

	@Test("Success variant has success foreground color")
	func successForegroundColor() {
		#expect(DSBadgeVariant.success.foregroundColor == ColorToken.statusSuccess)
	}

	@Test("Error variant has error foreground color")
	func errorForegroundColor() {
		#expect(DSBadgeVariant.error.foregroundColor == ColorToken.statusError)
	}

	@Test("Warning variant has warning foreground color")
	func warningForegroundColor() {
		#expect(DSBadgeVariant.warning.foregroundColor == ColorToken.statusWarning)
	}

	@Test("Neutral variant has neutral foreground color")
	func neutralForegroundColor() {
		#expect(DSBadgeVariant.neutral.foregroundColor == ColorToken.statusNeutral)
	}

	@Test("Accent variant has accent foreground color")
	func accentForegroundColor() {
		#expect(DSBadgeVariant.accent.foregroundColor == ColorToken.accent)
	}

	// MARK: - Background Colors

	@Test("Success variant has success background color with opacity")
	func successBackgroundColor() {
		#expect(DSBadgeVariant.success.backgroundColor == ColorToken.statusSuccess.opacity(0.15))
	}

	@Test("Error variant has error background color with opacity")
	func errorBackgroundColor() {
		#expect(DSBadgeVariant.error.backgroundColor == ColorToken.statusError.opacity(0.15))
	}

	@Test("Warning variant has warning background color with opacity")
	func warningBackgroundColor() {
		#expect(DSBadgeVariant.warning.backgroundColor == ColorToken.statusWarning.opacity(0.15))
	}

	@Test("Neutral variant has neutral background color with opacity")
	func neutralBackgroundColor() {
		#expect(DSBadgeVariant.neutral.backgroundColor == ColorToken.statusNeutral.opacity(0.15))
	}

	@Test("Accent variant has accent subtle background color")
	func accentBackgroundColor() {
		#expect(DSBadgeVariant.accent.backgroundColor == ColorToken.accentSubtle)
	}

	// MARK: - All Variants

	@Test("All variants have different foreground colors")
	func allVariantsHaveDifferentForegroundColors() {
		let variants: [DSBadgeVariant] = [.success, .error, .warning, .neutral, .accent]
		var colors: Set<String> = []

		for variant in variants {
			colors.insert(variant.foregroundColor.description)
		}

		#expect(colors.count == variants.count)
	}
}
