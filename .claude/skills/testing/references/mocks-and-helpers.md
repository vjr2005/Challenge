# Mocks, Stubs & Helpers

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
    private var storage: [String: Data] = [:]  // Real storage

    func get(key: String) -> Data? {
        storage[key]  // Real lookup
    }
    func save(_ data: Data, key: String) {
        storage[key] = data  // Real storage
    }
}
```

### Mock Pattern for Actor Contracts (`: Actor`)

When mocking `: Actor` protocols (e.g., EntityDataSource, UserDefaultsDataSource), the mock must also be an `actor` with setter methods:

```swift
// Contract
protocol CharacterLocalDataSourceContract: Actor {
    func getCharacter(identifier: Int) -> CharacterDTO?
    func saveCharacter(_ character: CharacterDTO)
}

// Mock — actor with setter methods for configuration
actor CharacterLocalDataSourceMock: CharacterLocalDataSourceContract {
    private(set) var characterToReturn: CharacterDTO?
    private(set) var saveCallCount = 0

    func setCharacterToReturn(_ character: CharacterDTO?) {
        characterToReturn = character
    }

    func getCharacter(identifier: Int) -> CharacterDTO? { characterToReturn }
    func saveCharacter(_ character: CharacterDTO) {
        saveCallCount += 1
    }
}
```

Tests use `await` for all mock property reads and setter calls.

### Mock Pattern for Sendable Contracts with `nonisolated` Methods

When mocking `: Sendable` protocols with `nonisolated` methods (e.g., FileSystem wrapping a thread-safe API), use `final class` + `@unchecked Sendable` + `nonisolated(unsafe)` properties + `nonisolated` methods:

```swift
// Contract — Sendable with nonisolated methods (NOT Actor)
protocol FileSystemContract: Sendable {
    nonisolated func contents(at url: URL) throws -> Data
    nonisolated func write(_ data: Data, to url: URL) throws
}

// Mock — final class with nonisolated(unsafe) properties
final class FileSystemMock: FileSystemContract, @unchecked Sendable {
    nonisolated(unsafe) var files: [URL: Data] = [:]
    nonisolated(unsafe) var writeError: (any Error)?
    nonisolated(unsafe) private(set) var writeCallCount = 0

    @MainActor init() {}

    nonisolated func contents(at url: URL) throws -> Data {
        guard let data = files[url] else { throw CocoaError(.fileReadNoSuchFile) }
        return data
    }

    nonisolated func write(_ data: Data, to url: URL) throws {
        writeCallCount += 1
        if let writeError { throw writeError }
        files[url] = data
    }
}
```

**Why this is safe:** The actor that owns the mock serializes all calls. Tests configure the mock on MainActor (setup) and verify on MainActor (assertions) — no concurrent access. No `await` needed for mock property reads/writes.

**When to use which pattern:**

| Protocol type | Mock type | Properties | Methods | `await` in tests |
|--------------|-----------|------------|---------|-----------------|
| `: Actor` | `actor` | `private(set)` + setter methods | Actor-isolated | Yes, for all access |
| `: Sendable` + `nonisolated` | `final class @unchecked Sendable` | `nonisolated(unsafe)` | `nonisolated` | No |

---

## Stubs (Test Data for Domain Models)

Use the **stub pattern** to create test data for **Domain Models only**.

**Location:** `Tests/Shared/Stubs/`

```
FeatureName/
└── Tests/
    ├── Unit/
    ├── Snapshots/
    └── Shared/
        ├── Stubs/                # Test data factories for Domain Models
        │   ├── Character+Stub.swift
        │   └── Location+Stub.swift
        ├── Mocks/
        ├── Fixtures/
        ├── Extensions/
        └── Resources/
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

## Equatable Extensions for Tests

When a type doesn't conform to `Equatable` in production code (e.g., contains `Error`), but tests need to compare it with `#expect(value == expected)`, create an **Equatable extension in the shared test folder**.

**Location:** `Tests/Shared/Extensions/`

```
FeatureName/
└── Tests/
    └── Shared/
        └── Extensions/
            ├── SomeViewState+Equatable.swift
            └── AnotherType+Equatable.swift
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
