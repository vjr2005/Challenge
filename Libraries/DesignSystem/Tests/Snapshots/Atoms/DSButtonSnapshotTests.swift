import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSButtonSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Primary Variant

	@Test("Renders primary button with default styling")
	func primaryButton() {
		let view = DSButton("Primary Button") {}
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders primary button with trailing icon")
	func primaryButtonWithIcon() {
		let view = DSButton("With Icon", icon: "arrow.right") {}
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders primary button in loading state with spinner")
	func primaryButtonLoading() {
		let view = DSButton("Loading", isLoading: true) {}
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Secondary Variant

	@Test("Renders secondary button variant")
	func secondaryButton() {
		let view = DSButton("Secondary", variant: .secondary) {}
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders secondary button with icon")
	func secondaryButtonWithIcon() {
		let view = DSButton("With Icon", icon: "plus", variant: .secondary) {}
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Tertiary Variant

	@Test("Renders tertiary button variant")
	func tertiaryButton() {
		let view = DSButton("Tertiary", variant: .tertiary) {}
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders tertiary button with icon")
	func tertiaryButtonWithIcon() {
		let view = DSButton("With Icon", icon: "gear", variant: .tertiary) {}
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - All Variants Gallery

	@Test("Renders gallery of all button variants and states")
	func allVariantsGallery() {
		let view = VStack(spacing: DefaultSpacing().lg) {
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
