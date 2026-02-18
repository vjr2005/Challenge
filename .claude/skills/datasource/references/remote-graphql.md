# GraphQL DataSource Templates

Placeholders: `{Name}` (PascalCase entity), `{Feature}` (PascalCase module), `{name}` (snake_case).

GraphQL infrastructure lives in `Libraries/Networking/Sources/GraphQL/` and provides `GraphQLClientContract`, `GraphQLClient`, `GraphQLOperation`, `GraphQLVariable`.

---

### {Name}DTO.swift — `Sources/Data/DTOs/`

```swift
nonisolated struct {Name}DTO: Decodable, Equatable {
	let id: String
	let name: String
	// Add fields matching GraphQL response. Use CodingKeys for snake_case fields.
}
```

GraphQL IDs are strings. Use `CodingKeys` when GraphQL field names differ from Swift conventions:

```swift
enum CodingKeys: String, CodingKey {
	case id, name
	case airDate = "air_date"
}
```

For paginated responses:

```swift
nonisolated struct {Name}sResponseDTO: Decodable, Equatable {
	let info: {Name}PaginationInfoDTO
	let results: [{Name}DTO]
}

nonisolated struct {Name}PaginationInfoDTO: Decodable, Equatable {
	let count: Int
	let pages: Int
	let next: Int?
	let prev: Int?
}
```

GraphQL pagination returns page numbers (not URLs like REST).

### {Name}RemoteDataSourceContract.swift — `Sources/Data/DataSources/Remote/`

```swift
nonisolated protocol {Name}RemoteDataSourceContract: Sendable {
	@concurrent func fetch{Name}(identifier: Int) async throws -> {Name}DTO
	@concurrent func fetch{Name}s(page: Int, filter: {Name}FilterDTO) async throws -> {Name}sResponseDTO
}
```

The contract is transport-agnostic — same contract for REST or GraphQL. Filter types are DTOs — DataSources only work with DTOs, never domain objects.

### {Name}GraphQLDataSource.swift — `Sources/Data/DataSources/Remote/`

```swift
import ChallengeNetworking
import Foundation

nonisolated struct {Name}GraphQLDataSource: {Name}RemoteDataSourceContract {
	private let graphQLClient: any GraphQLClientContract
	private let errorMapper = GraphQLErrorMapper()

	init(graphQLClient: any GraphQLClientContract) {
		self.graphQLClient = graphQLClient
	}

	@concurrent func fetch{Name}s(page: Int, filter: {Name}FilterDTO) async throws -> {Name}sResponseDTO {
		var variables: [String: GraphQLVariable] = ["page": .int(page)]

		if let name = filter.name, !name.isEmpty {
			variables["name"] = .string(name)
		}

		let operation = GraphQLOperation(
			query: Self.{name}sQuery,
			variables: variables,
			operationName: "Get{Name}s"
		)

		let response: {Name}sQueryResponse = try await request(operation)
		return response.{name}s
	}

	@concurrent func fetch{Name}(identifier: Int) async throws -> {Name}DTO {
		let operation = GraphQLOperation(
			query: Self.{name}Query,
			variables: ["id": .string(String(identifier))],
			operationName: "Get{Name}"
		)

		let response: {Name}QueryResponse = try await request(operation)
		return response.{name}
	}
}

// MARK: - Private

nonisolated private extension {Name}GraphQLDataSource {
	func request<T: Decodable>(_ operation: GraphQLOperation) async throws -> T {
		do {
			return try await graphQLClient.execute(operation)
		} catch let error as GraphQLError {
			throw errorMapper.map(error)
		}
	}
}

// MARK: - Response Wrappers

nonisolated private struct {Name}sQueryResponse: Decodable {
	let {name}s: {Name}sResponseDTO
}

nonisolated private struct {Name}QueryResponse: Decodable {
	let {name}: {Name}DTO
}

// MARK: - Queries

nonisolated extension {Name}GraphQLDataSource {
	static let {name}sQuery = """
		query Get{Name}s($page: Int, $name: String) {
			{name}s(page: $page, filter: { name: $name }) {
				info { count pages next prev }
				results {
					id
					name
					// ... fields matching DTO
				}
			}
		}
		"""

	static let {name}Query = """
		query Get{Name}($id: ID!) {
			{name}(id: $id) {
				id
				name
				// ... fields matching DTO
			}
		}
		"""
}
```

Key patterns:
- **Response wrappers**: Private structs that match the GraphQL `data` structure (e.g., `{ "{name}s": { ... } }`). Unwrap and return the inner DTO.
- **Query strings**: `static let` on the DataSource. Exposed (not private) so tests can verify the correct query is sent.
- **Error mapping**: The `GraphQLClient` throws `GraphQLError`. The DataSource catches it and maps to `APIError` via `GraphQLErrorMapper` (same pattern as REST DataSource with `HTTPErrorMapper`).

> **Note:** Both the contract and implementation use `nonisolated` + `@concurrent`. `@concurrent` guarantees execution on the cooperative thread pool (not MainActor). Extensions must have their own `nonisolated` keyword — it doesn't propagate from the type. `ChallengeNetworking` uses `nonisolated` default isolation — `GraphQLOperation`, `GraphQLVariable`, and other networking types don't need `nonisolated` annotations.

### Container Wiring

The container receives `HTTPClientContract` and creates the `GraphQLClient` internally:

```swift
import ChallengeCore
import ChallengeNetworking

struct {Feature}Container {
	private let tracker: any TrackerContract
	private let {name}Repository: {Name}RepositoryContract

	init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
		self.tracker = tracker
		let graphQLClient = GraphQLClient(httpClient: httpClient)
		let remoteDataSource = {Name}GraphQLDataSource(graphQLClient: graphQLClient)
		self.{name}Repository = {Name}Repository(remoteDataSource: remoteDataSource)
	}
}
```

The Feature entry point also receives `HTTPClientContract`:

```swift
public init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
	self.container = {Feature}Container(httpClient: httpClient, tracker: tracker)
}
```

### {Name}RemoteDataSourceMock.swift — `Tests/Shared/Mocks/`

Same as REST — the mock is transport-agnostic:

```swift
import Foundation

@testable import Challenge{Feature}

nonisolated final class {Name}RemoteDataSourceMock: {Name}RemoteDataSourceContract, @unchecked Sendable {
	var {name}sResult: Result<{Name}sResponseDTO, Error> = .failure(NotConfiguredError.notConfigured)
	var {name}Result: Result<{Name}DTO, Error> = .failure(NotConfiguredError.notConfigured)
	private(set) var fetch{Name}sCallCount = 0
	private(set) var fetch{Name}CallCount = 0
	private(set) var lastFetchedPage: Int?
	private(set) var lastFetchedFilter: {Name}FilterDTO?
	private(set) var lastFetchedIdentifier: Int?

	@concurrent func fetch{Name}s(page: Int, filter: {Name}FilterDTO) async throws -> {Name}sResponseDTO {
		fetch{Name}sCallCount += 1
		lastFetchedPage = page
		lastFetchedFilter = filter
		return try {name}sResult.get()
	}

	@concurrent func fetch{Name}(identifier: Int) async throws -> {Name}DTO {
		fetch{Name}CallCount += 1
		lastFetchedIdentifier = identifier
		return try {name}Result.get()
	}
}

private enum NotConfiguredError: Error {
	case notConfigured
}
```

### Fixtures

GraphQL fixtures contain the **response wrapper** structure (what `GraphQLClientMock` returns — the envelope is already stripped by the client):

**{name}.json:**
```json
{
	"{name}": {
		"id": "1",
		"name": "Example"
	}
}
```

**{name}s_response.json:**
```json
{
	"{name}s": {
		"info": { "count": 51, "pages": 3, "next": 2, "prev": null },
		"results": [
			{ "id": "1", "name": "Example" }
		]
	}
}
```

### {Name}GraphQLDataSourceTests.swift — `Tests/Unit/Data/`

```swift
import ChallengeCoreMocks
import ChallengeNetworking
import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import Challenge{Feature}

@Suite(.timeLimit(.minutes(1)))
struct {Name}GraphQLDataSourceTests {
	private let graphQLClientMock = GraphQLClientMock()
	private let sut: {Name}GraphQLDataSource

	init() {
		sut = {Name}GraphQLDataSource(graphQLClient: graphQLClientMock)
	}

	// MARK: - Fetch {Name}s

	@Test("Fetch {name}s sends correct operation")
	func fetch{Name}sSendsCorrectOperation() async throws {
		// Given
		let jsonData = try loadJSONData("{name}s_response")
		graphQLClientMock.result = .success(jsonData)

		// When
		_ = try await sut.fetch{Name}s(page: 1, filter: .empty)

		// Then
		let operation = try #require(graphQLClientMock.executedOperations.first)
		#expect(operation.operationName == "Get{Name}s")
		#expect(operation.query == {Name}GraphQLDataSource.{name}sQuery)
	}

	@Test("Fetch {name}s includes page variable")
	func fetch{Name}sIncludesPageVariable() async throws {
		// Given
		graphQLClientMock.result = .success(try loadJSONData("{name}s_response"))

		// When
		_ = try await sut.fetch{Name}s(page: 3, filter: .empty)

		// Then
		let operation = try #require(graphQLClientMock.executedOperations.first)
		let variables = try #require(operation.variables)
		#expect(variables["page"] == .int(3))
	}

	@Test("Fetch {name}s decodes response")
	func fetch{Name}sDecodesResponse() async throws {
		// Given
		graphQLClientMock.result = .success(try loadJSONData("{name}s_response"))

		// When
		let result = try await sut.fetch{Name}s(page: 1, filter: .empty)

		// Then
		#expect(result.results.count == 1)
		#expect(result.results.first?.name == "Example")
	}

	@Test("Fetch {name}s maps GraphQL statusCode 404 to APIError.notFound")
	func fetch{Name}sMapsGraphQLError() async {
		// Given
		graphQLClientMock.result = .failure(GraphQLError.statusCode(404, Data()))

		// When / Then
		await #expect(throws: APIError.notFound) {
			_ = try await sut.fetch{Name}s(page: 1, filter: .empty)
		}
	}

	// MARK: - Fetch {Name}

	@Test("Fetch {name} sends identifier as string variable")
	func fetch{Name}SendsIdentifier() async throws {
		// Given
		graphQLClientMock.result = .success(try loadJSONData("{name}"))

		// When
		_ = try await sut.fetch{Name}(identifier: 42)

		// Then
		let operation = try #require(graphQLClientMock.executedOperations.first)
		let variables = try #require(operation.variables)
		#expect(variables["id"] == .string("42"))
	}

	@Test("Fetch {name} decodes response")
	func fetch{Name}DecodesResponse() async throws {
		// Given
		graphQLClientMock.result = .success(try loadJSONData("{name}"))

		// When
		let result = try await sut.fetch{Name}(identifier: 1)

		// Then
		#expect(result.id == "1")
		#expect(result.name == "Example")
	}
}

// MARK: - Private

private extension {Name}GraphQLDataSourceTests {
	func loadJSONData(_ filename: String) throws -> Data {
		try Bundle.module.loadJSONData(filename)
	}
}
```

Tests use `GraphQLClientMock` (from `ChallengeNetworkingMocks`), which bypasses the GraphQL envelope — fixtures contain the unwrapped response wrapper directly.
