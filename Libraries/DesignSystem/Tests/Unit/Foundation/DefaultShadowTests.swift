import SwiftUI
import Testing

@testable import ChallengeDesignSystem

@Suite("DefaultShadow")
struct DefaultShadowTests {
	private let sut = DefaultShadow()

	// MARK: - Zero Shadow

	@Test("Zero shadow has no visible properties")
	func zeroShadowProperties() {
		#expect(sut.zero == DSShadowValue(color: .clear, radius: 0, x: 0, y: 0))
	}

	// MARK: - Small Shadow

	@Test("Small shadow has correct properties")
	func smallShadowProperties() {
		#expect(sut.small == DSShadowValue(color: .black.opacity(0.05), radius: 8, x: 0, y: 2))
	}

	// MARK: - Medium Shadow

	@Test("Medium shadow has correct properties")
	func mediumShadowProperties() {
		#expect(sut.medium == DSShadowValue(color: .black.opacity(0.08), radius: 12, x: 0, y: 4))
	}

	// MARK: - Large Shadow

	@Test("Large shadow has correct properties")
	func largeShadowProperties() {
		#expect(sut.large == DSShadowValue(color: .black.opacity(0.12), radius: 20, x: 0, y: 8))
	}

	// MARK: - Shadow Progression

	@Test("Shadow radius increases with shadow level")
	func shadowRadiusIncreases() {
		#expect(sut.zero.radius < sut.small.radius)
		#expect(sut.small.radius < sut.medium.radius)
		#expect(sut.medium.radius < sut.large.radius)
	}

	@Test("Shadow y offset increases with shadow level")
	func shadowYOffsetIncreases() {
		#expect(sut.zero.y < sut.small.y)
		#expect(sut.small.y < sut.medium.y)
		#expect(sut.medium.y < sut.large.y)
	}

	@Test("All shadows have zero x offset")
	func allShadowsHaveZeroXOffset() {
		#expect(sut.zero.x == 0)
		#expect(sut.small.x == 0)
		#expect(sut.medium.x == 0)
		#expect(sut.large.x == 0)
	}
}
