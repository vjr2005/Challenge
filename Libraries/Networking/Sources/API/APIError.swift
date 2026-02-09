import Foundation

/// API-agnostic errors that can occur during requests.
public enum APIError: Error, Equatable {
	case invalidRequest
	case invalidResponse
	case notFound
	case serverError(statusCode: Int)
	case decodingFailed(description: String)
}
