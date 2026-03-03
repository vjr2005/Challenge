import ChallengeSnapshotTestKit
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
			.dsCard(cornerRadius: DefaultCornerRadius().xl)
			.padding()
			.frame(width: 320)
			.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders dsCard extension with large shadow")
	func dsCardCustomShadow() {
		let view = Text("Large Shadow")
			.dsCard(shadow: DefaultShadow().large)
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
				cornerRadius: DefaultCornerRadius().md,
				shadow: DefaultShadow().medium
			)
			.padding()
			.frame(width: 320)
			.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders dsCard extension without shadow")
	func dsCardNoShadow() {
		let view = Text("No Shadow")
			.dsCard(shadow: DefaultShadow().zero)
			.padding()
			.frame(width: 320)
			.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders dsCard extension with complex nested content")
	func dsCardWithComplexContent() {
		let view = VStack(alignment: .leading, spacing: DefaultSpacing().sm) {
			Text("Card Title")
				.font(DefaultTypography().headline)
				.foregroundStyle(DefaultColorPalette().textPrimary)
			Text("This is a description inside the card.")
				.font(DefaultTypography().body)
				.foregroundStyle(DefaultColorPalette().textPrimary)
			DSButton("Action") {}
		}
		.dsCard()
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}
}
