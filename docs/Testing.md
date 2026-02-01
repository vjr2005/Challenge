# Testing

## Test Types

| Type | Framework | Location |
|------|-----------|----------|
| Unit Tests | Swift Testing | `*/Tests/` |
| Snapshot Tests | SnapshotTesting | `*/Tests/Snapshots/` |
| UI Tests | XCTest | `App/UITests/` |

## Test Structure

Tests follow Given/When/Then structure:

```swift
@Test
func fetchesCharacters() async throws {
    // Given
    let sut = GetCharactersUseCase(repository: repositoryMock)

    // When
    let result = try await sut.execute(page: 1)

    // Then
    #expect(result.characters.count == 2)
}
```

## Coverage

<img src="screenshots/coverage.png" width="100%">
