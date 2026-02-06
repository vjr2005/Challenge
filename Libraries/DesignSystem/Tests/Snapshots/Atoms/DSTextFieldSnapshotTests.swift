import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSTextFieldSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Empty State

	@Test("Renders text field with placeholder")
	func emptyWithPlaceholder() {
		let view = DSTextField(
			placeholder: "e.g. Human, Alien...",
			text: .constant("")
		)
		.padding()
		.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - With Text

	@Test("Renders text field with entered text")
	func withText() {
		let view = DSTextField(
			placeholder: "e.g. Human, Alien...",
			text: .constant("Human")
		)
		.padding()
		.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Gallery

	@Test("Renders gallery of text fields in different states")
	func textFieldGallery() {
		let view = VStack(spacing: DefaultSpacing().md) {
			DSTextField(
				placeholder: "e.g. Human, Alien...",
				text: .constant("")
			)
			DSTextField(
				placeholder: "e.g. Parasite, Robot...",
				text: .constant("Parasite")
			)
		}
		.padding()
		.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}
}
