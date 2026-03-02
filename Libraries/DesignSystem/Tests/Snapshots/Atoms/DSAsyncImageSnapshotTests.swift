import ChallengeCoreMocks
import ChallengeSnapshotTestKit
import SwiftUI
import Testing
import UIKit

@testable import ChallengeDesignSystem

struct DSAsyncImageSnapshotTests {
	private let emptyImageLoader: ImageLoaderMock
	private let loadedImageLoader: ImageLoaderMock

    private let testURL = URL(string: "https://example.com/test-image.jpg")

	init() {
		UIView.setAnimationsEnabled(false)
		emptyImageLoader = ImageLoaderMock(cachedImage: nil, asyncImage: nil)
		loadedImageLoader = ImageLoaderMock(cachedImage: .stub, asyncImage: .stub)
	}

	// MARK: - Default Content Initializer

	@Test("Renders async image with cached image content")
	func defaultContentWithLoadedImage() async {
		let controller = makeHostedView(imageLoader: loadedImageLoader) {
			DSAsyncImage(url: testURL)
		}

		assertSnapshot(of: controller, as: .image)
	}

	@Test("Renders async image placeholder when URL is nil")
	func defaultContentWithNilURL() async {
		let controller = makeHostedView(imageLoader: emptyImageLoader) {
			DSAsyncImage(url: nil)
		}

		assertSnapshot(of: controller, as: .image)
	}

	@Test("Renders async image after asynchronous load completes")
	func defaultContentWithAsyncLoadedImage() async {
		let signal = LoadSignal()
		let imageLoader = ImageLoaderMock(cachedImage: nil, asyncImage: .stub) {
			Task { await signal.complete() }
		}

		let controller = makeHostedView(imageLoader: imageLoader) {
			DSAsyncImage(url: testURL)
		}

		await signal.wait()

		assertSnapshot(of: controller, as: .image)
	}

	@Test("Renders async image placeholder when load fails")
	func defaultContentWithFailedImage() async {
		let signal = LoadSignal()
		let imageLoader = ImageLoaderMock(cachedImage: nil, asyncImage: nil) {
			Task { await signal.complete() }
		}

		let controller = makeHostedView(imageLoader: imageLoader) {
			DSAsyncImage(url: testURL)
		}

		await signal.wait()

		assertSnapshot(of: controller, as: .image)
	}

	// MARK: - ViewBuilder Content Initializer

	@Test("Renders custom content builder with nil URL showing progress")
	func customContentWithNilURL() async {
		let controller = makeHostedView(imageLoader: emptyImageLoader) {
			DSAsyncImage(url: nil) { phase in
				switch phase {
				case .success(let image):
					image.resizable().scaledToFill()
				case .empty:
					ProgressView()
				case .failure:
					errorView
				@unknown default:
					ProgressView()
				}
			}
		}

		assertSnapshot(of: controller, as: .image)
	}

	@Test("Renders custom content builder with loaded image")
	func customContentWithLoadedImage() async {
		let controller = makeHostedView(imageLoader: loadedImageLoader) {
			DSAsyncImage(url: testURL) { phase in
				switch phase {
				case .success(let image):
					image.resizable().scaledToFill()
				case .empty:
					ProgressView()
				case .failure:
					errorView
				@unknown default:
					ProgressView()
				}
			}
		}

		assertSnapshot(of: controller, as: .image)
	}
}

// MARK: - Test Helpers

private extension DSAsyncImageSnapshotTests {
	/// Hosts a SwiftUI view in a window to trigger the view lifecycle.
	/// This is necessary because SwiftUI's `.task` modifier only executes
	/// when the view appears in a real view hierarchy.
	func makeHostedView<Content: View>(
		imageLoader: ImageLoaderMock,
		@ViewBuilder content: () -> Content
	) -> UIHostingController<some View> {
		let view = content().imageLoader(imageLoader)
		let controller = UIHostingController(rootView: view)
		controller.view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
		let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		window.rootViewController = controller
		window.makeKeyAndVisible()
		return controller
	}

	var errorView: some View {
		ZStack {
			DefaultColorPalette().surfaceSecondary
			Image(systemName: "photo")
				.font(.title)
				.foregroundStyle(DefaultColorPalette().textTertiary)
		}
	}
}

// MARK: - Load Signal

private actor LoadSignal {
	private var continuation: CheckedContinuation<Void, Never>?
	private var isCompleted = false

	func wait() async {
		if isCompleted {
			return
		}
		await withCheckedContinuation { continuation in
			if isCompleted {
				continuation.resume()
				return
			}
			self.continuation = continuation
		}
	}

	func complete() {
		isCompleted = true
		continuation?.resume()
		continuation = nil
	}
}
