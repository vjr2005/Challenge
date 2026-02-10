# How To: Create Navigator

Create Navigators for navigation between screens. Navigators decouple ViewModels from navigation implementation.

## Scope & Boundaries

This guide covers screen Navigators, IncomingNavigation, OutgoingNavigation, DeepLinkHandler, and AppNavigationRedirect.

| Need | Delegate to |
|------|-------------|
| ViewModel creation | [Create ViewModel](create-viewmodel.md) |
| Feature entry point | [Create Feature](create-feature.md) |

## Prerequisites

- Feature module exists (see [Create Feature](create-feature.md))
- IncomingNavigation defined (created with feature)

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          RootContainerView                              │
│  @State private var coordinator = NavigationCoordinator(                │
│      redirector: AppNavigationRedirect()                                │
│  )                                                                      │
│                                                                         │
│  NavigationStack(path: $coordinator.path) { ... }                       │
│  .sheet(item: $coordinator.sheetNavigation) { modal in                  │
│      ModalContainerView(modal:appContainer:onDismiss:)                  │
│  }                                                                      │
│  .fullScreenCover(item: $coordinator.fullScreenCoverNavigation) { ... } │
└─────────────────────────────────────────────────────────────────────────┘

Push Navigation Flow:
1. HomeNavigator.navigateToCharacters()
2. coordinator.navigate(to: HomeOutgoingNavigation.characters)
3. AppNavigationRedirect.redirect() → CharacterIncomingNavigation.list
4. NavigationStack shows CharacterListView

Modal Navigation Flow:
1. Navigator.presentFilter()
2. coordinator.present(Navigation.filter, style: .sheet(detents: [.medium, .large]))
3. sheetNavigation is set → .sheet(item:) activates
4. ModalContainerView creates its own NavigationCoordinator + NavigationStack
5. Modal can push internally or present nested modals
```

## Navigation Types

| Type | Description | Implementation |
|------|-------------|----------------|
| **Incoming** | Destinations a feature can handle | `{Feature}IncomingNavigation` enum |
| **Outgoing** | Destinations a feature wants to navigate to | `{Feature}OutgoingNavigation` enum |
| **Redirect** | Connects Outgoing → Incoming | `AppNavigationRedirect` in App layer |

**Why?** Features remain decoupled. Feature A doesn't import Feature B. The App layer connects them via redirects.

## Navigator Pattern

ViewModels use **Navigators** instead of NavigatorContract directly. This:
1. Decouples ViewModels from navigation implementation details
2. Makes testing easier with focused mocks
3. Provides semantic navigation methods

**Key Difference:**
- **Internal navigation:** Uses `{Feature}IncomingNavigation` directly
- **External navigation:** Uses `{Feature}OutgoingNavigation` (redirected by App layer)

## File Structure

```
Features/{Feature}/
├── Sources/Presentation/
│   ├── Navigation/
│   │   ├── {Feature}IncomingNavigation.swift
│   │   ├── {Feature}OutgoingNavigation.swift
│   │   └── {Feature}DeepLinkHandler.swift
│   └── {Screen}/
│       └── Navigator/
│           ├── {Screen}NavigatorContract.swift
│           └── {Screen}Navigator.swift
└── Tests/Unit/Presentation/
    ├── Navigation/{Feature}DeepLinkHandlerTests.swift
    └── {Screen}/Navigator/{Screen}NavigatorTests.swift
```

---

## Step 1 — Internal Navigation (same feature)

For navigation within the same feature (e.g., list → detail).

### 1. Create Navigator Contract

Create `Sources/Presentation/{Screen}/Navigator/{Screen}NavigatorContract.swift`:

```swift
protocol {Screen}NavigatorContract {
    func navigateToDetail(identifier: Int)
}
```

### 2. Create Navigator

Create `Sources/Presentation/{Screen}/Navigator/{Screen}Navigator.swift`:

```swift
import ChallengeCore

struct {Screen}Navigator: {Screen}NavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToDetail(identifier: Int) {
        // Uses IncomingNavigation (same feature)
        navigator.navigate(to: {Feature}IncomingNavigation.detail(identifier: identifier))
    }
}
```

> **Note:** Internal navigation uses `{Feature}IncomingNavigation` because the destination is within the same feature.

### 3. Create Mock

Create `Tests/Shared/Mocks/{Screen}NavigatorMock.swift`:

```swift
@testable import Challenge{Feature}

final class {Screen}NavigatorMock: {Screen}NavigatorContract {
    private(set) var navigateToDetailIdentifiers: [Int] = []

    func navigateToDetail(identifier: Int) {
        navigateToDetailIdentifiers.append(identifier)
    }
}
```

### 4. Create Tests

Create `Tests/Unit/Presentation/{Screen}/Navigator/{Screen}NavigatorTests.swift`:

```swift
import ChallengeCoreMocks
import Testing

@testable import Challenge{Feature}

struct {Screen}NavigatorTests {
    @Test("Navigate to detail uses correct navigation")
    func navigateToDetailUsesCorrectNavigation() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = {Screen}Navigator(navigator: navigatorMock)

        // When
        sut.navigateToDetail(identifier: 42)

        // Then
        let destination = navigatorMock.navigatedDestinations.first as? {Feature}IncomingNavigation
        #expect(destination == .detail(identifier: 42))
    }
}
```

---

## Step 2 — Navigation with Go Back

For detail screens that need back navigation.

### 1. Create Navigator Contract

Create `Sources/Presentation/{Screen}/Navigator/{Screen}NavigatorContract.swift`:

```swift
protocol {Screen}NavigatorContract {
    func goBack()
}
```

### 2. Create Navigator

Create `Sources/Presentation/{Screen}/Navigator/{Screen}Navigator.swift`:

```swift
import ChallengeCore

struct {Screen}Navigator: {Screen}NavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func goBack() {
        navigator.goBack()
    }
}
```

### 3. Create Mock

Create `Tests/Shared/Mocks/{Screen}NavigatorMock.swift`:

```swift
@testable import Challenge{Feature}

final class {Screen}NavigatorMock: {Screen}NavigatorContract {
    private(set) var goBackCallCount = 0

    func goBack() {
        goBackCallCount += 1
    }
}
```

### 4. Create Tests

Create `Tests/Unit/Presentation/{Screen}/Navigator/{Screen}NavigatorTests.swift`:

```swift
import ChallengeCoreMocks
import Testing

@testable import Challenge{Feature}

struct {Screen}NavigatorTests {
    private let navigatorMock = NavigatorMock()
    private let sut: {Screen}Navigator

    init() {
        sut = {Screen}Navigator(navigator: navigatorMock)
    }

    @Test("Go back calls navigator go back")
    func goBackCallsNavigatorGoBack() {
        // When
        sut.goBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }
}
```

---

## Step 3 — External Navigation (different feature)

For navigation to a different feature (e.g., Home → Character).

### 1. Create Outgoing Navigation

Create `Sources/Presentation/Navigation/{Feature}OutgoingNavigation.swift`:

```swift
import ChallengeCore

public enum {Feature}OutgoingNavigation: OutgoingNavigationContract {
    case characters
    case settings
}
```

> **Note:** Outgoing navigations are `public` so `AppNavigationRedirect` can access them.

### 2. Create Navigator Contract

Create `Sources/Presentation/{Screen}/Navigator/{Screen}NavigatorContract.swift`:

```swift
protocol {Screen}NavigatorContract {
    func navigateToCharacters()
}
```

### 3. Create Navigator

Create `Sources/Presentation/{Screen}/Navigator/{Screen}Navigator.swift`:

```swift
import ChallengeCore

struct {Screen}Navigator: {Screen}NavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToCharacters() {
        // Uses OutgoingNavigation (different feature)
        // AppNavigationRedirect will convert to CharacterIncomingNavigation.list
        navigator.navigate(to: {Feature}OutgoingNavigation.characters)
    }
}
```

### 4. Register redirect in AppKit

Edit `AppKit/Sources/Presentation/Navigation/AppNavigationRedirect.swift`:

```swift
import Challenge{Feature}
import ChallengeCharacter
import ChallengeCore

struct AppNavigationRedirect: NavigationRedirectContract {
    func redirect(_ navigation: any NavigationContract) -> (any NavigationContract)? {
        switch navigation {
        case let outgoing as {Feature}OutgoingNavigation:
            return redirect(outgoing)
        default:
            return nil
        }
    }

    // MARK: - Private

    private func redirect(_ navigation: {Feature}OutgoingNavigation) -> any NavigationContract {
        switch navigation {
        case .characters:
            return CharacterIncomingNavigation.list
        case .settings:
            return SettingsIncomingNavigation.main
        }
    }
}
```

**Rules:**
- Centralized place to connect features
- Maps Outgoing → Incoming navigation
- Only place that imports multiple features

### 5. Create Mock

Create `Tests/Shared/Mocks/{Screen}NavigatorMock.swift`:

```swift
@testable import Challenge{Feature}

final class {Screen}NavigatorMock: {Screen}NavigatorContract {
    private(set) var navigateToCharactersCallCount = 0

    func navigateToCharacters() {
        navigateToCharactersCallCount += 1
    }
}
```

### 6. Create Tests

Create `Tests/Unit/Presentation/{Screen}/Navigator/{Screen}NavigatorTests.swift`:

```swift
import ChallengeCoreMocks
import Testing

@testable import Challenge{Feature}

struct {Screen}NavigatorTests {
    private let navigatorMock = NavigatorMock()
    private let sut: {Screen}Navigator

    init() {
        sut = {Screen}Navigator(navigator: navigatorMock)
    }

    @Test("Navigate to characters uses outgoing navigation")
    func navigateToCharactersUsesOutgoingNavigation() {
        // When
        sut.navigateToCharacters()

        // Then
        #expect(navigatorMock.navigatedDestinations.count == 1)
        let destination = navigatorMock.navigatedDestinations.first as? {Feature}OutgoingNavigation
        #expect(destination == .characters)
    }
}
```

### 7. Test AppNavigationRedirect

Create `App/Tests/Navigation/AppNavigationRedirectTests.swift`:

```swift
import Challenge{Feature}
import ChallengeCharacter
import Testing

@testable import Challenge

struct AppNavigationRedirectTests {
    @Test("Redirect {Feature} outgoing characters to Character list")
    func redirectOutgoingCharactersToCharacterList() throws {
        // Given
        let sut = AppNavigationRedirect()

        // When
        let result = sut.redirect({Feature}OutgoingNavigation.characters)

        // Then
        let characterNavigation = try #require(result as? CharacterIncomingNavigation)
        #expect(characterNavigation == .list)
    }

    @Test("Redirect unknown navigation returns nil")
    func redirectUnknownNavigationReturnsNil() {
        // Given
        let sut = AppNavigationRedirect()

        // When
        let result = sut.redirect(CharacterIncomingNavigation.list)

        // Then
        #expect(result == nil)
    }
}
```

---

## Step 4 — Modal Navigation (present/dismiss)

For presenting screens as modals (sheet or fullScreenCover).

### 1. Create Navigator Contract

Create `Sources/Presentation/{Screen}/Navigator/{Screen}NavigatorContract.swift`:

```swift
protocol {Screen}NavigatorContract {
    func presentFilter()
    func dismiss()
}
```

### 2. Create Navigator

Create `Sources/Presentation/{Screen}/Navigator/{Screen}Navigator.swift`:

```swift
import ChallengeCore

struct {Screen}Navigator: {Screen}NavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func presentFilter() {
        navigator.present(
            {Feature}IncomingNavigation.filter,
            style: .sheet(detents: [.medium, .large])
        )
    }

    func dismiss() {
        navigator.dismiss()
    }
}
```

> **Note:** `present(_:style:)` supports two styles:
> - `.sheet(detents:)` — partial or full sheet (default detents: `[.large]`)
> - `.fullScreenCover` — full-screen modal
>
> `dismiss()` closes the topmost modal. Priority: fullScreenCover > sheet > parent onDismiss.

### 3. Create Mock

Create `Tests/Shared/Mocks/{Screen}NavigatorMock.swift`:

```swift
@testable import Challenge{Feature}

final class {Screen}NavigatorMock: {Screen}NavigatorContract {
    private(set) var presentFilterCallCount = 0
    private(set) var dismissCallCount = 0

    func presentFilter() {
        presentFilterCallCount += 1
    }

    func dismiss() {
        dismissCallCount += 1
    }
}
```

### 4. Create Tests

Create `Tests/Unit/Presentation/{Screen}/Navigator/{Screen}NavigatorTests.swift`:

```swift
import ChallengeCoreMocks
import Testing

@testable import Challenge{Feature}

struct {Screen}NavigatorTests {
    private let navigatorMock = NavigatorMock()
    private let sut: {Screen}Navigator

    init() {
        sut = {Screen}Navigator(navigator: navigatorMock)
    }

    @Test("Present filter presents sheet with correct detents")
    func presentFilterPresentsSheet() {
        // When
        sut.presentFilter()

        // Then
        #expect(navigatorMock.presentedModals.count == 1)
        let modal = navigatorMock.presentedModals.first
        let destination = modal?.destination as? {Feature}IncomingNavigation
        #expect(destination == .filter)
        #expect(modal?.style == .sheet(detents: [.medium, .large]))
    }

    @Test("Dismiss calls navigator dismiss")
    func dismissCallsNavigatorDismiss() {
        // When
        sut.dismiss()

        // Then
        #expect(navigatorMock.dismissCallCount == 1)
    }
}
```

---

## Step 5 — DeepLinkHandler

For URL-based navigation to feature screens.

### 1. Create DeepLinkHandler

Create `Sources/Presentation/Navigation/{Feature}DeepLinkHandler.swift`:

```swift
import ChallengeCore
import Foundation

struct {Feature}DeepLinkHandler: DeepLinkHandlerContract {
    let scheme = "challenge"
    let host = "{feature}"  // e.g., "character"

    func resolve(_ url: URL) -> (any NavigationContract)? {
        let pathComponents = url.pathComponents
        guard pathComponents.count >= 2 else {
            return nil
        }
        switch pathComponents[1] {
        case "list":
            return {Feature}IncomingNavigation.list

        case "detail":
            guard pathComponents.count >= 3,
                  let identifier = Int(pathComponents[2]) else {
                return nil
            }
            return {Feature}IncomingNavigation.detail(identifier: identifier)

        default:
            return nil
        }
    }
}
```

**URL Format:** `challenge://{feature}/{path}/{param}` — parameters are embedded in the path, never as query items.

Examples:
- `challenge://character/list`
- `challenge://character/detail/42`

### 2. Create Tests

Create `Tests/Unit/Presentation/Navigation/{Feature}DeepLinkHandlerTests.swift`:

```swift
import ChallengeCore
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Feature}DeepLinkHandlerTests {
    @Test("Resolve list path returns list navigation")
    func resolveListPathReturnsListNavigation() throws {
        // Given
        let sut = {Feature}DeepLinkHandler()
        let url = try #require(URL(string: "challenge://{feature}/list"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result as? {Feature}IncomingNavigation == .list)
    }

    @Test("Resolve detail path with valid id returns detail navigation")
    func resolveDetailPathWithValidIdReturnsDetailNavigation() throws {
        // Given
        let sut = {Feature}DeepLinkHandler()
        let url = try #require(URL(string: "challenge://{feature}/detail/42"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result as? {Feature}IncomingNavigation == .detail(identifier: 42))
    }

    @Test("Resolve detail path without id returns nil")
    func resolveDetailPathWithoutIdReturnsNil() throws {
        // Given
        let sut = {Feature}DeepLinkHandler()
        let url = try #require(URL(string: "challenge://{feature}/detail"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result == nil)
    }

    @Test("Resolve unknown path returns nil")
    func resolveUnknownPathReturnsNil() throws {
        // Given
        let sut = {Feature}DeepLinkHandler()
        let url = try #require(URL(string: "challenge://{feature}/unknown"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result == nil)
    }
}
```

---

## Checklist

### Feature Implementation
- [ ] `{Feature}IncomingNavigation` in `Presentation/Navigation/`
- [ ] `{Feature}OutgoingNavigation` for cross-feature navigation (if needed)
- [ ] `{Feature}DeepLinkHandler` returning `IncomingNavigationContract` (if deep links needed)
- [ ] Each screen has `NavigatorContract` and `Navigator`
- [ ] Navigator uses `IncomingNavigationContract` for internal, `OutgoingNavigationContract` for external
- [ ] Container factories receive `navigator: any NavigatorContract`

### Testing
- [ ] Navigator tests verify correct Navigation enum is used
- [ ] AppNavigationRedirect tests verify Outgoing → Incoming mapping
- [ ] DeepLinkHandler tests verify URL → IncomingNavigationContract resolution

---

## See also

- [Create ViewModel](create-viewmodel.md) — ViewModel that uses the Navigator
- [Create Feature](create-feature.md) — IncomingNavigation and Feature definition
