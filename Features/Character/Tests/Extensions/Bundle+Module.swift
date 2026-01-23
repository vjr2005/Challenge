import Foundation

private final class BundleFinder {}

extension Bundle {
	/// The bundle associated with the current Swift module.
	static let module = Bundle(for: BundleFinder.self)
}
