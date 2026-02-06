---
name: testing
description: Testing patterns and conventions. Use when writing unit tests, using Swift Testing framework, or following Given/When/Then structure.
---

# Skill: Testing

Guide for writing tests using Swift Testing framework following project conventions.

## When to use this skill

- Write unit tests for any component
- Follow Given/When/Then structure
- Use parameterized tests
- Create test stubs for domain models

---

## Testing Frameworks

| Framework | Usage |
|-----------|-------|
| **Testing** (Swift Testing) | Unit tests, integration tests |
| **SnapshotTesting** | Snapshot tests for UI components (see `/snapshot` skill) |
| **XCTest** | UI tests (see `/ui-tests` skill) |

---

## Test Coverage Requirements

- All business logic (Use Cases) must have **100% test coverage**
- All ViewModels must have **comprehensive test coverage**
- All public API of shared modules must be tested
- UI components should have **snapshot tests**

### Coverage Scope

| Include | Exclude |
|---------|---------|
| Source targets (`Sources/`) | Mock targets (`Mocks/`) |
| Production code | Test targets (`Tests/`) |
| | External libraries |

**Never measure coverage on mock targets** - they exist solely to support tests and don't require their own coverage metrics.

---

## System Under Test (SUT)

Always name the object being tested as `sut` (System Under Test):

```swift
// RIGHT - Object under test named sut
let sut = GetUserUseCase(client: mockClient)
let result = try await sut.execute()

// WRONG - Generic or unclear names
let useCase = GetUserUseCase(client: mockClient)
let getUserUseCase = GetUserUseCase(client: mockClient)
```

---

## Test Descriptions

**All tests MUST include a description** in the `@Test` attribute:

```swift
// RIGHT - Always include a description
@Test("Fetches user successfully from repository")
func fetchesUserSuccessfully() async throws { }

@Test("Returns error when user not found")
func returnsErrorWhenUserNotFound() async throws { }

// WRONG - Missing description
@Test
func fetchesUserSuccessfully() async throws { }
```

**Rules:**
- Description should clearly explain what the test verifies
- Use sentence case (capitalize first word only)
- Keep descriptions concise but meaningful
- For parameterized tests, include description before `arguments:`

```swift
@Test("Rick and Morty API returns valid URL for all environments", arguments: [
    AppEnvironment.development,
    AppEnvironment.staging,
    AppEnvironment.production
])
func rickAndMortyReturnsValidURL(_ environment: AppEnvironment) { }
```

---

## Given / When / Then Structure

All tests must use `// Given`, `// When`, `// Then` comments:

```swift
@Test("Fetches user successfully from repository")
func fetchesUserSuccessfully() async throws {
    // Given
    let expectedUser = User(id: 1, name: "John")
    let mockClient = HTTPClientMock(result: .success(expectedUser.encoded()))
    let sut = GetUserUseCase(client: mockClient)

    // When
    let result = try await sut.execute(userId: 1)

    // Then
    #expect(result == expectedUser)
}
```

---

## Parameterized Tests

Always prefer `@Test(arguments:)` for testing multiple cases:

```swift
// RIGHT - Parameterized test with description
@Test("Endpoint supports HTTP method", arguments: [
    HTTPMethod.get,
    HTTPMethod.post,
    HTTPMethod.put,
    HTTPMethod.patch,
    HTTPMethod.delete,
])
func endpointSupportsHTTPMethod(_ method: HTTPMethod) {
    // Given
    let path = "/test"

    // When
    let sut = Endpoint(path: path, method: method)

    // Then
    #expect(sut.method == method)
}

// WRONG - Loop inside test (and missing description)
@Test("Endpoint supports all methods")
func endpointSupportsAllMethods() {
    for method in [HTTPMethod.get, .post, .put] {
        let endpoint = Endpoint(path: "/test", method: method)
        #expect(endpoint.method == method)
    }
}
```

### Multiple Arguments

```swift
@Test("HTTP error status code equality", arguments: [
    (404, 404, true),
    (404, 500, false),
    (200, 200, true),
])
func httpErrorStatusCodeEquality(
    lhsCode: Int,
    rhsCode: Int,
    expectedEqual: Bool
) {
    // Given
    let data = Data("test".utf8)
    let lhs = HTTPError.statusCode(lhsCode, data)
    let rhs = HTTPError.statusCode(rhsCode, data)

    // When
    let areEqual = lhs == rhs

    // Then
    #expect(areEqual == expectedEqual)
}
```

---

## Assertions

```swift
// Use #expect for assertions
#expect(value == expected)
#expect(array.isEmpty)
#expect(count > 0)

// Use #require for unwrapping (fails test if nil)
let data = try #require(response.data)
let user = try #require(users.first)

// Use #expect(throws:) for error testing
await #expect(throws: HTTPError.invalidURL) {
    try await client.request(invalidEndpoint)
}
```

---

## Comparing Results

**Always compare full objects** instead of checking individual properties:

```swift
// RIGHT - Compare full objects using stubs
@Test("Fetches character correctly from repository")
func fetchesCharacterCorrectly() async throws {
    // Given
    let expected = Character.stub()
    let dataSource = CharacterDataSourceMock(result: .success(.stub()))
    let sut = CharacterRepository(dataSource: dataSource)

    // When
    let value = try await sut.getCharacter(id: 1)

    // Then
    #expect(value == expected)
}

// WRONG - Checking individual properties
@Test("Fetches character correctly from repository")
func fetchesCharacterCorrectly() async throws {
    // ...
    let result = try await sut.getCharacter(id: 1)

    #expect(result.id == 1)
    #expect(result.name == "Rick Sanchez")
    #expect(result.status == .alive)
    #expect(result.species == "Human")
}
```

**Rules:**
- Use `value` as the variable name for the result being tested
- Create an `expected` variable with the stub matching the expected output
- Compare with a single `#expect(value == expected)`

---

## Test Naming

```swift
// RIGHT - Descriptive function name, no "test" prefix, with description
@Test("Returns correct value when input is valid")
func returnsCorrectValue() { }

@Test("Throws error when input is invalid")
func throwsErrorWhenInvalid() { }

@Test("Fetches user successfully from remote")
func fetchesUserSuccessfully() { }

// WRONG - "test" prefix
@Test("Returns correct value")
func testReturnsCorrectValue() { }
```

---

## Time Limits

Use `@Suite(.timeLimit(.minutes(1)))` **only** for test suites that use `async/await` to prevent infinite waits:

```swift
// RIGHT - Async tests need time limit
@Suite(.timeLimit(.minutes(1)))
struct GetCharacterUseCaseTests {
    @Test("Fetches character successfully from repository")
    func fetchesCharacterSuccessfully() async throws {
        // ...
    }
}

// RIGHT - Synchronous tests don't need time limit
struct CharacterStatusTests {
    @Test("Init from string returns correct status value")
    func initFromStringReturnsCorrectValue() {
        // ...
    }
}
```

**Rules:**
- Add `@Suite(.timeLimit(.minutes(1)))` to suites with `async` test functions
- Omit time limit for synchronous test suites (snapshot tests, unit tests without async)
- Time limit prevents tests from hanging indefinitely on failed async operations

---

## Stubs (Test Data for Domain Models)

Use the **stub pattern** to create test data for **Domain Models only**.

**Location:** `Tests/Shared/Stubs/`

```
FeatureName/
└── Tests/
    ├── Unit/                     # Unit tests
    ├── Snapshots/                # Snapshot tests
    └── Shared/                   # Shared resources (used by both Unit and Snapshots)
        ├── Stubs/                # Test data factories for Domain Models
        │   ├── Character+Stub.swift
        │   └── Location+Stub.swift
        ├── Mocks/                # Internal test mocks
        ├── Fixtures/             # JSON files for DTOs
        ├── Extensions/           # Equatable conformances, etc.
        └── Resources/            # Test images
```

**Stub extension pattern:**

```swift
// Tests/Shared/Stubs/User+Stub.swift
extension User {
    static func stub(
        id: Int = 1,
        name: String = "John Doe",
        email: String = "john@example.com"
    ) -> User {
        User(
            id: id,
            name: name,
            email: email
        )
    }
}
```

**Rules:**
- File naming: `{TypeName}+Stub.swift`
- Method name: `static func stub(...)`
- All parameters must have default values
- Defaults should be valid, realistic values
- Located in `Tests/Shared/Stubs/` (shared between Unit and Snapshot tests)
- **Only for Domain Models** (not DTOs - use JSON fixtures instead)

**Usage in tests:**

```swift
@Test("Processes user correctly with default values")
func processesUserCorrectly() {
    // Default stub
    let user = User.stub()

    // Customized stub
    let admin = User.stub(name: "Admin", role: .admin)

    // Multiple stubs
    let users = [User.stub(id: 1), User.stub(id: 2)]
}
```

---

## JSON Fixtures (for DTOs)

**DTOs use JSON files** instead of stubs. See `/datasource` skill for JSON fixtures documentation.

---

## Mocks Location

| Location | Visibility | Usage |
|----------|------------|-------|
| `Mocks/` (framework) | Public | Mocks used by other modules |
| `Tests/Shared/Mocks/` | Internal | Mocks shared between Unit and Snapshot tests |

### Mock vs Fake

**Mocks** should NOT contain implementation logic. They only:
1. Return configurable values
2. Track method calls (counts, parameters)

```swift
// RIGHT - Pure Mock (no logic)
final class DataSourceMock: DataSourceContract {
    var valueToReturn: Data?
    private(set) var saveCallCount = 0
    private(set) var saveLastValue: Data?

    func get() -> Data? { valueToReturn }
    func save(_ data: Data) {
        saveCallCount += 1
        saveLastValue = data
    }
}

// WRONG - Fake with implementation logic
final class DataSourceMock: DataSourceContract {
    private var storage: [String: Data] = [:]  // ❌ Real storage

    func get(key: String) -> Data? {
        storage[key]  // ❌ Real lookup
    }
    func save(_ data: Data, key: String) {
        storage[key] = data  // ❌ Real storage
    }
}
```

### Mock Pattern for Actor Types

When mocking `actor` types (e.g., MemoryDataSource), use a plain `final class` with `@unchecked Sendable`:

```swift
// Original in main module
actor CharacterMemoryDataSource: CharacterMemoryDataSourceContract { }

// Mock in test module - plain class, no actor isolation
final class CharacterMemoryDataSourceMock: CharacterMemoryDataSourceContract, @unchecked Sendable {
    var characterToReturn: CharacterDTO?
    private(set) var saveCallCount = 0
    private(set) var saveLastValue: CharacterDTO?

    func getCharacter(identifier: Int) -> CharacterDTO? { characterToReturn }
    func saveCharacter(_ character: CharacterDTO) {
        saveCallCount += 1
        saveLastValue = character
    }
}
```

**Why:** Using a plain class avoids actor isolation in tests, allowing direct property access without `await` for configuring and verifying mocks.

---

## Equatable Extensions for Tests

When a type doesn't conform to `Equatable` in production code (e.g., contains `Error`), but tests need to compare it with `#expect(value == expected)`, create an **Equatable extension in the shared test folder**.

**Location:** `Tests/Shared/Extensions/`

```
FeatureName/
└── Tests/
    ├── Unit/
    ├── Snapshots/
    └── Shared/
        ├── Extensions/                # Equatable conformances for testing
        │   ├── SomeViewState+Equatable.swift
        │   └── AnotherType+Equatable.swift
        ├── Stubs/
        ├── Mocks/
        └── ...
```

**Extension pattern:**

```swift
// Tests/Shared/Extensions/CharacterDetailViewState+Equatable.swift
import Foundation

@testable import {AppName}Character

extension CharacterDetailViewState: @retroactive Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
		case (.idle, .idle), (.loading, .loading):
			true
		case let (.loaded(lhsValue), .loaded(rhsValue)):
			lhsValue == rhsValue
		case let (.error(lhsError), .error(rhsError)):
			lhsError.localizedDescription == rhsError.localizedDescription
		default:
			false
		}
	}
}
```

**Rules:**
- File naming: `{TypeName}+Equatable.swift`
- Located in `Tests/Shared/Extensions/` (shared between Unit and Snapshot tests)
- **Use `@retroactive`** to silence the "conformance of imported type" warning
- Use for types that can't be Equatable in production (contain `Error`, closures, etc.)
- Compare `Error` cases by `localizedDescription` for simplicity
- Keep production code clean - no test-only conformances in source

**Common types needing this pattern:**
- ViewState enums with `.error(Error)` cases
- Result wrappers with non-Equatable associated values

---

## Test File Patterns

### Simple Tests (no shared state)

For tests without shared dependencies, use inline setup:

```swift
import Foundation
import Testing

@testable import {AppName}Character

struct GetCharacterUseCaseTests {
    @Test("Returns character from repository")
    func returnsCharacterFromRepository() async throws {
        // Given
        let expected = Character.stub()
        let repositoryMock = CharacterRepositoryMock()
        repositoryMock.result = .success(expected)
        let sut = GetCharacterUseCase(repository: repositoryMock)

        // When
        let value = try await sut.execute(id: 1)

        // Then
        #expect(value == expected)
    }
}
```

### Tests with Instance Variables (preferred for ViewModels)

For tests that share mocks and SUT across multiple tests, use instance variables with `init()`:

```swift
import Foundation
import Testing

@testable import {AppName}Character

@Suite(.timeLimit(.minutes(1)))
struct CharacterListViewModelTests {
    // MARK: - Properties

    private let useCaseMock = GetCharactersUseCaseMock()
    private let navigatorMock = CharacterListNavigatorMock()
    private let sut: CharacterListViewModel

    // MARK: - Initialization

    init() {
        sut = CharacterListViewModel(
            getCharactersUseCase: useCaseMock,
            navigator: navigatorMock
        )
    }

    // MARK: - Tests

    @Test("Initial state is idle")
    func initialStateIsIdle() {
        // Then
        #expect(sut.state == .idle)
    }

    @Test("Load sets loaded state on success")
    func loadSetsLoadedStateOnSuccess() async {
        // Given
        let expected = CharactersPage.stub()
        useCaseMock.result = .success(expected)

        // When
        await sut.didAppear()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test("Did select navigates to character detail")
    func didSelectNavigatesToCharacterDetail() {
        // Given
        let character = Character.stub(id: 42)

        // When
        sut.didSelect(character)

        // Then
        #expect(navigatorMock.navigateToDetailIds == [42])
    }
}
```

**Benefits of instance variables pattern:**
- Cleaner tests without repeated setup
- `// Given` section only contains test-specific configuration
- Mocks configured on the instance, SUT created in `init()`
- Each test method gets a fresh instance (Swift Testing creates new struct per test)

---

## Test Isolation for Parallel Execution

All test targets use `parallelization: .swiftTestingOnly`, so tests within each target run in parallel. To prevent race conditions, tests must avoid shared mutable state.

### Unique Hosts for URLProtocolMock

When testing code that uses `URLProtocolMock`, each test must use a **unique host** to prevent handler collisions in the global handler dictionary:

```swift
@Test("Fetches data from correct URL")
func fetchesDataFromCorrectURL() async throws {
    // Given
    let (sut, baseURL) = try makeSUT(host: "test-fetches-data")
    // ...
}

@Test("Decodes response correctly")
func decodesResponseCorrectly() async throws {
    // Given
    let (sut, baseURL) = try makeSUT(host: "test-decodes-response")
    // ...
}

private func makeSUT(host: String) throws -> (HTTPClient, URL) {
    let baseURL = try #require(URL(string: "https://\(host).example.com"))
    let sut = HTTPClient(baseURL: baseURL, session: URLSession.mockSession())
    return (sut, baseURL)
}
```

**Rules:**
- Each test gets a unique host name (e.g., `test-builds-url`, `test-decodes-json`)
- Use a `makeSUT(host:)` factory method to create the SUT with a unique base URL
- Never use `.serialized` trait when unique hosts eliminate the race condition

### Deterministic Async Testing with Task.value

When testing ViewModels that spawn internal `Task`s (e.g., debounced search), **never use `Task.sleep`** to wait for completion. Instead, expose the task as `private(set)` and use `await task.value`:

```swift
// In ViewModel: expose the task for test access
private(set) var searchTask: Task<Void, Never>?

// In tests: wait deterministically
sut.searchQuery = "Rick"
await sut.searchTask?.value

#expect(searchUseCaseMock.lastRequestedQuery == "Rick")
```

**Rules:**
- Inject `debounceInterval: .zero` in tests to eliminate timing sensitivity
- Use `await sut.searchTask?.value` to wait for the spawned task to complete
- Never use `Task.sleep` or `Task.yield` — they are inherently flaky under load
- The `private(set)` visibility allows `@testable import` access without exposing publicly

---

## Checklist

- [ ] Test file named `{ComponentName}Tests.swift` in `Tests/Unit/`
- [ ] **All `@Test` attributes include a description**
- [ ] SUT variable named `sut`
- [ ] All tests use Given/When/Then comments
- [ ] No `test` prefix in method names
- [ ] Full object comparison (not individual properties)
- [ ] Parameterized tests for multiple cases
- [ ] Stubs created for Domain Models in `Tests/Shared/Stubs/`
- [ ] Mocks placed in appropriate location (`Tests/Shared/Mocks/` or `Mocks/`)
- [ ] Equatable extensions in `Tests/Shared/Extensions/` for types with `Error`
- [ ] JSON fixtures in `Tests/Shared/Fixtures/`
- [ ] Test resources (images) in `Tests/Shared/Resources/`
