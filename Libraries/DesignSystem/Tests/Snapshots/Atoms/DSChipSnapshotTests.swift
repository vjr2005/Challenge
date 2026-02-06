import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSChipSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Unselected

	@Test("Renders unselected chip with border")
	func unselectedChip() {
		let view = DSChip("Alive", isSelected: false) {}
			.padding()

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Selected

	@Test("Renders selected chip with accent background")
	func selectedChip() {
		let view = DSChip("Alive", isSelected: true) {}
			.padding()

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Gallery

	@Test("Renders gallery of selected and unselected chips")
	func chipGallery() {
		let view = HStack(spacing: DefaultSpacing().sm) {
			DSChip("Alive", isSelected: true) {}
			DSChip("Dead", isSelected: false) {}
			DSChip("Unknown", isSelected: false) {}
		}
		.padding()

		assertSnapshot(of: view, as: .image)
	}
}
