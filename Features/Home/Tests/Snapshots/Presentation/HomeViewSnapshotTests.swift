import Lottie
import SnapshotTesting
import SwiftUI
import Testing
import UIKit

@testable import ChallengeHome

struct HomeViewSnapshotTests {
	init() {
		UIView.setAnimationsEnabled(false)
	}

	@Test
	@MainActor
	func beforeAnimation() {
		// Given
		let viewModel = HomeViewModelStub()
		let view = HomeView(
			viewModel: viewModel,
			playbackMode: .paused(at: .progress(0)),
			showButton: false
		)

		// When
		let hostingController = UIHostingController(rootView: view)
		hostingController.view.frame = CGRect(
			origin: .zero,
			size: ViewImageConfig.iPhone13ProMax.size!
		)
		hostingController.view.layoutIfNeeded()

		// Then
		assertSnapshot(
			of: hostingController.view,
			as: .imageOfPresentationLayer()
		)
	}

	@Test
	@MainActor
	func afterAnimation() {
		// Given
		let viewModel = HomeViewModelStub()
		let view = HomeView(
			viewModel: viewModel,
			playbackMode: .paused(at: .progress(1)),
			showButton: true
		)

		// When
		let hostingController = UIHostingController(rootView: view)
		hostingController.view.frame = CGRect(
			origin: .zero,
			size: ViewImageConfig.iPhone13ProMax.size!
		)
		hostingController.view.layoutIfNeeded()

		// Then
		assertSnapshot(
			of: hostingController.view,
			as: .imageOfPresentationLayer()
		)
	}
}
