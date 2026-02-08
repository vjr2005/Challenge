import UIKit

/// Image loader with in-memory caching and deduplication of in-flight requests.
public final class CachedImageLoader: ImageLoaderContract {
	private let cache: ImageCache
	private let requestCoordinator: ImageRequestCoordinator
	private let session: URLSession

	/// Creates a new cached image loader.
	/// - Parameter session: The URL session to use for network requests.
	public init(session: URLSession = .shared) {
		self.session = session
		self.cache = ImageCache()
		self.requestCoordinator = ImageRequestCoordinator()
	}

	/// Returns the cached image for the given URL, or `nil` if not cached.
	public func cachedImage(for url: URL) -> UIImage? {
		cache.image(for: url)
	}

	/// Returns the image for the given URL, loading from the network if not cached.
	public func image(for url: URL) async -> UIImage? {
		if let cached = cache.image(for: url) {
			return cached
		}

		let image = await requestCoordinator.loadImage(for: url, session: session)

		if let image {
			cache.setImage(image, for: url)
		}

		return image
	}
}

private final class ImageCache {
	private let storage = NSCache<NSURL, UIImage>()

	func image(for url: URL) -> UIImage? {
		storage.object(forKey: url as NSURL)
	}

	func setImage(_ image: UIImage, for url: URL) {
		storage.setObject(image, forKey: url as NSURL)
	}
}

private actor ImageRequestCoordinator {
	private var inFlightRequests: [URL: Task<UIImage?, Never>] = [:]

	func loadImage(for url: URL, session: URLSession) async -> UIImage? {
		if let existingTask = inFlightRequests[url] {
			return await existingTask.value
		}

		let task = Task<UIImage?, Never> {
			await Self.downloadImage(from: url, session: session)
		}

		inFlightRequests[url] = task
		let image = await task.value
		inFlightRequests[url] = nil

		return image
	}

	private static func downloadImage(from url: URL, session: URLSession) async -> UIImage? {
		guard let (data, response) = try? await session.data(from: url) else {
			return nil
		}
		guard let httpResponse = response as? HTTPURLResponse,
			  (200...299).contains(httpResponse.statusCode) else {
			return nil
		}
		return UIImage(data: data)
	}
}
