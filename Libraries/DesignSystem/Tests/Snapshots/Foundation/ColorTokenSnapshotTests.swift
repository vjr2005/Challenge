import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DefaultColorPaletteSnapshotTests {
	private let palette = DefaultColorPalette()

	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Background Colors

	@Test("Renders background color tokens palette")
	func backgroundColors() {
		let view = VStack(spacing: SpacingToken.sm) {
			colorSwatch("backgroundPrimary", color: palette.backgroundPrimary)
			colorSwatch("backgroundSecondary", color: palette.backgroundSecondary)
			colorSwatch("backgroundTertiary", color: palette.backgroundTertiary)
		}
		.padding()
		.frame(width: 300)
		.background(Color.gray.opacity(0.3))

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Surface Colors

	@Test("Renders surface color tokens palette")
	func surfaceColors() {
		let view = VStack(spacing: SpacingToken.sm) {
			colorSwatch("surfacePrimary", color: palette.surfacePrimary)
			colorSwatch("surfaceSecondary", color: palette.surfaceSecondary)
		}
		.padding()
		.frame(width: 300)
		.background(Color.gray.opacity(0.3))

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Text Colors

	@Test("Renders text color tokens palette")
	func textColors() {
		let view = VStack(spacing: SpacingToken.sm) {
			colorSwatch("textPrimary", color: palette.textPrimary)
			colorSwatch("textSecondary", color: palette.textSecondary)
			colorSwatch("textTertiary", color: palette.textTertiary)
			colorSwatch("textInverted", color: palette.textInverted)
		}
		.padding()
		.frame(width: 300)
		.background(Color.gray.opacity(0.3))

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Status Colors

	@Test("Renders status color tokens palette")
	func statusColors() {
		let view = VStack(spacing: SpacingToken.sm) {
			colorSwatch("statusSuccess", color: palette.statusSuccess)
			colorSwatch("statusError", color: palette.statusError)
			colorSwatch("statusWarning", color: palette.statusWarning)
			colorSwatch("statusNeutral", color: palette.statusNeutral)
		}
		.padding()
		.frame(width: 300)
		.background(palette.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Interactive Colors

	@Test("Renders interactive color tokens palette")
	func interactiveColors() {
		let view = VStack(spacing: SpacingToken.sm) {
			colorSwatch("accent", color: palette.accent)
			colorSwatch("accentSubtle", color: palette.accentSubtle)
			colorSwatch("disabled", color: palette.disabled)
		}
		.padding()
		.frame(width: 300)
		.background(palette.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Separator Colors

	@Test("Renders separator color tokens palette")
	func separatorColors() {
		let view = VStack(spacing: SpacingToken.sm) {
			colorSwatch("separator", color: palette.separator)
			colorSwatch("separatorOpaque", color: palette.separatorOpaque)
		}
		.padding()
		.frame(width: 300)
		.background(palette.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Full Gallery

	@Test("Renders complete gallery of all color tokens organized by category")
	func fullColorGallery() {
		let view = VStack(spacing: SpacingToken.lg) {
			colorSection("Background") {
				colorSwatch("backgroundPrimary", color: palette.backgroundPrimary)
				colorSwatch("backgroundSecondary", color: palette.backgroundSecondary)
				colorSwatch("backgroundTertiary", color: palette.backgroundTertiary)
			}

			colorSection("Surface") {
				colorSwatch("surfacePrimary", color: palette.surfacePrimary)
				colorSwatch("surfaceSecondary", color: palette.surfaceSecondary)
			}

			colorSection("Text") {
				colorSwatch("textPrimary", color: palette.textPrimary)
				colorSwatch("textSecondary", color: palette.textSecondary)
				colorSwatch("textTertiary", color: palette.textTertiary)
			}

			colorSection("Status") {
				colorSwatch("statusSuccess", color: palette.statusSuccess)
				colorSwatch("statusError", color: palette.statusError)
				colorSwatch("statusWarning", color: palette.statusWarning)
				colorSwatch("statusNeutral", color: palette.statusNeutral)
			}

			colorSection("Interactive") {
				colorSwatch("accent", color: palette.accent)
				colorSwatch("accentSubtle", color: palette.accentSubtle)
				colorSwatch("disabled", color: palette.disabled)
			}

			colorSection("Separator") {
				colorSwatch("separator", color: palette.separator)
				colorSwatch("separatorOpaque", color: palette.separatorOpaque)
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
				.foregroundStyle(palette.textPrimary)
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
				.foregroundStyle(palette.textSecondary)
			VStack(spacing: SpacingToken.xs) {
				content()
			}
		}
	}
}
