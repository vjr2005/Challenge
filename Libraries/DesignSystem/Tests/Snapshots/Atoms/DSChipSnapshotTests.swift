import ChallengeSnapshotTestKit
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
		assertSnapshot(
			of: DSChip("Alive", isSelected: false) {}.padding(),
			as: .component(size: CGSize(width: 200, height: 60))
		)
	}

	// MARK: - Selected

	@Test("Renders selected chip with accent background")
	func selectedChip() {
		assertSnapshot(
			of: DSChip("Alive", isSelected: true) {}.padding(),
			as: .component(size: CGSize(width: 200, height: 60))
		)
	}

	// MARK: - Gallery

	@Test("Renders gallery of selected and unselected chips")
	func chipGallery() {
		let gallery = HStack(spacing: DefaultSpacing().sm) {
			DSChip("Alive", isSelected: true) {}
			DSChip("Dead", isSelected: false) {}
			DSChip("Unknown", isSelected: false) {}
		}

		assertSnapshot(
			of: gallery.padding(),
			as: .component(size: CGSize(width: 320, height: 60))
		)
	}
}
