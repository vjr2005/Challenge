import ChallengeCoreMocks
import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

/*
@Suite(.timeLimit(.minutes(1)))
struct DSListItemCardSnapshotTests {
	private let imageLoader: ImageLoaderMock

	init() {
		UIView.setAnimationsEnabled(false)
		imageLoader = ImageLoaderMock(image: nil)
	}

	// MARK: - Full Card

	@Test
	func fullCard() {
		let view = DSListItemCard(
			title: "Rick Sanchez",
			subtitle: "Human",
			caption: "Earth (C-137)",
			leading: {
				DSAsyncAvatar(url: nil, size: .medium)
			},
			trailing: {
				DSStatusBadge(status: .alive)
			}
		)
		.padding()
		.frame(width: 360)
		.background(ColorToken.backgroundSecondary)
		.imageLoader(imageLoader)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Without Trailing

	@Test
	func withoutTrailing() {
		let view = DSListItemCard<DSAsyncAvatar, EmptyView>(
			title: "Morty Smith",
			subtitle: "Human"
		) {
			DSAsyncAvatar(url: nil, size: .medium)
		}
		.padding()
		.frame(width: 360)
		.background(ColorToken.backgroundSecondary)
		.imageLoader(imageLoader)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Without Leading

	@Test
	func withoutLeading() {
		let view = DSListItemCard<EmptyView, DSStatusBadge>(
			title: "Jerry Smith",
			subtitle: "Human",
			caption: "Earth (C-137)"
		) {
			DSStatusBadge(status: .alive)
		}
		.padding()
		.frame(width: 360)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Text Only

	@Test
	func textOnly() {
		let view = DSListItemCard<EmptyView, EmptyView>(
			title: "Simple Card",
			subtitle: "With subtitle only"
		)
		.padding()
		.frame(width: 360)
		.background(ColorToken.backgroundSecondary)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - With Caption

	@Test
	func withCaption() {
		let view = DSListItemCard(
			title: "Summer Smith",
			subtitle: "Human",
			caption: "Origin: Earth (Replacement Dimension)",
			leading: {
				DSAsyncAvatar(url: nil, size: .medium)
			},
			trailing: {
				DSStatusBadge(status: .alive)
			}
		)
		.padding()
		.frame(width: 360)
		.background(ColorToken.backgroundSecondary)
		.imageLoader(imageLoader)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Different Status

	@Test
	func listItemsGallery() {
		let view = VStack(spacing: SpacingToken.md) {
			DSListItemCard(
				title: "Rick Sanchez",
				subtitle: "Human",
				leading: {
					DSAsyncAvatar(url: nil, size: .medium)
				},
				trailing: {
					DSStatusBadge(status: .alive)
				}
			)

			DSListItemCard(
				title: "Birdperson",
				subtitle: "Birdperson",
				leading: {
					DSAsyncAvatar(url: nil, size: .medium)
				},
				trailing: {
					DSStatusBadge(status: .dead)
				}
			)

			DSListItemCard(
				title: "Unknown Character",
				subtitle: "Unknown species",
				leading: {
					DSAsyncAvatar(url: nil, size: .medium)
				},
				trailing: {
					DSStatusBadge(status: .unknown)
				}
			)
		}
		.padding()
		.frame(width: 360)
		.background(ColorToken.backgroundSecondary)
		.imageLoader(imageLoader)

		assertSnapshot(of: view, as: .image)
	}
}
*/
