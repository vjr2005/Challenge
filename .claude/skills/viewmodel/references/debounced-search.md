# Debounced Search ViewModel

Extends the stateful list pattern with search query debouncing and recent searches. Uses `@Observable` with observable state and search properties.

Placeholders: `{Name}` (PascalCase entity), `{Screen}` (PascalCase screen), `{Feature}` (PascalCase module), `{AppName}` (app target prefix).

---

## Contract

```swift
import Foundation

protocol {Screen}ViewModelContract: AnyObject {
    var state: {Screen}ViewState { get }
    var searchQuery: String { get set }
    var recentSearches: [String] { get }
    func didAppear() async
    func didTapOnRetryButton() async
    func didPullToRefresh() async
    func didSelect(_ item: {Name})
    func didSelectRecentSearch(_ query: String) async
    func didDeleteRecentSearch(_ query: String)
}
```

## Search Property with Guard

```swift
var searchQuery: String = "" {
    didSet {
        if searchQuery != oldValue {
            searchQueryDidChange()
        }
    }
}
```

> **Why:** SwiftUI may re-set binding values during navigation transitions, triggering `didSet` even when the value hasn't changed. The guard prevents unnecessary reloads.

## Debounce Mechanism

```swift
@Observable
final class {Screen}ViewModel: {Screen}ViewModelContract {
    private(set) var state: {Screen}ViewState = .idle
    private(set) var recentSearches: [String] = []
    var searchQuery: String = "" {
        didSet {
            if searchQuery != oldValue {
                searchQueryDidChange()
            }
        }
    }

    private let get{Name}sUseCase: Get{Name}sUseCaseContract
    private let search{Name}sUseCase: Search{Name}sUseCaseContract
    private let getRecentSearchesUseCase: GetRecentSearchesUseCaseContract
    private let saveRecentSearchUseCase: SaveRecentSearchUseCaseContract
    private let deleteRecentSearchUseCase: DeleteRecentSearchUseCaseContract
    private let navigator: {Screen}NavigatorContract
    private let tracker: {Screen}TrackerContract
    private let debounceInterval: Duration
    private(set) var searchTask: Task<Void, Never>?

    init(
        get{Name}sUseCase: Get{Name}sUseCaseContract,
        search{Name}sUseCase: Search{Name}sUseCaseContract,
        getRecentSearchesUseCase: GetRecentSearchesUseCaseContract,
        saveRecentSearchUseCase: SaveRecentSearchUseCaseContract,
        deleteRecentSearchUseCase: DeleteRecentSearchUseCaseContract,
        navigator: {Screen}NavigatorContract,
        tracker: {Screen}TrackerContract,
        debounceInterval: Duration = .milliseconds(300)
    ) {
        self.get{Name}sUseCase = get{Name}sUseCase
        self.search{Name}sUseCase = search{Name}sUseCase
        self.getRecentSearchesUseCase = getRecentSearchesUseCase
        self.saveRecentSearchUseCase = saveRecentSearchUseCase
        self.deleteRecentSearchUseCase = deleteRecentSearchUseCase
        self.navigator = navigator
        self.tracker = tracker
        self.debounceInterval = debounceInterval
    }

    // ... public methods (didAppear, didTapOnRetryButton, etc.)

    func didSelectRecentSearch(_ query: String) async {
        searchQuery = query
        searchTask?.cancel()
        saveRecentSearchUseCase.execute(query: query)
        loadRecentSearches()
        tracker.trackSearchPerformed(query: query)
        await fetchResults()
    }

    func didDeleteRecentSearch(_ query: String) {
        deleteRecentSearchUseCase.execute(query: query)
        loadRecentSearches()
    }
}

// MARK: - Private

private extension {Screen}ViewModel {
    var normalizedQuery: String? {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }

    func searchQueryDidChange() {
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            try? await Task.sleep(for: debounceInterval)
            if !Task.isCancelled {
                if let query = normalizedQuery {
                    tracker.trackSearchPerformed(query: query)
                    saveRecentSearchUseCase.execute(query: query)
                    loadRecentSearches()
                }
                await fetchResults()
            }
        }
    }

    func fetchResults() async {
        do {
            let result: [{Name}]
            if let query = normalizedQuery {
                result = try await search{Name}sUseCase.execute(query: query)
            } else {
                result = try await get{Name}sUseCase.execute()
            }
            state = result.isEmpty ? .empty : .loaded(result)
        } catch {
            guard !Task.isCancelled else { return }
            tracker.trackFetchError(description: error.debugDescription)
            state = .error(error)
        }
    }

    func loadRecentSearches() {
        recentSearches = getRecentSearchesUseCase.execute()
    }
}
```

**Debounce Rules:**
- Inject `debounceInterval: Duration` with default `.milliseconds(300)`
- Expose `searchTask` as `private(set)` for deterministic test waiting
- Cancel the previous task before creating a new one
- Check `Task.isCancelled` after the sleep to avoid stale executions
- Guard against `Task.isCancelled` in the catch block to ignore errors from cancelled requests

## Testing Debounced Search

```swift
import Foundation
import Testing

@testable import {AppName}{Feature}

struct {Screen}ViewModelTests {
    private let getUseCaseMock = Get{Name}sUseCaseMock()
    private let searchUseCaseMock = Search{Name}sUseCaseMock()
    private let getRecentSearchesMock = GetRecentSearchesUseCaseMock()
    private let saveRecentSearchMock = SaveRecentSearchUseCaseMock()
    private let deleteRecentSearchMock = DeleteRecentSearchUseCaseMock()
    private let navigatorMock = {Screen}NavigatorMock()
    private let trackerMock = {Screen}TrackerMock()
    private let sut: {Screen}ViewModel

    init() {
        sut = {Screen}ViewModel(
            get{Name}sUseCase: getUseCaseMock,
            search{Name}sUseCase: searchUseCaseMock,
            getRecentSearchesUseCase: getRecentSearchesMock,
            saveRecentSearchUseCase: saveRecentSearchMock,
            deleteRecentSearchUseCase: deleteRecentSearchMock,
            navigator: navigatorMock,
            tracker: trackerMock,
            debounceInterval: .zero    // Zero debounce for tests
        )
    }

    @Test("Search query triggers debounced search")
    func searchQueryTriggersSearch() async {
        // Given
        searchUseCaseMock.result = .success([.stub()])

        // When
        sut.searchQuery = "Rick"
        await sut.searchTask?.value

        // Then
        #expect(searchUseCaseMock.lastRequestedQuery == "Rick")
    }

    @Test("Search query guards against unchanged value")
    func searchQueryGuardsUnchanged() async {
        // Given
        searchUseCaseMock.result = .success([.stub()])
        sut.searchQuery = "Rick"
        await sut.searchTask?.value

        // When — set same value again
        sut.searchQuery = "Rick"
        await sut.searchTask?.value

        // Then — only one search call
        #expect(searchUseCaseMock.executeCallCount == 1)
    }

    @Test("Empty search query fetches all items")
    func emptySearchFetchesAll() async {
        // Given
        getUseCaseMock.result = .success([.stub()])
        searchUseCaseMock.result = .success([.stub()])
        sut.searchQuery = "Rick"
        await sut.searchTask?.value

        // When
        sut.searchQuery = ""
        await sut.searchTask?.value

        // Then
        #expect(getUseCaseMock.executeCallCount == 1)
    }

    @Test("didSelectRecentSearch searches immediately")
    func didSelectRecentSearchSearchesImmediately() async {
        // Given
        searchUseCaseMock.result = .success([.stub()])

        // When
        await sut.didSelectRecentSearch("Rick")

        // Then
        #expect(searchUseCaseMock.lastRequestedQuery == "Rick")
    }

    @Test("didDeleteRecentSearch removes and reloads")
    func didDeleteRecentSearchRemovesAndReloads() {
        // When
        sut.didDeleteRecentSearch("Rick")

        // Then
        #expect(deleteRecentSearchMock.executeCallCount == 1)
        #expect(getRecentSearchesMock.executeCallCount == 1)
    }
}
```

> **Important:** Never use `Task.sleep` in tests to wait for debounce. Use `await sut.searchTask?.value` instead — it is deterministic and verified stable at 1000 iterations.
