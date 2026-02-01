import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSCardSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Basic Card

	@Test("Renders basic card with title and description")
	func basicCard() {
		let view = DSCard {
			VStack(alignment: .leading, spacing: SpacingToken.sm) {
				Text("Card Title")
					.font(TextStyle.headline.font)
					.foregroundStyle(ColorToken.textPrimary)
				Text("This is the card content with some description text.")
					.font(TextStyle.body.font)
					.foregroundStyle(ColorToken.textPrimary)
			}
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Shadow Variants

	@Test("Renders card without shadow")
	func noShadow() {
		let view = DSCard(shadow: .zero) {
			Text("No Shadow Card")
				.font(TextStyle.body.font)
				.foregroundStyle(ColorToken.textPrimary)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders card with small shadow elevation")
	func smallShadow() {
		let view = DSCard(shadow: .small) {
			Text("Small Shadow Card")
				.font(TextStyle.body.font)
				.foregroundStyle(ColorToken.textPrimary)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders card with medium shadow elevation")
	func mediumShadow() {
		let view = DSCard(shadow: .medium) {
			Text("Medium Shadow Card")
				.font(TextStyle.body.font)
				.foregroundStyle(ColorToken.textPrimary)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders card with large shadow elevation")
	func largeShadow() {
		let view = DSCard(shadow: .large) {
			Text("Large Shadow Card")
				.font(TextStyle.body.font)
				.foregroundStyle(ColorToken.textPrimary)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Shadow Gallery

	@Test("Renders gallery of all card shadow variants")
	func shadowGallery() {
		let view = VStack(spacing: SpacingToken.lg) {
			DSCard(shadow: .zero) {
				Text("Zero Shadow")
					.font(TextStyle.body.font)
					.foregroundStyle(ColorToken.textPrimary)
			}
			DSCard(shadow: .small) {
				Text("Small Shadow")
					.font(TextStyle.body.font)
					.foregroundStyle(ColorToken.textPrimary)
			}
			DSCard(shadow: .medium) {
				Text("Medium Shadow")
					.font(TextStyle.body.font)
					.foregroundStyle(ColorToken.textPrimary)
			}
			DSCard(shadow: .large) {
				Text("Large Shadow")
					.font(TextStyle.body.font)
					.foregroundStyle(ColorToken.textPrimary)
			}
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}
}
