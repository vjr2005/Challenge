import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultBorderWidth")
struct DefaultBorderWidthTests {
	private let sut = DefaultBorderWidth()

	@Test("Border width values are correct")
	func borderWidthValues() {
		#expect(sut.hairline == 0.5)
		#expect(sut.thin == 1)
		#expect(sut.medium == 2)
		#expect(sut.thick == 4)
	}

	@Test("Border width values increase monotonically")
	func borderWidthValuesIncrease() {
		#expect(sut.hairline < sut.thin)
		#expect(sut.thin < sut.medium)
		#expect(sut.medium < sut.thick)
	}
}
