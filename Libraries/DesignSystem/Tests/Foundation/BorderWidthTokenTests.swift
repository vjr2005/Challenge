import Testing

@testable import ChallengeDesignSystem

@Suite("BorderWidthToken")
struct BorderWidthTokenTests {
	@Test("Border width values are correct")
	func borderWidthValues() {
		#expect(BorderWidthToken.hairline == 0.5)
		#expect(BorderWidthToken.thin == 1)
		#expect(BorderWidthToken.medium == 2)
		#expect(BorderWidthToken.thick == 4)
	}

	@Test("Border width values increase monotonically")
	func borderWidthValuesIncrease() {
		#expect(BorderWidthToken.hairline < BorderWidthToken.thin)
		#expect(BorderWidthToken.thin < BorderWidthToken.medium)
		#expect(BorderWidthToken.medium < BorderWidthToken.thick)
	}
}
