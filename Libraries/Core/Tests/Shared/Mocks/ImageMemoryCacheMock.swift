import UIKit

@testable import ChallengeCore

final class ImageMemoryCacheMock: ImageMemoryCacheContract {
	// MARK: - Call Tracking

	private(set) var imageCallCount = 0
	private(set) var setImageCallCount = 0
	private(set) var removeCachedImageCallCount = 0
	private(set) var removeAllCallCount = 0

	// MARK: - Storage

	private var images: [URL: UIImage] = [:]

	// MARK: - ImageMemoryCacheContract

	func image(for url: URL) -> UIImage? {
		imageCallCount += 1
		return images[url]
	}

	func setImage(_ image: UIImage, for url: URL) {
		setImageCallCount += 1
		images[url] = image
	}

	func removeCachedImage(for url: URL) {
		removeCachedImageCallCount += 1
		images[url] = nil
	}

	func removeAll() {
		removeAllCallCount += 1
		images.removeAll()
	}
}
