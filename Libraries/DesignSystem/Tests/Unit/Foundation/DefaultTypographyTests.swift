import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultTypography")
struct DefaultTypographyTests {
	private let sut = DefaultTypography()

	@Test("largeTitle returns rounded bold")
	func largeTitle() {
		#expect(sut.largeTitle == .system(.largeTitle, design: .rounded, weight: .bold))
	}

	@Test("title returns rounded bold")
	func title() {
		#expect(sut.title == .system(.title, design: .rounded, weight: .bold))
	}

	@Test("title2 returns rounded semibold")
	func title2() {
		#expect(sut.title2 == .system(.title2, design: .rounded, weight: .semibold))
	}

	@Test("title3 returns rounded semibold")
	func title3() {
		#expect(sut.title3 == .system(.title3, design: .rounded, weight: .semibold))
	}

	@Test("headline returns rounded semibold")
	func headline() {
		#expect(sut.headline == .system(.headline, design: .rounded, weight: .semibold))
	}

	@Test("body returns rounded")
	func body() {
		#expect(sut.body == .system(.body, design: .rounded))
	}

	@Test("subheadline returns serif")
	func subheadline() {
		#expect(sut.subheadline == .system(.subheadline, design: .serif))
	}

	@Test("footnote returns rounded")
	func footnote() {
		#expect(sut.footnote == .system(.footnote, design: .rounded))
	}

	@Test("caption returns rounded")
	func caption() {
		#expect(sut.caption == .system(.caption, design: .rounded))
	}

	@Test("caption2 returns monospaced")
	func caption2() {
		#expect(sut.caption2 == .system(.caption2, design: .monospaced))
	}
}
