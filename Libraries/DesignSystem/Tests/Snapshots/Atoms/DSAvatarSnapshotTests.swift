import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSAvatarSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - DSAsyncAvatar Empty State (ProgressView - when URL is nil)

	@Test
	func emptyStateSmall() {
		let view = DSAsyncAvatar(url: nil, size: .small)
			.padding()
			.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func emptyStateMedium() {
		let view = DSAsyncAvatar(url: nil, size: .medium)
			.padding()
			.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func emptyStateLarge() {
		let view = DSAsyncAvatar(url: nil, size: .large)
			.padding()
			.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func emptyStateExtraLarge() {
		let view = DSAsyncAvatar(url: nil, size: .extraLarge)
			.padding()
			.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - DSAvatar Placeholder State (simulates failure/unknown phases)

	@Test
	func placeholderStateSmall() {
		let view = DSAvatar(size: .small) {
			placeholderContent(size: .small)
		}
		.padding()
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func placeholderStateMedium() {
		let view = DSAvatar(size: .medium) {
			placeholderContent(size: .medium)
		}
		.padding()
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func placeholderStateLarge() {
		let view = DSAvatar(size: .large) {
			placeholderContent(size: .large)
		}
		.padding()
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func placeholderStateExtraLarge() {
		let view = DSAvatar(size: .extraLarge) {
			placeholderContent(size: .extraLarge)
		}
		.padding()
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - DSAvatar Success State (simulates loaded image)

	@Test
	func successStateWithImage() {
		let view = DSAvatar(size: .large) {
			Image(systemName: "person.crop.circle.fill")
				.resizable()
				.foregroundStyle(ColorToken.accent)
		}
		.padding()
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func successStateWithColor() {
		let view = DSAvatar(size: .large) {
			LinearGradient(
				colors: [.blue, .purple],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
		}
		.padding()
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Custom Size

	@Test
	func customSize() {
		let view = DSAsyncAvatar(url: nil, size: .custom(100))
			.padding()
			.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Custom Content (initials avatar)

	@Test
	func customContentInitials() {
		let view = DSAvatar(size: .large) {
			ZStack {
				ColorToken.accent
				DSText("RS", style: .headline, color: ColorToken.textInverted)
			}
		}
		.padding()
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - All States Gallery

	@Test
	func allStatesGallery() {
		let view = VStack(spacing: SpacingToken.lg) {
			HStack(spacing: SpacingToken.md) {
				Text("Empty")
					.font(TextStyle.caption.font)
					.foregroundStyle(ColorToken.textSecondary)
					.frame(width: 70, alignment: .leading)
				DSAsyncAvatar(url: nil, size: .small)
				DSAsyncAvatar(url: nil, size: .medium)
				DSAsyncAvatar(url: nil, size: .large)
			}

			HStack(spacing: SpacingToken.md) {
				Text("Placeholder")
					.font(TextStyle.caption.font)
					.foregroundStyle(ColorToken.textSecondary)
					.frame(width: 70, alignment: .leading)
				avatarWithPlaceholder(size: .small)
				avatarWithPlaceholder(size: .medium)
				avatarWithPlaceholder(size: .large)
			}

			HStack(spacing: SpacingToken.md) {
				Text("Success")
					.font(TextStyle.caption.font)
					.foregroundStyle(ColorToken.textSecondary)
					.frame(width: 70, alignment: .leading)
				avatarWithContent(size: .small, color: .blue)
				avatarWithContent(size: .medium, color: .green)
				avatarWithContent(size: .large, color: .orange)
			}
		}
		.padding()
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - All Sizes Gallery

	@Test
	func allSizesGallery() {
		let view = HStack(spacing: SpacingToken.lg) {
			VStack(spacing: SpacingToken.sm) {
				DSAsyncAvatar(url: nil, size: .small)
				DSText("Small", style: .caption)
			}
			VStack(spacing: SpacingToken.sm) {
				DSAsyncAvatar(url: nil, size: .medium)
				DSText("Medium", style: .caption)
			}
			VStack(spacing: SpacingToken.sm) {
				DSAsyncAvatar(url: nil, size: .large)
				DSText("Large", style: .caption)
			}
			VStack(spacing: SpacingToken.sm) {
				DSAsyncAvatar(url: nil, size: .extraLarge)
				DSText("XL", style: .caption)
			}
		}
		.padding()
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Helpers

	/// Replicates the placeholder view from DSAsyncAvatar for testing failure/unknown states
	private func placeholderContent(size: DSAvatarSize) -> some View {
		ZStack {
			ColorToken.surfaceSecondary
			Image(systemName: "person.fill")
				.font(.system(size: size.dimension * 0.4))
				.foregroundStyle(ColorToken.textTertiary)
		}
	}

	private func avatarWithPlaceholder(size: DSAvatarSize) -> some View {
		DSAvatar(size: size) {
			placeholderContent(size: size)
		}
	}

	private func avatarWithContent(size: DSAvatarSize, color: Color) -> some View {
		DSAvatar(size: size) {
			color
		}
	}
}
