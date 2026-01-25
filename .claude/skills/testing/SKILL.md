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
| **XCTest** | UI tests / E2E (see `/e2e-tests` skill) |

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

## Given / When / Then Structure

All tests must use `// Given`, `// When`, `// Then` comments:

```swift
@Test
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
// RIGHT - Parameterized test
@Test(arguments: [
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

// WRONG - Loop inside test
@Test
func endpointSupportsAllMethods() {
    for method in [HTTPMethod.get, .post, .put] {
        let endpoint = Endpoint(path: "/test", method: method)
        #expect(endpoint.method == method)
    }
}
```

### Multiple Arguments

```swift
@Test(arguments: [
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
@Test
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
@Test
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
// RIGHT - Descriptive, no "test" prefix
func returnsCorrectValue() { }
func throwsErrorWhenInvalid() { }
func fetchesUserSuccessfully() { }

// WRONG - "test" prefix
func testReturnsCorrectValue() { }
func testThrowsError() { }
```

---

## Stubs (Test Data for Domain Models)

Use the **stub pattern** to create test data for **Domain Models only**.

**Location:** `Tests/Stubs/`

```
FeatureName/
└── Tests/
    ├── Stubs/                    # Test data factories for Domain Models
    │   ├── Character+Stub.swift
    │   └── Location+Stub.swift
    ├── Mocks/
    └── Data/
```

**Stub extension pattern:**

```swift
// Tests/Stubs/User+Stub.swift
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
- Located in `Tests/Stubs/` (internal to test target)
- **Only for Domain Models** (not DTOs - use JSON fixtures instead)

**Usage in tests:**

```swift
@Test
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
| `Tests/Mocks/` | Internal | Mocks only used within the test target |

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

### Mock Actor Isolation

The project uses `SWIFT_DEFAULT_ACTOR_ISOLATION: MainActor`. When mocking `actor` types from the main module:

```swift
// Original in main module (compiles because same-module access)
actor CharacterMemoryDataSource: CharacterMemoryDataSourceContract { }

// Mock in test module - use @MainActor class instead of actor
@MainActor
final class CharacterMemoryDataSourceMock: CharacterMemoryDataSourceContract, @unchecked Sendable {
    // Implementation
}
```

**Why:** When importing types with `@testable import`, the test module sees types with MainActor isolation. Using `@MainActor final class` aligns the mock with this isolation context.

---

## Equatable Extensions for Tests

When a type doesn't conform to `Equatable` in production code (e.g., contains `Error`), but tests need to compare it with `#expect(value == expected)`, create an **Equatable extension in the test target**.

**Location:** `Tests/Extensions/`

```
FeatureName/
└── Tests/
    ├── Extensions/                    # Equatable conformances for testing
    │   ├── SomeViewState+Equatable.swift
    │   └── AnotherType+Equatable.swift
    ├── Stubs/
    ├── Mocks/
    └── ...
```

**Extension pattern:**

```swift
// Tests/Extensions/CharacterDetailViewState+Equatable.swift
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
- Located in `Tests/Extensions/` (internal to test target)
- **Use `@retroactive`** to silence the "conformance of imported type" warning
- Use for types that can't be Equatable in production (contain `Error`, closures, etc.)
- Compare `Error` cases by `localizedDescription` for simplicity
- Keep production code clean - no test-only conformances in source

**Common types needing this pattern:**
- ViewState enums with `.error(Error)` cases
- Result wrappers with non-Equatable associated values

---

## Example Test File

```swift
import Foundation
import Testing

@testable import {AppName}Character

struct GetCharacterUseCaseTests {
    @Test
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

    @Test
    func callsRepositoryWithCorrectId() async throws {
        // Given
        let repositoryMock = CharacterRepositoryMock()
        repositoryMock.result = .success(.stub())
        let sut = GetCharacterUseCase(repository: repositoryMock)

        // When
        _ = try await sut.execute(id: 42)

        // Then
        #expect(repositoryMock.getCallCount == 1)
        #expect(repositoryMock.lastRequestedId == 42)
    }

    @Test
    func propagatesRepositoryError() async throws {
        // Given
        let repositoryMock = CharacterRepositoryMock()
        repositoryMock.result = .failure(TestError.network)
        let sut = GetCharacterUseCase(repository: repositoryMock)

        // When / Then
        await #expect(throws: TestError.network) {
            _ = try await sut.execute(id: 1)
        }
    }
}

private enum TestError: Error {
    case network
}
```

---

## Checklist

- [ ] Test file named `{ComponentName}Tests.swift`
- [ ] SUT variable named `sut`
- [ ] All tests use Given/When/Then comments
- [ ] No `test` prefix in method names
- [ ] Full object comparison (not individual properties)
- [ ] Parameterized tests for multiple cases
- [ ] Stubs created for Domain Models in `Tests/Stubs/`
- [ ] Mocks placed in appropriate location (Tests/Mocks/ or Mocks/)
- [ ] Equatable extensions in `Tests/Extensions/` for types with `Error`
