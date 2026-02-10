# Test Patterns

## Simple Tests (no shared state)

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

---

## Tests with Instance Variables (preferred for ViewModels)

For tests that share mocks and SUT across multiple tests, use instance variables with `init()`:

```swift
import Foundation
import Testing

@testable import {AppName}Character

@Suite(.timeLimit(.minutes(1)))
struct CharacterListViewModelTests {
    // MARK: - Properties

    private let useCaseMock = GetCharactersPageUseCaseMock()
    private let navigatorMock = CharacterListNavigatorMock()
    private let sut: CharacterListViewModel

    // MARK: - Initialization

    init() {
        sut = CharacterListViewModel(
            getCharactersPageUseCase: useCaseMock,
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
