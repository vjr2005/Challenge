import SwiftUI
import Testing

@testable import ChallengeCore

@Suite(.timeLimit(.minutes(1)))
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

	@Test("Executes action on first appear")
	func executesActionOnFirstAppear() async {
		// Given
		var isFirstAppearCalled = false
		let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

		// When
		await withCheckedContinuation { continuation in
			let view = Text("Test").onFirstAppear {
				isFirstAppearCalled = true
				continuation.resume()
			}
			window.rootViewController = UIHostingController(rootView: view)
			window.makeKeyAndVisible()
		}

		// Then
		#expect(isFirstAppearCalled)
	}
}
