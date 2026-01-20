import Testing

@testable import ChallengeDesignSystem

@Suite("SpacingToken")
struct SpacingTokenTests {
	@Test("Spacing values are correct")
	func spacingValues() {
		#expect(SpacingToken.xxs == 2)
		#expect(SpacingToken.xs == 4)
		#expect(SpacingToken.sm == 8)
		#expect(SpacingToken.md == 12)
		#expect(SpacingToken.lg == 16)
		#expect(SpacingToken.xl == 20)
		#expect(SpacingToken.xxl == 24)
		#expect(SpacingToken.xxxl == 32)
	}

	@Test("Spacing values increase monotonically")
	func spacingValuesIncrease() {
		#expect(SpacingToken.xxs < SpacingToken.xs)
		#expect(SpacingToken.xs < SpacingToken.sm)
		#expect(SpacingToken.sm < SpacingToken.md)
		#expect(SpacingToken.md < SpacingToken.lg)
		#expect(SpacingToken.lg < SpacingToken.xl)
		#expect(SpacingToken.xl < SpacingToken.xxl)
		#expect(SpacingToken.xxl < SpacingToken.xxxl)
	}
}
