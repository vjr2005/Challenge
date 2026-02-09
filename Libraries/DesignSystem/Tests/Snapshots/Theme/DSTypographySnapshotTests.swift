import ChallengeSnapshotTestKit
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSTypographySnapshotTests {
	private let typography = DefaultTypography()
	private let palette = DefaultColorPalette()

	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Typography Gallery

	@Test("Renders gallery of all text styles with default colors")
	func typographyGallery() {
		let view = VStack(alignment: .leading, spacing: DefaultSpacing().md) {
			Text("Large Title")
				.font(typography.largeTitle)
				.foregroundStyle(palette.textPrimary)

			Text("Title")
				.font(typography.title)
				.foregroundStyle(palette.textPrimary)

			Text("Title 2")
				.font(typography.title2)
				.foregroundStyle(palette.textPrimary)

			Text("Title 3")
				.font(typography.title3)
				.foregroundStyle(palette.textPrimary)

			Text("Headline")
				.font(typography.headline)
				.foregroundStyle(palette.textPrimary)

			Text("Body")
				.font(typography.body)
				.foregroundStyle(palette.textPrimary)

			Text("Subheadline")
				.font(typography.subheadline)
				.foregroundStyle(palette.textSecondary)

			Text("Footnote")
				.font(typography.footnote)
				.foregroundStyle(palette.textSecondary)

			Text("Caption")
				.font(typography.caption)
				.foregroundStyle(palette.textSecondary)

			Text("Caption 2")
				.font(typography.caption2)
				.foregroundStyle(palette.textTertiary)
		}
		.padding()
		.frame(width: 320, alignment: .leading)
		.background(palette.backgroundPrimary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Typography with Labels

	@Test("Renders text styles with monospaced labels for reference")
	func typographyWithLabels() {
		let view = VStack(alignment: .leading, spacing: DefaultSpacing().lg) {
			typographyRow("largeTitle", font: typography.largeTitle, color: palette.textPrimary)
			typographyRow("title", font: typography.title, color: palette.textPrimary)
			typographyRow("title2", font: typography.title2, color: palette.textPrimary)
			typographyRow("title3", font: typography.title3, color: palette.textPrimary)
			typographyRow("headline", font: typography.headline, color: palette.textPrimary)
			typographyRow("body", font: typography.body, color: palette.textPrimary)
			typographyRow("subheadline", font: typography.subheadline, color: palette.textSecondary)
			typographyRow("footnote", font: typography.footnote, color: palette.textSecondary)
			typographyRow("caption", font: typography.caption, color: palette.textSecondary)
			typographyRow("caption2", font: typography.caption2, color: palette.textTertiary)
		}
		.padding()
		.frame(width: 360, alignment: .leading)
		.background(palette.backgroundPrimary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Design Variants

	@Test("Renders comparison of rounded, serif, and monospaced designs")
	func fontDesignComparison() {
		let view = VStack(alignment: .leading, spacing: DefaultSpacing().lg) {
			VStack(alignment: .leading, spacing: DefaultSpacing().xs) {
				Text("Rounded (titles, body)")
					.font(.system(.caption, design: .rounded, weight: .semibold))
					.foregroundStyle(palette.textSecondary)
				Text("The quick brown fox jumps")
					.font(typography.body)
					.foregroundStyle(palette.textPrimary)
			}

			VStack(alignment: .leading, spacing: DefaultSpacing().xs) {
				Text("Serif (subheadline)")
					.font(.system(.caption, design: .rounded, weight: .semibold))
					.foregroundStyle(palette.textSecondary)
				Text("The quick brown fox jumps")
					.font(typography.subheadline)
					.foregroundStyle(palette.textSecondary)
			}

			VStack(alignment: .leading, spacing: DefaultSpacing().xs) {
				Text("Monospaced (caption2)")
					.font(.system(.caption, design: .rounded, weight: .semibold))
					.foregroundStyle(palette.textSecondary)
				Text("The quick brown fox jumps")
					.font(typography.caption2)
					.foregroundStyle(palette.textTertiary)
			}
		}
		.padding()
		.frame(width: 320, alignment: .leading)
		.background(palette.backgroundPrimary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Hierarchy Example

	@Test("Renders typography hierarchy example with real content")
	func typographyHierarchy() {
		let view = VStack(alignment: .leading, spacing: DefaultSpacing().md) {
			Text("Page Title")
				.font(typography.largeTitle)
				.foregroundStyle(palette.textPrimary)

			Text("Section Header")
				.font(typography.title2)
				.foregroundStyle(palette.textPrimary)

			Text("This is the main body text that provides detailed information.")
				.font(typography.body)
				.foregroundStyle(palette.textPrimary)

			Text("Additional context in subheadline")
				.font(typography.subheadline)
				.foregroundStyle(palette.textSecondary)

			Text("Last updated: 2024-01-15")
				.font(typography.caption)
				.foregroundStyle(palette.textSecondary)
		}
		.padding()
		.frame(width: 320, alignment: .leading)
		.background(palette.backgroundPrimary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Helpers

	private func typographyRow(_ name: String, font: Font, color: Color) -> some View {
		HStack(alignment: .firstTextBaseline) {
			Text(name)
				.font(.system(.caption, design: .monospaced))
				.foregroundStyle(palette.textTertiary)
				.frame(width: 90, alignment: .leading)

			Text("Sample Text")
				.font(font)
				.foregroundStyle(color)

			Spacer()
		}
	}
}
