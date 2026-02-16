import ChallengeNetworking
import Foundation

/// Mock implementation of GraphQLClientContract for testing.
public final class GraphQLClientMock: GraphQLClientContract, @unchecked Sendable {
	/// The result to return from execute calls.
	public var result: Result<Data, Error> = .success(Data())

	/// The operations that have been executed.
	public private(set) var executedOperations: [GraphQLOperation] = []

	/// Creates a new GraphQL client mock.
	public init() {}

	/// Records the operation and returns the mock result decoded as the specified type.
	@concurrent public func execute<T: Decodable>(_ operation: GraphQLOperation) async throws -> T {
		executedOperations.append(operation)
		let data = try result.get()
		return try JSONDecoder().decode(T.self, from: data)
	}
}
