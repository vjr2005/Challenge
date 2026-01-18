import ChallengeCore
import UIKit

/// Mock image loader for testing.
public final class ImageLoaderMock: ImageLoaderContract, @unchecked Sendable {
	private let image: UIImage?

	/// Creates a mock image loader.
	/// - Parameter image: The image to return for all requests.
	public init(image: UIImage?) {
		self.image = image
	}

	public func cachedImage(for url: URL) -> UIImage? {
		image
	}

	public func image(for url: URL) async -> UIImage? {
		image
	}
}
