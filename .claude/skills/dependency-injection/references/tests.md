# Feature Tests

Features are tested through their **public interface**. Factory methods are internal to Container.

---

## CharacterFeatureTests

```swift
import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Foundation
import SwiftUI
import Testing

@testable import ChallengeCharacter

struct CharacterFeatureTests {
    // MARK: - Properties

    private let httpClientMock = HTTPClientMock()
    private let trackerMock = TrackerMock()
    private let navigatorMock = NavigatorMock()
    private let sut: CharacterFeature

    // MARK: - Initialization

    init() {
        sut = CharacterFeature(httpClient: httpClientMock, tracker: trackerMock)
    }

    // MARK: - Init

    @Test("Init with HTTP client does not crash")
    func initWithHTTPClientDoesNotCrash() {
        _ = sut
    }

    // MARK: - Feature Protocol

    @Test("Make main view returns character list view")
    func makeMainViewReturnsCharacterListView() {
        // When
        let result = sut.makeMainView(navigator: navigatorMock)

        // Then
        _ = result
    }

    @Test("Resolve list navigation returns view")
    func resolveListNavigationReturnsView() {
        // When
        let result = sut.resolve(CharacterIncomingNavigation.list, navigator: navigatorMock)

        // Then
        #expect(result != nil)
    }

    @Test("Resolve detail navigation returns view")
    func resolveDetailNavigationReturnsView() {
        // When
        let result = sut.resolve(CharacterIncomingNavigation.detail(identifier: 42), navigator: navigatorMock)

        // Then
        #expect(result != nil)
    }

    @Test("Resolve unknown navigation returns nil")
    func resolveUnknownNavigationReturnsNil() {
        // Given
        struct UnknownNavigation: NavigationContract {}

        // When
        let result = sut.resolve(UnknownNavigation(), navigator: navigatorMock)

        // Then
        #expect(result == nil)
    }
}
```

---

## HomeFeatureTests (Simple Feature)

```swift
import ChallengeCore
import ChallengeCoreMocks
import SwiftUI
import Testing

@testable import ChallengeHome

struct HomeFeatureTests {
    // MARK: - Properties

    private let trackerMock = TrackerMock()
    private let navigatorMock = NavigatorMock()
    private let sut: HomeFeature

    // MARK: - Initialization

    init() {
        sut = HomeFeature(tracker: trackerMock)
    }

    // MARK: - Init

    @Test("Init does not crash")
    func initDoesNotCrash() {
        _ = sut
    }

    // MARK: - Feature Protocol

    @Test("Make main view returns home view")
    func makeMainViewReturnsHomeView() {
        // When
        let view = sut.makeMainView(navigator: navigatorMock)

        // Then
        _ = view
    }

    @Test("Resolve main navigation returns view")
    func resolveMainNavigationReturnsView() {
        // When
        let result = sut.resolve(HomeIncomingNavigation.main, navigator: navigatorMock)

        // Then
        #expect(result != nil)
    }

    @Test("Resolve unknown navigation returns nil")
    func resolveUnknownNavigationReturnsNil() {
        // Given
        struct UnknownNavigation: NavigationContract {}

        // When
        let result = sut.resolve(UnknownNavigation(), navigator: navigatorMock)

        // Then
        #expect(result == nil)
    }
}
```

---

## Generic Feature Tests Pattern

```swift
import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Foundation
import SwiftUI
import Testing

@testable import Challenge{Feature}

struct {Feature}FeatureTests {
    // MARK: - Properties

    private let httpClientMock = HTTPClientMock()
    private let trackerMock = TrackerMock()
    private let navigatorMock = NavigatorMock()
    private let sut: {Feature}Feature

    // MARK: - Initialization

    init() {
        sut = {Feature}Feature(httpClient: httpClientMock, tracker: trackerMock)
    }

    // MARK: - Init

    @Test("Init with HTTP client does not crash")
    func initWithHTTPClientDoesNotCrash() {
        _ = sut
    }

    // MARK: - Feature Protocol

    @Test("Make main view returns view")
    func makeMainViewReturnsView() {
        // When
        let result = sut.makeMainView(navigator: navigatorMock)

        // Then
        _ = result
    }

    @Test("Resolve list navigation returns view")
    func resolveListNavigationReturnsView() {
        // When
        let result = sut.resolve({Feature}IncomingNavigation.list, navigator: navigatorMock)

        // Then
        #expect(result != nil)
    }

    @Test("Resolve unknown navigation returns nil")
    func resolveUnknownNavigationReturnsNil() {
        // Given
        struct UnknownNavigation: NavigationContract {}

        // When
        let result = sut.resolve(UnknownNavigation(), navigator: navigatorMock)

        // Then
        #expect(result == nil)
    }
}
```

---

## What to Test

| Test | Purpose |
|------|---------|
| Init with HTTPClient | Verify feature initializes without crashing |
| makeMainView() | Verify default entry point view is created |
| resolve() with valid navigation | Verify correct view is returned for each navigation case |
| resolve() with unknown navigation | Verify nil is returned for unhandled navigation |

**Note:** Factory methods are internal to Container. Test them indirectly through ViewModel tests, Repository tests, and DeepLinkHandler tests.
