import ChallengeSnapshotTestKit
import SwiftUI
import Testing

@testable import ChallengeHome

struct AboutViewSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	@Test("Renders about view")
	func defaultState() {
		// Given
		let viewModel = AboutViewModelStub()

		// When
		let view = NavigationStack {
			AboutView(viewModel: viewModel)
		}

		// Then
		assertSnapshot(of: view, as: .device)
	}
}
