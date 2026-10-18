import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultDimensions")
struct DefaultDimensionsTests {
	private let sut = DefaultDimensions()

	@Test("Dimension values are correct")
	func dimensionValues() {
		// When
		let xs = sut.xs
		let sm = sut.sm
		let md = sut.md
		let lg = sut.lg
		let xl = sut.xl
		let xxl = sut.xxl
		let xxxl = sut.xxxl
		let xxxxl = sut.xxxxl

		// Then
		#expect(xs == 8)
		#expect(sm == 12)
		#expect(md == 16)
		#expect(lg == 24)
		#expect(xl == 32)
		#expect(xxl == 48)
		#expect(xxxl == 56)
		#expect(xxxxl == 150)
	}

	@Test("Dimension values increase monotonically")
	func dimensionValuesIncrease() {
		// When
		let xs = sut.xs
		let sm = sut.sm
		let md = sut.md
		let lg = sut.lg
		let xl = sut.xl
		let xxl = sut.xxl
		let xxxl = sut.xxxl
		let xxxxl = sut.xxxxl

		// Then
		#expect(xs < sm)
		#expect(sm < md)
		#expect(md < lg)
		#expect(lg < xl)
		#expect(xl < xxl)
		#expect(xxl < xxxl)
		#expect(xxxl < xxxxl)
	}
}
