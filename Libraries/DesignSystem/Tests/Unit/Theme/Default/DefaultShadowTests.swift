import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultShadow")
struct DefaultShadowTests {
	private let sut = DefaultShadow()

	// MARK: - Zero Shadow

	@Test("Zero shadow has no visible properties")
	func zeroShadowProperties() {
		// When
		let zero = sut.zero

		// Then
		#expect(zero == DSShadowValue(color: .clear, radius: 0, x: 0, y: 0))
	}

	// MARK: - Small Shadow

	@Test("Small shadow has correct properties")
	func smallShadowProperties() {
		// When
		let small = sut.small

		// Then
		#expect(small == DSShadowValue(color: .black.opacity(0.05), radius: 8, x: 0, y: 2))
	}

	// MARK: - Medium Shadow

	@Test("Medium shadow has correct properties")
	func mediumShadowProperties() {
		// When
		let medium = sut.medium

		// Then
		#expect(medium == DSShadowValue(color: .black.opacity(0.08), radius: 12, x: 0, y: 4))
	}

	// MARK: - Large Shadow

	@Test("Large shadow has correct properties")
	func largeShadowProperties() {
		// When
		let large = sut.large

		// Then
		#expect(large == DSShadowValue(color: .black.opacity(0.12), radius: 20, x: 0, y: 8))
	}

	// MARK: - Shadow Progression

	@Test("Shadow radius increases with shadow level")
	func shadowRadiusIncreases() {
		// When
		let zeroRadius = sut.zero.radius
		let smallRadius = sut.small.radius
		let mediumRadius = sut.medium.radius
		let largeRadius = sut.large.radius

		// Then
		#expect(zeroRadius < smallRadius)
		#expect(smallRadius < mediumRadius)
		#expect(mediumRadius < largeRadius)
	}

	@Test("Shadow y offset increases with shadow level")
	func shadowYOffsetIncreases() {
		// When
		let zeroY = sut.zero.y
		let smallY = sut.small.y
		let mediumY = sut.medium.y
		let largeY = sut.large.y

		// Then
		#expect(zeroY < smallY)
		#expect(smallY < mediumY)
		#expect(mediumY < largeY)
	}

	@Test("All shadows have zero x offset")
	func allShadowsHaveZeroXOffset() {
		// When
		let zeroX = sut.zero.x
		let smallX = sut.small.x
		let mediumX = sut.medium.x
		let largeX = sut.large.x

		// Then
		#expect(zeroX == 0)
		#expect(smallX == 0)
		#expect(mediumX == 0)
		#expect(largeX == 0)
	}
}
