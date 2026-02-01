import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite("View+AccessibilityIdentifier")
struct ViewAccessibilityIdentifierTests {
	// MARK: - dsAccessibility Helper

	@Test("dsAccessibility applies identifier with suffix when baseID and suffix provided")
	func dsAccessibilityWithBaseIDAndSuffix() {
		// Given
		let baseID = DSAccessibilityIdentifier("base")
		let suffix = "name"

		// When
		let resultID = baseID.appending(suffix)

		// Then
		#expect(resultID.rawValue == "base.name")
	}

	@Test("dsAccessibility constructs correct identifier for atoms")
	func dsAccessibilityForAtoms() {
		// Given
		let baseID = DSAccessibilityIdentifier("characterList.row.1")

		// When
		let imageID = baseID.appending("image")
		let nameID = baseID.appending("name")
		let statusID = baseID.appending("status")

		// Then
		#expect(imageID.rawValue == "characterList.row.1.image")
		#expect(nameID.rawValue == "characterList.row.1.name")
		#expect(statusID.rawValue == "characterList.row.1.status")
	}

	@Test("dsAccessibility constructs correct identifier for nested components")
	func dsAccessibilityForNestedComponents() {
		// Given
		let baseID = DSAccessibilityIdentifier("infoRow")

		// When
		let iconID = baseID.appending("icon")
		let labelID = baseID.appending("label")
		let valueID = baseID.appending("value")

		// Then
		#expect(iconID.rawValue == "infoRow.icon")
		#expect(labelID.rawValue == "infoRow.label")
		#expect(valueID.rawValue == "infoRow.value")
	}
}

@Suite("DSAccessibilityIdentifier Environment")
struct DSAccessibilityEnvironmentTests {
	@Test("Environment key has nil default value")
	func environmentKeyDefaultValue() {
		// Given/When
		let environment = EnvironmentValues()

		// Then
		#expect(environment.dsAccessibilityIdentifier == nil)
	}

	@Test("Environment key can be set and retrieved")
	func environmentKeySetAndGet() {
		// Given
		var environment = EnvironmentValues()
		let identifier = DSAccessibilityIdentifier("test.id")

		// When
		environment.dsAccessibilityIdentifier = identifier

		// Then
		#expect(environment.dsAccessibilityIdentifier?.rawValue == "test.id")
	}

	@Test("Environment key can be set to nil")
	func environmentKeySetToNil() {
		// Given
		var environment = EnvironmentValues()
		environment.dsAccessibilityIdentifier = DSAccessibilityIdentifier("initial")

		// When
		environment.dsAccessibilityIdentifier = nil

		// Then
		#expect(environment.dsAccessibilityIdentifier == nil)
	}
}
