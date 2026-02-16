import Foundation

/// Contract for GraphQL client implementations.
public protocol GraphQLClientContract: Sendable {
	/// Executes a GraphQL operation and decodes the data payload.
	/// - Parameter operation: The GraphQL operation to execute.
	/// - Returns: The decoded data payload.
	@concurrent func execute<T: Decodable>(_ operation: GraphQLOperation) async throws -> T
}
