import Testing

@testable import ChallengeDesignSystem

@Suite("DSAccessibilityIdentifier")
struct DSAccessibilityIdentifierTests {
	// MARK: - Initialization

	@Test("Creates identifier from string")
	func initWithString() {
		// Given
		let value = "base"

		// When
		let sut = DSAccessibilityIdentifier(value)

		// Then
		#expect(sut.rawValue == "base")
	}

	@Test("Creates identifier with dot-separated path")
	func initWithDotSeparatedPath() {
		// Given
		let value = "characterList.row.1"

		// When
		let sut = DSAccessibilityIdentifier(value)

		// Then
		#expect(sut.rawValue == "characterList.row.1")
	}

	// MARK: - Appending

	@Test("Appends suffix correctly")
	func appendsSuffix() {
		// Given
		let sut = DSAccessibilityIdentifier("base")

		// When
		let result = sut.appending("name")

		// Then
		#expect(result.rawValue == "base.name")
	}

	@Test("Chains multiple suffixes")
	func chainsMultipleSuffixes() {
		// Given
		let sut = DSAccessibilityIdentifier("base")

		// When
		let result = sut.appending("info").appending("label")

		// Then
		#expect(result.rawValue == "base.info.label")
	}

	@Test("Appends suffix to complex path")
	func appendsSuffixToComplexPath() {
		// Given
		let sut = DSAccessibilityIdentifier("characterList.row.42")

		// When
		let result = sut.appending("image")

		// Then
		#expect(result.rawValue == "characterList.row.42.image")
	}

	// MARK: - Equality

	@Test("Equal identifiers are equal")
	func equalIdentifiersAreEqual() {
		// Given
		let id1 = DSAccessibilityIdentifier("test")
		let id2 = DSAccessibilityIdentifier("test")

		// When/Then
		#expect(id1 == id2)
	}

	@Test("Different identifiers are not equal")
	func differentIdentifiersAreNotEqual() {
		// Given
		let id1 = DSAccessibilityIdentifier("test")
		let id2 = DSAccessibilityIdentifier("other")

		// When/Then
		#expect(id1 != id2)
	}

	@Test("Appended identifiers differ from original")
	func appendedIdentifiersDifferFromOriginal() {
		// Given
		let original = DSAccessibilityIdentifier("base")

		// When
		let appended = original.appending("suffix")

		// Then
		#expect(original != appended)
	}
}
