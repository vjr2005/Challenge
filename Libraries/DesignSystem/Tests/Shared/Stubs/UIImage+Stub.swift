import UIKit

extension UIImage {
	static var stub: UIImage? {
		guard let path = Bundle.module.path(forResource: "test-avatar", ofType: "jpg") else {
			return nil
		}
		return UIImage(contentsOfFile: path)
	}
}
