import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct CornerRadiusTokenSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Corner Radius Gallery

	@Test("Renders gallery of all corner radius tokens")
	func cornerRadiusGallery() {
		let view = VStack(spacing: SpacingToken.lg) {
			cornerRadiusRow("zero", value: CornerRadiusToken.zero)
			cornerRadiusRow("xs", value: CornerRadiusToken.xs)
			cornerRadiusRow("sm", value: CornerRadiusToken.sm)
			cornerRadiusRow("md", value: CornerRadiusToken.md)
			cornerRadiusRow("lg", value: CornerRadiusToken.lg)
			cornerRadiusRow("xl", value: CornerRadiusToken.xl)
			cornerRadiusRow("full", value: CornerRadiusToken.full)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Corner Radius Comparison

	@Test("Renders visual comparison of small corner radius values")
	func cornerRadiusComparison() {
		let view = HStack(spacing: SpacingToken.md) {
			cornerBox("zero", radius: CornerRadiusToken.zero)
			cornerBox("xs", radius: CornerRadiusToken.xs)
			cornerBox("sm", radius: CornerRadiusToken.sm)
			cornerBox("md", radius: CornerRadiusToken.md)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders visual comparison of large corner radius values")
	func cornerRadiusLargeComparison() {
		let view = HStack(spacing: SpacingToken.md) {
			cornerBox("lg", radius: CornerRadiusToken.lg)
			cornerBox("xl", radius: CornerRadiusToken.xl)
			cornerBox("full", radius: CornerRadiusToken.full)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Button Context

	@Test("Renders corner radius tokens applied to button context")
	func cornerRadiusButtonContext() {
		let view = VStack(spacing: SpacingToken.md) {
			buttonExample("xs (4pt)", radius: CornerRadiusToken.xs)
			buttonExample("sm (8pt)", radius: CornerRadiusToken.sm)
			buttonExample("md (12pt)", radius: CornerRadiusToken.md)
			buttonExample("full", radius: CornerRadiusToken.full)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Card Context

	@Test("Renders corner radius tokens applied to card context")
	func cornerRadiusCardContext() {
		let view = VStack(spacing: SpacingToken.lg) {
			cardExample("sm (8pt)", radius: CornerRadiusToken.sm)
			cardExample("md (12pt)", radius: CornerRadiusToken.md)
			cardExample("lg (16pt)", radius: CornerRadiusToken.lg)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Helpers

	private func cornerRadiusRow(_ name: String, value: CGFloat) -> some View {
		HStack(spacing: SpacingToken.md) {
			Text(name)
				.font(.system(.footnote, design: .monospaced))
				.frame(width: 40, alignment: .leading)
				.foregroundStyle(ColorToken.textPrimary)

			RoundedRectangle(cornerRadius: value)
				.fill(ColorToken.accent)
				.frame(width: 60, height: 40)

			Text(value == 9999 ? "∞" : "\(Int(value))pt")
				.font(.system(.caption, design: .monospaced))
				.foregroundStyle(ColorToken.textSecondary)

			Spacer()
		}
	}

	private func cornerBox(_ name: String, radius: CGFloat) -> some View {
		VStack(spacing: SpacingToken.xs) {
			RoundedRectangle(cornerRadius: radius)
				.fill(ColorToken.accent)
				.frame(width: 50, height: 50)
			Text(name)
				.font(.system(.caption2, design: .monospaced))
				.foregroundStyle(ColorToken.textSecondary)
		}
	}

	private func buttonExample(_ label: String, radius: CGFloat) -> some View {
		HStack {
			Text(label)
				.font(.system(.caption, design: .monospaced))
				.foregroundStyle(ColorToken.textSecondary)
				.frame(width: 80, alignment: .leading)

			Text("Button")
				.font(.system(.body, design: .rounded, weight: .medium))
				.foregroundStyle(.white)
				.padding(.horizontal, SpacingToken.lg)
				.padding(.vertical, SpacingToken.sm)
				.background(ColorToken.accent)
				.clipShape(RoundedRectangle(cornerRadius: radius))

			Spacer()
		}
	}

	private func cardExample(_ label: String, radius: CGFloat) -> some View {
		VStack(alignment: .leading, spacing: SpacingToken.xs) {
			Text(label)
				.font(.system(.caption, design: .rounded, weight: .semibold))
				.foregroundStyle(ColorToken.textSecondary)

			RoundedRectangle(cornerRadius: radius)
				.fill(ColorToken.surfacePrimary)
				.frame(height: 60)
				.overlay(
					Text("Card Content")
						.font(.system(.body, design: .rounded))
						.foregroundStyle(ColorToken.textPrimary)
				)
		}
	}
}
