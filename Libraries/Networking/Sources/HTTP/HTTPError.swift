import Foundation

/// Errors that can occur during HTTP requests.
public enum HTTPError: Error, Equatable {
	case invalidURL
	case invalidResponse
	case statusCode(Int, Data)
}

// MARK: - Equatable

extension HTTPError {
	public static func == (lhs: HTTPError, rhs: HTTPError) -> Bool {
		switch (lhs, rhs) {
		case (.invalidURL, .invalidURL):
			true
		case (.invalidResponse, .invalidResponse):
			true
		case let (.statusCode(lhsCode, lhsData), .statusCode(rhsCode, rhsData)):
			lhsCode == rhsCode && lhsData == rhsData
		default:
			false
		}
	}
}
