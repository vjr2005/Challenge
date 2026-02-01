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

	/// Loads a JSON fixture from the test bundle.
	/// - Parameter name: The fixture file name without extension.
	/// - Returns: The fixture data.
	static func fixture(_ name: String) -> Data {
		guard let url = Bundle.module.url(forResource: name, withExtension: "json"),
			  let data = try? Data(contentsOf: url) else {
			fatalError("Fixture not found: \(name).json")
		}
		return data
	}
}
