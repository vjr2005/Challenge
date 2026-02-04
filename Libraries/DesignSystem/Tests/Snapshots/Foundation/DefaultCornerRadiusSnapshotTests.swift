import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DefaultCornerRadiusSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Corner Radius Gallery

	@Test("Renders gallery of all corner radius tokens")
	func cornerRadiusGallery() {
		let view = VStack(spacing: DefaultSpacing().lg) {
			cornerRadiusRow("zero", value: DefaultCornerRadius().zero)
			cornerRadiusRow("xs", value: DefaultCornerRadius().xs)
			cornerRadiusRow("sm", value: DefaultCornerRadius().sm)
			cornerRadiusRow("md", value: DefaultCornerRadius().md)
			cornerRadiusRow("lg", value: DefaultCornerRadius().lg)
			cornerRadiusRow("xl", value: DefaultCornerRadius().xl)
			cornerRadiusRow("full", value: DefaultCornerRadius().full)
		}
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Corner Radius Comparison

	@Test("Renders visual comparison of small corner radius values")
	func cornerRadiusComparison() {
		let view = HStack(spacing: DefaultSpacing().md) {
			cornerBox("zero", radius: DefaultCornerRadius().zero)
			cornerBox("xs", radius: DefaultCornerRadius().xs)
			cornerBox("sm", radius: DefaultCornerRadius().sm)
			cornerBox("md", radius: DefaultCornerRadius().md)
		}
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders visual comparison of large corner radius values")
	func cornerRadiusLargeComparison() {
		let view = HStack(spacing: DefaultSpacing().md) {
			cornerBox("lg", radius: DefaultCornerRadius().lg)
			cornerBox("xl", radius: DefaultCornerRadius().xl)
			cornerBox("full", radius: DefaultCornerRadius().full)
		}
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Button Context

	@Test("Renders corner radius tokens applied to button context")
	func cornerRadiusButtonContext() {
		let view = VStack(spacing: DefaultSpacing().md) {
			buttonExample("xs (4pt)", radius: DefaultCornerRadius().xs)
			buttonExample("sm (8pt)", radius: DefaultCornerRadius().sm)
			buttonExample("md (12pt)", radius: DefaultCornerRadius().md)
			buttonExample("full", radius: DefaultCornerRadius().full)
		}
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Card Context

	@Test("Renders corner radius tokens applied to card context")
	func cornerRadiusCardContext() {
		let view = VStack(spacing: DefaultSpacing().lg) {
			cardExample("sm (8pt)", radius: DefaultCornerRadius().sm)
			cardExample("md (12pt)", radius: DefaultCornerRadius().md)
			cardExample("lg (16pt)", radius: DefaultCornerRadius().lg)
		}
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Helpers

	private func cornerRadiusRow(_ name: String, value: CGFloat) -> some View {
		HStack(spacing: DefaultSpacing().md) {
			Text(name)
				.font(.system(.footnote, design: .monospaced))
				.frame(width: 40, alignment: .leading)
				.foregroundStyle(DefaultColorPalette().textPrimary)

			RoundedRectangle(cornerRadius: value)
				.fill(DefaultColorPalette().accent)
				.frame(width: 60, height: 40)

			Text(value == 9999 ? "∞" : "\(Int(value))pt")
				.font(.system(.caption, design: .monospaced))
				.foregroundStyle(DefaultColorPalette().textSecondary)

			Spacer()
		}
	}

	private func cornerBox(_ name: String, radius: CGFloat) -> some View {
		VStack(spacing: DefaultSpacing().xs) {
			RoundedRectangle(cornerRadius: radius)
				.fill(DefaultColorPalette().accent)
				.frame(width: 50, height: 50)
			Text(name)
				.font(.system(.caption2, design: .monospaced))
				.foregroundStyle(DefaultColorPalette().textSecondary)
		}
	}

	private func buttonExample(_ label: String, radius: CGFloat) -> some View {
		HStack {
			Text(label)
				.font(.system(.caption, design: .monospaced))
				.foregroundStyle(DefaultColorPalette().textSecondary)
				.frame(width: 80, alignment: .leading)

			Text("Button")
				.font(.system(.body, design: .rounded, weight: .medium))
				.foregroundStyle(.white)
				.padding(.horizontal, DefaultSpacing().lg)
				.padding(.vertical, DefaultSpacing().sm)
				.background(DefaultColorPalette().accent)
				.clipShape(RoundedRectangle(cornerRadius: radius))

			Spacer()
		}
	}

	private func cardExample(_ label: String, radius: CGFloat) -> some View {
		VStack(alignment: .leading, spacing: DefaultSpacing().xs) {
			Text(label)
				.font(.system(.caption, design: .rounded, weight: .semibold))
				.foregroundStyle(DefaultColorPalette().textSecondary)

			RoundedRectangle(cornerRadius: radius)
				.fill(DefaultColorPalette().surfacePrimary)
				.frame(height: 60)
				.overlay(
					Text("Card Content")
						.font(.system(.body, design: .rounded))
						.foregroundStyle(DefaultColorPalette().textPrimary)
				)
		}
	}
}
