import Testing

@testable import ChallengeDesignSystem

@Suite("OpacityToken")
struct OpacityTokenTests {
	@Test("Opacity values are correct")
	func opacityValues() {
		#expect(OpacityToken.subtle == 0.1)
		#expect(OpacityToken.light == 0.15)
		#expect(OpacityToken.medium == 0.4)
		#expect(OpacityToken.heavy == 0.6)
		#expect(OpacityToken.almostOpaque == 0.8)
	}

	@Test("Opacity values increase monotonically")
	func opacityValuesIncrease() {
		#expect(OpacityToken.subtle < OpacityToken.light)
		#expect(OpacityToken.light < OpacityToken.medium)
		#expect(OpacityToken.medium < OpacityToken.heavy)
		#expect(OpacityToken.heavy < OpacityToken.almostOpaque)
	}

	@Test("Opacity values are within valid range")
	func opacityValuesAreValid() {
		#expect(OpacityToken.subtle >= 0 && OpacityToken.subtle <= 1)
		#expect(OpacityToken.light >= 0 && OpacityToken.light <= 1)
		#expect(OpacityToken.medium >= 0 && OpacityToken.medium <= 1)
		#expect(OpacityToken.heavy >= 0 && OpacityToken.heavy <= 1)
		#expect(OpacityToken.almostOpaque >= 0 && OpacityToken.almostOpaque <= 1)
	}
}
