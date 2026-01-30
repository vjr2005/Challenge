import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite("ShadowToken")
struct ShadowTokenTests {
	// MARK: - Zero Shadow

	@Test("Zero shadow has no visible properties")
	func zeroShadowProperties() {
		// Given
		let shadow = ShadowToken.zero

		// Then
		#expect(shadow.color == .clear)
		#expect(shadow.radius == 0)
		#expect(shadow.x == 0)
		#expect(shadow.y == 0)
	}

	// MARK: - Small Shadow

	@Test("Small shadow has correct properties")
	func smallShadowProperties() {
		// Given
		let shadow = ShadowToken.small

		// Then
		#expect(shadow.color == .black.opacity(0.05))
		#expect(shadow.radius == 8)
		#expect(shadow.x == 0)
		#expect(shadow.y == 2)
	}

	// MARK: - Medium Shadow

	@Test("Medium shadow has correct properties")
	func mediumShadowProperties() {
		// Given
		let shadow = ShadowToken.medium

		// Then
		#expect(shadow.color == .black.opacity(0.08))
		#expect(shadow.radius == 12)
		#expect(shadow.x == 0)
		#expect(shadow.y == 4)
	}

	// MARK: - Large Shadow

	@Test("Large shadow has correct properties")
	func largeShadowProperties() {
		// Given
		let shadow = ShadowToken.large

		// Then
		#expect(shadow.color == .black.opacity(0.12))
		#expect(shadow.radius == 20)
		#expect(shadow.x == 0)
		#expect(shadow.y == 8)
	}

	// MARK: - Shadow Progression

	@Test("Shadow radius increases with shadow level")
	func shadowRadiusIncreases() {
		#expect(ShadowToken.zero.radius < ShadowToken.small.radius)
		#expect(ShadowToken.small.radius < ShadowToken.medium.radius)
		#expect(ShadowToken.medium.radius < ShadowToken.large.radius)
	}

	@Test("Shadow y offset increases with shadow level")
	func shadowYOffsetIncreases() {
		#expect(ShadowToken.zero.y < ShadowToken.small.y)
		#expect(ShadowToken.small.y < ShadowToken.medium.y)
		#expect(ShadowToken.medium.y < ShadowToken.large.y)
	}

	@Test("All shadows have zero x offset")
	func allShadowsHaveZeroXOffset() {
		#expect(ShadowToken.zero.x == 0)
		#expect(ShadowToken.small.x == 0)
		#expect(ShadowToken.medium.x == 0)
		#expect(ShadowToken.large.x == 0)
	}
}
