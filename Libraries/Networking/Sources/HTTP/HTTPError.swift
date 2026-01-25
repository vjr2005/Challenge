import Foundation

/// Errors that can occur during HTTP requests.
public enum HTTPError: Error, Equatable {
	case invalidURL
	case invalidResponse
	case statusCode(Int, Data)
}
