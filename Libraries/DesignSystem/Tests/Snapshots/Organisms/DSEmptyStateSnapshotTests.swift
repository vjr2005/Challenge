import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSEmptyStateSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Minimal

	@Test("Renders minimal empty state with icon and title only")
	func minimal() {
		let view = DSEmptyState(
			icon: "magnifyingglass",
			title: "No Results"
		)
		.frame(width: 320, height: 300)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - With Message

	@Test("Renders empty state with descriptive message")
	func withMessage() {
		let view = DSEmptyState(
			icon: "tray",
			title: "No Characters",
			message: "There are no characters to display at this time."
		)
		.frame(width: 320, height: 300)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - With Action Button

	@Test("Renders empty state with action button")
	func withActionButton() {
		let view = DSEmptyState(
			icon: "tray",
			title: "No Characters",
			message: "There are no characters to display at this time.",
			actionTitle: "Refresh"
		) {}
		.frame(width: 320, height: 350)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Different Icons

	@Test("Renders search empty state with search icon")
	func searchEmpty() {
		let view = DSEmptyState(
			icon: "magnifyingglass",
			title: "No Search Results",
			message: "Try adjusting your search terms.",
			actionTitle: "Clear Search"
		) {}
		.frame(width: 320, height: 350)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders favorites empty state with heart icon")
	func favoritesEmpty() {
		let view = DSEmptyState(
			icon: "heart",
			title: "No Favorites",
			message: "Characters you favorite will appear here."
		)
		.frame(width: 320, height: 300)

		assertSnapshot(of: view, as: .image)
	}
}
