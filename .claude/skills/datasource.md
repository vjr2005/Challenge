# Skill: RemoteDataSource

Guide for creating RemoteDataSources that consume REST APIs using the Repository pattern.

## When to use this skill

- Create a new RemoteDataSource to consume an API
- Add endpoints to an existing DataSource
- Create DTOs for API responses

## File structure

```
Libraries/Features/{FeatureName}/
├── Sources/
│   └── Data/
│       ├── DataSources/
│       │   └── {Name}RemoteDataSource.swift    # Contract + Implementation
│       └── DTOs/
│           └── {Name}DTO.swift                  # Data Transfer Objects (internal)
└── Tests/
    ├── Data/
    │   └── {Name}RemoteDataSourceTests.swift    # Tests
    └── Mocks/
        └── {Name}RemoteDataSourceMock.swift     # Mock (internal to tests)
```

> **Note:** DataSource mocks are placed in `Tests/Mocks/` because they use internal DTOs and are only needed within the feature's test target.

## API Configuration

Base URLs are defined in `Libraries/Core/Sources/API/APIConfiguration.swift`:

```swift
public enum APIConfiguration {
    case example
    // Add new APIs here

    public var baseURL: URL {
        switch self {
        case .example:
            URL(string: "https://api.example.com")!
        }
    }
}
```

> **Note:** Add new cases for each API your app consumes.

## RemoteDataSource Pattern

### 1. Contract (Protocol)

```swift
protocol {Name}RemoteDataSourceContract: Sendable {
    func fetch{Name}(id: Int) async throws -> {Name}DTO
    func fetchAll{Name}s() async throws -> [{Name}DTO]
}
```

**Rules:**
- `Contract` suffix in the name
- **Internal visibility** (not public) - DataSources are implementation details
- Conform to `Sendable`
- Methods are `async throws`
- Return DTOs, not domain models

### 2. Implementation

```swift
struct {Name}RemoteDataSource: {Name}RemoteDataSourceContract {
    private let httpClient: HTTPClientContract

    init(httpClient: HTTPClientContract) {
        self.httpClient = httpClient
    }

    func fetch{Name}(id: Int) async throws -> {Name}DTO {
        let endpoint = Endpoint(path: "/{resource}/\(id)")
        return try await httpClient.request(endpoint)
    }
}
```

**Rules:**
- **Internal visibility** (not public)
- Inject `HTTPClientContract` (not the concrete implementation)
- Use `Endpoint` to define requests
- `HTTPClient` automatically decodes the response

### 3. DTO (Data Transfer Object)

```swift
struct {Name}DTO: Decodable {
    let id: Int
    let name: String
    // Properties matching the API JSON response
}
```

**Rules:**
- `DTO` suffix in the name
- **Never public** - DTOs are internal implementation details of the Data layer
- Conform to `Decodable`
- Use `let` properties (immutable)
- Property names must match JSON keys (or use CodingKeys)

### 4. Mock (in Tests/Mocks/)

```swift
import Foundation

@testable import Challenge{FeatureName}

final class {Name}RemoteDataSourceMock: {Name}RemoteDataSourceContract, @unchecked Sendable {
    var result: Result<{Name}DTO, Error> = .failure(MockError.notConfigured)
    private(set) var fetchCallCount = 0
    private(set) var lastFetchedId: Int?

    func fetch{Name}(id: Int) async throws -> {Name}DTO {
        fetchCallCount += 1
        lastFetchedId = id
        return try result.get()
    }
}

private enum MockError: Error {
    case notConfigured
}
```

**Rules:**
- `Mock` suffix in the name
- **Internal visibility** - placed in `Tests/Mocks/`, not in `Mocks/` framework
- **Requires `@testable import`** to access internal types (Contract, DTO)
- `@unchecked Sendable` if it has mutable state
- Properties for call tracking
- Configurable result using `Result`
- Default result should be `.failure` to catch unconfigured mocks

## Testing

### RemoteDataSource Test

```swift
import ChallengeNetworkingMocks
import Foundation
import Testing

@testable import Challenge{FeatureName}

struct {Name}RemoteDataSourceTests {
    @Test
    func fetchesFromCorrectEndpoint() async throws {
        // Given
        let httpClient = HTTPClientMock(result: .success(makeStubData()))
        let sut = {Name}RemoteDataSource(httpClient: httpClient)

        // When
        _ = try await sut.fetch{Name}(id: 1)

        // Then
        let endpoint = try #require(httpClient.requestedEndpoints.first)
        #expect(endpoint.path == "/{resource}/1")
        #expect(endpoint.method == .get)
    }

    @Test
    func decodesResponseCorrectly() async throws {
        // Given
        let httpClient = HTTPClientMock(result: .success(makeStubData()))
        let sut = {Name}RemoteDataSource(httpClient: httpClient)

        // When
        let result = try await sut.fetch{Name}(id: 1)

        // Then
        #expect(result.id == 1)
        #expect(result.name == "Expected Name")
    }

    @Test
    func throwsOnHTTPError() async throws {
        // Given
        let httpClient = HTTPClientMock(result: .failure(TestError.network))
        let sut = {Name}RemoteDataSource(httpClient: httpClient)

        // When / Then
        await #expect(throws: TestError.network) {
            _ = try await sut.fetch{Name}(id: 1)
        }
    }
}

private enum TestError: Error {
    case network
}

private extension {Name}RemoteDataSourceTests {
    func makeStubData() -> Data {
        let json = """
        {
            "id": 1,
            "name": "Expected Name"
        }
        """
        return Data(json.utf8)
    }
}
```

## Usage with HTTPClient

```swift
// Create the client with the API base URL
let httpClient = HTTPClient(baseURL: APIConfiguration.example.baseURL)

// Create the DataSource
let dataSource = {Name}RemoteDataSource(httpClient: httpClient)

// Fetch data
let item = try await dataSource.fetch{Name}(id: 1)
```

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| Contract | internal | `Sources/Data/DataSources/` |
| Implementation | internal | `Sources/Data/DataSources/` |
| DTO | internal | `Sources/Data/DTOs/` |
| Mock | internal | `Tests/Mocks/` |

## Checklist

- [ ] Create DTO with properties matching the JSON (internal)
- [ ] Create Contract with async throws methods (internal)
- [ ] Create Implementation injecting HTTPClientContract (internal)
- [ ] Create Mock in `Tests/Mocks/` with call tracking (internal)
- [ ] Create tests using HTTPClientMock
- [ ] Add module to Project.swift
- [ ] Run `tuist generate`
- [ ] Run tests
