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
	/// - Parameters:
	///   - name: The fixture file name without extension.
	///   - baseURL: Optional base URL to replace `{{BASE_URL}}` placeholders.
	/// - Returns: The fixture data.
	static func fixture(_ name: String, baseURL: String? = nil) -> Data {
		guard let url = Bundle.module.url(forResource: name, withExtension: "json"),
			  let data = try? Data(contentsOf: url) else {
			fatalError("Fixture not found: \(name).json")
		}

		guard let baseURL else {
			return data
		}

		guard let jsonString = String(data: data, encoding: .utf8) else {
			return data
		}

		let replacedString = jsonString.replacingOccurrences(of: "{{BASE_URL}}", with: baseURL)
		return Data(replacedString.utf8)
	}
}
