import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite("DSStatus")
struct DSStatusTests {
	private let palette = DefaultColorPalette()

	// MARK: - Color Properties

	@Test("Alive status has success color")
	func aliveStatusColor() {
		#expect(DSStatus.alive.color(in: palette) == palette.statusSuccess)
	}

	@Test("Dead status has error color")
	func deadStatusColor() {
		#expect(DSStatus.dead.color(in: palette) == palette.statusError)
	}

	@Test("Unknown status has neutral color")
	func unknownStatusColor() {
		#expect(DSStatus.unknown.color(in: palette) == palette.statusNeutral)
	}

	// MARK: - Raw Values

	@Test("Status has the expected raw value", arguments: [
		(DSStatus.alive, "alive"),
		(DSStatus.dead, "dead"),
		(DSStatus.unknown, "unknown")
	])
	func rawValue(status: DSStatus, expected: String) {
		#expect(status.rawValue == expected)
	}

	// MARK: - From String Conversion

	@Test("From string creates the expected status regardless of case", arguments: [
		("alive", DSStatus.alive), ("Alive", DSStatus.alive), ("ALIVE", DSStatus.alive),
		("dead", DSStatus.dead), ("Dead", DSStatus.dead), ("DEAD", DSStatus.dead),
		("unknown", DSStatus.unknown), ("Unknown", DSStatus.unknown), ("UNKNOWN", DSStatus.unknown)
	])
	func fromString(input: String, expected: DSStatus) {
		#expect(DSStatus.from(input) == expected)
	}

	@Test("From string returns unknown for invalid value", arguments: ["invalid", "", "something else"])
	func fromStringInvalid(input: String) {
		#expect(DSStatus.from(input) == .unknown)
	}

	// MARK: - CaseIterable

	@Test("All cases are present")
	func allCasesPresent() {
		let allCases = DSStatus.allCases
		#expect(allCases.count == 3)
		#expect(allCases.contains(.alive))
		#expect(allCases.contains(.dead))
		#expect(allCases.contains(.unknown))
	}
}
