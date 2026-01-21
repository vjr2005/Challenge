import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSInfoRowSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Individual Rows

	@Test
	func defaultInfoRow() {
		let view = DSInfoRow(icon: "person.fill", label: "Name", value: "Rick Sanchez")
			.padding()
			.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	@Test
	func infoRowWithCustomIconColor() {
		let view = DSInfoRow(
			icon: "heart.fill",
			label: "Status",
			value: "Alive",
			iconColor: ColorToken.statusSuccess
		)
		.padding()
		.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Gallery

	@Test
	func infoRowGallery() {
		let view = VStack(spacing: SpacingToken.md) {
			DSInfoRow(icon: "person.fill", label: "Name", value: "Rick Sanchez")
			DSInfoRow(icon: "location.fill", label: "Location", value: "Citadel of Ricks")
			DSInfoRow(icon: "globe", label: "Origin", value: "Earth (C-137)")
			DSInfoRow(
				icon: "heart.fill",
				label: "Status",
				value: "Alive",
				iconColor: ColorToken.statusSuccess
			)
			DSInfoRow(
				icon: "exclamationmark.triangle.fill",
				label: "Warning",
				value: "Dangerous",
				iconColor: ColorToken.statusWarning
			)
		}
		.padding()
		.frame(width: 320)

		assertSnapshot(of: view, as: .image)
	}
}
