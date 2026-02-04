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

	@Test("Alive status has correct raw value")
	func aliveRawValue() {
		#expect(DSStatus.alive.rawValue == "alive")
	}

	@Test("Dead status has correct raw value")
	func deadRawValue() {
		#expect(DSStatus.dead.rawValue == "dead")
	}

	@Test("Unknown status has correct raw value")
	func unknownRawValue() {
		#expect(DSStatus.unknown.rawValue == "unknown")
	}

	// MARK: - From String Conversion

	@Test("From string creates alive status")
	func fromStringAlive() {
		#expect(DSStatus.from("alive") == .alive)
		#expect(DSStatus.from("Alive") == .alive)
		#expect(DSStatus.from("ALIVE") == .alive)
	}

	@Test("From string creates dead status")
	func fromStringDead() {
		#expect(DSStatus.from("dead") == .dead)
		#expect(DSStatus.from("Dead") == .dead)
		#expect(DSStatus.from("DEAD") == .dead)
	}

	@Test("From string creates unknown status")
	func fromStringUnknown() {
		#expect(DSStatus.from("unknown") == .unknown)
		#expect(DSStatus.from("Unknown") == .unknown)
		#expect(DSStatus.from("UNKNOWN") == .unknown)
	}

	@Test("From string returns unknown for invalid value")
	func fromStringInvalid() {
		#expect(DSStatus.from("invalid") == .unknown)
		#expect(DSStatus.from("") == .unknown)
		#expect(DSStatus.from("something else") == .unknown)
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
