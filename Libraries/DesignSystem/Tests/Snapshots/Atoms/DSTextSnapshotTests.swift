import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeDesignSystem

struct DSTextSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	// MARK: - Typography Gallery

	@Test("Renders gallery of all typography styles")
	func typographyGallery() {
		let view = VStack(alignment: .leading, spacing: SpacingToken.md) {
			DSText("Large Title", style: .largeTitle)
			DSText("Title", style: .title)
			DSText("Title 2", style: .title2)
			DSText("Title 3", style: .title3)
			DSText("Headline", style: .headline)
			DSText("Body", style: .body)
			DSText("Subheadline", style: .subheadline)
			DSText("Footnote", style: .footnote)
			DSText("Caption", style: .caption)
			DSText("Caption 2", style: .caption2)
		}
		.padding()

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Custom Colors

	@Test("Renders text with custom color tokens")
	func customColors() {
		let view = VStack(alignment: .leading, spacing: SpacingToken.md) {
			DSText("Success Color", style: .headline, color: ColorToken.statusSuccess)
			DSText("Error Color", style: .headline, color: ColorToken.statusError)
			DSText("Warning Color", style: .headline, color: ColorToken.statusWarning)
			DSText("Accent Color", style: .headline, color: ColorToken.accent)
			DSText("Secondary Color", style: .headline, color: ColorToken.textSecondary)
			DSText("Tertiary Color", style: .headline, color: ColorToken.textTertiary)
		}
		.padding()

		assertSnapshot(of: view, as: .image)
	}

	// MARK: - Individual Styles

	@Test("Renders text with large title style")
	func largeTitleStyle() {
		let view = DSText("Large Title", style: .largeTitle)
			.padding()

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders text with headline style")
	func headlineStyle() {
		let view = DSText("Headline Text", style: .headline)
			.padding()

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders text with body style supporting multiline wrapping")
	func bodyStyle() {
		let view = DSText("Body text for longer content that might wrap to multiple lines.", style: .body)
			.padding()
			.frame(width: 300)

		assertSnapshot(of: view, as: .image)
	}

	@Test("Renders text with caption style")
	func captionStyle() {
		let view = DSText("Caption text", style: .caption)
			.padding()

		assertSnapshot(of: view, as: .image)
	}
}
