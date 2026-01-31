import Foundation

private final class BundleFinder {}

extension Bundle {
	/// The bundle associated with the ChallengeHome module.
	static let home = Bundle(for: BundleFinder.self)
}
