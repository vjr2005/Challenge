import Lottie
import ChallengeSnapshotTestKit
import SwiftUI
import Testing

@testable import ChallengeHome

struct HomeViewSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	@Test("Renders home view before animation starts")
	func beforeAnimation() {
		// Given
		let viewModel = HomeViewModelStub()

		// When
        let view = NavigationStack {
            HomeView(
                viewModel: viewModel,
                playbackMode: .paused(at: .progress(0)),
                showButton: false
            )
        }

		// Then
		assertSnapshot(of: view, as: .presentationLayer)
	}

	@Test("Renders home view after animation completes with button visible")
	func afterAnimation() {
		// Given
		let viewModel = HomeViewModelStub()

		// When
        let view = NavigationStack {
            HomeView(
                viewModel: viewModel,
                playbackMode: .paused(at: .progress(1)),
                showButton: true
            )
        }

		// Then
		assertSnapshot(of: view, as: .presentationLayer)
	}
}
