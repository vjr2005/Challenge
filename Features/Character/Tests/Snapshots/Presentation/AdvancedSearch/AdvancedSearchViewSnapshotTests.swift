import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeCharacter

struct AdvancedSearchViewSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Empty State

	@Test("Renders advanced search with no filters selected")
	func emptyState() {
		// Given
		let viewModel = AdvancedSearchViewModelStub()

		// When
		let view = NavigationStack {
			AdvancedSearchView(viewModel: viewModel)
		}

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	// MARK: - Partially Filled

	@Test("Renders advanced search with status selected")
	func statusSelected() {
		// Given
		let viewModel = AdvancedSearchViewModelStub(
			status: .alive,
			hasActiveFilters: true
		)

		// When
		let view = NavigationStack {
			AdvancedSearchView(viewModel: viewModel)
		}

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	@Test("Renders advanced search with gender selected")
	func genderSelected() {
		// Given
		let viewModel = AdvancedSearchViewModelStub(
			gender: .female,
			hasActiveFilters: true
		)

		// When
		let view = NavigationStack {
			AdvancedSearchView(viewModel: viewModel)
		}

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	@Test("Renders advanced search with text fields filled")
	func textFieldsFilled() {
		// Given
		let viewModel = AdvancedSearchViewModelStub(
			species: "Human",
			type: "Parasite",
			hasActiveFilters: true
		)

		// When
		let view = NavigationStack {
			AdvancedSearchView(viewModel: viewModel)
		}

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}

	// MARK: - Fully Filled

	@Test("Renders advanced search with all filters selected")
	func allFiltersSelected() {
		// Given
		let viewModel = AdvancedSearchViewModelStub(
			status: .dead,
			species: "Alien",
			type: "Robot",
			gender: .male,
			hasActiveFilters: true
		)

		// When
		let view = NavigationStack {
			AdvancedSearchView(viewModel: viewModel)
		}

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}
}
