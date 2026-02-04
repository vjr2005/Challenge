import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DefaultSpacingSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Spacing Gallery

	@Test("Renders gallery of all spacing tokens with values")
	func spacingGallery() {
		let view = VStack(alignment: .leading, spacing: DefaultSpacing().md) {
			spacingRow("xxs", value: DefaultSpacing().xxs)
			spacingRow("xs", value: DefaultSpacing().xs)
			spacingRow("sm", value: DefaultSpacing().sm)
			spacingRow("md", value: DefaultSpacing().md)
			spacingRow("lg", value: DefaultSpacing().lg)
			spacingRow("xl", value: DefaultSpacing().xl)
			spacingRow("xxl", value: DefaultSpacing().xxl)
			spacingRow("xxxl", value: DefaultSpacing().xxxl)
		}
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Spacing Comparison

	@Test("Renders visual comparison of spacing token heights")
	func spacingComparison() {
		let view = HStack(alignment: .bottom, spacing: DefaultSpacing().md) {
			spacingBar("xxs", value: DefaultSpacing().xxs)
			spacingBar("xs", value: DefaultSpacing().xs)
			spacingBar("sm", value: DefaultSpacing().sm)
			spacingBar("md", value: DefaultSpacing().md)
			spacingBar("lg", value: DefaultSpacing().lg)
			spacingBar("xl", value: DefaultSpacing().xl)
			spacingBar("xxl", value: DefaultSpacing().xxl)
			spacingBar("xxxl", value: DefaultSpacing().xxxl)
		}
		.padding()
		.frame(width: 320, height: 180)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Spacing In Context

	@Test("Renders spacing tokens applied to real UI context")
	func spacingInContext() {
		let view = VStack(spacing: DefaultSpacing().lg) {
			contextExample("xxs (2pt)", spacing: DefaultSpacing().xxs)
			contextExample("sm (8pt)", spacing: DefaultSpacing().sm)
			contextExample("md (12pt)", spacing: DefaultSpacing().md)
			contextExample("lg (16pt)", spacing: DefaultSpacing().lg)
		}
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Helpers

	private func spacingRow(_ name: String, value: CGFloat) -> some View {
		HStack(spacing: DefaultSpacing().md) {
			Text(name)
				.font(.system(.footnote, design: .monospaced))
				.frame(width: 40, alignment: .leading)
				.foregroundStyle(DefaultColorPalette().textPrimary)

			Rectangle()
				.fill(DefaultColorPalette().accent)
				.frame(width: value, height: 20)

			Text("\(Int(value))pt")
				.font(.system(.caption, design: .monospaced))
				.foregroundStyle(DefaultColorPalette().textSecondary)

			Spacer()
		}
	}

	private func spacingBar(_ name: String, value: CGFloat) -> some View {
		VStack(spacing: DefaultSpacing().xs) {
			Rectangle()
				.fill(DefaultColorPalette().accent)
				.frame(width: 24, height: value * 3)
			Text(name)
				.font(.system(.caption2, design: .monospaced))
				.foregroundStyle(DefaultColorPalette().textSecondary)
		}
	}

	private func contextExample(_ label: String, spacing: CGFloat) -> some View {
		VStack(alignment: .leading, spacing: DefaultSpacing().xs) {
			Text(label)
				.font(.system(.caption, design: .rounded, weight: .semibold))
				.foregroundStyle(DefaultColorPalette().textSecondary)

			HStack(spacing: spacing) {
				ForEach(0..<4, id: \.self) { _ in
					RoundedRectangle(cornerRadius: DefaultCornerRadius().xs)
						.fill(DefaultColorPalette().accent)
						.frame(width: 40, height: 30)
				}
			}
		}
	}
}
