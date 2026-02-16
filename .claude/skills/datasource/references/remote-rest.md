# REST DataSource Templates

Placeholders: `{Name}` (PascalCase entity), `{Feature}` (PascalCase module), `{name}` (snake_case), `{resource}` (API path segment), `{endpoint}` (full API path).

---

### {Name}DTO.swift — `Sources/Data/DTOs/`

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

### {Name}RemoteDataSourceContract.swift — `Sources/Data/DataSources/Remote/`

```swift
protocol {Name}RemoteDataSourceContract: Sendable {
	func fetch{Name}(identifier: Int) async throws -> {Name}DTO
}
```

### {Name}RESTDataSource.swift — `Sources/Data/DataSources/Remote/`

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

> **Note:** `@concurrent` is on `HTTPClientContract.request()`, NOT on DataSource methods. The transport client handles off-MainActor execution (JSON decode + network I/O). DataSources only do trivial work (endpoint building, error mapping). `ChallengeNetworking` uses `nonisolated` default isolation — `Endpoint`, `HTTPMethod`, and other networking types don't need `nonisolated` annotations.

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

### {Name}RemoteDataSourceMock.swift — `Tests/Shared/Mocks/`

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

### {name}.json — `Tests/Shared/Fixtures/`

```json
{
	"id": 1,
	"name": "Example"
}
```

Match the exact structure returned by the API. Use realistic data.

### {Name}RESTDataSourceTests.swift — `Tests/Unit/Data/`

```swift
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import Challenge{Feature}

@Suite(.timeLimit(.minutes(1)))
struct {Name}RESTDataSourceTests {
	private let httpClientMock = HTTPClientMock()
	private let sut: {Name}RESTDataSource

	init() {
		sut = {Name}RESTDataSource(httpClient: httpClientMock)
	}

	// MARK: - Fetch {Name}

	@Test("Fetch {name} uses correct endpoint")
	func fetchUsesCorrectEndpoint() async throws {
		// Given
		let jsonData = try loadJSONData("{name}")
		httpClientMock.result = .success(jsonData)

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
		httpClientMock.result = .success(jsonData)

		// When
		let result = try await sut.fetch{Name}(identifier: 1)

		// Then
		#expect(result.id == 1)
	}

	@Test("Fetch {name} maps HTTP error to API error")
	func fetchMapsHTTPError() async {
		// Given
		httpClientMock.result = .failure(HTTPError.statusCode(404, Data()))

		// When / Then
		await #expect(throws: APIError.notFound) {
			try await sut.fetch{Name}(identifier: 999)
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
