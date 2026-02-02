# How To: Create ViewModel

Create ViewModels for state management with the ViewState pattern.

## Prerequisites

- Feature module exists (see [Create Feature](create-feature.md))
- UseCase exists (see [Create UseCase](create-usecase.md))
- Navigator exists (see [Create Navigator](create-navigator.md))

## File structure

```
Features/{Feature}/
├── Sources/
│   └── Presentation/
│       └── {ScreenName}/
│           └── ViewModels/
│               ├── {ScreenName}ViewModelContract.swift
│               ├── {ScreenName}ViewState.swift
│               └── {ScreenName}ViewModel.swift
└── Tests/
    ├── Unit/
    │   └── Presentation/
    │       └── {ScreenName}/
    │           └── ViewModels/
    │               └── {ScreenName}ViewModelTests.swift
    └── Shared/
        ├── Stubs/
        │   └── {ScreenName}ViewModelStub.swift
        └── Extensions/
            └── {ScreenName}ViewState+Equatable.swift
```

---

## Option A: Detail ViewModel (with state)

For ViewModels that display a single item with loading/error states.

### 1. Create ViewState

Create `Sources/Presentation/{ScreenName}/ViewModels/{ScreenName}ViewState.swift`:

```swift
import Foundation

enum {ScreenName}ViewState {
    case idle
    case loading
    case loaded({Name})
    case error({Feature}Error)
}
```

> **Note:** ViewState is kept simple. Equatable conformance is added in `Tests/Shared/Extensions/` for testing.

### 2. Create ViewModel Contract

Create `Sources/Presentation/{ScreenName}/ViewModels/{ScreenName}ViewModelContract.swift`:

```swift
import Foundation

protocol {ScreenName}ViewModelContract: AnyObject {
    var state: {ScreenName}ViewState { get }
    func loadIfNeeded() async
    func refresh() async
    func didTapOnBack()
}
```

### 3. Create ViewModel

Create `Sources/Presentation/{ScreenName}/ViewModels/{ScreenName}ViewModel.swift`:

```swift
import Foundation

@Observable
final class {ScreenName}ViewModel: {ScreenName}ViewModelContract {
    private(set) var state: {ScreenName}ViewState = .idle

    private let identifier: Int
    private let get{Name}UseCase: Get{Name}UseCaseContract
    private let navigator: {ScreenName}NavigatorContract

    init(
        identifier: Int,
        get{Name}UseCase: Get{Name}UseCaseContract,
        navigator: {ScreenName}NavigatorContract
    ) {
        self.identifier = identifier
        self.get{Name}UseCase = get{Name}UseCase
        self.navigator = navigator
    }

    func loadIfNeeded() async {
        switch state {
        case .idle, .error:
            await load()
        case .loading, .loaded:
            break
        }
    }

    func refresh() async {
        do {
            let item = try await get{Name}UseCase.execute(
                identifier: identifier,
                cachePolicy: .remoteFirst
            )
            state = .loaded(item)
        } catch {
            state = .error(error)
        }
    }

    func didTapOnBack() {
        navigator.goBack()
    }
}

// MARK: - Private

private extension {ScreenName}ViewModel {
    func load() async {
        state = .loading
        do {
            let item = try await get{Name}UseCase.execute(identifier: identifier)
            state = .loaded(item)
        } catch {
            state = .error(error)
        }
    }
}
```

**Key patterns:**
- `@Observable` for SwiftUI integration (iOS 17+)
- `loadIfNeeded()` is public, `load()` is private
- `refresh()` uses `.remoteFirst` cache policy
- State is `private(set)` - only ViewModel mutates it

### 4. Create ViewState Equatable extension (for tests)

Create `Tests/Shared/Extensions/{ScreenName}ViewState+Equatable.swift`:

```swift
@testable import Challenge{Feature}

extension {ScreenName}ViewState: @retroactive Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            true
        case let (.loaded(lhsItem), .loaded(rhsItem)):
            lhsItem == rhsItem
        case let (.error(lhsError), .error(rhsError)):
            lhsError == rhsError
        default:
            false
        }
    }
}
```

### 5. Create Stub (for snapshot tests)

Create `Tests/Shared/Stubs/{ScreenName}ViewModelStub.swift`:

```swift
import Foundation

@testable import Challenge{Feature}

/// ViewModel stub for snapshot tests.
/// Maintains a fixed state without performing any async operations.
@Observable
final class {ScreenName}ViewModelStub: {ScreenName}ViewModelContract {
    var state: {ScreenName}ViewState

    init(state: {ScreenName}ViewState) {
        self.state = state
    }

    func loadIfNeeded() async {
        // No-op: state is fixed for snapshots
    }

    func refresh() async {
        // No-op: state is fixed for snapshots
    }

    func didTapOnBack() {
        // No-op: navigation not tested in snapshots
    }
}
```

### 6. Create tests

Create `Tests/Unit/Presentation/{ScreenName}/ViewModels/{ScreenName}ViewModelTests.swift`:

```swift
import Foundation
import Testing

@testable import Challenge{Feature}

@Suite(.timeLimit(.minutes(1)))
struct {ScreenName}ViewModelTests {
    private let identifier = 1
    private let useCaseMock = Get{Name}UseCaseMock()
    private let navigatorMock = {ScreenName}NavigatorMock()
    private let sut: {ScreenName}ViewModel

    init() {
        sut = {ScreenName}ViewModel(
            identifier: identifier,
            get{Name}UseCase: useCaseMock,
            navigator: navigatorMock
        )
    }

    // MARK: - Initial State

    @Test("Initial state is idle before loading")
    func initialStateIsIdle() {
        // Then
        #expect(sut.state == .idle)
    }

    // MARK: - Load If Needed

    @Test("Load if needed sets loaded state on success")
    func loadIfNeededSetsLoadedStateOnSuccess() async {
        // Given
        let expected = {Name}.stub()
        useCaseMock.result = .success(expected)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test("Load if needed sets error state on failure")
    func loadIfNeededSetsErrorStateOnFailure() async {
        // Given
        useCaseMock.result = .failure(.loadFailed)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    @Test("Load if needed calls use case with correct identifier")
    func loadIfNeededCallsUseCaseWithCorrectIdentifier() async {
        // Given
        useCaseMock.result = .success(.stub())

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.executeCallCount == 1)
        #expect(useCaseMock.lastRequestedIdentifier == identifier)
    }

    @Test("Load if needed uses localFirst cache policy by default")
    func loadIfNeededUsesLocalFirstCachePolicy() async {
        // Given
        useCaseMock.result = .success(.stub())

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.lastCachePolicy == .localFirst)
    }

    @Test("Load if needed does nothing when already loaded")
    func loadIfNeededDoesNothingWhenLoaded() async {
        // Given
        useCaseMock.result = .success(.stub())
        await sut.loadIfNeeded()
        let callCountAfterFirstLoad = useCaseMock.executeCallCount

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.executeCallCount == callCountAfterFirstLoad)
    }

    @Test("Load if needed retries when in error state")
    func loadIfNeededRetriesWhenError() async {
        // Given
        useCaseMock.result = .failure(.loadFailed)
        await sut.loadIfNeeded()
        let callCountAfterFirstLoad = useCaseMock.executeCallCount

        // When
        useCaseMock.result = .success(.stub())
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.executeCallCount == callCountAfterFirstLoad + 1)
    }

    // MARK: - Refresh

    @Test("Refresh updates item with fresh data from API")
    func refreshUpdatesItemFromAPI() async {
        // Given
        useCaseMock.result = .success(.stub(name: "Initial"))
        await sut.loadIfNeeded()
        useCaseMock.result = .success(.stub(name: "Refreshed"))

        // When
        await sut.refresh()

        // Then
        #expect(useCaseMock.executeCallCount == 2)
    }

    @Test("Refresh uses remoteFirst cache policy")
    func refreshUsesRemoteFirstCachePolicy() async {
        // Given
        useCaseMock.result = .success(.stub())

        // When
        await sut.refresh()

        // Then
        #expect(useCaseMock.lastCachePolicy == .remoteFirst)
    }

    @Test("Refresh sets error state on failure")
    func refreshSetsErrorStateOnFailure() async {
        // Given
        useCaseMock.result = .failure(.loadFailed)

        // When
        await sut.refresh()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    // MARK: - Navigation

    @Test("Tap on back navigates back")
    func didTapOnBackCallsNavigatorGoBack() {
        // When
        sut.didTapOnBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }
}
```

---

## Option B: List ViewModel (with pagination)

For ViewModels that display lists with pagination support.

### 1. Create ViewState

Create `Sources/Presentation/{ScreenName}/ViewModels/{ScreenName}ViewState.swift`:

```swift
import Foundation

enum {ScreenName}ViewState {
    case idle
    case loading
    case loaded({Name}sPage)
    case empty
    case error({Feature}Error)
}
```

### 2. Create ViewModel Contract

Create `Sources/Presentation/{ScreenName}/ViewModels/{ScreenName}ViewModelContract.swift`:

```swift
import Foundation

protocol {ScreenName}ViewModelContract: AnyObject {
    var state: {ScreenName}ViewState { get }
    func loadIfNeeded() async
    func didSelect(_ item: {Name})
}
```

### 3. Create ViewModel

Create `Sources/Presentation/{ScreenName}/ViewModels/{ScreenName}ViewModel.swift`:

```swift
import Foundation

@Observable
final class {ScreenName}ViewModel: {ScreenName}ViewModelContract {
    private(set) var state: {ScreenName}ViewState = .idle

    private let get{Name}sUseCase: Get{Name}sUseCaseContract
    private let navigator: {ScreenName}NavigatorContract

    init(
        get{Name}sUseCase: Get{Name}sUseCaseContract,
        navigator: {ScreenName}NavigatorContract
    ) {
        self.get{Name}sUseCase = get{Name}sUseCase
        self.navigator = navigator
    }

    func loadIfNeeded() async {
        switch state {
        case .idle, .error:
            await load()
        case .loading, .loaded, .empty:
            break
        }
    }

    func didSelect(_ item: {Name}) {
        navigator.navigateToDetail(id: item.id)
    }
}

// MARK: - Private

private extension {ScreenName}ViewModel {
    func load() async {
        state = .loading
        do {
            let result = try await get{Name}sUseCase.execute(page: 1)
            state = result.items.isEmpty ? .empty : .loaded(result)
        } catch {
            state = .error(error)
        }
    }
}
```

### 4. Create ViewState Equatable extension

Create `Tests/Shared/Extensions/{ScreenName}ViewState+Equatable.swift`:

```swift
@testable import Challenge{Feature}

extension {ScreenName}ViewState: @retroactive Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.empty, .empty):
            true
        case let (.loaded(lhsPage), .loaded(rhsPage)):
            lhsPage == rhsPage
        case let (.error(lhsError), .error(rhsError)):
            lhsError == rhsError
        default:
            false
        }
    }
}
```

### 5. Create Stub

Create `Tests/Shared/Stubs/{ScreenName}ViewModelStub.swift`:

```swift
import Foundation

@testable import Challenge{Feature}

@Observable
final class {ScreenName}ViewModelStub: {ScreenName}ViewModelContract {
    var state: {ScreenName}ViewState

    init(state: {ScreenName}ViewState) {
        self.state = state
    }

    func loadIfNeeded() async {}

    func didSelect(_ item: {Name}) {}
}
```

### 6. Create tests

Create `Tests/Unit/Presentation/{ScreenName}/ViewModels/{ScreenName}ViewModelTests.swift`:

```swift
import Foundation
import Testing

@testable import Challenge{Feature}

@Suite(.timeLimit(.minutes(1)))
struct {ScreenName}ViewModelTests {
    private let useCaseMock = Get{Name}sUseCaseMock()
    private let navigatorMock = {ScreenName}NavigatorMock()
    private let sut: {ScreenName}ViewModel

    init() {
        sut = {ScreenName}ViewModel(
            get{Name}sUseCase: useCaseMock,
            navigator: navigatorMock
        )
    }

    // MARK: - Initial State

    @Test("Initial state is idle")
    func initialStateIsIdle() {
        #expect(sut.state == .idle)
    }

    // MARK: - Load If Needed

    @Test("Load if needed sets loaded state on success")
    func loadIfNeededSetsLoadedStateOnSuccess() async {
        // Given
        let expected = {Name}sPage.stub()
        useCaseMock.result = .success(expected)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test("Load if needed sets empty state when no items")
    func loadIfNeededSetsEmptyStateWhenNoItems() async {
        // Given
        useCaseMock.result = .success({Name}sPage.stub(items: []))

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .empty)
    }

    @Test("Load if needed sets error state on failure")
    func loadIfNeededSetsErrorStateOnFailure() async {
        // Given
        useCaseMock.result = .failure(.loadFailed)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    @Test("Load if needed does nothing when loaded")
    func loadIfNeededDoesNothingWhenLoaded() async {
        // Given
        useCaseMock.result = .success(.stub())
        await sut.loadIfNeeded()
        let callCount = useCaseMock.executeCallCount

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.executeCallCount == callCount)
    }

    @Test("Load if needed does nothing when empty")
    func loadIfNeededDoesNothingWhenEmpty() async {
        // Given
        useCaseMock.result = .success(.stub(items: []))
        await sut.loadIfNeeded()
        let callCount = useCaseMock.executeCallCount

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.executeCallCount == callCount)
    }

    @Test("Load if needed retries when error")
    func loadIfNeededRetriesWhenError() async {
        // Given
        useCaseMock.result = .failure(.loadFailed)
        await sut.loadIfNeeded()
        let callCount = useCaseMock.executeCallCount

        // When
        useCaseMock.result = .success(.stub())
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.executeCallCount == callCount + 1)
    }

    // MARK: - Navigation

    @Test("Did select navigates to detail")
    func didSelectNavigatesToDetail() {
        // Given
        let item = {Name}.stub(id: 42)

        // When
        sut.didSelect(item)

        // Then
        #expect(navigatorMock.navigateToDetailIds == [42])
    }
}
```

---

## Option C: Stateless ViewModel (navigation only)

For ViewModels with no observable state, only navigation actions.

### 1. Create ViewModel Contract

Create `Sources/Presentation/{ScreenName}/ViewModels/{ScreenName}ViewModelContract.swift`:

```swift
protocol {ScreenName}ViewModelContract {
    func didTapOn{Action}()
}
```

### 2. Create ViewModel

Create `Sources/Presentation/{ScreenName}/ViewModels/{ScreenName}ViewModel.swift`:

```swift
/// Not @Observable: no state for the view to observe, only exposes actions.
final class {ScreenName}ViewModel: {ScreenName}ViewModelContract {
    private let navigator: {ScreenName}NavigatorContract

    init(navigator: {ScreenName}NavigatorContract) {
        self.navigator = navigator
    }

    func didTapOn{Action}() {
        navigator.navigateTo{Destination}()
    }
}
```

> **Note:** No `@Observable` - the ViewModel has no state for the View to observe.

### 3. Create Stub

Create `Tests/Shared/Stubs/{ScreenName}ViewModelStub.swift`:

```swift
@testable import Challenge{Feature}

final class {ScreenName}ViewModelStub: {ScreenName}ViewModelContract {
    func didTapOn{Action}() {}
}
```

### 4. Create tests

Create `Tests/Unit/Presentation/{ScreenName}/ViewModels/{ScreenName}ViewModelTests.swift`:

```swift
import Testing

@testable import Challenge{Feature}

@Suite(.timeLimit(.minutes(1)))
struct {ScreenName}ViewModelTests {
    private let navigatorMock = {ScreenName}NavigatorMock()
    private let sut: {ScreenName}ViewModel

    init() {
        sut = {ScreenName}ViewModel(navigator: navigatorMock)
    }

    @Test("Did tap on action navigates to destination")
    func didTapOnActionNavigatesToDestination() {
        // When
        sut.didTapOn{Action}()

        // Then
        #expect(navigatorMock.navigateTo{Destination}CallCount == 1)
    }
}
```

---

## Generate and verify

```bash
./generate.sh
```

## Next steps

- [Create View](create-view.md) - Create SwiftUI View that uses the ViewModel

## See also

- [Create UseCase](create-usecase.md) - UseCase that ViewModel depends on
- [Create Navigator](create-navigator.md) - Navigator for navigation
- [Testing](../Testing.md)
