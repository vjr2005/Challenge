import Testing

@testable import ChallengeDesignSystem

@Suite("DSButtonVariant")
struct DSButtonVariantTests {
	// MARK: - Variant Cases

	@Test("Primary variant exists")
	func primaryVariantExists() {
		let variant = DSButtonVariant.primary
		#expect(variant == .primary)
	}

	@Test("Secondary variant exists")
	func secondaryVariantExists() {
		let variant = DSButtonVariant.secondary
		#expect(variant == .secondary)
	}

	@Test("Tertiary variant exists")
	func tertiaryVariantExists() {
		let variant = DSButtonVariant.tertiary
		#expect(variant == .tertiary)
	}

	// MARK: - Equatable

	@Test("Different variants are not equal")
	func differentVariantsNotEqual() {
		#expect(DSButtonVariant.primary != DSButtonVariant.secondary)
		#expect(DSButtonVariant.secondary != DSButtonVariant.tertiary)
		#expect(DSButtonVariant.primary != DSButtonVariant.tertiary)
	}
}
