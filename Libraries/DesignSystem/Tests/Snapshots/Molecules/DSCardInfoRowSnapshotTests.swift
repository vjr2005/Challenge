import ChallengeCoreMocks
import SnapshotTesting
import SwiftUI
import Testing
import UIKit

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
		let controller = makeHostedView {
			DSCardInfoRow(
				imageURL: URL(string: "https://example.com/image.jpg"),
				title: "Rick Sanchez",
				subtitle: "Human",
				caption: "Citadel of Ricks",
				captionIcon: "mappin.circle.fill",
				status: .alive,
				statusLabel: "Alive"
			)
		}

		assertSnapshot(of: controller, as: .image)
	}

	// MARK: - Minimal Configuration

	@Test("Renders row card with only required properties")
	func minimalConfiguration() {
		let controller = makeHostedView {
			DSCardInfoRow(
				imageURL: nil,
				title: "Unknown Character"
			)
		}

		assertSnapshot(of: controller, as: .image)
	}

	// MARK: - Partial Configurations

	@Test("Renders row card with title and subtitle only")
	func titleAndSubtitleOnly() {
		let controller = makeHostedView {
			DSCardInfoRow(
				imageURL: URL(string: "https://example.com/image.jpg"),
				title: "Morty Smith",
				subtitle: "Human"
			)
		}

		assertSnapshot(of: controller, as: .image)
	}

	@Test("Renders row card with status but no status label")
	func statusWithoutLabel() {
		let controller = makeHostedView {
			DSCardInfoRow(
				imageURL: URL(string: "https://example.com/image.jpg"),
				title: "Summer Smith",
				subtitle: "Human",
				status: .alive
			)
		}

		assertSnapshot(of: controller, as: .image)
	}

	@Test("Renders row card with caption but no icon")
	func captionWithoutIcon() {
		let controller = makeHostedView {
			DSCardInfoRow(
				imageURL: URL(string: "https://example.com/image.jpg"),
				title: "Beth Smith",
				subtitle: "Human",
				caption: "Earth (C-137)"
			)
		}

		assertSnapshot(of: controller, as: .image)
	}

	// MARK: - Status Variants

	@Test("Renders row card with alive status")
	func aliveStatus() {
		let controller = makeHostedView {
			DSCardInfoRow(
				imageURL: URL(string: "https://example.com/image.jpg"),
				title: "Rick Sanchez",
				status: .alive,
				statusLabel: "Alive"
			)
		}

		assertSnapshot(of: controller, as: .image)
	}

	@Test("Renders row card with dead status")
	func deadStatus() {
		let controller = makeHostedView {
			DSCardInfoRow(
				imageURL: URL(string: "https://example.com/image.jpg"),
				title: "Birdperson",
				status: .dead,
				statusLabel: "Dead"
			)
		}

		assertSnapshot(of: controller, as: .image)
	}

	@Test("Renders row card with unknown status")
	func unknownStatus() {
		let controller = makeHostedView {
			DSCardInfoRow(
				imageURL: URL(string: "https://example.com/image.jpg"),
				title: "Mr. Meeseeks",
				status: .unknown,
				statusLabel: "Unknown"
			)
		}

		assertSnapshot(of: controller, as: .image)
	}

	// MARK: - Gallery

	@Test("Renders gallery of row cards with various configurations")
	func rowCardGallery() {
		let controller = makeHostedView(width: 375, height: 500) {
			VStack(spacing: DefaultSpacing().lg) {
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
		}

		assertSnapshot(of: controller, as: .image)
	}
}

// MARK: - Test Helpers

private extension DSCardInfoRowSnapshotTests {
	func makeHostedView<Content: View>(
		width: CGFloat = 375,
		height: CGFloat = 120,
		@ViewBuilder content: () -> Content
	) -> UIHostingController<some View> {
		let view = content().imageLoader(loadedImageLoader)
		let controller = UIHostingController(rootView: view)
		controller.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
		let window = UIWindow(frame: CGRect(x: 0, y: 0, width: width, height: height))
		window.rootViewController = controller
		window.makeKeyAndVisible()
		return controller
	}
}
