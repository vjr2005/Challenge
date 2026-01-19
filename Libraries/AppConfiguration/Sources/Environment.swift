import Foundation

/// Application environment configuration.
public enum Environment {
	case development
	case staging
	case production

	/// Current environment based on build configuration.
	public static var current: Self {
		#if DEBUG_PROD
		.production
		#elseif DEBUG_STAGING
		.staging
		#elseif DEBUG
		.development
		#elseif STAGING
		.staging
		#else
		.production
		#endif
	}

	/// Whether the current environment is a debug build.
	public var isDebug: Bool {
		self == .development
	}

	/// Whether the current environment is a release build.
	public var isRelease: Bool {
		self == .production
	}
}

// MARK: - API Configuration

public extension Environment {
	struct API {
		public let baseURL: URL
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
