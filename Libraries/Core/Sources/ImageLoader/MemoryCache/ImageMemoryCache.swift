import UIKit

final class ImageMemoryCache: ImageMemoryCacheContract {
	private let storage = NSCache<NSURL, UIImage>()

	func image(for url: URL) -> UIImage? {
		storage.object(forKey: url as NSURL)
	}

	func setImage(_ image: UIImage, for url: URL) {
		storage.setObject(image, forKey: url as NSURL)
	}

	func removeCachedImage(for url: URL) {
		storage.removeObject(forKey: url as NSURL)
	}

	func removeAll() {
		storage.removeAllObjects()
	}
}
