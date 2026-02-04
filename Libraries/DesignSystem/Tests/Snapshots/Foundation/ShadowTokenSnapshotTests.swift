import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct ShadowTokenSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Shadow Gallery

	@Test("Renders gallery of all shadow tokens on cards")
	func shadowGallery() {
		let view = VStack(spacing: DefaultSpacing().xxl) {
			shadowCard("zero", token: .zero)
			shadowCard("small", token: .small)
			shadowCard("medium", token: .medium)
			shadowCard("large", token: .large)
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
			shadowBox("zero", token: .zero)
			shadowBox("small", token: .small)
			shadowBox("medium", token: .medium)
			shadowBox("large", token: .large)
		}
		.padding(DefaultSpacing().xl)
		.frame(width: 360)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Shadow Properties

	@Test("Renders shadow tokens with property values displayed")
	func shadowProperties() {
		let view = VStack(alignment: .leading, spacing: DefaultSpacing().lg) {
			shadowPropertyRow("zero", token: .zero)
			shadowPropertyRow("small", token: .small)
			shadowPropertyRow("medium", token: .medium)
			shadowPropertyRow("large", token: .large)
		}
		.padding()
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Shadow In Context

	@Test("Renders shadow tokens applied to real card context")
	func shadowCardContext() {
		let view = VStack(spacing: DefaultSpacing().xxl) {
			contextCard("Flat Card", token: .zero)
			contextCard("Subtle Elevation", token: .small)
			contextCard("Standard Card", token: .medium)
			contextCard("Floating Element", token: .large)
		}
		.padding(DefaultSpacing().xl)
		.frame(width: 320)
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Helpers

	private func shadowCard(_ name: String, token: ShadowToken) -> some View {
		HStack {
			Text(name)
				.font(.system(.footnote, design: .monospaced))
				.foregroundStyle(DefaultColorPalette().textSecondary)
				.frame(width: 60, alignment: .leading)

			RoundedRectangle(cornerRadius: DefaultCornerRadius().md)
				.fill(DefaultColorPalette().surfacePrimary)
				.frame(width: 160, height: 50)
				.shadow(token)

			Spacer()
		}
	}

	private func shadowBox(_ name: String, token: ShadowToken) -> some View {
		VStack(spacing: DefaultSpacing().sm) {
			RoundedRectangle(cornerRadius: DefaultCornerRadius().sm)
				.fill(DefaultColorPalette().surfacePrimary)
				.frame(width: 60, height: 60)
				.shadow(token)

			Text(name)
				.font(.system(.caption2, design: .monospaced))
				.foregroundStyle(DefaultColorPalette().textSecondary)
		}
	}

	private func shadowPropertyRow(_ name: String, token: ShadowToken) -> some View {
		HStack(spacing: DefaultSpacing().md) {
			Text(name)
				.font(.system(.footnote, design: .monospaced))
				.foregroundStyle(DefaultColorPalette().textPrimary)
				.frame(width: 50, alignment: .leading)

			VStack(alignment: .leading, spacing: 2) {
				Text("radius: \(Int(token.radius))pt")
				Text("y: \(Int(token.y))pt")
			}
			.font(.system(.caption2, design: .monospaced))
			.foregroundStyle(DefaultColorPalette().textSecondary)

			Spacer()

			Circle()
				.fill(token.color)
				.frame(width: 20, height: 20)
				.overlay(
					Circle()
						.stroke(Color.gray.opacity(0.3), lineWidth: 1)
				)
		}
	}

	private func contextCard(_ title: String, token: ShadowToken) -> some View {
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
		.shadow(token)
	}
}
