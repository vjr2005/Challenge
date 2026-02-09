import Foundation

public struct GraphQLErrorMapper {
	public init() {}

	public func map(_ input: GraphQLError) -> APIError {
		switch input {
		case .statusCode(404, _):
			.notFound
		case .statusCode(let code, _):
			.serverError(statusCode: code)
		case .response:
			.invalidResponse
		case .decodingFailed(let description):
			.decodingFailed(description: description)
		case .invalidResponse:
			.invalidResponse
		}
	}
}
