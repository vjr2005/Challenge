import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct SpacingTokenSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Spacing Gallery

	@Test("Renders gallery of all spacing tokens with values")
	func spacingGallery() {
		let view = VStack(alignment: .leading, spacing: SpacingToken.md) {
			spacingRow("xxs", value: SpacingToken.xxs)
			spacingRow("xs", value: SpacingToken.xs)
			spacingRow("sm", value: SpacingToken.sm)
			spacingRow("md", value: SpacingToken.md)
			spacingRow("lg", value: SpacingToken.lg)
			spacingRow("xl", value: SpacingToken.xl)
			spacingRow("xxl", value: SpacingToken.xxl)
			spacingRow("xxxl", value: SpacingToken.xxxl)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Spacing Comparison

	@Test("Renders visual comparison of spacing token heights")
	func spacingComparison() {
		let view = HStack(alignment: .bottom, spacing: SpacingToken.md) {
			spacingBar("xxs", value: SpacingToken.xxs)
			spacingBar("xs", value: SpacingToken.xs)
			spacingBar("sm", value: SpacingToken.sm)
			spacingBar("md", value: SpacingToken.md)
			spacingBar("lg", value: SpacingToken.lg)
			spacingBar("xl", value: SpacingToken.xl)
			spacingBar("xxl", value: SpacingToken.xxl)
			spacingBar("xxxl", value: SpacingToken.xxxl)
		}
		.padding()
		.frame(width: 320, height: 180)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Spacing In Context

	@Test("Renders spacing tokens applied to real UI context")
	func spacingInContext() {
		let view = VStack(spacing: SpacingToken.lg) {
			contextExample("xxs (2pt)", spacing: SpacingToken.xxs)
			contextExample("sm (8pt)", spacing: SpacingToken.sm)
			contextExample("md (12pt)", spacing: SpacingToken.md)
			contextExample("lg (16pt)", spacing: SpacingToken.lg)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Helpers

	private func spacingRow(_ name: String, value: CGFloat) -> some View {
		HStack(spacing: SpacingToken.md) {
			Text(name)
				.font(.system(.footnote, design: .monospaced))
				.frame(width: 40, alignment: .leading)
				.foregroundStyle(ColorToken.textPrimary)

			Rectangle()
				.fill(ColorToken.accent)
				.frame(width: value, height: 20)

			Text("\(Int(value))pt")
				.font(.system(.caption, design: .monospaced))
				.foregroundStyle(ColorToken.textSecondary)

			Spacer()
		}
	}

	private func spacingBar(_ name: String, value: CGFloat) -> some View {
		VStack(spacing: SpacingToken.xs) {
			Rectangle()
				.fill(ColorToken.accent)
				.frame(width: 24, height: value * 3)
			Text(name)
				.font(.system(.caption2, design: .monospaced))
				.foregroundStyle(ColorToken.textSecondary)
		}
	}

	private func contextExample(_ label: String, spacing: CGFloat) -> some View {
		VStack(alignment: .leading, spacing: SpacingToken.xs) {
			Text(label)
				.font(.system(.caption, design: .rounded, weight: .semibold))
				.foregroundStyle(ColorToken.textSecondary)

			HStack(spacing: spacing) {
				ForEach(0..<4, id: \.self) { _ in
					RoundedRectangle(cornerRadius: CornerRadiusToken.xs)
						.fill(ColorToken.accent)
						.frame(width: 40, height: 30)
				}
			}
		}
	}
}
