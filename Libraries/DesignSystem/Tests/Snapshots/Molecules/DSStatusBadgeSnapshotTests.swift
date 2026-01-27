import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite(.timeLimit(.minutes(1)))
struct DSStatusBadgeSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Individual Status

	@Test
	func aliveBadge() {
		let view = DSStatusBadge(status: .alive)
			.padding()

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func deadBadge() {
		let view = DSStatusBadge(status: .dead)
			.padding()

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func unknownBadge() {
		let view = DSStatusBadge(status: .unknown)
			.padding()

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Variants

	@Test
	func customLabel() {
		let view = DSStatusBadge(status: .alive, label: "Active")
			.padding()

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func withoutIndicator() {
		let view = DSStatusBadge(status: .alive, showIndicator: false)
			.padding()

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - All Status Gallery

	@Test
	func allStatusGallery() {
		let view = VStack(spacing: SpacingToken.md) {
			DSStatusBadge(status: .alive)
			DSStatusBadge(status: .dead)
			DSStatusBadge(status: .unknown)
			DSStatusBadge(status: .alive, label: "Active")
			DSStatusBadge(status: .alive, showIndicator: false)
		}
		.padding()

		assertSnapshot(of: view, as: .image)
	}
}
