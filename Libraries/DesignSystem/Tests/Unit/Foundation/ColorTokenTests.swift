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

	@Test("Accent color matches system accent")
	func accentColorMatchesSystem() {
		#expect(ColorToken.accent == .accentColor)
	}

	@Test("Accent subtle has reduced opacity")
	func accentSubtleHasReducedOpacity() {
		#expect(ColorToken.accentSubtle == .accentColor.opacity(0.1))
	}
}
