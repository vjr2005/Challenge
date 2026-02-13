import UIKit

/// Image loader with in-memory caching, disk caching, and deduplication of in-flight requests.
public final class CachedImageLoader: ImageLoaderContract {
	private let cache: ImageMemoryCacheContract
	private let diskCache: ImageDiskCacheContract
	private let requestCoordinator: ImageRequestCoordinator
	private let session: URLSession

	public convenience init() {
		self.init(session: .shared,
				  memoryCache: ImageMemoryCache(),
				  diskCache: ImageDiskCache(configuration: .default, fileSystem: FileSystem()))
	}

	init(
		session: URLSession = .shared,
		memoryCache: ImageMemoryCacheContract = ImageMemoryCache(),
		diskCache: ImageDiskCacheContract = ImageDiskCache(configuration: .default, fileSystem: FileSystem())
	) {
		self.session = session
		self.cache = memoryCache
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
	public func removeCachedImage(for url: URL) async {
		cache.removeCachedImage(for: url)
		await diskCache.remove(for: url)
	}

	/// Clears all cached images from memory and disk.
	public func clearCache() async {
		cache.removeAll()
		await diskCache.removeAll()
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
		defer { inFlightRequests[url] = nil }

		return await task.value
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
