import Foundation
import Testing

@testable import ChallengeDesignSystem

@Suite("DSAvatarSize")
struct DSAvatarSizeTests {
	// MARK: - Dimension Values

	@Test("Small size has correct dimension")
	func smallSizeDimension() {
		#expect(DSAvatarSize.small.dimension == 32)
	}

	@Test("Medium size has correct dimension")
	func mediumSizeDimension() {
		#expect(DSAvatarSize.medium.dimension == 48)
	}

	@Test("Large size has correct dimension")
	func largeSizeDimension() {
		#expect(DSAvatarSize.large.dimension == 64)
	}

	@Test("Extra large size has correct dimension")
	func extraLargeSizeDimension() {
		#expect(DSAvatarSize.extraLarge.dimension == 80)
	}

	@Test("Custom size returns provided value")
	func customSizeDimension() {
		// Given
		let customValue: CGFloat = 100

		// When
		let size = DSAvatarSize.custom(customValue)

		// Then
		#expect(size.dimension == customValue)
	}

	// MARK: - Size Progression

	@Test("Sizes increase monotonically")
	func sizesIncreaseMonotonically() {
		#expect(DSAvatarSize.small.dimension < DSAvatarSize.medium.dimension)
		#expect(DSAvatarSize.medium.dimension < DSAvatarSize.large.dimension)
		#expect(DSAvatarSize.large.dimension < DSAvatarSize.extraLarge.dimension)
	}

	// MARK: - Custom Size Edge Cases

	@Test("Custom size with zero value")
	func customSizeZero() {
		let size = DSAvatarSize.custom(0)
		#expect(size.dimension == 0)
	}

	@Test("Custom size with large value")
	func customSizeLarge() {
		let size = DSAvatarSize.custom(200)
		#expect(size.dimension == 200)
	}
}
