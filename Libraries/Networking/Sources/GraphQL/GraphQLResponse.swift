import Foundation

/// Internal envelope for GraphQL responses.
struct GraphQLResponse<T: Decodable>: Decodable {
	/// The data payload, present on success.
	let data: T?

	/// The errors array, present when the operation fails.
	let errors: [GraphQLResponseError]?
}
