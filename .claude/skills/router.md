---
name: router
description: Creates Routers for navigation management. Use when creating navigation for a feature, adding type-safe destinations, or implementing NavigationStack.
---

# Skill: Router

Guide for creating Routers that manage navigation using `NavigationStack`.

## When to use this skill

- Create navigation for a feature
- Add type-safe navigation destinations
- Create Router tests

## File structure

```
Libraries/Features/{FeatureName}/
├── Sources/
│   └── Presentation/
│       └── Router/
│           └── {Feature}Router.swift             # Router
└── Tests/
    └── Presentation/
        └── Router/
            └── {Feature}RouterTests.swift        # Tests
```

---

## Router Pattern

```swift
import SwiftUI

@MainActor
@Observable
final class {Feature}Router {
    enum Destination: Hashable {
        case detail(id: Int)
        case settings
    }

    var path = NavigationPath()

    func navigate(to destination: Destination) {
        path.append(destination)
    }

    func pop() {
        guard !path.isEmpty else { 
            return 
        }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}
```

**Rules:**
- `@MainActor` for UI thread safety
- `@Observable` for SwiftUI integration (iOS 17+)
- `final class` to prevent subclassing
- **Internal visibility** (not public)
- One Router per feature
- `Destination` enum with all possible destinations
- `path` is public for binding to `NavigationStack`
- **Use primitive IDs, not domain objects** - Destinations should only contain minimal data needed to render the screen (e.g., `detail(id: Int)` instead of `detail(Character)`)

---

## Using Router in ViewModel

Inject Router as a **required** dependency for ViewModels that handle navigation:

```swift
@MainActor
@Observable
final class {Name}ListViewModel {
    private let router: {Feature}Router

    init(router: {Feature}Router) {
        self.router = router
    }

    func didSelectItem(_ item: {Name}) {
        router.navigate(to: .detail(id: item.id))
    }
}
```

> **Note:** ViewModels that don't navigate (e.g., DetailViewModel) don't need a Router. See `/viewmodel` skill for details.

---

## Testing

### Router Tests

```swift
import Foundation
import Testing

@testable import Challenge{FeatureName}

@MainActor
struct {Feature}RouterTests {
    @Test
    func initialPathIsEmpty() {
        // Given
        let sut = {Feature}Router()

        // Then
        #expect(sut.path.isEmpty)
    }

    @Test
    func navigateAddsDestinationToPath() {
        // Given
        let sut = {Feature}Router()
        let destination = {Feature}Router.Destination.detail(id: 1)

        // When
        sut.navigate(to: destination)

        // Then
        #expect(sut.path.count == 1)
    }

    @Test
    func popRemovesLastDestination() {
        // Given
        let sut = {Feature}Router()
        sut.navigate(to: .detail(id: 1))
        sut.navigate(to: .settings)

        // When
        sut.pop()

        // Then
        #expect(sut.path.count == 1)
    }

    @Test
    func popDoesNothingWhenPathIsEmpty() {
        // Given
        let sut = {Feature}Router()

        // When
        sut.pop()

        // Then
        #expect(sut.path.isEmpty)
    }

    @Test
    func popToRootRemovesAllDestinations() {
        // Given
        let sut = {Feature}Router()
        sut.navigate(to: .detail(id: 1))
        sut.navigate(to: .settings)

        // When
        sut.popToRoot()

        // Then
        #expect(sut.path.isEmpty)
    }
}
```

**Testing Rules:**
- `@MainActor` on test struct to access Router
- Test initial state, navigation, pop, and popToRoot
- Use primitive IDs in test destinations (e.g., `detail(id: 1)`)

---

## Example: CharacterRouter

### Router

```swift
// Sources/Presentation/Router/CharacterRouter.swift
import SwiftUI

@MainActor
@Observable
final class CharacterRouter {
    var path = NavigationPath()

    enum Destination: Hashable {
        case detail(id: Int)
    }

    func navigate(to destination: Destination) {
        path.append(destination)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}
```

### Tests

```swift
// Tests/Presentation/Router/CharacterRouterTests.swift
import Foundation
import Testing

@testable import ChallengeCharacter

@MainActor
struct CharacterRouterTests {
    @Test
    func initialPathIsEmpty() {
        let sut = CharacterRouter()

        #expect(sut.path.isEmpty)
    }

    @Test
    func navigateAddsDestinationToPath() {
        let sut = CharacterRouter()

        sut.navigate(to: .detail(id: 1))

        #expect(sut.path.count == 1)
    }

    @Test
    func popRemovesLastDestination() {
        let sut = CharacterRouter()
        sut.navigate(to: .detail(id: 1))

        sut.pop()

        #expect(sut.path.isEmpty)
    }

    @Test
    func popDoesNothingWhenPathIsEmpty() {
        let sut = CharacterRouter()

        sut.pop()

        #expect(sut.path.isEmpty)
    }

    @Test
    func popToRootRemovesAllDestinations() {
        let sut = CharacterRouter()
        sut.navigate(to: .detail(id: 1))
        sut.navigate(to: .detail(id: 2))

        sut.popToRoot()

        #expect(sut.path.isEmpty)
    }
}
```

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| Router | internal | `Sources/Presentation/Router/` |

---

## Checklist

- [ ] Create Router class with @MainActor and @Observable
- [ ] Define Destination enum with primitive IDs (not domain objects)
- [ ] Implement navigate, pop, popToRoot methods
- [ ] Create tests for initial state, navigate, pop, popToRoot
- [ ] Run tests
