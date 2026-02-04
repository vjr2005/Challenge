import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSShadowSnapshotTests {
	private let shadow = DefaultShadow()

	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Shadow Gallery

	@Test("Renders gallery of all shadow values on cards")
	func shadowGallery() {
		let view = VStack(spacing: DefaultSpacing().xxl) {
			shadowCard("zero", value: shadow.zero)
			shadowCard("small", value: shadow.small)
			shadowCard("medium", value: shadow.medium)
			shadowCard("large", value: shadow.large)
		}
		.padding(DefaultSpacing().xl)
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Shadow Comparison

	@Test("Renders side-by-side comparison of shadow intensities")
	func shadowComparison() {
		let view = HStack(spacing: DefaultSpacing().lg) {
			shadowBox("zero", value: shadow.zero)
			shadowBox("small", value: shadow.small)
			shadowBox("medium", value: shadow.medium)
			shadowBox("large", value: shadow.large)
		}
		.padding(DefaultSpacing().xl)
		.frame(width: 360)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Shadow Properties

	@Test("Renders shadow values with property values displayed")
	func shadowProperties() {
		let view = VStack(alignment: .leading, spacing: DefaultSpacing().lg) {
			shadowPropertyRow("zero", value: shadow.zero)
			shadowPropertyRow("small", value: shadow.small)
			shadowPropertyRow("medium", value: shadow.medium)
			shadowPropertyRow("large", value: shadow.large)
		}
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Shadow In Context

	@Test("Renders shadow values applied to real card context")
	func shadowCardContext() {
		let view = VStack(spacing: DefaultSpacing().xxl) {
			contextCard("Flat Card", value: shadow.zero)
			contextCard("Subtle Elevation", value: shadow.small)
			contextCard("Standard Card", value: shadow.medium)
			contextCard("Floating Element", value: shadow.large)
		}
		.padding(DefaultSpacing().xl)
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Helpers

	private func shadowCard(_ name: String, value: DSShadowValue) -> some View {
		HStack {
			Text(name)
				.font(.system(.footnote, design: .monospaced))
				.foregroundStyle(DefaultColorPalette().textSecondary)
				.frame(width: 60, alignment: .leading)

			RoundedRectangle(cornerRadius: DefaultCornerRadius().md)
				.fill(DefaultColorPalette().surfacePrimary)
				.frame(width: 160, height: 50)
				.shadow(value)

			Spacer()
		}
	}

	private func shadowBox(_ name: String, value: DSShadowValue) -> some View {
		VStack(spacing: DefaultSpacing().sm) {
			RoundedRectangle(cornerRadius: DefaultCornerRadius().sm)
				.fill(DefaultColorPalette().surfacePrimary)
				.frame(width: 60, height: 60)
				.shadow(value)

			Text(name)
				.font(.system(.caption2, design: .monospaced))
				.foregroundStyle(DefaultColorPalette().textSecondary)
		}
	}

	private func shadowPropertyRow(_ name: String, value: DSShadowValue) -> some View {
		HStack(spacing: DefaultSpacing().md) {
			Text(name)
				.font(.system(.footnote, design: .monospaced))
				.foregroundStyle(DefaultColorPalette().textPrimary)
				.frame(width: 50, alignment: .leading)

			VStack(alignment: .leading, spacing: 2) {
				Text("radius: \(Int(value.radius))pt")
				Text("y: \(Int(value.y))pt")
			}
			.font(.system(.caption2, design: .monospaced))
			.foregroundStyle(DefaultColorPalette().textSecondary)

			Spacer()

			Circle()
				.fill(value.color)
				.frame(width: 20, height: 20)
				.overlay(
					Circle()
						.stroke(Color.gray.opacity(0.3), lineWidth: 1)
				)
		}
	}

	private func contextCard(_ title: String, value: DSShadowValue) -> some View {
		VStack(alignment: .leading, spacing: DefaultSpacing().sm) {
			Text(title)
				.font(.system(.headline, design: .rounded))
				.foregroundStyle(DefaultColorPalette().textPrimary)

			Text("Description text for the card content.")
				.font(.system(.subheadline, design: .rounded))
				.foregroundStyle(DefaultColorPalette().textSecondary)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding()
		.background(DefaultColorPalette().surfacePrimary)
		.clipShape(RoundedRectangle(cornerRadius: DefaultCornerRadius().md))
		.shadow(value)
	}
}
