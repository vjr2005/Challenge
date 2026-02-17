# How To: Create DataSource

Create DataSources for data access: REST APIs, GraphQL APIs, SwiftData persistence (two-level cache), or UserDefaults persistence.

> **Source of truth:** `/datasource` skill. Consult it for the authoritative workflow and all patterns.

## Prerequisites

- Feature module exists (see [Create Feature](create-feature.md))
- API endpoint or storage requirements identified
- JSON response structure known (for remote DataSources)

## DataSource Types

| Type | Transport | Contract | Implementation | Error Mapper |
|------|-----------|----------|----------------|-------------|
| REST | HTTP | `: Sendable` | `struct` with `HTTPClientContract` | `HTTPErrorMapper` |
| GraphQL | HTTP/GraphQL | `: Sendable` | `struct` with `GraphQLClientContract` | `GraphQLErrorMapper` |
| SwiftData | SwiftData | `: Actor` | `@ModelActor actor` with `ModelContainer` | -- |
| UserDefaults | Local | `: Actor` | `actor` with `UserDefaults` | -- |

## File Structure

```
Features/{Feature}/
+-- Sources/
|   +-- Data/
|       +-- DataSources/
|       |   +-- Remote/
|       |   |   +-- {Name}RemoteDataSourceContract.swift
|       |   |   +-- {Name}RESTDataSource.swift (or {Name}GraphQLDataSource.swift)
|       |   +-- Local/
|       |       +-- {Name}LocalDataSourceContract.swift
|       |       +-- {Name}EntityDataSource.swift           # SwiftData (two-level cache)
|       |       +-- {Name}UserDefaultsDataSource.swift     # Optional: UserDefaults
|       +-- Entities/                                      # SwiftData models
|       |   +-- {Name}Entity.swift
|       |   +-- {Name}ModelContainer.swift
|       +-- DTOs/
|           +-- {Name}DTO.swift
+-- Tests/
    +-- Unit/Data/
    +-- Shared/Fixtures/
    |   +-- {name}.json
    |   +-- {name}s_response.json
    +-- Shared/Mocks/
```

---

## Part A: REST DataSource

### 1. Create DTO

> *"A Data Transfer Object is one of those objects our mothers told us never to write. It's often little more than a bunch of fields and the getters and setters for them."*
> -- Martin Fowler, [PoEAA](https://martinfowler.com/eaaCatalog/dataTransferObject.html)

Create `Sources/Data/DTOs/{Name}DTO.swift`:

```swift
struct {Name}DTO: Decodable, Equatable {
	let id: Int
	let name: String
	// Add fields matching JSON response
}
```

For paginated responses, create a wrapper:

```swift
struct {Name}sResponseDTO: Decodable, Equatable {
	let info: PaginationInfoDTO
	let results: [{Name}DTO]
}

struct PaginationInfoDTO: Decodable, Equatable {
	let count: Int
	let pages: Int
	let next: String?
	let prev: String?
}
```

> **Note:** DTOs are intentionally anemic -- they exist purely to transfer data. No behavior, no `toDomain()` methods. Mapping belongs in the Repository. REST IDs are `Int`.

### 2. Create RemoteDataSource Contract

Create `Sources/Data/DataSources/Remote/{Name}RemoteDataSourceContract.swift`:

```swift
protocol {Name}RemoteDataSourceContract: Sendable {
	func fetch{Name}(identifier: Int) async throws -> {Name}DTO
}
```

The contract is transport-agnostic -- the same contract works for both REST and GraphQL implementations.

### 3. Create REST Implementation

Create `Sources/Data/DataSources/Remote/{Name}RESTDataSource.swift`:

```swift
import ChallengeNetworking
import Foundation

struct {Name}RESTDataSource: {Name}RemoteDataSourceContract {
	private let httpClient: any HTTPClientContract
	private let errorMapper = HTTPErrorMapper()

	init(httpClient: any HTTPClientContract) {
		self.httpClient = httpClient
	}

	func fetch{Name}(identifier: Int) async throws -> {Name}DTO {
		let endpoint = Endpoint(path: "{endpoint}/\(identifier)")
		return try await request(endpoint)
	}
}

// MARK: - Private

private extension {Name}RESTDataSource {
	func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
		do {
			return try await httpClient.request(endpoint)
		} catch let error as HTTPError {
			throw errorMapper.map(error)
		}
	}
}
```

For endpoints with query parameters:

```swift
func fetch{Name}s(page: Int, filter: {Name}FilterDTO) async throws -> {Name}sResponseDTO {
	var queryItems = [URLQueryItem(name: "page", value: String(page))]
	if let name = filter.name, !name.isEmpty {
		queryItems.append(URLQueryItem(name: "name", value: name))
	}
	let endpoint = Endpoint(path: "{endpoint}", queryItems: queryItems)
	return try await request(endpoint)
}
```

> **Note:** `HTTPErrorMapper` maps `HTTPError` to `APIError` internally. Repositories and upper layers only see `APIError`, never `HTTPError`. `ChallengeNetworking` uses `nonisolated` default isolation — `Endpoint`, `HTTPMethod`, and other networking types don't need `nonisolated` annotations.

### 4. Create JSON Fixture

Create `Tests/Shared/Fixtures/{name}.json`:

```json
{
	"id": 1,
	"name": "Example"
}
```

Match the exact structure returned by the API. Use realistic data.

### 5. Create Mock

Create `Tests/Shared/Mocks/{Name}RemoteDataSourceMock.swift`:

```swift
import Foundation

@testable import Challenge{Feature}

final class {Name}RemoteDataSourceMock: {Name}RemoteDataSourceContract, @unchecked Sendable {
	var result: Result<{Name}DTO, Error> = .failure(NotConfiguredError.notConfigured)
	private(set) var fetchCallCount = 0
	private(set) var lastFetchedIdentifier: Int?

	func fetch{Name}(identifier: Int) async throws -> {Name}DTO {
		fetchCallCount += 1
		lastFetchedIdentifier = identifier
		return try result.get()
	}
}

private enum NotConfiguredError: Error {
	case notConfigured
}
```

### 6. Create Tests

Create `Tests/Unit/Data/{Name}RESTDataSourceTests.swift`:

```swift
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Name}RESTDataSourceTests {
	// MARK: - Fetch {Name}

	@Test("Fetch {name} uses correct endpoint")
	func fetchUsesCorrectEndpoint() async throws {
		// Given
		let jsonData = try loadJSONData("{name}")
		let httpClientMock = HTTPClientMock()
		httpClientMock.result = .success(jsonData)
		let sut = {Name}RESTDataSource(httpClient: httpClientMock)

		// When
		_ = try await sut.fetch{Name}(identifier: 1)

		// Then
		let endpoint = try #require(httpClientMock.requestedEndpoints.first)
		#expect(endpoint.path == "{endpoint}/1")
		#expect(endpoint.method == .get)
	}

	@Test("Fetch {name} decodes response")
	func fetchDecodesResponse() async throws {
		// Given
		let jsonData = try loadJSONData("{name}")
		let httpClientMock = HTTPClientMock()
		httpClientMock.result = .success(jsonData)
		let sut = {Name}RESTDataSource(httpClient: httpClientMock)

		// When
		let result = try await sut.fetch{Name}(identifier: 1)

		// Then
		#expect(result.id == 1)
	}

	@Test("Fetch {name} maps HTTP error to API error")
	func fetchMapsHTTPError() async {
		// Given
		let httpClientMock = HTTPClientMock()
		httpClientMock.result = .failure(HTTPError.statusCode(404, Data()))
		let sut = {Name}RESTDataSource(httpClient: httpClientMock)

		// When / Then
		await #expect(throws: APIError.notFound) {
			_ = try await sut.fetch{Name}(identifier: 999)
		}
	}
}

// MARK: - Private

private extension {Name}RESTDataSourceTests {
	func loadJSON<T: Decodable>(_ filename: String) throws -> T {
		try Bundle.module.loadJSON(filename)
	}

	func loadJSONData(_ filename: String) throws -> Data {
		try Bundle.module.loadJSONData(filename)
	}
}
```

---

## Part B: GraphQL DataSource

### 1. Create DTO

Create `Sources/Data/DTOs/{Name}DTO.swift`:

```swift
struct {Name}DTO: Decodable, Equatable {
	let id: String
	let name: String
	// Add fields matching GraphQL response. Use CodingKeys for snake_case fields.
}
```

> **Note:** GraphQL IDs are `String` (not `Int` like REST). Use `CodingKeys` when field names differ from Swift conventions.

For paginated responses:

```swift
struct {Name}sResponseDTO: Decodable, Equatable {
	let info: {Name}PaginationInfoDTO
	let results: [{Name}DTO]
}

struct {Name}PaginationInfoDTO: Decodable, Equatable {
	let count: Int
	let pages: Int
	let next: Int?
	let prev: Int?
}
```

GraphQL pagination returns page numbers (not URLs like REST).

### 2. Create RemoteDataSource Contract

Same transport-agnostic contract as REST:

```swift
protocol {Name}RemoteDataSourceContract: Sendable {
	func fetch{Name}(identifier: Int) async throws -> {Name}DTO
	func fetch{Name}s(page: Int, filter: {Name}FilterDTO) async throws -> {Name}sResponseDTO
}
```

### 3. Create GraphQL Implementation

Create `Sources/Data/DataSources/Remote/{Name}GraphQLDataSource.swift`:

```swift
import ChallengeNetworking
import Foundation

struct {Name}GraphQLDataSource: {Name}RemoteDataSourceContract {
	private let graphQLClient: any GraphQLClientContract
	private let errorMapper = GraphQLErrorMapper()

	init(graphQLClient: any GraphQLClientContract) {
		self.graphQLClient = graphQLClient
	}

	func fetch{Name}s(page: Int, filter: {Name}FilterDTO) async throws -> {Name}sResponseDTO {
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

	func fetch{Name}(identifier: Int) async throws -> {Name}DTO {
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

private extension {Name}GraphQLDataSource {
	func request<T: Decodable>(_ operation: GraphQLOperation) async throws -> T {
		do {
			return try await graphQLClient.execute(operation)
		} catch let error as GraphQLError {
			throw errorMapper.map(error)
		}
	}
}

// MARK: - Response Wrappers

private struct {Name}sQueryResponse: Decodable {
	let {name}s: {Name}sResponseDTO
}

private struct {Name}QueryResponse: Decodable {
	let {name}: {Name}DTO
}

// MARK: - Queries

extension {Name}GraphQLDataSource {
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
- **Response wrappers**: Private structs that match the GraphQL `data` structure. Unwrap and return the inner DTO.
- **Query strings**: `static let` on the DataSource. Exposed (not private) so tests can verify the correct query is sent.
- **Error mapping**: `GraphQLErrorMapper` maps `GraphQLError` to `APIError` (same pattern as REST with `HTTPErrorMapper`).

### 4. Container Wiring

The container receives `HTTPClientContract` and creates the `GraphQLClient` internally:

```swift
import ChallengeCore
import ChallengeNetworking

public final class {Feature}Container {
	private let tracker: any TrackerContract
	private let {name}Repository: any {Name}RepositoryContract

	public init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
		self.tracker = tracker
		let graphQLClient = GraphQLClient(httpClient: httpClient)
		let remoteDataSource = {Name}GraphQLDataSource(graphQLClient: graphQLClient)
		self.{name}Repository = {Name}Repository(remoteDataSource: remoteDataSource)
	}
}
```

### 5. Create JSON Fixtures

GraphQL fixtures contain the **response wrapper** structure:

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

### 6. Create Mock

Same transport-agnostic mock as REST:

```swift
import Foundation

@testable import Challenge{Feature}

final class {Name}RemoteDataSourceMock: {Name}RemoteDataSourceContract, @unchecked Sendable {
	var {name}sResult: Result<{Name}sResponseDTO, Error> = .failure(NotConfiguredError.notConfigured)
	var {name}Result: Result<{Name}DTO, Error> = .failure(NotConfiguredError.notConfigured)
	private(set) var fetch{Name}sCallCount = 0
	private(set) var fetch{Name}CallCount = 0
	private(set) var lastFetchedPage: Int?
	private(set) var lastFetchedFilter: {Name}Filter?
	private(set) var lastFetchedIdentifier: Int?

	func fetch{Name}s(page: Int, filter: {Name}FilterDTO) async throws -> {Name}sResponseDTO {
		fetch{Name}sCallCount += 1
		lastFetchedPage = page
		lastFetchedFilter = filter
		return try {name}sResult.get()
	}

	func fetch{Name}(identifier: Int) async throws -> {Name}DTO {
		fetch{Name}CallCount += 1
		lastFetchedIdentifier = identifier
		return try {name}Result.get()
	}
}

private enum NotConfiguredError: Error {
	case notConfigured
}
```

### 7. Create Tests

Create `Tests/Unit/Data/{Name}GraphQLDataSourceTests.swift`:

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

Tests use `GraphQLClientMock` (from `ChallengeNetworkingMocks`), which bypasses the GraphQL envelope -- fixtures contain the unwrapped response wrapper directly.

---

## Part C: SwiftData EntityDataSource (Two-Level Cache)

Used for two-level caching (volatile + persistence): same `EntityDataSource` type, different `ModelContainer` configurations (in-memory vs on-disk).

### 1. Create Entity Models

Create `Sources/Data/Entities/{Name}Entity.swift`:

```swift
import Foundation
import SwiftData

@Model
nonisolated final class {Name}Entity {
	@Attribute(.unique) var identifier: Int
	var name: String

	init(identifier: Int, name: String) {
		self.identifier = identifier
		self.name = name
	}
}
```

Rules: `@Model`, `nonisolated final class`, `@Attribute(.unique)` on identifier. Use `@Relationship(deleteRule: .cascade, inverse: \ChildEntity.parent)` for parent-child relationships.

### 2. Create ModelContainer Factory

Create `Sources/Data/Entities/{Name}ModelContainer.swift`:

```swift
import Foundation
import SwiftData

enum {Name}ModelContainer {
	private static let schema = Schema([
		{Name}Entity.self
	])

	static func create(inMemoryOnly: Bool = false) -> ModelContainer {
		do {
			let configuration = ModelConfiguration("{Name}Store", schema: schema, isStoredInMemoryOnly: inMemoryOnly)
			return try ModelContainer(for: schema, configurations: [configuration])
		} catch {
			fatalError("Failed to create {Name}ModelContainer: \(error)")
		}
	}
}
```

Rules: Factory enum, single schema definition. **Named `ModelConfiguration` is mandatory** — each module must use a unique store name (e.g., `"{Name}Store"`) to avoid schema collisions when multiple modules use SwiftData. `inMemoryOnly: true` for volatile (L1), `false` for persistence (L2).

### 3. Create Entity Mappers

Create `Sources/Data/Mappers/{Name}EntityMapper.swift` and `{Name}EntityDTOMapper.swift`:

```swift
import ChallengeCore

struct {Name}EntityMapper: MapperContract {
	nonisolated func map(_ input: {Name}DTO) -> {Name}Entity {
		{Name}Entity(identifier: input.id, name: input.name)
	}
}

struct {Name}EntityDTOMapper: MapperContract {
	nonisolated func map(_ input: {Name}Entity) -> {Name}DTO {
		{Name}DTO(id: input.identifier, name: input.name)
	}
}
```

Rules: `nonisolated func map`, `MapperContract` from `ChallengeCore`. Sort collections by identifier when mapping from entity to DTO (SwiftData relationships don't guarantee order).

### 4. Create LocalDataSource Contract

Create `Sources/Data/DataSources/Local/{Name}LocalDataSourceContract.swift`:

```swift
protocol {Name}LocalDataSourceContract: Actor {
	func get{Name}(identifier: Int) -> {Name}DTO?
	func save{Name}(_ item: {Name}DTO)
}
```

Rules: `: Actor`, return optionals for get. Same contract for both volatile and persistence data sources.

### 5. Create EntityDataSource Implementation

Create `Sources/Data/DataSources/Local/{Name}EntityDataSource.swift`:

```swift
import Foundation
import SwiftData

@ModelActor
actor {Name}EntityDataSource: {Name}LocalDataSourceContract {
	private let entityMapper = {Name}EntityMapper()
	private let entityDTOMapper = {Name}EntityDTOMapper()

	func get{Name}(identifier: Int) -> {Name}DTO? {
		let descriptor = FetchDescriptor<{Name}Entity>(
			predicate: #Predicate { $0.identifier == identifier }
		)
		guard let entity = try? modelContext.fetch(descriptor).first else { return nil }
		return entityDTOMapper.map(entity)
	}

	func save{Name}(_ item: {Name}DTO) {
		let deleteDescriptor = FetchDescriptor<{Name}Entity>(
			predicate: #Predicate { $0.identifier == item.id }
		)
		if let existing = try? modelContext.fetch(deleteDescriptor).first {
			modelContext.delete(existing)
		}
		let entity = entityMapper.map(item)
		modelContext.insert(entity)
		try? modelContext.save()
	}
}
```

Rules: `@ModelActor` provides automatic actor isolation + `modelContext`. For upsert: delete existing before insert.

### 6. Container Wiring

```swift
let volatileContainer = {Name}ModelContainer.create(inMemoryOnly: true)
let persistenceContainer = {Name}ModelContainer.create()
let volatileDataSource = {Name}EntityDataSource(modelContainer: volatileContainer)
let persistenceDataSource = {Name}EntityDataSource(modelContainer: persistenceContainer)
self.repository = {Name}Repository(
	remoteDataSource: remoteDataSource,
	volatile: volatileDataSource,
	persistence: persistenceDataSource
)
```

Two `ModelContainer` instances → two `EntityDataSource` instances → both injected into repository as `volatile:` and `persistence:`.

### 7. Create Mock

Create `Tests/Shared/Mocks/{Name}LocalDataSourceMock.swift`:

```swift
import Foundation

@testable import Challenge{Feature}

actor {Name}LocalDataSourceMock: {Name}LocalDataSourceContract {
	// MARK: - Configurable Returns

	private(set) var itemToReturn: {Name}DTO?

	func setItemToReturn(_ item: {Name}DTO?) {
		itemToReturn = item
	}

	// MARK: - Call Tracking

	private(set) var get{Name}CallCount = 0
	private(set) var save{Name}CallCount = 0
	private(set) var save{Name}LastValue: {Name}DTO?

	// MARK: - {Name}LocalDataSourceContract

	func get{Name}(identifier: Int) -> {Name}DTO? {
		get{Name}CallCount += 1
		return itemToReturn
	}

	func save{Name}(_ item: {Name}DTO) {
		save{Name}CallCount += 1
		save{Name}LastValue = item
	}
}
```

Actor mock: `private(set)` on configurable returns with setter methods. Tests use `await` for all property reads and setter calls.

### 8. Create Tests

Create `Tests/Unit/Data/{Name}EntityDataSourceTests.swift`:

```swift
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Name}EntityDataSourceTests {
	private let sut: {Name}EntityDataSource

	init() {
		let container = {Name}ModelContainer.create(inMemoryOnly: true)
		sut = {Name}EntityDataSource(modelContainer: container)
	}

	@Test("Returns nil when not found")
	func returnsNil() async {
		let result = await sut.get{Name}(identifier: 999)
		#expect(result == nil)
	}

	@Test("Returns item after saving")
	func returnsAfterSaving() async throws {
		// Given
		let dto: {Name}DTO = try loadJSON("{name}")

		// When
		await sut.save{Name}(dto)
		let result = await sut.get{Name}(identifier: dto.id)

		// Then
		#expect(result == dto)
	}

	@Test("Upserts existing item")
	func upsertsExistingItem() async throws {
		// Given
		let original: {Name}DTO = try loadJSON("{name}")
		await sut.save{Name}(original)

		// When
		let updated: {Name}DTO = try loadJSON("{name}_updated")
		await sut.save{Name}(updated)
		let result = await sut.get{Name}(identifier: original.id)

		// Then
		#expect(result == updated)
	}
}

// MARK: - Private

private extension {Name}EntityDataSourceTests {
	func loadJSON<T: Decodable>(_ filename: String) throws -> T {
		try Bundle.module.loadJSON(filename)
	}
}
```

Tests use in-memory `ModelContainer` for isolation.

---

## Part D: UserDefaults DataSource

### 1. Create LocalDataSource Contract

Create `Sources/Data/DataSources/Local/{Name}LocalDataSourceContract.swift`:

```swift
protocol {Name}LocalDataSourceContract: Actor {
	func getItems() -> [String]
	func saveItem(_ item: String)
	func deleteItem(_ item: String)
}
```

Rules: `: Actor`. Methods are actor-isolated (implicitly `async` from caller). Adapt return types and parameters to the specific data being stored.

### 2. Create UserDefaultsDataSource Implementation

Create `Sources/Data/DataSources/Local/{Name}UserDefaultsDataSource.swift`:

```swift
import Foundation

actor {Name}UserDefaultsDataSource: {Name}LocalDataSourceContract {
	private let userDefaults: UserDefaults
	private let key = "{storageKey}"

	init(userDefaults: UserDefaults = .standard) {
		self.userDefaults = userDefaults
	}

	func getItems() -> [String] {
		userDefaults.stringArray(forKey: key) ?? []
	}

	func saveItem(_ item: String) {
		var items = getItems()
		// Remove duplicates (case-insensitive)
		items.removeAll { $0.caseInsensitiveCompare(item) == .orderedSame }
		items.insert(item, at: 0)
		// Enforce limit
		if items.count > 5 {
			items = Array(items.prefix(5))
		}
		userDefaults.set(items, forKey: key)
	}

	func deleteItem(_ item: String) {
		var items = getItems()
		items.removeAll { $0.caseInsensitiveCompare(item) == .orderedSame }
		userDefaults.set(items, forKey: key)
	}
}
```

> **Note:** `private let userDefaults` -- no `nonisolated(unsafe)` needed inside the actor. Actor isolation is sufficient. `UserDefaults` is thread-safe so it doesn't need additional protection. Adapt business rules (deduplication, ordering, limits) to the specific use case.

### 3. Create Mock

Create `Tests/Shared/Mocks/{Name}LocalDataSourceMock.swift`:

```swift
import Foundation

@testable import Challenge{Feature}

actor {Name}LocalDataSourceMock: {Name}LocalDataSourceContract {
	// MARK: - Configurable Returns

	private(set) var items: [String] = []

	func setItems(_ items: [String]) {
		self.items = items
	}

	// MARK: - Call Tracking

	private(set) var getItemsCallCount = 0
	private(set) var saveItemCallCount = 0
	private(set) var lastSavedItem: String?
	private(set) var deleteItemCallCount = 0
	private(set) var lastDeletedItem: String?

	// MARK: - {Name}LocalDataSourceContract

	func getItems() -> [String] {
		getItemsCallCount += 1
		return items
	}

	func saveItem(_ item: String) {
		saveItemCallCount += 1
		lastSavedItem = item
	}

	func deleteItem(_ item: String) {
		deleteItemCallCount += 1
		lastDeletedItem = item
	}
}
```

### 4. Create Tests

Create `Tests/Unit/Data/{Name}UserDefaultsDataSourceTests.swift`:

```swift
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Name}UserDefaultsDataSourceTests {
	// MARK: - Properties

	private let sut: {Name}UserDefaultsDataSource
	private nonisolated(unsafe) let userDefaults: UserDefaults

	// MARK: - Init

	init() {
		let suite = UserDefaults(suiteName: "\(type(of: self))")!
		suite.removePersistentDomain(forName: "\(type(of: self))")
		self.userDefaults = suite
		sut = {Name}UserDefaultsDataSource(userDefaults: suite)
	}

	// MARK: - Get

	@Test("Returns empty array initially")
	func returnsEmptyArrayInitially() async {
		let result = await sut.getItems()
		#expect(result.isEmpty)
	}

	// MARK: - Save

	@Test("Saves and retrieves item")
	func savesAndRetrievesItem() async {
		// When
		await sut.saveItem("test")

		// Then
		let result = await sut.getItems()
		#expect(result == ["test"])
	}

	@Test("Most recent item is first")
	func mostRecentItemIsFirst() async {
		// Given
		await sut.saveItem("first")

		// When
		await sut.saveItem("second")

		// Then
		let result = await sut.getItems()
		#expect(result == ["second", "first"])
	}

	@Test("Deduplicates case-insensitively")
	func deduplicatesCaseInsensitively() async {
		// Given
		await sut.saveItem("Test")

		// When
		await sut.saveItem("test")

		// Then
		let result = await sut.getItems()
		#expect(result == ["test"])
	}

	@Test("Enforces maximum limit")
	func enforcesMaximumLimit() async {
		// Given
		for i in 1...6 {
			await sut.saveItem("item\(i)")
		}

		// Then
		let result = await sut.getItems()
		#expect(result.count == 5)
		#expect(result.first == "item6")
	}

	// MARK: - Delete

	@Test("Deletes item case-insensitively")
	func deletesItemCaseInsensitively() async {
		// Given
		await sut.saveItem("Test")

		// When
		await sut.deleteItem("test")

		// Then
		let result = await sut.getItems()
		#expect(result.isEmpty)
	}

	// MARK: - Persistence

	@Test("Persists across instances")
	func persistsAcrossInstances() async {
		// Given
		await sut.saveItem("persisted")

		// When
		let otherInstance = {Name}UserDefaultsDataSource(userDefaults: userDefaults)
		let result = await otherInstance.getItems()

		// Then
		#expect(result == ["persisted"])
	}
}
```

**Key:** `nonisolated(unsafe)` on the test's `userDefaults` property -- needed because `UserDefaults` is not `Sendable` and crosses isolation boundaries when passed to the actor init. The `nonisolated(unsafe)` belongs at the **call site** (sender), not inside the actor.

Each test uses a dedicated `UserDefaults` suite to avoid cross-test contamination. The `init` clears the suite before each test.

---

## Key Principles

- Transport clients (`HTTPClientContract`, `GraphQLClientContract`) use `@concurrent` for off-MainActor execution — DataSource contracts do NOT need `@concurrent`
- **Contracts** are transport-agnostic, in separate files. Remote: `: Sendable`. Local (SwiftData, UserDefaults): `: Actor`
- **DTOs** are anemic: `Decodable`, `Equatable`, no behavior, no `toDomain()`
- **Error mapping**: DataSources catch transport errors and map to `APIError`. REST uses `HTTPErrorMapper`, GraphQL uses `GraphQLErrorMapper`
- **Repositories and upper layers only see `APIError`**, never transport-specific errors

## Checklists

### RemoteDataSource (REST)
- [ ] Create DTO (`Decodable`, `Equatable`, IDs are `Int`)
- [ ] Create Contract in `Remote/` with `async throws`
- [ ] Create RESTDataSource in `Remote/` with `HTTPErrorMapper`
- [ ] Create Mock in `Tests/Shared/Mocks/`
- [ ] Create JSON fixtures in `Tests/Shared/Fixtures/`
- [ ] Create tests

### RemoteDataSource (GraphQL)
- [ ] Create DTO (`Decodable`, `Equatable`, IDs are `String`)
- [ ] Create Contract in `Remote/` with `async throws`
- [ ] Create GraphQLDataSource in `Remote/` with `GraphQLErrorMapper`
- [ ] Create Mock in `Tests/Shared/Mocks/`
- [ ] Create JSON fixtures in `Tests/Shared/Fixtures/`
- [ ] Create tests

### EntityDataSource (SwiftData)
- [ ] Create `@Model` entities in `Entities/` with `nonisolated final class`
- [ ] Create `{Name}ModelContainer` enum with `create(inMemoryOnly:)` factory
- [ ] Create Contract in `Local/` with `: Actor`
- [ ] Create `@ModelActor actor` Implementation in `Local/`
- [ ] Create DTO ↔ Entity mappers in `Mappers/` (`MapperContract`)
- [ ] Create `actor` Mock with setter methods and call tracking
- [ ] Create tests (use in-memory `ModelContainer` for isolation)

### LocalDataSource (UserDefaults)
- [ ] Create Contract in `Local/` with `: Actor`
- [ ] Create `actor` Implementation in `Local/` with `private let userDefaults`
- [ ] Create `actor` Mock with setter methods and call tracking
- [ ] Create `async` tests using custom `UserDefaults` suite (`nonisolated(unsafe)` on test property)

## Next steps

- [Create Repository](create-repository.md) -- Create data abstraction using these DataSources

## See also

- [Project Structure](../ProjectStructure.md)
- [Testing](../Testing.md)
