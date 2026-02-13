import UIKit

protocol ImageMemoryCacheContract {
	func image(for url: URL) -> UIImage?
	func setImage(_ image: UIImage, for url: URL)
	func removeCachedImage(for url: URL)
	func removeAll()
}
