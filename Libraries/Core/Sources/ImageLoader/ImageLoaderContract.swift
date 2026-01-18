import UIKit

/// Contract for loading images.
public protocol ImageLoaderContract: Sendable {
	/// Returns immediately available image (from cache or mock).
	/// - Parameter url: The URL of the image.
	/// - Returns: The image if immediately available, nil otherwise.
	func cachedImage(for url: URL) -> UIImage?

	/// Loads an image from the given URL asynchronously.
	/// - Parameter url: The URL to load the image from.
	/// - Returns: The loaded image, or nil if loading failed.
	func image(for url: URL) async -> UIImage?
}
