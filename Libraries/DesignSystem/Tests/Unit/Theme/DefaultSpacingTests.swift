import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultSpacing")
struct DefaultSpacingTests {
	private let sut = DefaultSpacing()

	@Test("Spacing values are correct")
	func spacingValues() {
		#expect(sut.xxs == 2)
		#expect(sut.xs == 4)
		#expect(sut.sm == 8)
		#expect(sut.md == 12)
		#expect(sut.lg == 16)
		#expect(sut.xl == 20)
		#expect(sut.xxl == 24)
		#expect(sut.xxxl == 32)
	}

	@Test("Spacing values increase monotonically")
	func spacingValuesIncrease() {
		#expect(sut.xxs < sut.xs)
		#expect(sut.xs < sut.sm)
		#expect(sut.sm < sut.md)
		#expect(sut.md < sut.lg)
		#expect(sut.lg < sut.xl)
		#expect(sut.xl < sut.xxl)
		#expect(sut.xxl < sut.xxxl)
	}
}
