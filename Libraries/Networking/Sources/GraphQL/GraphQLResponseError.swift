import Foundation

/// Represents an error returned in a GraphQL response body.
public struct GraphQLResponseError: Decodable, Equatable, Sendable {
	/// The error message.
	public let message: String

	/// The locations in the query where the error occurred.
	public let locations: [Location]?

	/// The path to the field that caused the error.
	public let path: [String]?

	nonisolated public static func == (lhs: GraphQLResponseError, rhs: GraphQLResponseError) -> Bool {
		lhs.message == rhs.message && lhs.locations == rhs.locations && lhs.path == rhs.path
	}

	/// A location in a GraphQL query.
	public struct Location: Decodable, Equatable, Sendable {
		/// The line number.
		public let line: Int

		/// The column number.
		public let column: Int

		nonisolated public static func == (lhs: Location, rhs: Location) -> Bool {
			lhs.line == rhs.line && lhs.column == rhs.column
		}
	}
}
