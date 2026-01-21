import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSCardSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Basic Card

	@Test
	func basicCard() {
		let view = DSCard {
			VStack(alignment: .leading, spacing: SpacingToken.sm) {
				DSText("Card Title", style: .headline)
				DSText("This is the card content with some description text.", style: .body)
			}
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Shadow Variants

	@Test
	func noShadow() {
		let view = DSCard(shadow: .zero) {
			DSText("No Shadow Card", style: .body)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func smallShadow() {
		let view = DSCard(shadow: .small) {
			DSText("Small Shadow Card", style: .body)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func mediumShadow() {
		let view = DSCard(shadow: .medium) {
			DSText("Medium Shadow Card", style: .body)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func largeShadow() {
		let view = DSCard(shadow: .large) {
			DSText("Large Shadow Card", style: .body)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Shadow Gallery

	@Test
	func shadowGallery() {
		let view = VStack(spacing: SpacingToken.lg) {
			DSCard(shadow: .zero) {
				DSText("Zero Shadow", style: .body)
			}
			DSCard(shadow: .small) {
				DSText("Small Shadow", style: .body)
			}
			DSCard(shadow: .medium) {
				DSText("Medium Shadow", style: .body)
			}
			DSCard(shadow: .large) {
				DSText("Large Shadow", style: .body)
			}
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}
}
