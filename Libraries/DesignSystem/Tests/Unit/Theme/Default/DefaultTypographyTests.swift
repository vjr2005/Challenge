import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultTypography")
struct DefaultTypographyTests {
	private let sut = DefaultTypography()

	@Test("largeTitle returns rounded bold")
	func largeTitle() {
		// When
		let largeTitle = sut.largeTitle

		// Then
		#expect(largeTitle == .system(.largeTitle, design: .rounded, weight: .bold))
	}

	@Test("title returns rounded bold")
	func title() {
		// When
		let title = sut.title

		// Then
		#expect(title == .system(.title, design: .rounded, weight: .bold))
	}

	@Test("title2 returns rounded semibold")
	func title2() {
		// When
		let title2 = sut.title2

		// Then
		#expect(title2 == .system(.title2, design: .rounded, weight: .semibold))
	}

	@Test("title3 returns rounded semibold")
	func title3() {
		// When
		let title3 = sut.title3

		// Then
		#expect(title3 == .system(.title3, design: .rounded, weight: .semibold))
	}

	@Test("headline returns rounded semibold")
	func headline() {
		// When
		let headline = sut.headline

		// Then
		#expect(headline == .system(.headline, design: .rounded, weight: .semibold))
	}

	@Test("body returns rounded")
	func body() {
		// When
		let body = sut.body

		// Then
		#expect(body == .system(.body, design: .rounded))
	}

	@Test("subheadline returns serif")
	func subheadline() {
		// When
		let subheadline = sut.subheadline

		// Then
		#expect(subheadline == .system(.subheadline, design: .serif))
	}

	@Test("footnote returns rounded")
	func footnote() {
		// When
		let footnote = sut.footnote

		// Then
		#expect(footnote == .system(.footnote, design: .rounded))
	}

	@Test("caption returns rounded")
	func caption() {
		// When
		let caption = sut.caption

		// Then
		#expect(caption == .system(.caption, design: .rounded))
	}

	@Test("caption2 returns monospaced")
	func caption2() {
		// When
		let caption2 = sut.caption2

		// Then
		#expect(caption2 == .system(.caption2, design: .monospaced))
	}
}
