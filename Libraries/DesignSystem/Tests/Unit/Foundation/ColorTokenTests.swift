import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite("ColorToken")
struct ColorTokenTests {
	// MARK: - Status Colors

	@Test("Status colors match expected values")
	func statusColorsMatchExpected() {
		#expect(ColorToken.statusSuccess == .green)
		#expect(ColorToken.statusError == .red)
		#expect(ColorToken.statusWarning == .orange)
		#expect(ColorToken.statusNeutral == .gray)
	}

	// MARK: - Accent Colors

	@Test("Accent color matches expected value")
	func accentColorMatchesExpected() {
		let expected = Color(red: 0x33 / 255.0, green: 0x38 / 255.0, blue: 0x44 / 255.0)
		#expect(ColorToken.accent == expected)
	}

	@Test("Accent subtle has reduced opacity")
	func accentSubtleHasReducedOpacity() {
		let expected = Color(red: 0x33 / 255.0, green: 0x38 / 255.0, blue: 0x44 / 255.0).opacity(0.1)
		#expect(ColorToken.accentSubtle == expected)
	}
}
