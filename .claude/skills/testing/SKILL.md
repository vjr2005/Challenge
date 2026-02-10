---
name: testing
description: Testing patterns and conventions. Use when writing unit tests, using Swift Testing framework, or following Given/When/Then structure.
---

# Skill: Testing

Guide for writing tests using Swift Testing framework following project conventions.

## References

- **Test file patterns** (simple, instance variables, isolation): See [references/test-patterns.md](references/test-patterns.md)
- **Mocks, stubs & helpers** (mock patterns, stubs, Equatable extensions): See [references/mocks-and-helpers.md](references/mocks-and-helpers.md)

---

## Testing Frameworks

| Framework | Usage |
|-----------|-------|
| **Testing** (Swift Testing) | Unit tests, integration tests |
| **ChallengeSnapshotTestKit** | Snapshot tests for UI components (see `/snapshot` skill) |
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

---

## System Under Test (SUT)

Always name the object being tested as `sut`:

```swift
// RIGHT
let sut = GetUserUseCase(client: mockClient)

// WRONG
let useCase = GetUserUseCase(client: mockClient)
```

---

## Test Descriptions

**All tests MUST include a description** in the `@Test` attribute:

```swift
// RIGHT
@Test("Fetches user successfully from repository")
func fetchesUserSuccessfully() async throws { }

// WRONG - Missing description
@Test
func fetchesUserSuccessfully() async throws { }
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
let expected = Character.stub()
let value = try await sut.getCharacter(id: 1)
#expect(value == expected)

// WRONG - Checking individual properties
#expect(result.id == 1)
#expect(result.name == "Rick Sanchez")
```

**Rules:**
- Use `value` as the variable name for the result being tested
- Create an `expected` variable with the stub matching the expected output
- Compare with a single `#expect(value == expected)`

---

## Parameterized Tests

Always prefer `@Test(arguments:)` for testing multiple cases:

```swift
@Test("Endpoint supports HTTP method", arguments: [
    HTTPMethod.get,
    HTTPMethod.post,
    HTTPMethod.put,
])
func endpointSupportsHTTPMethod(_ method: HTTPMethod) {
    // Given
    let path = "/test"

    // When
    let sut = Endpoint(path: path, method: method)

    // Then
    #expect(sut.method == method)
}
```

---

## Test Naming

```swift
// RIGHT - Descriptive function name, no "test" prefix
@Test("Returns correct value when input is valid")
func returnsCorrectValue() { }

// WRONG - "test" prefix
@Test("Returns correct value")
func testReturnsCorrectValue() { }
```

---

## Time Limits

Use `@Suite(.timeLimit(.minutes(1)))` **only** for test suites that use `async/await`:

```swift
// Async tests need time limit
@Suite(.timeLimit(.minutes(1)))
struct GetCharacterUseCaseTests { }

// Synchronous tests don't need time limit
struct CharacterStatusTests { }
```

---

## File Structure

```
Tests/
├── Unit/
│   ├── Domain/UseCases/{Name}UseCaseTests.swift
│   ├── Data/{Name}RepositoryTests.swift
│   ├── Presentation/{Screen}/ViewModels/{Screen}ViewModelTests.swift
│   └── Feature/{Feature}FeatureTests.swift
├── Snapshots/Presentation/{Screen}/{Screen}ViewSnapshotTests.swift
└── Shared/
    ├── Stubs/{Name}+Stub.swift
    ├── Mocks/{Name}Mock.swift
    ├── Fixtures/{name}.json
    ├── Extensions/{Name}+Equatable.swift
    └── Resources/test-avatar.jpg
```

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
