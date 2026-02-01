# Testing

## Test Types

| Type | Framework | Location |
|------|-----------|----------|
| Unit Tests | Swift Testing | `*/Tests/Unit/` |
| Snapshot Tests | SnapshotTesting | `*/Tests/Snapshots/` |
| UI Tests | XCTest | `App/Tests/UI/` |

## Test Structure

Tests follow Given/When/Then structure:

```swift
@Test("Fetches characters from repository")
func fetchesCharacters() async throws {
    // Given
    let sut = GetCharactersUseCase(repository: repositoryMock)

    // When
    let result = try await sut.execute(page: 1)

    // Then
    #expect(result.characters.count == 2)
}
```

## Test Doubles

The project uses **Mocks** to isolate units under test. Mocks are located in:

| Location | Scope | Purpose |
|----------|-------|---------|
| `Libraries/Core/Mocks/` | Public | Shared mocks for Core protocols |
| `Libraries/Networking/Mocks/` | Public | Shared mocks for Networking protocols |
| `*/Tests/Shared/Mocks/` | Internal | Module-specific test mocks |

### Example Mock

```swift
final class CharacterRepositoryMock: CharacterRepositoryContract {
    var getCharactersResult: Result<CharacterPage, Error> = .success(.stub())

    func getCharacters(page: Int) async throws -> CharacterPage {
        try getCharactersResult.get()
    }
}
```

### Test Data

| Location | Purpose |
|----------|---------|
| `*/Tests/Shared/Stubs/` | Domain model test data (`.stub()` extensions) |
| `*/Tests/Shared/Fixtures/` | JSON files for DTO testing |

## Coverage

The project achieves **100% code coverage** across all modules.

<img src="screenshots/coverage.png" width="100%">

### Coverage Policy

- All production code must be tested
- Only source targets are measured (mocks and test helpers are excluded)
- Coverage is enforced in CI pipeline
