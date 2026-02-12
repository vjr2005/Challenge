import ChallengeCore
import UIKit

/// Mock image loader for testing.
public final class ImageLoaderMock: ImageLoaderContract, @unchecked Sendable {
	private let cachedImageResult: UIImage?
	private let asyncImageResult: UIImage?
	private let onImageLoaded: (@Sendable () -> Void)?
	public private(set) var removeImageCallCount = 0
	public private(set) var removeImageLastURL: URL?
	public private(set) var clearCacheCallCount = 0

	/// Creates a mock image loader with different results for cached and async loading.
	/// - Parameters:
	///   - cachedImage: The image to return for cached requests.
	///   - asyncImage: The image to return for async requests.
	///   - onImageLoaded: Callback invoked when async image loading completes.
	public init(cachedImage: UIImage?, asyncImage: UIImage?, onImageLoaded: (@Sendable () -> Void)? = nil) {
		self.cachedImageResult = cachedImage
		self.asyncImageResult = asyncImage
		self.onImageLoaded = onImageLoaded
	}

	public func cachedImage(for url: URL) -> UIImage? {
		cachedImageResult
	}

	public func image(for url: URL) async -> UIImage? {
		let result = asyncImageResult
		onImageLoaded?()
		return result
	}

	public func removeImage(for url: URL) async {
		removeImageCallCount += 1
		removeImageLastURL = url
	}

	public func clearCache() async {
		clearCacheCallCount += 1
	}
}
