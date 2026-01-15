import Foundation

/// Centralized configuration for API base URLs.
public enum APIConfiguration {
	case rickAndMorty

	public var baseURL: URL {
		switch self {
		case .rickAndMorty:
			URL(string: "https://rickandmortyapi.com/api")!
		}
	}
}
