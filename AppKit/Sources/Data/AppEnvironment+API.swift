import ChallengeCore
import Foundation

// MARK: - API Configuration

extension AppEnvironment {
	public struct API {
		public let baseURL: URL
	}

	public var rickAndMorty: API {
		let urlString: String = switch self {
		case .development:
			// TODO: replace by development url
			"https://rickandmortyapi.com"
		case .staging:
			// TODO: replace by staging url
			"https://rickandmortyapi.com"
		case .production:
			// TODO: replace by production url
			"https://rickandmortyapi.com"
		}
		guard let url = URL(string: urlString) else {
			preconditionFailure("Invalid API base URL: \(urlString)")
		}
		return API(baseURL: url)
	}
}
