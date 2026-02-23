import Foundation
import UIKit

@testable import ChallengeCore

actor ImageDiskCacheMock: ImageDiskCacheContract {
	// MARK: - Configurable Returns

	private(set) var imageToReturn: UIImage?

	func setImageToReturn(_ image: UIImage?) {
		imageToReturn = image
	}

	// MARK: - Call Tracking

	private(set) var imageCallCount = 0

	private(set) var storeCallCount = 0
	private(set) var storeLastURL: URL?

	private(set) var removeCallCount = 0
	private(set) var removeLastURL: URL?

	private(set) var removeAllCallCount = 0

	// MARK: - ImageDiskCacheContract

	func image(for url: URL) -> UIImage? {
		imageCallCount += 1
		return imageToReturn
	}

	func store(_ data: Data, for url: URL) {
		storeCallCount += 1
		storeLastURL = url
	}

	func remove(for url: URL) {
		removeCallCount += 1
		removeLastURL = url
	}

	func removeAll() {
		removeAllCallCount += 1
	}
}
