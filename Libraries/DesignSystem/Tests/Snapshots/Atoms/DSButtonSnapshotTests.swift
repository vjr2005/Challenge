import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite(.timeLimit(.minutes(1)))
struct DSButtonSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Primary Variant

	@Test
	func primaryButton() {
		let view = DSButton("Primary Button") {}
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func primaryButtonWithIcon() {
		let view = DSButton("With Icon", icon: "arrow.right") {}
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func primaryButtonLoading() {
		let view = DSButton("Loading", isLoading: true) {}
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Secondary Variant

	@Test
	func secondaryButton() {
		let view = DSButton("Secondary", variant: .secondary) {}
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func secondaryButtonWithIcon() {
		let view = DSButton("With Icon", icon: "plus", variant: .secondary) {}
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Tertiary Variant

	@Test
	func tertiaryButton() {
		let view = DSButton("Tertiary", variant: .tertiary) {}
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func tertiaryButtonWithIcon() {
		let view = DSButton("With Icon", icon: "gear", variant: .tertiary) {}
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - All Variants Gallery

	@Test
	func allVariantsGallery() {
		let view = VStack(spacing: SpacingToken.lg) {
			DSButton("Primary Button") {}
			DSButton("With Icon", icon: "arrow.right") {}
			DSButton("Secondary", variant: .secondary) {}
			DSButton("Secondary Icon", icon: "plus", variant: .secondary) {}
			DSButton("Tertiary", variant: .tertiary) {}
			DSButton("Tertiary Icon", icon: "gear", variant: .tertiary) {}
			DSButton("Loading", isLoading: true) {}
		}
		.padding()
		.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}
}
