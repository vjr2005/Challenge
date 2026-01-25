import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite(.timeLimit(.minutes(1)))
struct DSErrorViewSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Title Only

	@Test
	func titleOnly() {
		let view = DSErrorView(title: "Something went wrong")
			.frame(width: 320, height: 300)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - With Message

	@Test
	func withMessage() {
		let view = DSErrorView(
			title: "Connection Error",
			message: "Please check your internet connection and try again."
		)
		.frame(width: 320, height: 300)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - With Retry Button

	@Test
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

	@Test
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
