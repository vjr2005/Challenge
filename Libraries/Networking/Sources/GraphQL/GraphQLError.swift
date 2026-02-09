import Foundation

/// Errors that can occur during GraphQL operations.
public enum GraphQLError: Error, Equatable {
	case statusCode(Int, Data)
	case response([GraphQLResponseError])
	case decodingFailed(description: String)
	case invalidResponse
}
