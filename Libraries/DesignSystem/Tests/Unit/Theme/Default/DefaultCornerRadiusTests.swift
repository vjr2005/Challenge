import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultCornerRadius")
struct DefaultCornerRadiusTests {
	private let sut = DefaultCornerRadius()

	@Test("Corner radius values are correct")
	func cornerRadiusValues() {
		// When
		let zero = sut.zero
		let xs = sut.xs
		let sm = sut.sm
		let md = sut.md
		let lg = sut.lg
		let xl = sut.xl
		let full = sut.full

		// Then
		#expect(zero == 0)
		#expect(xs == 4)
		#expect(sm == 8)
		#expect(md == 12)
		#expect(lg == 16)
		#expect(xl == 20)
		#expect(full == 9999)
	}

	@Test("Corner radius values increase monotonically (except full)")
	func cornerRadiusValuesIncrease() {
		// When
		let zero = sut.zero
		let xs = sut.xs
		let sm = sut.sm
		let md = sut.md
		let lg = sut.lg
		let xl = sut.xl

		// Then
		#expect(zero < xs)
		#expect(xs < sm)
		#expect(sm < md)
		#expect(md < lg)
		#expect(lg < xl)
	}
}
