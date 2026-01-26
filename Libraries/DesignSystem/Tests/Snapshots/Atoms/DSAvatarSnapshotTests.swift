import ChallengeCoreMocks
import SnapshotTesting
import SwiftUI
import Testing
import UIKit

@testable import ChallengeDesignSystem

@Suite(.timeLimit(.minutes(1)))
struct DSAvatarSnapshotTests {
	private let emptyImageLoader: ImageLoaderMock
	private let loadedImageLoader: ImageLoaderMock

	init() {
		UIView.setAnimationsEnabled(false)
		emptyImageLoader = ImageLoaderMock(image: nil)
		loadedImageLoader = ImageLoaderMock(image: Self.testImage)
	}

	// MARK: - DSAsyncAvatar Placeholder State (when URL is nil or image fails to load)

	@Test
	func placeholderStateSmall() {
		let view = DSAsyncAvatar(url: nil, size: .small)
			.padding()
			.background(ColorToken.backgroundSecondary)
			.imageLoader(emptyImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func placeholderStateMedium() {
		let view = DSAsyncAvatar(url: nil, size: .medium)
			.padding()
			.background(ColorToken.backgroundSecondary)
			.imageLoader(emptyImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func placeholderStateLarge() {
		let view = DSAsyncAvatar(url: nil, size: .large)
			.padding()
			.background(ColorToken.backgroundSecondary)
			.imageLoader(emptyImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func placeholderStateExtraLarge() {
		let view = DSAsyncAvatar(url: nil, size: .extraLarge)
			.padding()
			.background(ColorToken.backgroundSecondary)
			.imageLoader(emptyImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - DSAsyncAvatar Loaded State (when image loads successfully)

	@Test
	func loadedStateSmall() {
		let view = DSAsyncAvatar(url: Self.testURL, size: .small)
			.padding()
			.background(ColorToken.backgroundSecondary)
			.imageLoader(loadedImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func loadedStateMedium() {
		let view = DSAsyncAvatar(url: Self.testURL, size: .medium)
			.padding()
			.background(ColorToken.backgroundSecondary)
			.imageLoader(loadedImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func loadedStateLarge() {
		let view = DSAsyncAvatar(url: Self.testURL, size: .large)
			.padding()
			.background(ColorToken.backgroundSecondary)
			.imageLoader(loadedImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func loadedStateExtraLarge() {
		let view = DSAsyncAvatar(url: Self.testURL, size: .extraLarge)
			.padding()
			.background(ColorToken.backgroundSecondary)
			.imageLoader(loadedImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - DSAvatar with Custom Content

	@Test
	func customContentWithImage() {
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
	func customContentWithGradient() {
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

	@Test
	func customContentWithInitials() {
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

	// MARK: - Custom Size

	@Test
	func customSizePlaceholder() {
		let view = DSAsyncAvatar(url: nil, size: .custom(100))
			.padding()
			.background(ColorToken.backgroundSecondary)
			.imageLoader(emptyImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func customSizeLoaded() {
		let view = DSAsyncAvatar(url: Self.testURL, size: .custom(100))
			.padding()
			.background(ColorToken.backgroundSecondary)
			.imageLoader(loadedImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - All Sizes Gallery

	@Test
	func allSizesPlaceholderGallery() {
		let view = HStack(spacing: SpacingToken.lg) {
			sizeColumn(url: nil, size: .small, label: "Small")
			sizeColumn(url: nil, size: .medium, label: "Medium")
			sizeColumn(url: nil, size: .large, label: "Large")
			sizeColumn(url: nil, size: .extraLarge, label: "XL")
		}
		.padding()
		.background(ColorToken.backgroundSecondary)
		.imageLoader(emptyImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func allSizesLoadedGallery() {
		let view = HStack(spacing: SpacingToken.lg) {
			sizeColumn(url: Self.testURL, size: .small, label: "Small")
			sizeColumn(url: Self.testURL, size: .medium, label: "Medium")
			sizeColumn(url: Self.testURL, size: .large, label: "Large")
			sizeColumn(url: Self.testURL, size: .extraLarge, label: "XL")
		}
		.padding()
		.background(ColorToken.backgroundSecondary)
		.imageLoader(loadedImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - All States Gallery

	@Test
	func allStatesGallery() {
		let view = VStack(spacing: SpacingToken.lg) {
			HStack(spacing: SpacingToken.md) {
				stateLabel("Placeholder")
				DSAsyncAvatar(url: nil, size: .small)
					.imageLoader(emptyImageLoader)
				DSAsyncAvatar(url: nil, size: .medium)
					.imageLoader(emptyImageLoader)
				DSAsyncAvatar(url: nil, size: .large)
					.imageLoader(emptyImageLoader)
			}

			HStack(spacing: SpacingToken.md) {
				stateLabel("Loaded")
				DSAsyncAvatar(url: Self.testURL, size: .small)
					.imageLoader(loadedImageLoader)
				DSAsyncAvatar(url: Self.testURL, size: .medium)
					.imageLoader(loadedImageLoader)
				DSAsyncAvatar(url: Self.testURL, size: .large)
					.imageLoader(loadedImageLoader)
			}

			HStack(spacing: SpacingToken.md) {
				stateLabel("Custom")
				avatarWithContent(size: .small, color: .blue)
				avatarWithContent(size: .medium, color: .green)
				avatarWithContent(size: .large, color: .orange)
			}
		}
		.padding()
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}
}

// MARK: - Helpers

private extension DSAvatarSnapshotTests {
	static let testURL = URL(string: "https://example.com/avatar.jpg")

	static var testImage: UIImage {
		let size = CGSize(width: 200, height: 200)
		let renderer = UIGraphicsImageRenderer(size: size)

		return renderer.image { context in
			let colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
			let colorSpace = CGColorSpaceCreateDeviceRGB()

			guard let gradient = CGGradient(
				colorsSpace: colorSpace,
				colors: colors as CFArray,
				locations: [0, 1]
			) else { return }

			context.cgContext.drawLinearGradient(
				gradient,
				start: .zero,
				end: CGPoint(x: size.width, y: size.height),
				options: []
			)
		}
	}

	func sizeColumn(url: URL?, size: DSAvatarSize, label: String) -> some View {
		VStack(spacing: SpacingToken.sm) {
			DSAsyncAvatar(url: url, size: size)
			DSText(label, style: .caption)
		}
	}

	func stateLabel(_ text: String) -> some View {
		Text(text)
			.font(TextStyle.caption.font)
			.foregroundStyle(ColorToken.textSecondary)
			.frame(width: 70, alignment: .leading)
	}

	func avatarWithContent(size: DSAvatarSize, color: Color) -> some View {
		DSAvatar(size: size) {
			color
		}
	}
}
