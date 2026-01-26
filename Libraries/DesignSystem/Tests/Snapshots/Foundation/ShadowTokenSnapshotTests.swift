import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

/*
@Suite(.timeLimit(.minutes(1)))
struct ShadowTokenSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Shadow Gallery

	@Test
	func shadowGallery() {
		let view = VStack(spacing: SpacingToken.xxl) {
			shadowCard("zero", token: .zero)
			shadowCard("small", token: .small)
			shadowCard("medium", token: .medium)
			shadowCard("large", token: .large)
		}
		.padding(SpacingToken.xl)
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Shadow Comparison

	@Test
	func shadowComparison() {
		let view = HStack(spacing: SpacingToken.lg) {
			shadowBox("zero", token: .zero)
			shadowBox("small", token: .small)
			shadowBox("medium", token: .medium)
			shadowBox("large", token: .large)
		}
		.padding(SpacingToken.xl)
		.frame(width: 360)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Shadow Properties

	@Test
	func shadowProperties() {
		let view = VStack(alignment: .leading, spacing: SpacingToken.lg) {
			shadowPropertyRow("zero", token: .zero)
			shadowPropertyRow("small", token: .small)
			shadowPropertyRow("medium", token: .medium)
			shadowPropertyRow("large", token: .large)
		}
		.padding()
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Shadow In Context

	@Test
	func shadowCardContext() {
		let view = VStack(spacing: SpacingToken.xxl) {
			contextCard("Flat Card", token: .zero)
			contextCard("Subtle Elevation", token: .small)
			contextCard("Standard Card", token: .medium)
			contextCard("Floating Element", token: .large)
		}
		.padding(SpacingToken.xl)
		.frame(width: 320)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Helpers

	private func shadowCard(_ name: String, token: ShadowToken) -> some View {
		HStack {
			Text(name)
				.font(.system(.footnote, design: .monospaced))
				.foregroundStyle(ColorToken.textSecondary)
				.frame(width: 60, alignment: .leading)

			RoundedRectangle(cornerRadius: CornerRadiusToken.md)
				.fill(ColorToken.surfacePrimary)
				.frame(width: 160, height: 50)
				.shadow(token)

			Spacer()
		}
	}

	private func shadowBox(_ name: String, token: ShadowToken) -> some View {
		VStack(spacing: SpacingToken.sm) {
			RoundedRectangle(cornerRadius: CornerRadiusToken.sm)
				.fill(ColorToken.surfacePrimary)
				.frame(width: 60, height: 60)
				.shadow(token)

			Text(name)
				.font(.system(.caption2, design: .monospaced))
				.foregroundStyle(ColorToken.textSecondary)
		}
	}

	private func shadowPropertyRow(_ name: String, token: ShadowToken) -> some View {
		HStack(spacing: SpacingToken.md) {
			Text(name)
				.font(.system(.footnote, design: .monospaced))
				.foregroundStyle(ColorToken.textPrimary)
				.frame(width: 50, alignment: .leading)

			VStack(alignment: .leading, spacing: 2) {
				Text("radius: \(Int(token.radius))pt")
				Text("y: \(Int(token.y))pt")
			}
			.font(.system(.caption2, design: .monospaced))
			.foregroundStyle(ColorToken.textSecondary)

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
		VStack(alignment: .leading, spacing: SpacingToken.sm) {
			Text(title)
				.font(.system(.headline, design: .rounded))
				.foregroundStyle(ColorToken.textPrimary)

			Text("Description text for the card content.")
				.font(.system(.subheadline, design: .rounded))
				.foregroundStyle(ColorToken.textSecondary)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding()
		.background(ColorToken.surfacePrimary)
		.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))
		.shadow(token)
	}
}
*/
