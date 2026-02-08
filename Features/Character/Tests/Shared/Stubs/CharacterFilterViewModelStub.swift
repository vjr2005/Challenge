import Foundation

@testable import ChallengeCharacter

/// ViewModel stub for CharacterFilterView snapshot tests.
/// Maintains a fixed state without performing any operations.
@Observable
final class CharacterFilterViewModelStub: CharacterFilterViewModelContract {
	var filter: CharacterFilter
	var hasActiveFilters: Bool

	init(
		status: CharacterStatus? = nil,
		species: String? = nil,
		type: String? = nil,
		gender: CharacterGender? = nil,
		hasActiveFilters: Bool = false
	) {
		self.filter = CharacterFilter(
			status: status,
			species: species,
			type: type,
			gender: gender
		)
		self.hasActiveFilters = hasActiveFilters
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
