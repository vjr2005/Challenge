import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultDimensions")
struct DefaultDimensionsTests {
	private let sut = DefaultDimensions()

	@Test("Dimension values are correct")
	func dimensionValues() {
		#expect(sut.xs == 8)
		#expect(sut.sm == 12)
		#expect(sut.md == 16)
		#expect(sut.lg == 24)
		#expect(sut.xl == 32)
		#expect(sut.xxl == 48)
		#expect(sut.xxxl == 56)
		#expect(sut.xxxxl == 150)
	}

	@Test("Dimension values increase monotonically")
	func dimensionValuesIncrease() {
		#expect(sut.xs < sut.sm)
		#expect(sut.sm < sut.md)
		#expect(sut.md < sut.lg)
		#expect(sut.lg < sut.xl)
		#expect(sut.xl < sut.xxl)
		#expect(sut.xxl < sut.xxxl)
		#expect(sut.xxxl < sut.xxxxl)
	}
}
