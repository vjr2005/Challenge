import ChallengeCore
import Foundation

// MARK: - API Configuration

extension AppEnvironment {
	public struct API {
		public let baseURL: URL
	}

	// swiftlint:disable force_unwrapping
	public var rickAndMorty: API {
		let urlString: String = switch self {
		case .development:
			// TODO: replace by development url
			"https://rickandmortyapi.com/api"
		case .staging:
			// TODO: replace by staging url
			"https://rickandmortyapi.com/api"
		case .production:
			// TODO: replace by production url
			"https://rickandmortyapi.com/api"
		}
		let url = URL(string: urlString)!
		return API(baseURL: url)
	}
	// swiftlint:enable force_unwrapping
}
