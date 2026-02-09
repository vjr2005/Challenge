import Foundation

/// Represents a GraphQL operation (query or mutation).
public struct GraphQLOperation: Sendable, Equatable {
	/// The GraphQL query or mutation string.
	public let query: String

	/// The variables for the operation.
	public let variables: [String: GraphQLVariable]?

	/// An optional operation name for the query.
	public let operationName: String?

	/// Creates a new GraphQL operation.
	/// - Parameters:
	///   - query: The GraphQL query or mutation string.
	///   - variables: The variables for the operation.
	///   - operationName: An optional operation name.
	public init(
		query: String,
		variables: [String: GraphQLVariable]? = nil,
		operationName: String? = nil
	) {
		self.query = query
		self.variables = variables
		self.operationName = operationName
	}
}
