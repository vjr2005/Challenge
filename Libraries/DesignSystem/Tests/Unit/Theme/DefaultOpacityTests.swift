import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultOpacity")
struct DefaultOpacityTests {
	private let sut = DefaultOpacity()

	@Test("Opacity values are correct")
	func opacityValues() {
		#expect(sut.subtle == 0.1)
		#expect(sut.light == 0.15)
		#expect(sut.medium == 0.4)
		#expect(sut.heavy == 0.6)
		#expect(sut.almostOpaque == 0.8)
	}

	@Test("Opacity values increase monotonically")
	func opacityValuesIncrease() {
		#expect(sut.subtle < sut.light)
		#expect(sut.light < sut.medium)
		#expect(sut.medium < sut.heavy)
		#expect(sut.heavy < sut.almostOpaque)
	}

	@Test("Opacity values are within valid range")
	func opacityValuesAreValid() {
		#expect(sut.subtle >= 0 && sut.subtle <= 1)
		#expect(sut.light >= 0 && sut.light <= 1)
		#expect(sut.medium >= 0 && sut.medium <= 1)
		#expect(sut.heavy >= 0 && sut.heavy <= 1)
		#expect(sut.almostOpaque >= 0 && sut.almostOpaque <= 1)
	}
}
