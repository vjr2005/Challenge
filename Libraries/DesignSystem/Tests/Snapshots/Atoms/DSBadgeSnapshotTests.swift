import ChallengeSnapshotTestKit
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSBadgeSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	@Test("Renders content without badge when count is zero")
	func noBadge() {
		let view = DSBadge(count: 0) {
			Image(systemName: "line.3.horizontal.decrease.circle")
		}
		.padding()
		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders badge with single digit count")
	func singleDigit() {
		let view = DSBadge(count: 3) {
			Image(systemName: "line.3.horizontal.decrease.circle")
		}
		.padding()
		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders badge with double digit count expanding to pill shape")
	func doubleDigit() {
		let view = DSBadge(count: 12) {
			Image(systemName: "line.3.horizontal.decrease.circle")
		}
		.padding()
		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders gallery of badge states")
	func badgeGallery() {
		let view = HStack(spacing: DefaultSpacing().xl) {
			DSBadge(count: 0) {
				Image(systemName: "bell")
			}
			DSBadge(count: 1) {
				Image(systemName: "bell")
			}
			DSBadge(count: 9) {
				Image(systemName: "bell")
			}
			DSBadge(count: 42) {
				Image(systemName: "bell")
			}
		}
		.padding()
		assertSnapshot(of: view, as: .image)
	}
}
