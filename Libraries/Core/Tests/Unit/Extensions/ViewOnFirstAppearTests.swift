import SwiftUI
import Testing

@testable import ChallengeCore

struct ViewOnFirstAppearTests {
	@Test("onFirstAppear modifier returns a modified view")
	func onFirstAppearReturnsModifiedView() {
		// Given
		let baseView = Text("Test")

		// When
		let modifiedView = baseView.onFirstAppear {}

		// Then
		#expect(type(of: modifiedView) != type(of: baseView))
	}
}
