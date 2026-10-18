import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultColorPalette")
struct DefaultColorPaletteTests {
	private let sut = DefaultColorPalette()

	// MARK: - Status Colors

	@Test("Status colors match expected values")
	func statusColorsMatchExpected() {
		// When
		let statusSuccess = sut.statusSuccess
		let statusError = sut.statusError
		let statusWarning = sut.statusWarning
		let statusNeutral = sut.statusNeutral

		// Then
		#expect(statusSuccess == .green)
		#expect(statusError == .red)
		#expect(statusWarning == .orange)
		#expect(statusNeutral == .gray)
	}

	// MARK: - Accent Colors

	@Test("Accent color matches expected value")
	func accentColorMatchesExpected() {
		// Given
		let expected = Color(red: 0x33 / 255.0, green: 0x38 / 255.0, blue: 0x44 / 255.0)

		// When
		let accent = sut.accent

		// Then
		#expect(accent == expected)
	}

	@Test("Accent subtle has reduced opacity")
	func accentSubtleHasReducedOpacity() {
		// Given
		let expected = Color(red: 0x33 / 255.0, green: 0x38 / 255.0, blue: 0x44 / 255.0).opacity(0.1)

		// When
		let accentSubtle = sut.accentSubtle

		// Then
		#expect(accentSubtle == expected)
	}

	// MARK: - Background Colors

	@Test("Background colors use system colors")
	func backgroundColorsUseSystemColors() {
		// When
		let backgroundPrimary = sut.backgroundPrimary
		let backgroundSecondary = sut.backgroundSecondary
		let backgroundTertiary = sut.backgroundTertiary

		// Then
		#expect(backgroundPrimary == Color(.systemBackground))
		#expect(backgroundSecondary == Color(.systemGroupedBackground))
		#expect(backgroundTertiary == Color(.tertiarySystemBackground))
	}

	// MARK: - Surface Colors

	@Test("Surface colors use system colors")
	func surfaceColorsUseSystemColors() {
		// When
		let surfacePrimary = sut.surfacePrimary
		let surfaceSecondary = sut.surfaceSecondary

		// Then
		#expect(surfacePrimary == Color(.secondarySystemBackground))
		#expect(surfaceSecondary == Color(.tertiarySystemGroupedBackground))
	}

	// MARK: - Text Colors

	@Test("Text colors use system label colors")
	func textColorsUseSystemLabelColors() {
		// When
		let textPrimary = sut.textPrimary
		let textSecondary = sut.textSecondary
		let textTertiary = sut.textTertiary
		let textInverted = sut.textInverted

		// Then
		#expect(textPrimary == Color(.label))
		#expect(textSecondary == Color(.secondaryLabel))
		#expect(textTertiary == Color(.tertiaryLabel))
		#expect(textInverted == Color(.systemBackground))
	}

	// MARK: - Interactive Colors

	@Test("Disabled color uses system gray")
	func disabledColorUsesSystemGray() {
		// When
		let disabled = sut.disabled

		// Then
		#expect(disabled == Color(.systemGray3))
	}

	// MARK: - Separator Colors

	@Test("Separator colors use system separator colors")
	func separatorColorsUseSystemSeparatorColors() {
		// When
		let separator = sut.separator
		let separatorOpaque = sut.separatorOpaque

		// Then
		#expect(separator == Color(.separator))
		#expect(separatorOpaque == Color(.opaqueSeparator))
	}
}
