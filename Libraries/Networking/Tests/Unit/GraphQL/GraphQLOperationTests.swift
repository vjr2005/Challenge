import Foundation
import Testing

@testable import ChallengeNetworking

struct GraphQLOperationTests {
	// MARK: - Construction

	@Test("Creates operation with query only")
	func createsOperationWithQueryOnly() {
		// Given
		let query = "{ episodes { results { id } } }"

		// When
		let sut = GraphQLOperation(query: query)

		// Then
		#expect(sut.query == query)
		#expect(sut.variables == nil)
		#expect(sut.operationName == nil)
	}

	@Test("Creates operation with all parameters")
	func createsOperationWithAllParameters() {
		// Given
		let query = "query GetEpisodes($page: Int!) { episodes(page: $page) { results { id } } }"
		let variables: [String: GraphQLVariable] = ["page": .int(1)]
		let operationName = "GetEpisodes"

		// When
		let sut = GraphQLOperation(query: query, variables: variables, operationName: operationName)

		// Then
		#expect(sut.query == query)
		#expect(sut.variables == variables)
		#expect(sut.operationName == operationName)
	}

	// MARK: - Equatable

	@Test("Operations with same values are equal")
	func operationsWithSameValuesAreEqual() {
		// Given
		let lhs = GraphQLOperation(
			query: "{ episodes { results { id } } }",
			variables: ["page": .int(1)],
			operationName: "GetEpisodes"
		)
		let rhs = GraphQLOperation(
			query: "{ episodes { results { id } } }",
			variables: ["page": .int(1)],
			operationName: "GetEpisodes"
		)

		// Then
		#expect(lhs == rhs)
	}

	@Test("Operations with different queries are not equal")
	func operationsWithDifferentQueriesAreNotEqual() {
		// Given
		let lhs = GraphQLOperation(query: "{ episodes { results { id } } }")
		let rhs = GraphQLOperation(query: "{ characters { results { id } } }")

		// Then
		#expect(lhs != rhs)
	}

	@Test("Operations with different variables are not equal")
	func operationsWithDifferentVariablesAreNotEqual() {
		// Given
		let query = "query ($page: Int!) { episodes(page: $page) { results { id } } }"
		let lhs = GraphQLOperation(query: query, variables: ["page": .int(1)])
		let rhs = GraphQLOperation(query: query, variables: ["page": .int(2)])

		// Then
		#expect(lhs != rhs)
	}

	// MARK: - Variable Encoding

	@Test("String variable encodes correctly")
	func stringVariableEncodesCorrectly() throws {
		// Given
		let variables: [String: GraphQLVariable] = ["name": .string("Rick")]

		// When
		let data = try JSONEncoder().encode(variables)
		let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

		// Then
		#expect(json["name"] as? String == "Rick")
	}

	@Test("Int variable encodes correctly")
	func intVariableEncodesCorrectly() throws {
		// Given
		let variables: [String: GraphQLVariable] = ["page": .int(42)]

		// When
		let data = try JSONEncoder().encode(variables)
		let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

		// Then
		#expect(json["page"] as? Int == 42)
	}

	@Test("Bool variable encodes correctly")
	func boolVariableEncodesCorrectly() throws {
		// Given
		let variables: [String: GraphQLVariable] = ["active": .bool(true)]

		// When
		let data = try JSONEncoder().encode(variables)
		let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

		// Then
		#expect(json["active"] as? Bool == true)
	}

	@Test("Null variable encodes correctly")
	func nullVariableEncodesCorrectly() throws {
		// Given
		let variables: [String: GraphQLVariable] = ["filter": .null]

		// When
		let data = try JSONEncoder().encode(variables)
		let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

		// Then
		#expect(json["filter"] is NSNull)
	}
}
