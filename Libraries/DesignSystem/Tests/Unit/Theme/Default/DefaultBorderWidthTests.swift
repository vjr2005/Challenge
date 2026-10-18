import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultBorderWidth")
struct DefaultBorderWidthTests {
	private let sut = DefaultBorderWidth()

	@Test("Border width values are correct")
	func borderWidthValues() {
		// When
		let hairline = sut.hairline
		let thin = sut.thin
		let medium = sut.medium
		let thick = sut.thick

		// Then
		#expect(hairline == 0.5)
		#expect(thin == 1)
		#expect(medium == 2)
		#expect(thick == 4)
	}

	@Test("Border width values increase monotonically")
	func borderWidthValuesIncrease() {
		// When
		let hairline = sut.hairline
		let thin = sut.thin
		let medium = sut.medium
		let thick = sut.thick

		// Then
		#expect(hairline < thin)
		#expect(thin < medium)
		#expect(medium < thick)
	}
}
