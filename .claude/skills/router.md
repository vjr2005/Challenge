---
name: router
description: Creates Router for navigation. Use when setting up navigation, adding navigation to ViewModels, or testing navigation behavior.
---

# Skill: Router

Guide for implementing navigation using Router pattern with SwiftUI NavigationStack.

## When to use this skill

- Set up navigation in the App
- Add navigation to ViewModels
- Test navigation behavior

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         App                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  @State private var router = Router()               │    │
│  │  NavigationStack(path: $router.path)                │    │
│  └─────────────────────────────────────────────────────┘    │
│                            │                                 │
│                            ▼ passes router                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Feature.view(for: navigation, router: router)      │    │
│  └─────────────────────────────────────────────────────┘    │
│                            │                                 │
│                            ▼ passes to Container             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  container.makeViewModel(router: router)            │    │
│  └─────────────────────────────────────────────────────┘    │
│                            │                                 │
│                            ▼ injected via RouterContract     │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  ViewModel uses router.navigate(to:) / goBack()     │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

## Core Module Components

### RouterContract (Protocol)

```swift
// Libraries/Core/Sources/Navigation/RouterContract.swift
public protocol RouterContract {
    func navigate(to destination: any Navigation)
    func goBack()
}
```

### Navigation (Protocol)

```swift
// Libraries/Core/Sources/Navigation/Navigation.swift
public protocol Navigation: Hashable, Sendable {}
```

### Router (Implementation)

```swift
// Libraries/Core/Sources/Navigation/Router.swift
import SwiftUI

@Observable
public final class Router: RouterContract {
    public var path = NavigationPath()

    public init() {}

    public func navigate(to destination: any Navigation) {
        path.append(destination)
    }

    public func goBack() {
        guard !path.isEmpty else {
            return
        }
        path.removeLast()
    }
}
```

**Key points:**
- `@Observable` - SwiftUI observes path changes automatically
- `path` is `public var` - Allows binding with `$router.path`
- `init()` - No parameters, Router owns the NavigationPath
- One Router per NavigationStack

### RouterMock (for testing)

```swift
// Libraries/Core/Mocks/RouterMock.swift
import ChallengeCore

public final class RouterMock: RouterContract {
    public private(set) var navigatedDestinations: [any Navigation] = []
    public private(set) var goBackCallCount = 0

    public init() {}

    public func navigate(to destination: any Navigation) {
        navigatedDestinations.append(destination)
    }

    public func goBack() {
        goBackCallCount += 1
    }
}
```

---

## Feature Navigation

Each feature defines its navigation destinations:

```swift
// Libraries/Features/{Feature}/Sources/{Feature}Navigation.swift
import ChallengeCore

public enum {Feature}Navigation: Navigation {
    case list
    case detail(identifier: Int)
}
```

**Rules:**
- Conform to `Navigation` protocol from Core
- Use primitive types (Int, String, UUID) - never domain objects
- Public visibility for cross-module navigation

---

## App Setup

```swift
// App/Sources/ContentView.swift
import ChallengeCharacter
import ChallengeCore
import ChallengeHome
import SwiftUI

struct ContentView: View {
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeFeature.makeHomeView(router: router)
                .navigationDestination(for: CharacterNavigation.self) { navigation in
                    CharacterFeature.view(for: navigation, router: router)
                }
        }
    }
}
```

**Rules:**
- Create Router with `@State`
- Bind path with `$router.path`
- Pass same router instance to all features
- Register `.navigationDestination` for each feature's Navigation type

### Multiple NavigationStacks (Tabs)

```swift
struct ContentView: View {
    @State private var homeRouter = Router()
    @State private var settingsRouter = Router()

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                NavigationStack(path: $homeRouter.path) {
                    HomeFeature.makeHomeView(router: homeRouter)
                        .navigationDestination(for: CharacterNavigation.self) { nav in
                            CharacterFeature.view(for: nav, router: homeRouter)
                        }
                }
            }
            Tab("Settings", systemImage: "gear") {
                NavigationStack(path: $settingsRouter.path) {
                    SettingsFeature.makeSettingsView(router: settingsRouter)
                }
            }
        }
    }
}
```

---

## ViewModel with Navigation

ViewModels receive `RouterContract` and use semantic method names:

```swift
// Libraries/Features/{Feature}/Sources/Presentation/ViewModels/{Name}ViewModel.swift
import ChallengeCore
import SwiftUI

@Observable
final class {Name}ViewModel {
    private(set) var state: {Name}ViewState = .idle

    private let get{Name}UseCase: Get{Name}UseCaseContract
    private let router: RouterContract

    init(get{Name}UseCase: Get{Name}UseCaseContract, router: RouterContract) {
        self.get{Name}UseCase = get{Name}UseCase
        self.router = router
    }

    func load() async {
        // ...
    }

    // Semantic navigation methods
    func didSelectItem(_ item: Item) {
        router.navigate(to: {Feature}Navigation.detail(identifier: item.id))
    }

    func didTapOnBack() {
        router.goBack()
    }
}
```

**Rules:**
- Inject `RouterContract` (not concrete Router)
- Use semantic method names: `didTapOn...`, `didSelect...`
- Never expose router to View

---

## Testing Navigation

```swift
import ChallengeCoreMocks
import Testing

@testable import Challenge{Feature}

struct {Name}ViewModelTests {
    @Test
    func didSelectItemNavigatesToDetail() {
        // Given
        let router = RouterMock()
        let sut = {Name}ViewModel(
            get{Name}UseCase: Get{Name}UseCaseMock(),
            router: router
        )

        // When
        sut.didSelectItem(Item(id: 42, name: "Test"))

        // Then
        let destination = router.navigatedDestinations.first as? {Feature}Navigation
        #expect(destination == .detail(identifier: 42))
    }

    @Test
    func didTapOnBackCallsGoBack() {
        // Given
        let router = RouterMock()
        let sut = {Name}ViewModel(
            get{Name}UseCase: Get{Name}UseCaseMock(),
            router: router
        )

        // When
        sut.didTapOnBack()

        // Then
        #expect(router.goBackCallCount == 1)
    }

    @Test
    func didSelectItemCallsRouterOnce() {
        // Given
        let router = RouterMock()
        let sut = {Name}ViewModel(
            get{Name}UseCase: Get{Name}UseCaseMock(),
            router: router
        )

        // When
        sut.didSelectItem(Item(id: 1, name: "Test"))

        // Then
        #expect(router.navigatedDestinations.count == 1)
    }
}
```

---

## Example: HomeViewModel

```swift
// Libraries/Features/Home/Sources/Presentation/ViewModels/HomeViewModel.swift
import ChallengeCharacter
import ChallengeCore
import SwiftUI

@Observable
final class HomeViewModel {
    private let router: RouterContract

    init(router: RouterContract) {
        self.router = router
    }

    func didTapOnCharacterButton() {
        router.navigate(to: CharacterNavigation.detail(identifier: 1))
    }
}
```

### HomeViewModelTests

```swift
import ChallengeCharacter
import ChallengeCoreMocks
import Testing

@testable import ChallengeHome

struct HomeViewModelTests {
    @Test
    func didTapOnCharacterButtonNavigatesToCharacterDetail() {
        // Given
        let router = RouterMock()
        let sut = HomeViewModel(router: router)

        // When
        sut.didTapOnCharacterButton()

        // Then
        let destination = router.navigatedDestinations.first as? CharacterNavigation
        #expect(destination == .detail(identifier: 1))
    }

    @Test
    func didTapOnCharacterButtonCallsRouterOnce() {
        // Given
        let router = RouterMock()
        let sut = HomeViewModel(router: router)

        // When
        sut.didTapOnCharacterButton()

        // Then
        #expect(router.navigatedDestinations.count == 1)
    }
}
```

---

## Checklist

- [ ] Core has `RouterContract`, `Navigation`, `Router`, `RouterMock`
- [ ] Feature has `{Feature}Navigation` conforming to `Navigation`
- [ ] App creates `@State private var router = Router()`
- [ ] App uses `NavigationStack(path: $router.path)`
- [ ] App registers `.navigationDestination(for:)` for each feature
- [ ] Feature passes router to Container factory methods
- [ ] ViewModel injects `RouterContract`
- [ ] ViewModel uses semantic method names (`didTapOn...`, `didSelect...`)
- [ ] Tests use `RouterMock` to verify navigation
