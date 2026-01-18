import ChallengeCore
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
		let viewModel = HomeViewModel(router: RouterStub())

		// When
		let view = HomeView(viewModel: viewModel)

		// Then
		assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
	}
}

// MARK: - Test Helpers

private final class RouterStub: RouterContract {
	func navigate(to destination: any Navigation) {}
	func goBack() {}
}
