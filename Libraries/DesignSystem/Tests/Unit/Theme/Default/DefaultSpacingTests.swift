import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultSpacing")
struct DefaultSpacingTests {
	private let sut = DefaultSpacing()

	@Test("Spacing values are correct")
	func spacingValues() {
		// When
		let xxs = sut.xxs
		let xs = sut.xs
		let sm = sut.sm
		let md = sut.md
		let lg = sut.lg
		let xl = sut.xl
		let xxl = sut.xxl
		let xxxl = sut.xxxl

		// Then
		#expect(xxs == 2)
		#expect(xs == 4)
		#expect(sm == 8)
		#expect(md == 12)
		#expect(lg == 16)
		#expect(xl == 20)
		#expect(xxl == 24)
		#expect(xxxl == 32)
	}

	@Test("Spacing values increase monotonically")
	func spacingValuesIncrease() {
		// When
		let xxs = sut.xxs
		let xs = sut.xs
		let sm = sut.sm
		let md = sut.md
		let lg = sut.lg
		let xl = sut.xl
		let xxl = sut.xxl
		let xxxl = sut.xxxl

		// Then
		#expect(xxs < xs)
		#expect(xs < sm)
		#expect(sm < md)
		#expect(md < lg)
		#expect(lg < xl)
		#expect(xl < xxl)
		#expect(xxl < xxxl)
	}
}
