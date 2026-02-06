import Foundation

@testable import ChallengeCharacter

/// ViewModel stub for AdvancedSearchView snapshot tests.
/// Maintains a fixed state without performing any operations.
@Observable
final class AdvancedSearchViewModelStub: AdvancedSearchViewModelContract {
	let localFilterState: CharacterFilterState
	var hasActiveFilters: Bool

	init(
		status: CharacterStatus? = nil,
		species: String? = nil,
		type: String? = nil,
		gender: CharacterGender? = nil,
		hasActiveFilters: Bool = false
	) {
		self.localFilterState = CharacterFilterState()
		self.hasActiveFilters = hasActiveFilters
		localFilterState.status = status
		localFilterState.species = species
		localFilterState.type = type
		localFilterState.gender = gender
	}

	func didAppear() {
		// No-op: state is fixed for snapshots
	}

	func didTapApply() {
		// No-op: navigation not tested in snapshots
	}

	func didTapReset() {
		// No-op: state is fixed for snapshots
	}

	func didTapClose() {
		// No-op: navigation not tested in snapshots
	}
}
