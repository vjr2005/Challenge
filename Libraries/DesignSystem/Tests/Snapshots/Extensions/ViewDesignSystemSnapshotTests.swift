import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite(.timeLimit(.minutes(1)))
struct ViewDesignSystemSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - dsCard Extension

	@Test
	func dsCardDefault() {
		let view = Text("Card Content")
			.dsCard()
			.padding()
			.frame(width: 320)
			.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func dsCardCustomPadding() {
		let view = Text("Custom Padding")
			.dsCard(padding: SpacingToken.xxl)
			.padding()
			.frame(width: 320)
			.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func dsCardCustomCornerRadius() {
		let view = Text("Custom Corner Radius")
			.dsCard(cornerRadius: CornerRadiusToken.xl)
			.padding()
			.frame(width: 320)
			.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func dsCardCustomShadow() {
		let view = Text("Large Shadow")
			.dsCard(shadowToken: .large)
			.padding()
			.frame(width: 320)
			.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func dsCardFullCustomization() {
		let view = Text("Fully Customized")
			.dsCard(
				padding: SpacingToken.xl,
				cornerRadius: CornerRadiusToken.md,
				shadowToken: .medium
			)
			.padding()
			.frame(width: 320)
			.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func dsCardNoShadow() {
		let view = Text("No Shadow")
			.dsCard(shadowToken: .zero)
			.padding()
			.frame(width: 320)
			.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func dsCardWithComplexContent() {
		let view = VStack(alignment: .leading, spacing: SpacingToken.sm) {
			DSText("Card Title", style: .headline)
			DSText("This is a description inside the card.", style: .body)
			DSButton("Action") {}
		}
		.dsCard()
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - dsBackground Extension

	@Test
	func dsBackgroundDefault() {
		let view = Text("Default Background")
			.padding()
			.dsBackground()
			.frame(width: 320, height: 100)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func dsBackgroundSecondary() {
		let view = Text("Secondary Background")
			.padding()
			.dsBackground(ColorToken.backgroundSecondary)
			.frame(width: 320, height: 100)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func dsBackgroundTertiary() {
		let view = Text("Tertiary Background")
			.padding()
			.dsBackground(ColorToken.backgroundTertiary)
			.frame(width: 320, height: 100)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func dsBackgroundSurface() {
		let view = Text("Surface Background")
			.padding()
			.dsBackground(ColorToken.surfacePrimary)
			.frame(width: 320, height: 100)
			.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - dsCornerRadius Extension

	@Test
	func dsCornerRadiusDefault() {
		let view = Text("Default Corner Radius")
			.padding()
			.background(ColorToken.accent)
			.dsCornerRadius()
			.padding()
			.frame(width: 320)
			.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func dsCornerRadiusSmall() {
		let view = Text("Small Corner Radius")
			.padding()
			.background(ColorToken.accent)
			.dsCornerRadius(CornerRadiusToken.sm)
			.padding()
			.frame(width: 320)
			.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func dsCornerRadiusLarge() {
		let view = Text("Large Corner Radius")
			.padding()
			.background(ColorToken.accent)
			.dsCornerRadius(CornerRadiusToken.lg)
			.padding()
			.frame(width: 320)
			.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func dsCornerRadiusFull() {
		let view = Text("Full")
			.padding()
			.background(ColorToken.accent)
			.dsCornerRadius(CornerRadiusToken.full)
			.padding()
			.frame(width: 320)
			.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Combined Extensions Gallery

	@Test
	func combinedExtensionsGallery() {
		let view = VStack(spacing: SpacingToken.lg) {
			Text("dsCard")
				.dsCard()

			Text("dsBackground")
				.padding()
				.dsBackground(ColorToken.surfacePrimary)
				.dsCornerRadius()

			Text("dsCornerRadius")
				.padding()
				.background(ColorToken.accent)
				.dsCornerRadius(CornerRadiusToken.lg)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}
}
