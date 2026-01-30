import Testing

@testable import ChallengeDesignSystem

@Suite("CornerRadiusToken")
struct CornerRadiusTokenTests {
	@Test("Corner radius values are correct")
	func cornerRadiusValues() {
		#expect(CornerRadiusToken.zero == 0)
		#expect(CornerRadiusToken.xs == 4)
		#expect(CornerRadiusToken.sm == 8)
		#expect(CornerRadiusToken.md == 12)
		#expect(CornerRadiusToken.lg == 16)
		#expect(CornerRadiusToken.xl == 20)
		#expect(CornerRadiusToken.full == 9999)
	}

	@Test("Corner radius values increase monotonically (except full)")
	func cornerRadiusValuesIncrease() {
		#expect(CornerRadiusToken.zero < CornerRadiusToken.xs)
		#expect(CornerRadiusToken.xs < CornerRadiusToken.sm)
		#expect(CornerRadiusToken.sm < CornerRadiusToken.md)
		#expect(CornerRadiusToken.md < CornerRadiusToken.lg)
		#expect(CornerRadiusToken.lg < CornerRadiusToken.xl)
	}
}
