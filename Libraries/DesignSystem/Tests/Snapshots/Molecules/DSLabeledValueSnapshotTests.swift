import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite(.timeLimit(.minutes(1)))
struct DSLabeledValueSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Vertical Orientation

	@Test
	func verticalOrientation() {
		let view = DSLabeledValue(label: "Species", value: "Human")
			.padding()

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func verticalOrientationGallery() {
		let view = VStack(alignment: .leading, spacing: SpacingToken.lg) {
			DSLabeledValue(label: "Species", value: "Human")
			DSLabeledValue(label: "Gender", value: "Male")
			DSLabeledValue(label: "Origin", value: "Earth (C-137)")
		}
		.padding()

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Horizontal Orientation

	@Test
	func horizontalOrientation() {
		let view = DSLabeledValue(label: "Species", value: "Human", orientation: .horizontal)
			.padding()
			.frame(width: 300)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func horizontalOrientationGallery() {
		let view = VStack(spacing: SpacingToken.md) {
			DSLabeledValue(label: "Species", value: "Human", orientation: .horizontal)
			DSLabeledValue(label: "Gender", value: "Male", orientation: .horizontal)
			DSLabeledValue(label: "Origin", value: "Earth (C-137)", orientation: .horizontal)
		}
		.padding()
		.frame(width: 300)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Custom Styles

	@Test
	func customTextStyles() {
		let view = VStack(alignment: .leading, spacing: SpacingToken.lg) {
			DSLabeledValue(
				label: "Title",
				value: "Large Value",
				labelStyle: .footnote,
				valueStyle: .title3
			)
			DSLabeledValue(
				label: "Subtitle",
				value: "Headline Value",
				labelStyle: .caption2,
				valueStyle: .headline
			)
		}
		.padding()

		assertSnapshot(of: view, as: .image)
	}
}
