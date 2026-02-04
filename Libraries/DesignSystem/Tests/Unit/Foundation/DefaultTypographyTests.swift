import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultTypography")
struct DefaultTypographyTests {
	private let sut = DefaultTypography()
	private let palette = DefaultColorPalette()

	// MARK: - Font Mapping

	@Test("Font for largeTitle returns rounded bold")
	func fontForLargeTitle() {
		#expect(sut.font(for: .largeTitle) == .system(.largeTitle, design: .rounded, weight: .bold))
	}

	@Test("Font for title returns rounded bold")
	func fontForTitle() {
		#expect(sut.font(for: .title) == .system(.title, design: .rounded, weight: .bold))
	}

	@Test("Font for title2 returns rounded semibold")
	func fontForTitle2() {
		#expect(sut.font(for: .title2) == .system(.title2, design: .rounded, weight: .semibold))
	}

	@Test("Font for title3 returns rounded semibold")
	func fontForTitle3() {
		#expect(sut.font(for: .title3) == .system(.title3, design: .rounded, weight: .semibold))
	}

	@Test("Font for headline returns rounded semibold")
	func fontForHeadline() {
		#expect(sut.font(for: .headline) == .system(.headline, design: .rounded, weight: .semibold))
	}

	@Test("Font for body returns rounded")
	func fontForBody() {
		#expect(sut.font(for: .body) == .system(.body, design: .rounded))
	}

	@Test("Font for subheadline returns serif")
	func fontForSubheadline() {
		#expect(sut.font(for: .subheadline) == .system(.subheadline, design: .serif))
	}

	@Test("Font for footnote returns rounded")
	func fontForFootnote() {
		#expect(sut.font(for: .footnote) == .system(.footnote, design: .rounded))
	}

	@Test("Font for caption returns rounded")
	func fontForCaption() {
		#expect(sut.font(for: .caption) == .system(.caption, design: .rounded))
	}

	@Test("Font for caption2 returns monospaced")
	func fontForCaption2() {
		#expect(sut.font(for: .caption2) == .system(.caption2, design: .monospaced))
	}

	// MARK: - Default Colors

	@Test("Primary text styles have primary default color")
	func primaryTextStylesHavePrimaryColor() {
		let primaryStyles: [TextStyle] = [
			.largeTitle, .title, .title2, .title3, .headline, .body
		]

		for style in primaryStyles {
			#expect(
				sut.defaultColor(for: style, in: palette) == palette.textPrimary,
				"Style \(style) should have textPrimary as default color"
			)
		}
	}

	@Test("Secondary text styles have secondary default color")
	func secondaryTextStylesHaveSecondaryColor() {
		let secondaryStyles: [TextStyle] = [.subheadline, .footnote, .caption]

		for style in secondaryStyles {
			#expect(
				sut.defaultColor(for: style, in: palette) == palette.textSecondary,
				"Style \(style) should have textSecondary as default color"
			)
		}
	}

	@Test("Caption2 has tertiary default color")
	func caption2HasTertiaryColor() {
		#expect(sut.defaultColor(for: .caption2, in: palette) == palette.textTertiary)
	}
}
