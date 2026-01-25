import ChallengeCore
import Foundation

// MARK: - API Configuration

extension AppEnvironment {
	struct API {
		let baseURL: URL
	}

	var rickAndMorty: API {
		let urlString: String
		switch self {
		case .development:
			// TODO: Replace with development environment URL
			urlString = "https://rickandmortyapi.com/api"
		case .staging:
			// TODO: Replace with staging environment URL
			urlString = "https://rickandmortyapi.com/api"
		case .production:
			// TODO: Replace with production environment URL
			urlString = "https://rickandmortyapi.com/api"
		}
		guard let url = URL(string: urlString) else {
			preconditionFailure("Invalid URL: \(urlString)")
		}
		return API(baseURL: url)
	}
}
