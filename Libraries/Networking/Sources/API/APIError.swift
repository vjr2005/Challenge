import Foundation

/// API-agnostic errors that can occur during requests.
public enum APIError: Error, Equatable {
	case invalidRequest
	case invalidResponse
	case notFound
	case serverError(statusCode: Int)
	case decodingFailed(description: String)
}

// MARK: - HTTPError Mapping

public extension HTTPError {
	var toAPIError: APIError {
		switch self {
		case .invalidURL:
			.invalidRequest
		case .invalidResponse:
			.invalidResponse
		case .statusCode(404, _):
			.notFound
		case .statusCode(let code, _):
			.serverError(statusCode: code)
		}
	}
}
