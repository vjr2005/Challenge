import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultColorPalette")
struct DefaultColorPaletteTests {
	private let sut = DefaultColorPalette()

	// MARK: - Status Colors

	@Test("Status colors match expected values")
	func statusColorsMatchExpected() {
		#expect(sut.statusSuccess == .green)
		#expect(sut.statusError == .red)
		#expect(sut.statusWarning == .orange)
		#expect(sut.statusNeutral == .gray)
	}

	// MARK: - Accent Colors

	@Test("Accent color matches expected value")
	func accentColorMatchesExpected() {
		let expected = Color(red: 0x33 / 255.0, green: 0x38 / 255.0, blue: 0x44 / 255.0)
		#expect(sut.accent == expected)
	}

	@Test("Accent subtle has reduced opacity")
	func accentSubtleHasReducedOpacity() {
		let expected = Color(red: 0x33 / 255.0, green: 0x38 / 255.0, blue: 0x44 / 255.0).opacity(0.1)
		#expect(sut.accentSubtle == expected)
	}

	// MARK: - Background Colors

	@Test("Background colors use system colors")
	func backgroundColorsUseSystemColors() {
		#expect(sut.backgroundPrimary == Color(.systemBackground))
		#expect(sut.backgroundSecondary == Color(.systemGroupedBackground))
		#expect(sut.backgroundTertiary == Color(.tertiarySystemBackground))
	}

	// MARK: - Surface Colors

	@Test("Surface colors use system colors")
	func surfaceColorsUseSystemColors() {
		#expect(sut.surfacePrimary == Color(.secondarySystemBackground))
		#expect(sut.surfaceSecondary == Color(.tertiarySystemGroupedBackground))
	}

	// MARK: - Text Colors

	@Test("Text colors use system label colors")
	func textColorsUseSystemLabelColors() {
		#expect(sut.textPrimary == Color(.label))
		#expect(sut.textSecondary == Color(.secondaryLabel))
		#expect(sut.textTertiary == Color(.tertiaryLabel))
		#expect(sut.textInverted == Color(.systemBackground))
	}

	// MARK: - Interactive Colors

	@Test("Disabled color uses system gray")
	func disabledColorUsesSystemGray() {
		#expect(sut.disabled == Color(.systemGray3))
	}

	// MARK: - Separator Colors

	@Test("Separator colors use system separator colors")
	func separatorColorsUseSystemSeparatorColors() {
		#expect(sut.separator == Color(.separator))
		#expect(sut.separatorOpaque == Color(.opaqueSeparator))
	}
}
