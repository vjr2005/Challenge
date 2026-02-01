import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSErrorViewSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Title Only

	@Test("Renders error view with title only")
	func titleOnly() {
		let view = DSErrorView(title: "Something went wrong")
			.frame(width: 320, height: 300)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - With Message

	@Test("Renders error view with descriptive message")
	func withMessage() {
		let view = DSErrorView(
			title: "Connection Error",
			message: "Please check your internet connection and try again."
		)
		.frame(width: 320, height: 300)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - With Retry Button

	@Test("Renders error view with retry button")
	func withRetryButton() {
		let view = DSErrorView(
			title: "Connection Error",
			message: "Please check your internet connection and try again.",
			retryTitle: "Retry"
		) {}
		.frame(width: 320, height: 350)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Full Configuration

	@Test("Renders error view with all elements configured")
	func fullConfiguration() {
		let view = DSErrorView(
			title: "Unable to Load",
			message: "There was a problem loading the content. Please try again later.",
			retryTitle: "Try Again"
		) {}
		.frame(width: 320, height: 350)

		assertSnapshot(of: view, as: .image)
	}
}
