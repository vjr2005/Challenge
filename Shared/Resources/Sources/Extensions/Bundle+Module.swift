import Foundation

private final class BundleFinder {}

extension Bundle {
	static let module = Bundle(for: BundleFinder.self)
}
