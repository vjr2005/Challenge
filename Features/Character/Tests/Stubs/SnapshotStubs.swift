import Foundation
import UIKit

/// Provides local test image for snapshot testing to avoid network calls.
enum SnapshotStubs {
	/// Local test image loaded from bundle.
	static var testImage: UIImage? {
		guard let path = Bundle.module.path(forResource: "test-avatar", ofType: "jpg") else {
			return nil
		}
		return UIImage(contentsOfFile: path)
	}
}
