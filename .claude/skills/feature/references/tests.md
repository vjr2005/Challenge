# Test Templates

Same placeholders as [sources.md](sources.md).

---

## Mocks

### {Screen}NavigatorMock.swift

Path: `Tests/Shared/Mocks/{Screen}NavigatorMock.swift`

```swift
@testable import Challenge{Feature}

final class {Screen}NavigatorMock: {Screen}NavigatorContract {}
```

### {Screen}TrackerMock.swift

Path: `Tests/Shared/Mocks/{Screen}TrackerMock.swift`

```swift
@testable import Challenge{Feature}

final class {Screen}TrackerMock: {Screen}TrackerContract {
    private(set) var trackScreenViewedCallCount = 0

    func trackScreenViewed() {
        trackScreenViewedCallCount += 1
    }
}
```

---

## Stubs

### {Screen}ViewModelStub.swift

Path: `Tests/Shared/Stubs/{Screen}ViewModelStub.swift`

```swift
@testable import Challenge{Feature}

final class {Screen}ViewModelStub: {Screen}ViewModelContract {
    func didAppear() {}
}
```

---

## Unit Tests

### {Feature}FeatureTests.swift

Path: `Tests/Unit/Feature/{Feature}FeatureTests.swift`

```swift
import ChallengeCore
import ChallengeCoreMocks
import SwiftUI
import Testing

@testable import Challenge{Feature}

struct {Feature}FeatureTests {
    // MARK: - Properties

    private let navigatorMock = NavigatorMock()
    private let sut: {Feature}Feature

    // MARK: - Init

    init() {
        sut = {Feature}Feature(tracker: TrackerMock())
    }

    // MARK: - Deep Link Handler

    @Test("Deep link handler is not nil")
    func deepLinkHandlerIsNotNil() {
        #expect(sut.deepLinkHandler != nil)
    }

    // MARK: - Make Main View

    @Test("Make main view returns a view")
    func makeMainViewReturnsView() {
        // When
        let result = sut.makeMainView(navigator: navigatorMock)

        // Then
        _ = result
    }

    // MARK: - Resolve

    @Test("Resolve main navigation returns view")
    func resolveMainNavigationReturnsView() {
        // When
        let result = sut.resolve({Feature}IncomingNavigation.main, navigator: navigatorMock)

        // Then
        #expect(result != nil)
    }

    @Test("Resolve unknown navigation returns nil")
    func resolveUnknownNavigationReturnsNil() {
        // Given
        struct UnknownNav: NavigationContract {}

        // When
        let result = sut.resolve(UnknownNav(), navigator: navigatorMock)

        // Then
        #expect(result == nil)
    }
}
```

### {Feature}DeepLinkHandlerTests.swift

Path: `Tests/Unit/Presentation/Navigation/{Feature}DeepLinkHandlerTests.swift`

```swift
import ChallengeCore
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Feature}DeepLinkHandlerTests {
    // MARK: - Properties

    private let sut = {Feature}DeepLinkHandler()

    // MARK: - Scheme

    @Test("Scheme is challenge")
    func schemeIsChallenge() {
        #expect(sut.scheme == "challenge")
    }

    // MARK: - Host

    @Test("Host is {feature}")
    func hostIsCorrect() {
        #expect(sut.host == "{feature}")
    }

    // MARK: - Resolve

    @Test("Resolve main path returns main navigation")
    func resolveMainPathReturnsMainNavigation() throws {
        // Given
        let url = try #require(URL(string: "challenge://{feature}{deepLinkPath}"))

        // When
        let result = sut.resolve(url)

        // Then
        let navigation = result as? {Feature}IncomingNavigation
        #expect(navigation == .main)
    }

    @Test("Resolve unknown path returns nil")
    func resolveUnknownPathReturnsNil() throws {
        // Given
        let url = try #require(URL(string: "challenge://{feature}/unknown"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result == nil)
    }
}
```

### {Screen}NavigatorTests.swift

Path: `Tests/Unit/Presentation/{Screen}/Navigator/{Screen}NavigatorTests.swift`

```swift
import ChallengeCoreMocks
import Testing

@testable import Challenge{Feature}

struct {Screen}NavigatorTests {
    // MARK: - Properties

    private let navigatorMock = NavigatorMock()
    private let sut: {Screen}Navigator

    // MARK: - Init

    init() {
        sut = {Screen}Navigator(navigator: navigatorMock)
    }

    // MARK: - Init Test

    @Test("Init does not crash")
    func initDoesNotCrash() {
        _ = sut
    }
}
```

### {Screen}TrackerTests.swift

Path: `Tests/Unit/Presentation/{Screen}/Tracker/{Screen}TrackerTests.swift`

```swift
import ChallengeCoreMocks
import Testing

@testable import Challenge{Feature}

struct {Screen}TrackerTests {
    // MARK: - Properties

    private let trackerMock = TrackerMock()
    private let sut: {Screen}Tracker

    // MARK: - Init

    init() {
        sut = {Screen}Tracker(tracker: trackerMock)
    }

    // MARK: - Track Screen Viewed

    @Test("Track screen viewed dispatches correct event")
    func trackScreenViewedDispatchesCorrectEvent() {
        // When
        sut.trackScreenViewed()

        // Then
        #expect(trackerMock.trackedEvents.count == 1)
        #expect(trackerMock.trackedEvents.first == TrackedEvent(name: "{eventPrefix}_viewed", properties: [:]))
    }
}
```

### {Screen}EventTests.swift

Path: `Tests/Unit/Presentation/{Screen}/Tracker/{Screen}EventTests.swift`

```swift
import Testing

@testable import Challenge{Feature}

struct {Screen}EventTests {
    // MARK: - Screen Viewed

    @Test("Screen viewed has correct name")
    func screenViewedHasCorrectName() {
        #expect({Screen}Event.screenViewed.name == "{eventPrefix}_viewed")
    }

    @Test("Screen viewed has empty properties")
    func screenViewedHasEmptyProperties() {
        #expect({Screen}Event.screenViewed.properties == [:])
    }
}
```

### {Screen}ViewModelTests.swift

Path: `Tests/Unit/Presentation/{Screen}/ViewModels/{Screen}ViewModelTests.swift`

```swift
import Testing

@testable import Challenge{Feature}

struct {Screen}ViewModelTests {
    // MARK: - Properties

    private let navigatorMock = {Screen}NavigatorMock()
    private let trackerMock = {Screen}TrackerMock()
    private let sut: {Screen}ViewModel

    // MARK: - Init

    init() {
        sut = {Screen}ViewModel(
            navigator: navigatorMock,
            tracker: trackerMock
        )
    }

    // MARK: - Did Appear

    @Test("Did appear tracks screen viewed")
    func didAppearTracksScreenViewed() {
        // When
        sut.didAppear()

        // Then
        #expect(trackerMock.trackScreenViewedCallCount == 1)
    }
}
```
