import ChallengeNetworking
import UIKit

/// Image loader with in-memory caching and deduplication of in-flight requests.
public final class CachedImageLoader: ImageLoaderContract, Sendable {
	/// Shared instance for app-wide image caching.
	public static let shared = CachedImageLoader()

	private let cache: ImageCache
	private let requestCoordinator: ImageRequestCoordinator

	/// Creates a new cached image loader.
	/// - Parameter transport: The transport to use for network requests.
	public init(transport: any HTTPTransportContract = URLSessionTransport()) {
		self.cache = ImageCache()
		self.requestCoordinator = ImageRequestCoordinator(transport: transport)
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

		let image = await requestCoordinator.loadImage(for: url)

		if let image {
			cache.setImage(image, for: url)
		}

		return image
	}
}

private final class ImageCache: Sendable {
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
	private let transport: any HTTPTransportContract

	init(transport: any HTTPTransportContract) {
		self.transport = transport
	}

	func loadImage(for url: URL) async -> UIImage? {
		if let existingTask = inFlightRequests[url] {
			return await existingTask.value
		}

		let task = Task<UIImage?, Never> { [transport] in
			await Self.downloadImage(from: url, transport: transport)
		}

		inFlightRequests[url] = task
		let image = await task.value
		inFlightRequests[url] = nil

		return image
	}

	private static func downloadImage(from url: URL, transport: any HTTPTransportContract) async -> UIImage? {
		let request = URLRequest(url: url)
		guard let (data, response) = try? await transport.send(request),
			  (200...299).contains(response.statusCode) else {
			return nil
		}
		return UIImage(data: data)
	}
}
