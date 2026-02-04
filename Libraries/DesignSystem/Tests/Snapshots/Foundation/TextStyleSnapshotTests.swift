import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct TextStyleSnapshotTests {
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
				.font(typography.font(for: .largeTitle))
				.foregroundStyle(typography.defaultColor(for: .largeTitle, in: palette))

			Text("Title")
				.font(typography.font(for: .title))
				.foregroundStyle(typography.defaultColor(for: .title, in: palette))

			Text("Title 2")
				.font(typography.font(for: .title2))
				.foregroundStyle(typography.defaultColor(for: .title2, in: palette))

			Text("Title 3")
				.font(typography.font(for: .title3))
				.foregroundStyle(typography.defaultColor(for: .title3, in: palette))

			Text("Headline")
				.font(typography.font(for: .headline))
				.foregroundStyle(typography.defaultColor(for: .headline, in: palette))

			Text("Body")
				.font(typography.font(for: .body))
				.foregroundStyle(typography.defaultColor(for: .body, in: palette))

			Text("Subheadline")
				.font(typography.font(for: .subheadline))
				.foregroundStyle(typography.defaultColor(for: .subheadline, in: palette))

			Text("Footnote")
				.font(typography.font(for: .footnote))
				.foregroundStyle(typography.defaultColor(for: .footnote, in: palette))

			Text("Caption")
				.font(typography.font(for: .caption))
				.foregroundStyle(typography.defaultColor(for: .caption, in: palette))

			Text("Caption 2")
				.font(typography.font(for: .caption2))
				.foregroundStyle(typography.defaultColor(for: .caption2, in: palette))
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
					.font(typography.font(for: .body))
					.foregroundStyle(palette.textPrimary)
			}

			VStack(alignment: .leading, spacing: DefaultSpacing().xs) {
				Text("Serif (subheadline)")
					.font(.system(.caption, design: .rounded, weight: .semibold))
					.foregroundStyle(palette.textSecondary)
				Text("The quick brown fox jumps")
					.font(typography.font(for: .subheadline))
					.foregroundStyle(palette.textSecondary)
			}

			VStack(alignment: .leading, spacing: DefaultSpacing().xs) {
				Text("Monospaced (caption2)")
					.font(.system(.caption, design: .rounded, weight: .semibold))
					.foregroundStyle(palette.textSecondary)
				Text("The quick brown fox jumps")
					.font(typography.font(for: .caption2))
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
				.font(typography.font(for: .largeTitle))
				.foregroundStyle(typography.defaultColor(for: .largeTitle, in: palette))

			Text("Section Header")
				.font(typography.font(for: .title2))
				.foregroundStyle(typography.defaultColor(for: .title2, in: palette))

			Text("This is the main body text that provides detailed information.")
				.font(typography.font(for: .body))
				.foregroundStyle(typography.defaultColor(for: .body, in: palette))

			Text("Additional context in subheadline")
				.font(typography.font(for: .subheadline))
				.foregroundStyle(typography.defaultColor(for: .subheadline, in: palette))

			Text("Last updated: 2024-01-15")
				.font(typography.font(for: .caption))
				.foregroundStyle(typography.defaultColor(for: .caption, in: palette))
		}
		.padding()
		.frame(width: 320, alignment: .leading)
		.background(palette.backgroundPrimary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Helpers

	private func typographyRow(_ name: String, style: TextStyle) -> some View {
		HStack(alignment: .firstTextBaseline) {
			Text(name)
				.font(.system(.caption, design: .monospaced))
				.foregroundStyle(palette.textTertiary)
				.frame(width: 90, alignment: .leading)

			Text("Sample Text")
				.font(typography.font(for: style))
				.foregroundStyle(typography.defaultColor(for: style, in: palette))

			Spacer()
		}
	}
}
