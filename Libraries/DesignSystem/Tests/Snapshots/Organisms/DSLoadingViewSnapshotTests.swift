import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSLoadingViewSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Without Message

	@Test("Renders loading view without message")
	func withoutMessage() {
		let view = DSLoadingView(accessibilityIdentifier: "screen.loading")
			.frame(width: 320, height: 200)
			.dsTheme(.default)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - With Message

	@Test("Renders loading view with custom message")
	func withMessage() {
		let view = DSLoadingView(
			message: "Loading characters...",
			accessibilityIdentifier: "screen.loading"
		)
		.frame(width: 320, height: 200)

		assertSnapshot(of: view, as: .image)
	}
}
