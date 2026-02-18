import Foundation

public struct HTTPErrorMapper: Sendable {
	public init() {}

	public func map(_ input: HTTPError) -> APIError {
		switch input {
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
