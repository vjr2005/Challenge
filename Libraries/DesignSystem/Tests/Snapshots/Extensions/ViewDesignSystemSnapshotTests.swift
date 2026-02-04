import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct ViewDesignSystemSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - dsCard Extension

	@Test("Renders dsCard extension with default parameters")
	func dsCardDefault() {
		let view = Text("Card Content")
			.dsCard()
			.padding()
			.frame(width: 320)
			.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders dsCard extension with custom padding")
	func dsCardCustomPadding() {
		let view = Text("Custom Padding")
			.dsCard(padding: DefaultSpacing().xxl)
			.padding()
			.frame(width: 320)
			.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders dsCard extension with custom corner radius")
	func dsCardCustomCornerRadius() {
		let view = Text("Custom Corner Radius")
			.dsCard(cornerRadius: CornerRadiusToken.xl)
			.padding()
			.frame(width: 320)
			.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders dsCard extension with large shadow")
	func dsCardCustomShadow() {
		let view = Text("Large Shadow")
			.dsCard(shadowToken: .large)
			.padding()
			.frame(width: 320)
			.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders dsCard extension with all parameters customized")
	func dsCardFullCustomization() {
		let view = Text("Fully Customized")
			.dsCard(
				padding: DefaultSpacing().xl,
				cornerRadius: CornerRadiusToken.md,
				shadowToken: .medium
			)
			.padding()
			.frame(width: 320)
			.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders dsCard extension without shadow")
	func dsCardNoShadow() {
		let view = Text("No Shadow")
			.dsCard(shadowToken: .zero)
			.padding()
			.frame(width: 320)
			.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders dsCard extension with complex nested content")
	func dsCardWithComplexContent() {
		let view = VStack(alignment: .leading, spacing: DefaultSpacing().sm) {
			Text("Card Title")
				.font(DefaultTypography().font(for: .headline))
				.foregroundStyle(DefaultColorPalette().textPrimary)
			Text("This is a description inside the card.")
				.font(DefaultTypography().font(for: .body))
				.foregroundStyle(DefaultColorPalette().textPrimary)
			DSButton("Action") {}
		}
		.dsCard()
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - dsBackground Extension

	@Test("Renders dsBackground extension with default color")
	func dsBackgroundDefault() {
		let view = Text("Default Background")
			.padding()
			.dsBackground(DefaultColorPalette().backgroundPrimary)
			.frame(width: 320, height: 100)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders dsBackground extension with secondary color")
	func dsBackgroundSecondary() {
		let view = Text("Secondary Background")
			.padding()
			.dsBackground(DefaultColorPalette().backgroundSecondary)
			.frame(width: 320, height: 100)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders dsBackground extension with tertiary color")
	func dsBackgroundTertiary() {
		let view = Text("Tertiary Background")
			.padding()
			.dsBackground(DefaultColorPalette().backgroundTertiary)
			.frame(width: 320, height: 100)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders dsBackground extension with surface color")
	func dsBackgroundSurface() {
		let view = Text("Surface Background")
			.padding()
			.dsBackground(DefaultColorPalette().surfacePrimary)
			.frame(width: 320, height: 100)
			.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - dsCornerRadius Extension

	@Test("Renders dsCornerRadius extension with default value")
	func dsCornerRadiusDefault() {
		let view = Text("Default Corner Radius")
			.padding()
			.background(DefaultColorPalette().accent)
			.dsCornerRadius()
			.padding()
			.frame(width: 320)
			.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders dsCornerRadius extension with small value")
	func dsCornerRadiusSmall() {
		let view = Text("Small Corner Radius")
			.padding()
			.background(DefaultColorPalette().accent)
			.dsCornerRadius(CornerRadiusToken.sm)
			.padding()
			.frame(width: 320)
			.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders dsCornerRadius extension with large value")
	func dsCornerRadiusLarge() {
		let view = Text("Large Corner Radius")
			.padding()
			.background(DefaultColorPalette().accent)
			.dsCornerRadius(CornerRadiusToken.lg)
			.padding()
			.frame(width: 320)
			.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders dsCornerRadius extension with full circle value")
	func dsCornerRadiusFull() {
		let view = Text("Full")
			.padding()
			.background(DefaultColorPalette().accent)
			.dsCornerRadius(CornerRadiusToken.full)
			.padding()
			.frame(width: 320)
			.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Combined Extensions Gallery

	@Test("Renders gallery of all design system view extensions")
	func combinedExtensionsGallery() {
		let view = VStack(spacing: DefaultSpacing().lg) {
			Text("dsCard")
				.dsCard()

			Text("dsBackground")
				.padding()
				.dsBackground(DefaultColorPalette().surfacePrimary)
				.dsCornerRadius()

			Text("dsCornerRadius")
				.padding()
				.background(DefaultColorPalette().accent)
				.dsCornerRadius(CornerRadiusToken.lg)
		}
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}
}
