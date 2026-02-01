import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSStatusIndicatorSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Individual Status

	@Test("Renders alive status indicator with success color")
	func aliveStatus() {
		let view = DSStatusIndicator(status: .alive)
			.padding()

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders dead status indicator with error color")
	func deadStatus() {
		let view = DSStatusIndicator(status: .dead)
			.padding()

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders unknown status indicator with warning color")
	func unknownStatus() {
		let view = DSStatusIndicator(status: .unknown)
			.padding()

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Different Sizes

	@Test("Renders status indicators at small size")
	func smallSize() {
		let view = HStack(spacing: SpacingToken.md) {
			DSStatusIndicator(status: .alive, size: 8)
			DSStatusIndicator(status: .dead, size: 8)
			DSStatusIndicator(status: .unknown, size: 8)
		}
		.padding()

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders status indicators at default size")
	func defaultSize() {
		let view = HStack(spacing: SpacingToken.md) {
			DSStatusIndicator(status: .alive)
			DSStatusIndicator(status: .dead)
			DSStatusIndicator(status: .unknown)
		}
		.padding()

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders status indicators at large size")
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

	@Test("Renders gallery of all status types and sizes")
	func allStatusGallery() {
		let view = HStack(spacing: SpacingToken.lg) {
			ForEach(DSStatus.allCases, id: \.self) { status in
				VStack(spacing: SpacingToken.sm) {
					DSStatusIndicator(status: status, size: 8)
					DSStatusIndicator(status: status)
					DSStatusIndicator(status: status, size: 16)
					Text(status.rawValue.capitalized)
						.font(TextStyle.caption.font)
						.foregroundStyle(ColorToken.textPrimary)
				}
			}
		}
		.padding()

		assertSnapshot(of: view, as: .image)
	}
}
