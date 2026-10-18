import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultOpacity")
struct DefaultOpacityTests {
	private let sut = DefaultOpacity()

	@Test("Opacity values are correct")
	func opacityValues() {
		// When
		let subtle = sut.subtle
		let light = sut.light
		let medium = sut.medium
		let heavy = sut.heavy
		let almostOpaque = sut.almostOpaque

		// Then
		#expect(subtle == 0.1)
		#expect(light == 0.15)
		#expect(medium == 0.4)
		#expect(heavy == 0.6)
		#expect(almostOpaque == 0.8)
	}

	@Test("Opacity values increase monotonically")
	func opacityValuesIncrease() {
		// When
		let subtle = sut.subtle
		let light = sut.light
		let medium = sut.medium
		let heavy = sut.heavy
		let almostOpaque = sut.almostOpaque

		// Then
		#expect(subtle < light)
		#expect(light < medium)
		#expect(medium < heavy)
		#expect(heavy < almostOpaque)
	}

	@Test("Opacity values are within valid range")
	func opacityValuesAreValid() {
		// When
		let values = [sut.subtle, sut.light, sut.medium, sut.heavy, sut.almostOpaque]

		// Then
		#expect(values.allSatisfy { $0 >= 0 && $0 <= 1 })
	}
}
