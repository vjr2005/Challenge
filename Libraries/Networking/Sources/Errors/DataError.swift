import Foundation

/// Errors that can occur in the data layer.
public enum DataError: Error, Equatable, Sendable, LocalizedError {
	case network(underlying: String?)
	case server(statusCode: Int, message: String?)
	case parsing(underlying: String?)
	case notFound
	case invalidRequest

	public var errorDescription: String? {
		switch self {
		case .network(let underlying):
			if let underlying {
				return "Network error: \(underlying)"
			}
			return "Network error"
		case let .server(statusCode, message):
			if let message {
				return "Server error (\(statusCode)): \(message)"
			}
			return "Server error (\(statusCode))"
		case .parsing(let underlying):
			if let underlying {
				return "Parsing error: \(underlying)"
			}
			return "Parsing error"
		case .notFound:
			return "Resource not found"
		case .invalidRequest:
			return "Invalid request"
		}
	}
}
