import SnapshotTesting
import SwiftUI
import Testing

@testable import ChallengeHome

struct HomeViewSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	@Test
	func defaultState() {
		// Given
		let viewModel = HomeViewModelStub()

		// When
		let view = HomeView(viewModel: viewModel)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}
}
