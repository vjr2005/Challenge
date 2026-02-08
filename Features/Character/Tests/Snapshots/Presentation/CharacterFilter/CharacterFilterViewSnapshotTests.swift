import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeCharacter

struct CharacterFilterViewSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Empty State

	@Test("Renders character filter with no filters selected")
	func emptyState() {
		// Given
		let viewModel = CharacterFilterViewModelStub()

		// When
		let view = NavigationStack {
			CharacterFilterView(viewModel: viewModel)
		}

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	// MARK: - Partially Filled

	@Test("Renders character filter with status selected")
	func statusSelected() {
		// Given
		let viewModel = CharacterFilterViewModelStub(
			status: .alive,
			hasActiveFilters: true
		)

		// When
		let view = NavigationStack {
			CharacterFilterView(viewModel: viewModel)
		}

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	@Test("Renders character filter with gender selected")
	func genderSelected() {
		// Given
		let viewModel = CharacterFilterViewModelStub(
			gender: .female,
			hasActiveFilters: true
		)

		// When
		let view = NavigationStack {
			CharacterFilterView(viewModel: viewModel)
		}

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	@Test("Renders character filter with text fields filled")
	func textFieldsFilled() {
		// Given
		let viewModel = CharacterFilterViewModelStub(
			species: "Human",
			type: "Parasite",
			hasActiveFilters: true
		)

		// When
		let view = NavigationStack {
			CharacterFilterView(viewModel: viewModel)
		}

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	// MARK: - Fully Filled

	@Test("Renders character filter with all filters selected")
	func allFiltersSelected() {
		// Given
		let viewModel = CharacterFilterViewModelStub(
			status: .dead,
			species: "Alien",
			type: "Robot",
			gender: .male,
			hasActiveFilters: true
		)

		// When
		let view = NavigationStack {
			CharacterFilterView(viewModel: viewModel)
		}

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}
}
