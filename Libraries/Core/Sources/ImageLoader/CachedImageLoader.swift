import UIKit

/// Image loader with in-memory caching, disk caching, and deduplication of in-flight requests.
public final class CachedImageLoader: ImageLoaderContract {
	private let cache: ImageCache
	private let diskCache: ImageDiskCache
	private let requestCoordinator: ImageRequestCoordinator
	private let session: URLSession

	public init(session: URLSession = .shared, diskCacheConfiguration: DiskCacheConfiguration = .default) {
		self.session = session
		self.cache = ImageCache()
		self.requestCoordinator = ImageRequestCoordinator()
		self.diskCache = ImageDiskCache(configuration: diskCacheConfiguration, fileSystem: FileManager.default)
	}

	init(session: URLSession, diskCache: ImageDiskCache) {
		self.session = session
		self.cache = ImageCache()
		self.requestCoordinator = ImageRequestCoordinator()
		self.diskCache = diskCache
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

		if let diskImage = await diskCache.image(for: url) {
			cache.setImage(diskImage, for: url)
			return diskImage
		}

		guard let data = await requestCoordinator.loadData(for: url, session: session),
			  let image = UIImage(data: data) else {
			return nil
		}

		cache.setImage(image, for: url)
		await diskCache.store(data, for: url)

		return image
	}

	/// Removes the cached image for the given URL from memory and disk.
	public func removeImage(for url: URL) async {
		cache.removeImage(for: url)
		await diskCache.remove(for: url)
	}

	/// Clears all cached images from memory and disk.
	public func clearCache() async {
		cache.removeAll()
		await diskCache.removeAll()
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

	func removeImage(for url: URL) {
		storage.removeObject(forKey: url as NSURL)
	}

	func removeAll() {
		storage.removeAllObjects()
	}
}

private actor ImageRequestCoordinator {
	private var inFlightRequests: [URL: Task<Data?, Never>] = [:]

	func loadData(for url: URL, session: URLSession) async -> Data? {
		if let existingTask = inFlightRequests[url] {
			return await existingTask.value
		}

		let task = Task<Data?, Never> {
			await downloadData(from: url, session: session)
		}

		inFlightRequests[url] = task
		let result = await task.value
		inFlightRequests[url] = nil

		return result
	}

	nonisolated private func downloadData(from url: URL, session: URLSession) async -> Data? {
		guard let (data, response) = try? await session.data(from: url) else {
			return nil
		}
		guard let httpResponse = response as? HTTPURLResponse,
			  (200...299).contains(httpResponse.statusCode) else {
			return nil
		}
		return data
	}
}
