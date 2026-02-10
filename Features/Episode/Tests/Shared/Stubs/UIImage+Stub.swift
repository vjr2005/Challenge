import UIKit

extension UIImage {
	static var stub: UIImage? {
		let bundle = Bundle(for: EpisodeBundleFinder.self)
		guard let path = bundle.path(forResource: "test-avatar", ofType: "jpg") else {
			return nil
		}
		return UIImage(contentsOfFile: path)
	}
}

// Helper class to find the correct bundle
private final class EpisodeBundleFinder {}
