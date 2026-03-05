# Test Patterns

## Simple Tests (no shared state)

For tests without shared dependencies, use inline setup:

```swift
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
import Testing

@testable import {AppName}Character

struct CharacterListViewModelTests {
    // MARK: - Properties

    private let useCaseMock = GetCharactersPageUseCaseMock()
    private let navigatorMock = CharacterListNavigatorMock()
    private let trackerMock = CharacterListTrackerMock()
    private let sut: CharacterListViewModel

    // MARK: - Initialization

    init() {
        sut = CharacterListViewModel(
            getCharactersPageUseCase: useCaseMock,
            navigator: navigatorMock,
            tracker: trackerMock
        )
    }

    // MARK: - Initial State

    @Test("Initial state is idle before loading")
    func initialStateIsIdle() {
        #expect(sut.state == .idle)
    }

    // MARK: - didSelect

    @Test("Selecting character navigates to detail and tracks selection")
    func didSelectNavigatesToCharacterDetailAndTracksSelection() {
        // Given
        let character = Character.stub(id: 42)

        // When
        sut.didSelect(character)

        // Then
        #expect(navigatorMock.navigateToDetailIdentifiers == [42])
        #expect(trackerMock.selectedIdentifiers == [42])
    }
}
```

**Benefits of instance variables pattern:**
- Cleaner tests without repeated setup
- `// Given` section only contains test-specific configuration
- Mocks configured on the instance, SUT created in `init()`
- Each test method gets a fresh instance (Swift Testing creates new struct per test)
- **MARK sections organized by method name** (`// MARK: - didAppear`, `// MARK: - didSelect`)
- **Consolidated assertions**: Each test verifies all side effects of an action (state, navigation, tracking)

---

## Scenario-Based Parameterized Tests (for Stateful ViewModels)

For ViewModel actions with multiple outcomes (success/failure/edge cases), use **scenario structs** with `@Test(arguments:)`. This replaces individual tests per outcome with a single parameterized test:

### Scenario Struct Pattern

```swift
// MARK: - Test Helpers

extension {Screen}ViewModelTests {
    nonisolated struct DidAppearScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let result: Result<{Name}, {Feature}Error>
        }

        struct Expected: Sendable {
            let state: {Screen}ViewState
            let loadErrorDescriptions: [String]
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [DidAppearScenario] = [
            DidAppearScenario(
                testDescription: "On success sets loaded state without tracking error",
                given: Given(result: .success(.stub())),
                expected: Expected(state: .loaded(.stub()), loadErrorDescriptions: [])
            ),
            DidAppearScenario(
                testDescription: "On failure sets error state and tracks load error",
                given: Given(result: .failure(.loadFailed())),
                expected: Expected(
                    state: .error(.loadFailed()),
                    loadErrorDescriptions: [{Feature}Error.loadFailed().debugDescription]
                )
            ),
        ]
    }
}
```

**Rules:**
- `nonisolated struct` + `Sendable` + `CustomTestStringConvertible` — required for Swift Testing arguments
- Inner `Given` and `Expected` structs for clear input/output separation
- `testDescription` provides readable test names in output
- `static let all` defines all scenarios in one place
- Place in `// MARK: - Test Helpers` extension at the end of the test file

### Using Scenarios in Tests

```swift
// MARK: - didAppear

@Test("didAppear produces expected outcome per scenario", arguments: DidAppearScenario.all)
func didAppear(scenario: DidAppearScenario) async {
    // Given
    getUseCaseMock.result = scenario.given.result

    // When
    await sut.didAppear()

    // Then
    #expect(getUseCaseMock.executeCallCount == 1)
    #expect(trackerMock.screenViewedCallCount == 1)
    #expect(sut.state == scenario.expected.state)
    #expect(trackerMock.loadErrorDescriptions == scenario.expected.loadErrorDescriptions)
}
```

### Helper Methods for Test Preconditions

Use `givenXxx()` helper methods to set up common preconditions. Call `reset()` on mocks to clear state from setup:

```swift
// MARK: - Helpers

private func givenErrorState() async {
    getUseCaseMock.result = .failure(.loadFailed())
    await sut.didAppear()
    getUseCaseMock.reset()
    trackerMock.reset()
}

private func givenLoadedState() async {
    getUseCaseMock.result = .success(.stub())
    await sut.didAppear()
    getUseCaseMock.reset()
    trackerMock.reset()
}
```

**Then use in tests:**

```swift
// MARK: - didTapOnRetryButton

@Test("didTapOnRetryButton produces expected outcome per scenario", arguments: DidTapOnRetryButtonScenario.all)
func didTapOnRetryButton(scenario: DidTapOnRetryButtonScenario) async {
    // Given
    await givenErrorState()
    getUseCaseMock.result = scenario.given.result

    // When
    await sut.didTapOnRetryButton()

    // Then
    #expect(getUseCaseMock.executeCallCount == 1)
    #expect(trackerMock.retryButtonTappedCallCount == 1)
    #expect(sut.state == scenario.expected.state)
}
```

**When to use scenarios vs. simple tests:**

| Pattern | When |
|---------|------|
| Scenario-based | Stateful ViewModel actions with success/failure outcomes |
| Consolidated assertion | Synchronous actions with single outcome (navigation + tracking) |
| Simple test | Non-ViewModel tests, single-case behaviors |

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
