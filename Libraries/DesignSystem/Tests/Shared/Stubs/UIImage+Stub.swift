import UIKit

extension UIImage {
    static var stub: UIImage? {
        // Find the bundle containing this class (works for both Tests and SnapshotTests targets)
        let bundle = Bundle(for: BundleFinder.self)
        guard let path = bundle.path(forResource: "test-avatar", ofType: "jpg") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
}

// Helper class to find the correct bundle
private final class BundleFinder {}
