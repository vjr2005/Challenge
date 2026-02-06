# How To: Create Navigator

Create Navigators for navigation between screens. Navigators decouple ViewModels from navigation implementation.

## Prerequisites

- Feature module exists (see [Create Feature](create-feature.md))
- IncomingNavigation defined (created with feature)

## File structure

```
Features/{Feature}/
├── Sources/
│   └── Presentation/
│       └── {ScreenName}/
│           └── Navigator/
│               ├── {ScreenName}NavigatorContract.swift
│               └── {ScreenName}Navigator.swift
└── Tests/
    ├── Unit/
    │   └── Presentation/
    │       └── Navigation/
    │           └── {ScreenName}NavigatorTests.swift
    └── Shared/
        └── Mocks/
            └── {ScreenName}NavigatorMock.swift
```

---

## Option A: Internal Navigation (same feature)

For navigation within the same feature (e.g., list → detail).

### 1. Create Navigator Contract

Create `Sources/Presentation/{ScreenName}/Navigator/{ScreenName}NavigatorContract.swift`:

```swift
protocol {ScreenName}NavigatorContract {
    func navigateToDetail(identifier: Int)
}
```

### 2. Create Navigator

Create `Sources/Presentation/{ScreenName}/Navigator/{ScreenName}Navigator.swift`:

```swift
import ChallengeCore

struct {ScreenName}Navigator: {ScreenName}NavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToDetail(identifier: Int) {
        navigator.navigate(to: {Feature}IncomingNavigation.detail(identifier: identifier))
    }
}
```

> **Note:** Internal navigation uses `{Feature}IncomingNavigation` because the destination is within the same feature.

### 3. Create Mock

Create `Tests/Shared/Mocks/{ScreenName}NavigatorMock.swift`:

```swift
@testable import Challenge{Feature}

final class {ScreenName}NavigatorMock: {ScreenName}NavigatorContract {
    private(set) var navigateToDetailIdentifiers: [Int] = []

    func navigateToDetail(identifier: Int) {
        navigateToDetailIdentifiers.append(identifier)
    }
}
```

### 4. Create tests

Create `Tests/Unit/Presentation/Navigation/{ScreenName}NavigatorTests.swift`:

```swift
import ChallengeCoreMocks
import Testing

@testable import Challenge{Feature}

struct {ScreenName}NavigatorTests {
    private let navigatorMock = NavigatorMock()
    private let sut: {ScreenName}Navigator

    init() {
        sut = {ScreenName}Navigator(navigator: navigatorMock)
    }

    @Test("Navigate to detail uses correct navigation with identifier")
    func navigateToDetailUsesCorrectNavigation() {
        // Given
        let expected = {Feature}IncomingNavigation.detail(identifier: 42)

        // When
        sut.navigateToDetail(identifier: 42)

        // Then
        #expect(navigatorMock.navigatedDestinations.count == 1)
        let destination = navigatorMock.navigatedDestinations.first as? {Feature}IncomingNavigation
        #expect(destination == expected)
    }
}
```

---

## Option B: Navigation with Go Back

For detail screens that need back navigation.

### 1. Create Navigator Contract

Create `Sources/Presentation/{ScreenName}/Navigator/{ScreenName}NavigatorContract.swift`:

```swift
protocol {ScreenName}NavigatorContract {
    func goBack()
}
```

### 2. Create Navigator

Create `Sources/Presentation/{ScreenName}/Navigator/{ScreenName}Navigator.swift`:

```swift
import ChallengeCore

struct {ScreenName}Navigator: {ScreenName}NavigatorContract {
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

Create `Tests/Shared/Mocks/{ScreenName}NavigatorMock.swift`:

```swift
@testable import Challenge{Feature}

final class {ScreenName}NavigatorMock: {ScreenName}NavigatorContract {
    private(set) var goBackCallCount = 0

    func goBack() {
        goBackCallCount += 1
    }
}
```

### 4. Create tests

Create `Tests/Unit/Presentation/Navigation/{ScreenName}NavigatorTests.swift`:

```swift
import ChallengeCoreMocks
import Testing

@testable import Challenge{Feature}

struct {ScreenName}NavigatorTests {
    private let navigatorMock = NavigatorMock()
    private let sut: {ScreenName}Navigator

    init() {
        sut = {ScreenName}Navigator(navigator: navigatorMock)
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

## Option C: External Navigation (different feature)

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

Create `Sources/Presentation/{ScreenName}/Navigator/{ScreenName}NavigatorContract.swift`:

```swift
protocol {ScreenName}NavigatorContract {
    func navigateToCharacters()
}
```

### 3. Create Navigator

Create `Sources/Presentation/{ScreenName}/Navigator/{ScreenName}Navigator.swift`:

```swift
import ChallengeCore

struct {ScreenName}Navigator: {ScreenName}NavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToCharacters() {
        // Uses OutgoingNavigation - AppNavigationRedirect will convert this
        navigator.navigate(to: {Feature}OutgoingNavigation.characters)
    }
}
```

> **Note:** External navigation uses `{Feature}OutgoingNavigation`. The `AppNavigationRedirect` in AppKit converts it to the destination feature's `IncomingNavigation`.

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

### 5. Create Mock

Create `Tests/Shared/Mocks/{ScreenName}NavigatorMock.swift`:

```swift
@testable import Challenge{Feature}

final class {ScreenName}NavigatorMock: {ScreenName}NavigatorContract {
    private(set) var navigateToCharactersCallCount = 0

    func navigateToCharacters() {
        navigateToCharactersCallCount += 1
    }
}
```

### 6. Create tests

Create `Tests/Unit/Presentation/Navigation/{ScreenName}NavigatorTests.swift`:

```swift
import ChallengeCoreMocks
import Testing

@testable import Challenge{Feature}

struct {ScreenName}NavigatorTests {
    private let navigatorMock = NavigatorMock()
    private let sut: {ScreenName}Navigator

    init() {
        sut = {ScreenName}Navigator(navigator: navigatorMock)
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
    private let sut = AppNavigationRedirect()

    @Test("Redirect {Feature} outgoing characters to Character list")
    func redirect{Feature}OutgoingCharactersToCharacterList() throws {
        // When
        let result = sut.redirect({Feature}OutgoingNavigation.characters)

        // Then
        let characterNavigation = try #require(result as? CharacterIncomingNavigation)
        #expect(characterNavigation == .list)
    }

    @Test("Redirect unknown navigation returns nil")
    func redirectUnknownNavigationReturnsNil() {
        // When
        let result = sut.redirect(CharacterIncomingNavigation.list)

        // Then
        #expect(result == nil)
    }
}
```

---

## Option D: Modal Navigation (present/dismiss)

For presenting screens as modals (sheet or fullScreenCover).

### 1. Create Navigator Contract

Create `Sources/Presentation/{ScreenName}/Navigator/{ScreenName}NavigatorContract.swift`:

```swift
protocol {ScreenName}NavigatorContract {
    func presentFilter()
    func dismiss()
}
```

### 2. Create Navigator

Create `Sources/Presentation/{ScreenName}/Navigator/{ScreenName}Navigator.swift`:

```swift
import ChallengeCore

struct {ScreenName}Navigator: {ScreenName}NavigatorContract {
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

Create `Tests/Shared/Mocks/{ScreenName}NavigatorMock.swift`:

```swift
@testable import Challenge{Feature}

final class {ScreenName}NavigatorMock: {ScreenName}NavigatorContract {
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

### 4. Create tests

Create `Tests/Unit/Presentation/Navigation/{ScreenName}NavigatorTests.swift`:

```swift
import ChallengeCoreMocks
import Testing

@testable import Challenge{Feature}

struct {ScreenName}NavigatorTests {
    private let navigatorMock = NavigatorMock()
    private let sut: {ScreenName}Navigator

    init() {
        sut = {ScreenName}Navigator(navigator: navigatorMock)
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

## Wire Navigator in Container

Add factory method in the Container to create the Navigator:

```swift
// In {Feature}Container.swift

func make{ScreenName}ViewModel(navigator: any NavigatorContract) -> {ScreenName}ViewModel {
    {ScreenName}ViewModel(
        get{Name}UseCase: makeGet{Name}UseCase(),
        navigator: {ScreenName}Navigator(navigator: navigator)
    )
}
```

---

## Generate and verify

```bash
./generate.sh
```

## See also

- [Create ViewModel](create-viewmodel.md) - ViewModel that uses the Navigator
- [Create Feature](create-feature.md) - IncomingNavigation and Feature definition
- [Deep Linking](../DeepLinking.md) - URL-based navigation
