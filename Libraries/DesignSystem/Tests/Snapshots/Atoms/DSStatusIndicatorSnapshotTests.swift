import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite(.timeLimit(.minutes(1)))
struct DSStatusIndicatorSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Individual Status

	@Test
	func aliveStatus() {
		let view = DSStatusIndicator(status: .alive)
			.padding()

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func deadStatus() {
		let view = DSStatusIndicator(status: .dead)
			.padding()

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func unknownStatus() {
		let view = DSStatusIndicator(status: .unknown)
			.padding()

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Different Sizes

	@Test
	func smallSize() {
		let view = HStack(spacing: SpacingToken.md) {
			DSStatusIndicator(status: .alive, size: 8)
			DSStatusIndicator(status: .dead, size: 8)
			DSStatusIndicator(status: .unknown, size: 8)
		}
		.padding()

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func defaultSize() {
		let view = HStack(spacing: SpacingToken.md) {
			DSStatusIndicator(status: .alive)
			DSStatusIndicator(status: .dead)
			DSStatusIndicator(status: .unknown)
		}
		.padding()

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func largeSize() {
		let view = HStack(spacing: SpacingToken.md) {
			DSStatusIndicator(status: .alive, size: 16)
			DSStatusIndicator(status: .dead, size: 16)
			DSStatusIndicator(status: .unknown, size: 16)
		}
		.padding()

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - All Status Gallery

	@Test
	func allStatusGallery() {
		let view = HStack(spacing: SpacingToken.lg) {
			ForEach(DSStatus.allCases, id: \.self) { status in
				VStack(spacing: SpacingToken.sm) {
					DSStatusIndicator(status: status, size: 8)
					DSStatusIndicator(status: status)
					DSStatusIndicator(status: status, size: 16)
					DSText(status.rawValue.capitalized, style: .caption)
				}
			}
		}
		.padding()

		assertSnapshot(of: view, as: .image)
	}
}
