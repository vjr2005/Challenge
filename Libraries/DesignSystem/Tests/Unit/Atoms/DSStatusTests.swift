import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite("DSStatus")
struct DSStatusTests {
	private let palette = DefaultColorPalette()

	// MARK: - Color Properties

	@Test("Alive status has success color")
	func aliveStatusColor() {
		// When
		let aliveColor = DSStatus.alive.color(in: palette)

		// Then
		#expect(aliveColor == palette.statusSuccess)
	}

	@Test("Dead status has error color")
	func deadStatusColor() {
		// When
		let deadColor = DSStatus.dead.color(in: palette)

		// Then
		#expect(deadColor == palette.statusError)
	}

	@Test("Unknown status has neutral color")
	func unknownStatusColor() {
		// When
		let unknownColor = DSStatus.unknown.color(in: palette)

		// Then
		#expect(unknownColor == palette.statusNeutral)
	}

	// MARK: - Raw Values

	@Test("Status has the expected raw value", arguments: [
		(DSStatus.alive, "alive"),
		(DSStatus.dead, "dead"),
		(DSStatus.unknown, "unknown")
	])
	func rawValue(status: DSStatus, expected: String) {
		// When
		let rawValue = status.rawValue

		// Then
		#expect(rawValue == expected)
	}

	// MARK: - From String Conversion

	@Test("From string creates the expected status regardless of case", arguments: [
		("alive", DSStatus.alive), ("Alive", DSStatus.alive), ("ALIVE", DSStatus.alive),
		("dead", DSStatus.dead), ("Dead", DSStatus.dead), ("DEAD", DSStatus.dead),
		("unknown", DSStatus.unknown), ("Unknown", DSStatus.unknown), ("UNKNOWN", DSStatus.unknown)
	])
	func fromString(input: String, expected: DSStatus) {
		// When
		let status = DSStatus.from(input)

		// Then
		#expect(status == expected)
	}

	@Test("From string returns unknown for invalid value", arguments: ["invalid", "", "something else"])
	func fromStringInvalid(input: String) {
		// When
		let status = DSStatus.from(input)

		// Then
		#expect(status == .unknown)
	}

	// MARK: - CaseIterable

	@Test("All cases are present")
	func allCasesPresent() {
		// When
		let allCases = DSStatus.allCases

		// Then
		#expect(allCases.count == 3)
		#expect(allCases.contains(.alive))
		#expect(allCases.contains(.dead))
		#expect(allCases.contains(.unknown))
	}
}
