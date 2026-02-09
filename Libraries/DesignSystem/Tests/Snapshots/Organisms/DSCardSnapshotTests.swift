import ChallengeSnapshotTestKit
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSCardSnapshotTests {
	private let shadow = DefaultShadow()

	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Basic Card

	@Test("Renders basic card with title and description")
	func basicCard() {
		let view = DSCard {
			VStack(alignment: .leading, spacing: DefaultSpacing().sm) {
				Text("Card Title")
					.font(DefaultTypography().headline)
					.foregroundStyle(DefaultColorPalette().textPrimary)
				Text("This is the card content with some description text.")
					.font(DefaultTypography().body)
					.foregroundStyle(DefaultColorPalette().textPrimary)
			}
		}
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Shadow Variants

	@Test("Renders card without shadow")
	func noShadow() {
		let view = DSCard(shadow: shadow.zero) {
			Text("No Shadow Card")
				.font(DefaultTypography().body)
				.foregroundStyle(DefaultColorPalette().textPrimary)
		}
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders card with small shadow elevation")
	func smallShadow() {
		let view = DSCard(shadow: shadow.small) {
			Text("Small Shadow Card")
				.font(DefaultTypography().body)
				.foregroundStyle(DefaultColorPalette().textPrimary)
		}
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders card with medium shadow elevation")
	func mediumShadow() {
		let view = DSCard(shadow: shadow.medium) {
			Text("Medium Shadow Card")
				.font(DefaultTypography().body)
				.foregroundStyle(DefaultColorPalette().textPrimary)
		}
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders card with large shadow elevation")
	func largeShadow() {
		let view = DSCard(shadow: shadow.large) {
			Text("Large Shadow Card")
				.font(DefaultTypography().body)
				.foregroundStyle(DefaultColorPalette().textPrimary)
		}
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Shadow Gallery

	@Test("Renders gallery of all card shadow variants")
	func shadowGallery() {
		let view = VStack(spacing: DefaultSpacing().lg) {
			DSCard(shadow: shadow.zero) {
				Text("Zero Shadow")
					.font(DefaultTypography().body)
					.foregroundStyle(DefaultColorPalette().textPrimary)
			}
			DSCard(shadow: shadow.small) {
				Text("Small Shadow")
					.font(DefaultTypography().body)
					.foregroundStyle(DefaultColorPalette().textPrimary)
			}
			DSCard(shadow: shadow.medium) {
				Text("Medium Shadow")
					.font(DefaultTypography().body)
					.foregroundStyle(DefaultColorPalette().textPrimary)
			}
			DSCard(shadow: shadow.large) {
				Text("Large Shadow")
					.font(DefaultTypography().body)
					.foregroundStyle(DefaultColorPalette().textPrimary)
			}
		}
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}
}
