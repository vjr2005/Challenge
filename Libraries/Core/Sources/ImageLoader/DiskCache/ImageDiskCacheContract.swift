import Foundation
import UIKit

protocol ImageDiskCacheContract: Actor {
	func image(for url: URL) -> UIImage?
	func store(_ data: Data, for url: URL)
	func remove(for url: URL)
	func removeAll()
}
