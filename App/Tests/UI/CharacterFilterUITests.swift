import XCTest

/// UI tests for the character filter flow.
final class CharacterFilterUITests: UITestCase {
	@MainActor
	func testOpenCharacterFilterAndCloseWithoutApplying() async throws {
		// Given
		try await givenCharacterListSucceeds()

		// When
		launch()

		// Then
		home { robot in
			robot.tapCharacterButton()
		}

		characterList { robot in
			robot.verifyIsVisible()
			robot.verifyCharacterExists(identifier: 1)
			robot.tapFilterButton()
		}

		characterFilter { robot in
			robot.verifyIsVisible()
			robot.tapClose()
		}

		characterList { robot in
			robot.verifyIsVisible()
			robot.verifyCharacterExists(identifier: 1)
		}
	}

	@MainActor
	func testApplyStatusFilterAndVerifyListReloads() async throws {
		// Given
		try await givenCharacterListSucceeds()

		// When
		launch()

		// Then
		home { robot in
			robot.tapCharacterButton()
		}

		characterList { robot in
			robot.verifyIsVisible()
			robot.tapFilterButton()
		}

		characterFilter { robot in
			robot.verifyIsVisible()
			robot.tapStatusChip("Alive")
			robot.tapStatusChip("Alive")
			robot.tapStatusChip("Alive")
			robot.tapApply()
		}

		characterList { robot in
			robot.verifyIsVisible()
			robot.verifyCharacterExists(identifier: 1)
		}
	}

	@MainActor
	func testApplyMultipleFiltersAndResetThenApply() async throws {
		// Given
		try await givenCharacterListSucceeds()

		// When
		launch()

		// Then
		home { robot in
			robot.tapCharacterButton()
		}

		characterList { robot in
			robot.verifyIsVisible()
			robot.tapFilterButton()
		}

		characterFilter { robot in
			robot.verifyIsVisible()
			robot.tapStatusChip("Alive")
			robot.tapGenderChip("Male")
			robot.typeSpecies(text: "Human")
			robot.typeType(text: "Genetic")
			robot.tapReset()
			robot.tapApply()
		}

		characterList { robot in
			robot.verifyIsVisible()
			robot.verifyCharacterExists(identifier: 1)
		}
	}
}
