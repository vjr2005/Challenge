import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSChipGroupSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - No Selection

	@Test("Renders chip group with no selection")
	func noSelection() {
		let view = DSChipGroup(
			"Status",
			options: [
				(id: "alive", label: "Alive"),
				(id: "dead", label: "Dead"),
				(id: "unknown", label: "Unknown")
			],
			selectedID: nil as String?
		) { _ in }
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - With Selection

	@Test("Renders chip group with one chip selected")
	func withSelection() {
		let view = DSChipGroup(
			"Status",
			options: [
				(id: "alive", label: "Alive"),
				(id: "dead", label: "Dead"),
				(id: "unknown", label: "Unknown")
			],
			selectedID: "alive"
		) { _ in }
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Gallery

	@Test("Renders gallery of chip groups in different states")
	func chipGroupGallery() {
		let view = VStack(spacing: DefaultSpacing().lg) {
			DSChipGroup(
				"Status",
				options: [
					(id: "alive", label: "Alive"),
					(id: "dead", label: "Dead"),
					(id: "unknown", label: "Unknown")
				],
				selectedID: "dead"
			) { _ in }

			DSChipGroup(
				"Gender",
				options: [
					(id: "female", label: "Female"),
					(id: "male", label: "Male"),
					(id: "genderless", label: "Genderless"),
					(id: "unknown", label: "Unknown")
				],
				selectedID: nil as String?
			) { _ in }
		}
		.padding()
		.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}
}
