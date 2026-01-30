import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite("TextStyle")
struct TextStyleTests {
	// MARK: - Default Colors

	@Test("Primary text styles have primary default color")
	func primaryTextStylesHavePrimaryColor() {
		let primaryStyles: [TextStyle] = [
			.largeTitle, .title, .title2, .title3, .headline, .body
		]

		for style in primaryStyles {
			#expect(
				style.defaultColor == ColorToken.textPrimary,
				"Style \(style) should have textPrimary as default color"
			)
		}
	}

	@Test("Secondary text styles have secondary default color")
	func secondaryTextStylesHaveSecondaryColor() {
		let secondaryStyles: [TextStyle] = [.subheadline, .footnote, .caption]

		for style in secondaryStyles {
			#expect(
				style.defaultColor == ColorToken.textSecondary,
				"Style \(style) should have textSecondary as default color"
			)
		}
	}

	@Test("Caption2 has tertiary default color")
	func caption2HasTertiaryColor() {
		#expect(TextStyle.caption2.defaultColor == ColorToken.textTertiary)
	}
}
