import ChallengeCoreMocks
import SnapshotTesting
import SwiftUI
import Testing
import UIKit

@testable import ChallengeDesignSystem

struct DSAsyncImageSnapshotTests {
	private let emptyImageLoader: ImageLoaderMock
	private let loadedImageLoader: ImageLoaderMock

	init() {
		UIView.setAnimationsEnabled(false)
		emptyImageLoader = ImageLoaderMock(image: nil)
		loadedImageLoader = ImageLoaderMock(image: .stub)
	}

	// MARK: - Placeholder State (nil URL)

	@Test
	func placeholderWithNilURL() {
		let view = DSAsyncImage(url: nil) { phase in
			switch phase {
			case .success(let image):
				image.resizable().scaledToFill()
			case .empty:
				ProgressView()
			case .failure:
				Self.errorView
			@unknown default:
				ProgressView()
			}
		}
		.frame(width: 100, height: 100)
		.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))
		.padding()
		.background(ColorToken.backgroundSecondary)
		.imageLoader(emptyImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func placeholderWithCustomView() {
		let view = DSAsyncImage(url: nil) { phase in
			switch phase {
			case .success(let image):
				image.resizable().scaledToFill()
			case .empty:
				ZStack {
					ColorToken.surfaceSecondary
					Image(systemName: "hourglass")
						.font(.title)
						.foregroundStyle(ColorToken.textTertiary)
				}
			case .failure:
				Self.errorView
			@unknown default:
				EmptyView()
			}
		}
		.frame(width: 100, height: 100)
		.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))
		.padding()
		.background(ColorToken.backgroundSecondary)
		.imageLoader(emptyImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Loaded State (with image)

	@Test
	func loadedStateSmall() {
		let view = DSAsyncImage(url: Self.testURL) { phase in
			switch phase {
			case .success(let image):
				image.resizable().scaledToFill()
			case .empty:
				ProgressView()
			case .failure:
				Self.errorView
			@unknown default:
				ProgressView()
			}
		}
		.frame(width: 50, height: 50)
		.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.sm))
		.padding()
		.background(ColorToken.backgroundSecondary)
		.imageLoader(loadedImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func loadedStateMedium() {
		let view = DSAsyncImage(url: Self.testURL) { phase in
			switch phase {
			case .success(let image):
				image.resizable().scaledToFill()
			case .empty:
				ProgressView()
			case .failure:
				Self.errorView
			@unknown default:
				ProgressView()
			}
		}
		.frame(width: 100, height: 100)
		.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))
		.padding()
		.background(ColorToken.backgroundSecondary)
		.imageLoader(loadedImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func loadedStateLarge() {
		let view = DSAsyncImage(url: Self.testURL) { phase in
			switch phase {
			case .success(let image):
				image.resizable().scaledToFill()
			case .empty:
				ProgressView()
			case .failure:
				Self.errorView
			@unknown default:
				ProgressView()
			}
		}
		.frame(width: 150, height: 150)
		.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.lg))
		.padding()
		.background(ColorToken.backgroundSecondary)
		.imageLoader(loadedImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Content Modes

	@Test
	func scaledToFit() {
		let view = DSAsyncImage(url: Self.testURL) { phase in
			switch phase {
			case .success(let image):
				image.resizable().scaledToFit()
			case .empty:
				ProgressView()
			case .failure:
				Self.errorView
			@unknown default:
				ProgressView()
			}
		}
		.frame(width: 150, height: 100)
		.background(ColorToken.surfaceSecondary)
		.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))
		.padding()
		.background(ColorToken.backgroundSecondary)
		.imageLoader(loadedImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func scaledToFill() {
		let view = DSAsyncImage(url: Self.testURL) { phase in
			switch phase {
			case .success(let image):
				image.resizable().scaledToFill()
			case .empty:
				ProgressView()
			case .failure:
				Self.errorView
			@unknown default:
				ProgressView()
			}
		}
		.frame(width: 150, height: 100)
		.clipped()
		.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))
		.padding()
		.background(ColorToken.backgroundSecondary)
		.imageLoader(loadedImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Shapes

	@Test
	func circleShape() {
		let view = DSAsyncImage(url: Self.testURL) { phase in
			switch phase {
			case .success(let image):
				image.resizable().scaledToFill()
			case .empty:
				ProgressView()
			case .failure:
				Self.errorView
			@unknown default:
				ProgressView()
			}
		}
		.frame(width: 100, height: 100)
		.clipShape(Circle())
		.padding()
		.background(ColorToken.backgroundSecondary)
		.imageLoader(loadedImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func roundedRectangleShape() {
		let view = DSAsyncImage(url: Self.testURL) { phase in
			switch phase {
			case .success(let image):
				image.resizable().scaledToFill()
			case .empty:
				ProgressView()
			case .failure:
				Self.errorView
			@unknown default:
				ProgressView()
			}
		}
		.frame(width: 120, height: 80)
		.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.xl))
		.padding()
		.background(ColorToken.backgroundSecondary)
		.imageLoader(loadedImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Gallery

	@Test
	func statesGallery() {
		let view = HStack(spacing: SpacingToken.lg) {
			stateItem(url: nil, label: "Placeholder")
			stateItem(url: Self.testURL, label: "Loaded")
			circleStateItem(url: Self.testURL, label: "Circle")
		}
		.padding()
		.background(ColorToken.backgroundSecondary)
		.imageLoader(loadedImageLoader)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func sizesGallery() {
		let view = HStack(alignment: .bottom, spacing: SpacingToken.lg) {
			sizeItem(size: 40, cornerRadius: CornerRadiusToken.xs, label: "40pt")
			sizeItem(size: 64, cornerRadius: CornerRadiusToken.sm, label: "64pt")
			sizeItem(size: 100, cornerRadius: CornerRadiusToken.md, label: "100pt")
			sizeItem(size: 120, cornerRadius: CornerRadiusToken.lg, label: "120pt")
		}
		.padding()
		.background(ColorToken.backgroundSecondary)
		.imageLoader(loadedImageLoader)

		assertSnapshot(of: view, as: .image)
	}
}

// MARK: - Private

private extension DSAsyncImageSnapshotTests {
	static let testURL = URL(string: "https://example.com/test-image.jpg")

	static var errorView: some View {
		ZStack {
			ColorToken.surfaceSecondary
			Image(systemName: "photo")
				.font(.title)
				.foregroundStyle(ColorToken.textTertiary)
		}
	}

	func stateItem(url: URL?, label: String) -> some View {
		VStack(spacing: SpacingToken.sm) {
			DSAsyncImage(url: url) { phase in
				switch phase {
				case .success(let image):
					image.resizable().scaledToFill()
				case .empty:
					ZStack {
						ColorToken.surfaceSecondary
						ProgressView()
					}
				case .failure:
					Self.errorView
				@unknown default:
					ProgressView()
				}
			}
			.frame(width: 80, height: 80)
			.clipShape(RoundedRectangle(cornerRadius: CornerRadiusToken.md))

			DSText(label, style: .caption)
		}
	}

	func circleStateItem(url: URL?, label: String) -> some View {
		VStack(spacing: SpacingToken.sm) {
			DSAsyncImage(url: url) { phase in
				switch phase {
				case .success(let image):
					image.resizable().scaledToFill()
				case .empty:
					ProgressView()
				case .failure:
					Self.errorView
				@unknown default:
					ProgressView()
				}
			}
			.frame(width: 80, height: 80)
			.clipShape(Circle())

			DSText(label, style: .caption)
		}
	}

	func sizeItem(size: CGFloat, cornerRadius: CGFloat, label: String) -> some View {
		VStack(spacing: SpacingToken.sm) {
			DSAsyncImage(url: Self.testURL) { phase in
				switch phase {
				case .success(let image):
					image.resizable().scaledToFill()
				case .empty:
					ProgressView()
				case .failure:
					Self.errorView
				@unknown default:
					ProgressView()
				}
			}
			.frame(width: size, height: size)
			.clipShape(RoundedRectangle(cornerRadius: cornerRadius))

			DSText(label, style: .caption)
		}
	}
}
