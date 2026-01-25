import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite(.timeLimit(.minutes(1)))
struct TextStyleSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Typography Gallery

	@Test
	func typographyGallery() {
		let view = VStack(alignment: .leading, spacing: SpacingToken.md) {
			Text("Large Title")
				.font(TextStyle.largeTitle.font)
				.foregroundStyle(TextStyle.largeTitle.defaultColor)

			Text("Title")
				.font(TextStyle.title.font)
				.foregroundStyle(TextStyle.title.defaultColor)

			Text("Title 2")
				.font(TextStyle.title2.font)
				.foregroundStyle(TextStyle.title2.defaultColor)

			Text("Title 3")
				.font(TextStyle.title3.font)
				.foregroundStyle(TextStyle.title3.defaultColor)

			Text("Headline")
				.font(TextStyle.headline.font)
				.foregroundStyle(TextStyle.headline.defaultColor)

			Text("Body")
				.font(TextStyle.body.font)
				.foregroundStyle(TextStyle.body.defaultColor)

			Text("Subheadline")
				.font(TextStyle.subheadline.font)
				.foregroundStyle(TextStyle.subheadline.defaultColor)

			Text("Footnote")
				.font(TextStyle.footnote.font)
				.foregroundStyle(TextStyle.footnote.defaultColor)

			Text("Caption")
				.font(TextStyle.caption.font)
				.foregroundStyle(TextStyle.caption.defaultColor)

			Text("Caption 2")
				.font(TextStyle.caption2.font)
				.foregroundStyle(TextStyle.caption2.defaultColor)
		}
		.padding()
		.frame(width: 320, alignment: .leading)
		.background(ColorToken.backgroundPrimary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Typography with Labels

	@Test
	func typographyWithLabels() {
		let view = VStack(alignment: .leading, spacing: SpacingToken.lg) {
			typographyRow("largeTitle", style: .largeTitle)
			typographyRow("title", style: .title)
			typographyRow("title2", style: .title2)
			typographyRow("title3", style: .title3)
			typographyRow("headline", style: .headline)
			typographyRow("body", style: .body)
			typographyRow("subheadline", style: .subheadline)
			typographyRow("footnote", style: .footnote)
			typographyRow("caption", style: .caption)
			typographyRow("caption2", style: .caption2)
		}
		.padding()
		.frame(width: 360, alignment: .leading)
		.background(ColorToken.backgroundPrimary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Design Variants

	@Test
	func fontDesignComparison() {
		let view = VStack(alignment: .leading, spacing: SpacingToken.lg) {
			VStack(alignment: .leading, spacing: SpacingToken.xs) {
				Text("Rounded (titles, body)")
					.font(.system(.caption, design: .rounded, weight: .semibold))
					.foregroundStyle(ColorToken.textSecondary)
				Text("The quick brown fox jumps")
					.font(TextStyle.body.font)
					.foregroundStyle(ColorToken.textPrimary)
			}

			VStack(alignment: .leading, spacing: SpacingToken.xs) {
				Text("Serif (subheadline)")
					.font(.system(.caption, design: .rounded, weight: .semibold))
					.foregroundStyle(ColorToken.textSecondary)
				Text("The quick brown fox jumps")
					.font(TextStyle.subheadline.font)
					.foregroundStyle(ColorToken.textSecondary)
			}

			VStack(alignment: .leading, spacing: SpacingToken.xs) {
				Text("Monospaced (caption2)")
					.font(.system(.caption, design: .rounded, weight: .semibold))
					.foregroundStyle(ColorToken.textSecondary)
				Text("The quick brown fox jumps")
					.font(TextStyle.caption2.font)
					.foregroundStyle(ColorToken.textTertiary)
			}
		}
		.padding()
		.frame(width: 320, alignment: .leading)
		.background(ColorToken.backgroundPrimary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Hierarchy Example

	@Test
	func typographyHierarchy() {
		let view = VStack(alignment: .leading, spacing: SpacingToken.md) {
			Text("Page Title")
				.font(TextStyle.largeTitle.font)
				.foregroundStyle(TextStyle.largeTitle.defaultColor)

			Text("Section Header")
				.font(TextStyle.title2.font)
				.foregroundStyle(TextStyle.title2.defaultColor)

			Text("This is the main body text that provides detailed information.")
				.font(TextStyle.body.font)
				.foregroundStyle(TextStyle.body.defaultColor)

			Text("Additional context in subheadline")
				.font(TextStyle.subheadline.font)
				.foregroundStyle(TextStyle.subheadline.defaultColor)

			Text("Last updated: 2024-01-15")
				.font(TextStyle.caption.font)
				.foregroundStyle(TextStyle.caption.defaultColor)
		}
		.padding()
		.frame(width: 320, alignment: .leading)
		.background(ColorToken.backgroundPrimary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Helpers

	private func typographyRow(_ name: String, style: TextStyle) -> some View {
		HStack(alignment: .firstTextBaseline) {
			Text(name)
				.font(.system(.caption, design: .monospaced))
				.foregroundStyle(ColorToken.textTertiary)
				.frame(width: 90, alignment: .leading)

			Text("Sample Text")
				.font(style.font)
				.foregroundStyle(style.defaultColor)

			Spacer()
		}
	}
}
