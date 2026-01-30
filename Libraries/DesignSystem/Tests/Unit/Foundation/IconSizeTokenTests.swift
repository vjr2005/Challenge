import Testing

@testable import ChallengeDesignSystem

@Suite("IconSizeToken")
struct IconSizeTokenTests {
	@Test("Icon size values are correct")
	func iconSizeValues() {
		#expect(IconSizeToken.xs == 8)
		#expect(IconSizeToken.sm == 12)
		#expect(IconSizeToken.md == 16)
		#expect(IconSizeToken.lg == 24)
		#expect(IconSizeToken.xl == 32)
		#expect(IconSizeToken.xxl == 48)
		#expect(IconSizeToken.xxxl == 56)
	}

	@Test("Icon size values increase monotonically")
	func iconSizeValuesIncrease() {
		#expect(IconSizeToken.xs < IconSizeToken.sm)
		#expect(IconSizeToken.sm < IconSizeToken.md)
		#expect(IconSizeToken.md < IconSizeToken.lg)
		#expect(IconSizeToken.lg < IconSizeToken.xl)
		#expect(IconSizeToken.xl < IconSizeToken.xxl)
		#expect(IconSizeToken.xxl < IconSizeToken.xxxl)
	}
}
