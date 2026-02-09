import ChallengeCoreMocks
import ChallengeSnapshotTestKit
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSCardInfoRowSnapshotTests {
	private let loadedImageLoader: ImageLoaderMock

	init() {
		UIView.setAnimationsEnabled(false)
		loadedImageLoader = ImageLoaderMock(cachedImage: .stub, asyncImage: .stub)
	}

	// MARK: - Complete Configuration

	@Test("Renders row card with all properties configured")
	func fullConfiguration() {
		assertSnapshot(
			of: DSCardInfoRow(
				imageURL: URL(string: "https://example.com/image.jpg"),
				title: "Rick Sanchez",
				subtitle: "Human",
				caption: "Citadel of Ricks",
				captionIcon: "mappin.circle.fill",
				status: .alive,
				statusLabel: "Alive",
				accessibilityIdentifier: "test.cardInfoRow"
			).imageLoader(loadedImageLoader),
			as: .component(size: CGSize(width: 375, height: 120))
		)
	}

	// MARK: - Minimal Configuration

	@Test("Renders row card with only required properties")
	func minimalConfiguration() {
		assertSnapshot(
			of: DSCardInfoRow(
				imageURL: nil,
				title: "Unknown Character"
			).imageLoader(loadedImageLoader),
			as: .component(size: CGSize(width: 375, height: 120))
		)
	}

	// MARK: - Partial Configurations

	@Test("Renders row card with title and subtitle only")
	func titleAndSubtitleOnly() {
		assertSnapshot(
			of: DSCardInfoRow(
				imageURL: URL(string: "https://example.com/image.jpg"),
				title: "Morty Smith",
				subtitle: "Human"
			).imageLoader(loadedImageLoader),
			as: .component(size: CGSize(width: 375, height: 120))
		)
	}

	@Test("Renders row card with status but no status label")
	func statusWithoutLabel() {
		assertSnapshot(
			of: DSCardInfoRow(
				imageURL: URL(string: "https://example.com/image.jpg"),
				title: "Summer Smith",
				subtitle: "Human",
				status: .alive
			).imageLoader(loadedImageLoader),
			as: .component(size: CGSize(width: 375, height: 120))
		)
	}

	@Test("Renders row card with caption but no icon")
	func captionWithoutIcon() {
		assertSnapshot(
			of: DSCardInfoRow(
				imageURL: URL(string: "https://example.com/image.jpg"),
				title: "Beth Smith",
				subtitle: "Human",
				caption: "Earth (C-137)"
			).imageLoader(loadedImageLoader),
			as: .component(size: CGSize(width: 375, height: 120))
		)
	}

	// MARK: - Status Variants

	@Test("Renders row card with alive status")
	func aliveStatus() {
		assertSnapshot(
			of: DSCardInfoRow(
				imageURL: URL(string: "https://example.com/image.jpg"),
				title: "Rick Sanchez",
				status: .alive,
				statusLabel: "Alive"
			).imageLoader(loadedImageLoader),
			as: .component(size: CGSize(width: 375, height: 120))
		)
	}

	@Test("Renders row card with dead status")
	func deadStatus() {
		assertSnapshot(
			of: DSCardInfoRow(
				imageURL: URL(string: "https://example.com/image.jpg"),
				title: "Birdperson",
				status: .dead,
				statusLabel: "Dead"
			).imageLoader(loadedImageLoader),
			as: .component(size: CGSize(width: 375, height: 120))
		)
	}

	@Test("Renders row card with unknown status")
	func unknownStatus() {
		assertSnapshot(
			of: DSCardInfoRow(
				imageURL: URL(string: "https://example.com/image.jpg"),
				title: "Mr. Meeseeks",
				status: .unknown,
				statusLabel: "Unknown"
			).imageLoader(loadedImageLoader),
			as: .component(size: CGSize(width: 375, height: 120))
		)
	}

	// MARK: - Gallery

	@Test("Renders gallery of row cards with various configurations")
	func rowCardGallery() {
		let gallery = VStack(spacing: DefaultSpacing().lg) {
			DSCardInfoRow(
				imageURL: URL(string: "https://example.com/1.jpg"),
				title: "Rick Sanchez",
				subtitle: "Human",
				caption: "Citadel of Ricks",
				captionIcon: "mappin.circle.fill",
				status: .alive,
				statusLabel: "Alive"
			)

			DSCardInfoRow(
				imageURL: URL(string: "https://example.com/2.jpg"),
				title: "Morty Smith",
				subtitle: "Human",
				status: .alive,
				statusLabel: "Alive"
			)

			DSCardInfoRow(
				imageURL: nil,
				title: "Unknown Entity",
				subtitle: "Unknown species"
			)
		}
		.padding()
		.background(DefaultColorPalette().backgroundSecondary)

		assertSnapshot(
			of: gallery.imageLoader(loadedImageLoader),
			as: .component(size: CGSize(width: 375, height: 500))
		)
	}
}
