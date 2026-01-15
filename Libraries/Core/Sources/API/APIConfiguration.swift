import Foundation

/// Centralized configuration for API base URLs.
public enum APIConfiguration {
	case rickAndMorty

	public var baseURL: URL {
		let urlString: String
		switch self {
		case .rickAndMorty:
			urlString = "https://rickandmortyapi.com/api"
		}
		guard let url = URL(string: urlString) else {
			preconditionFailure("Invalid URL: \(urlString)")
		}
		return url
	}
}
