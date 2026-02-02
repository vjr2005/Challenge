import Foundation

extension Data {
	/// Loads the test avatar image data from the test bundle.
	static var stubAvatarImage: Data {
		guard let path = Bundle.module.path(forResource: "test-avatar", ofType: "jpg"),
			  let data = FileManager.default.contents(atPath: path) else {
			fatalError("test-avatar.jpg not found in test bundle")
		}
		return data
	}
}
