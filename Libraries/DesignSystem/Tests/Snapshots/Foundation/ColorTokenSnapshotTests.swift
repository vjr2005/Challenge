import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

/*
@Suite(.timeLimit(.minutes(1)))
struct ColorTokenSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Background Colors

	@Test
	func backgroundColors() {
		let view = VStack(spacing: SpacingToken.sm) {
			colorSwatch("backgroundPrimary", color: ColorToken.backgroundPrimary)
			colorSwatch("backgroundSecondary", color: ColorToken.backgroundSecondary)
			colorSwatch("backgroundTertiary", color: ColorToken.backgroundTertiary)
		}
		.padding()
		.frame(width: 300)
		.background(Color.gray.opacity(0.3))

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Surface Colors

	@Test
	func surfaceColors() {
		let view = VStack(spacing: SpacingToken.sm) {
			colorSwatch("surfacePrimary", color: ColorToken.surfacePrimary)
			colorSwatch("surfaceSecondary", color: ColorToken.surfaceSecondary)
		}
		.padding()
		.frame(width: 300)
		.background(Color.gray.opacity(0.3))

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Text Colors

	@Test
	func textColors() {
		let view = VStack(spacing: SpacingToken.sm) {
			colorSwatch("textPrimary", color: ColorToken.textPrimary)
			colorSwatch("textSecondary", color: ColorToken.textSecondary)
			colorSwatch("textTertiary", color: ColorToken.textTertiary)
			colorSwatch("textInverted", color: ColorToken.textInverted)
		}
		.padding()
		.frame(width: 300)
		.background(Color.gray.opacity(0.3))

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Status Colors

	@Test
	func statusColors() {
		let view = VStack(spacing: SpacingToken.sm) {
			colorSwatch("statusSuccess", color: ColorToken.statusSuccess)
			colorSwatch("statusError", color: ColorToken.statusError)
			colorSwatch("statusWarning", color: ColorToken.statusWarning)
			colorSwatch("statusNeutral", color: ColorToken.statusNeutral)
		}
		.padding()
		.frame(width: 300)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Interactive Colors

	@Test
	func interactiveColors() {
		let view = VStack(spacing: SpacingToken.sm) {
			colorSwatch("accent", color: ColorToken.accent)
			colorSwatch("accentSubtle", color: ColorToken.accentSubtle)
			colorSwatch("disabled", color: ColorToken.disabled)
		}
		.padding()
		.frame(width: 300)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Separator Colors

	@Test
	func separatorColors() {
		let view = VStack(spacing: SpacingToken.sm) {
			colorSwatch("separator", color: ColorToken.separator)
			colorSwatch("separatorOpaque", color: ColorToken.separatorOpaque)
		}
		.padding()
		.frame(width: 300)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Full Gallery

	@Test
	func fullColorGallery() {
		let view = VStack(spacing: SpacingToken.lg) {
			colorSection("Background") {
				colorSwatch("backgroundPrimary", color: ColorToken.backgroundPrimary)
				colorSwatch("backgroundSecondary", color: ColorToken.backgroundSecondary)
				colorSwatch("backgroundTertiary", color: ColorToken.backgroundTertiary)
			}

			colorSection("Surface") {
				colorSwatch("surfacePrimary", color: ColorToken.surfacePrimary)
				colorSwatch("surfaceSecondary", color: ColorToken.surfaceSecondary)
			}

			colorSection("Text") {
				colorSwatch("textPrimary", color: ColorToken.textPrimary)
				colorSwatch("textSecondary", color: ColorToken.textSecondary)
				colorSwatch("textTertiary", color: ColorToken.textTertiary)
			}

			colorSection("Status") {
				colorSwatch("statusSuccess", color: ColorToken.statusSuccess)
				colorSwatch("statusError", color: ColorToken.statusError)
				colorSwatch("statusWarning", color: ColorToken.statusWarning)
				colorSwatch("statusNeutral", color: ColorToken.statusNeutral)
			}

			colorSection("Interactive") {
				colorSwatch("accent", color: ColorToken.accent)
				colorSwatch("accentSubtle", color: ColorToken.accentSubtle)
				colorSwatch("disabled", color: ColorToken.disabled)
			}

			colorSection("Separator") {
				colorSwatch("separator", color: ColorToken.separator)
				colorSwatch("separatorOpaque", color: ColorToken.separatorOpaque)
			}
		}
		.padding()
		.frame(width: 320)
		.background(Color.gray.opacity(0.2))

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Helpers

	private func colorSwatch(_ name: String, color: Color) -> some View {
		HStack {
			RoundedRectangle(cornerRadius: CornerRadiusToken.sm)
				.fill(color)
				.frame(width: 40, height: 40)
				.overlay(
					RoundedRectangle(cornerRadius: CornerRadiusToken.sm)
						.stroke(Color.gray.opacity(0.3), lineWidth: 1)
				)
			Text(name)
				.font(.system(.footnote, design: .monospaced))
				.foregroundStyle(ColorToken.textPrimary)
			Spacer()
		}
	}

	private func colorSection<Content: View>(
		_ title: String,
		@ViewBuilder content: () -> Content
	) -> some View {
		VStack(alignment: .leading, spacing: SpacingToken.xs) {
			Text(title)
				.font(.system(.caption, design: .rounded, weight: .semibold))
				.foregroundStyle(ColorToken.textSecondary)
			VStack(spacing: SpacingToken.xs) {
				content()
			}
		}
	}
}
*/
