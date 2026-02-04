import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultCornerRadius")
struct DefaultCornerRadiusTests {
	private let sut = DefaultCornerRadius()

	@Test("Corner radius values are correct")
	func cornerRadiusValues() {
		#expect(sut.zero == 0)
		#expect(sut.xs == 4)
		#expect(sut.sm == 8)
		#expect(sut.md == 12)
		#expect(sut.lg == 16)
		#expect(sut.xl == 20)
		#expect(sut.full == 9999)
	}

	@Test("Corner radius values increase monotonically (except full)")
	func cornerRadiusValuesIncrease() {
		#expect(sut.zero < sut.xs)
		#expect(sut.xs < sut.sm)
		#expect(sut.sm < sut.md)
		#expect(sut.md < sut.lg)
		#expect(sut.lg < sut.xl)
	}
}
