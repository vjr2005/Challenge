# Feature Navigation Implementation

## Incoming Navigation (Destinations the feature handles)

```swift
// Features/{Feature}/Sources/Presentation/Navigation/{Feature}IncomingNavigation.swift
import ChallengeCore

public enum {Feature}IncomingNavigation: IncomingNavigationContract {
    case list
    case detail(identifier: Int)
}
```

---

## Outgoing Navigation (Destinations to other features)

```swift
// Features/{Feature}/Sources/Presentation/Navigation/{Feature}OutgoingNavigation.swift
import ChallengeCore

public enum {Feature}OutgoingNavigation: OutgoingNavigationContract {
    case characters  // Navigates to Character feature
    case settings    // Navigates to Settings feature
}
```

**Note:** Outgoing navigations are `public` so AppNavigationRedirect can access them.

---

## DeepLinkHandler

```swift
// Features/{Feature}/Sources/Presentation/Navigation/{Feature}DeepLinkHandler.swift
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

---

## Navigator Contract

```swift
// Features/{Feature}/Sources/Presentation/{Screen}/Navigator/{Screen}NavigatorContract.swift
protocol {Screen}NavigatorContract {
    func navigateToDetail(id: Int)  // Internal navigation
    func goBack()
}
```

---

## Navigator Implementation (Internal Navigation)

```swift
// Features/{Feature}/Sources/Presentation/{Screen}/Navigator/{Screen}Navigator.swift
import ChallengeCore

struct {Screen}Navigator: {Screen}NavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToDetail(id: Int) {
        // Uses IncomingNavigation (same feature)
        navigator.navigate(to: {Feature}IncomingNavigation.detail(identifier: id))
    }

    func goBack() {
        navigator.goBack()
    }
}
```

---

## Navigator Implementation (External Navigation)

```swift
// Features/Home/Sources/Presentation/Home/Navigator/HomeNavigator.swift
import ChallengeCore

struct HomeNavigator: HomeNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToCharacters() {
        // Uses OutgoingNavigation (different feature)
        // AppNavigationRedirect will convert to CharacterIncomingNavigation.list
        navigator.navigate(to: HomeOutgoingNavigation.characters)
    }
}
```

**Key Difference:**
- **Internal:** Uses `{Feature}IncomingNavigation` directly
- **External:** Uses `{Feature}OutgoingNavigation` (redirected by App layer)

---

## Modal Navigation

### Navigator Example with Modal

```swift
protocol FilterNavigatorContract {
    func presentFilter()
    func dismiss()
}

struct FilterNavigator: FilterNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func presentFilter() {
        navigator.present(
            FeatureIncomingNavigation.filter,
            style: .sheet(detents: [.medium, .large])
        )
    }

    func dismiss() {
        navigator.dismiss()
    }
}
```

### Present / Dismiss Behavior

| Style | Description |
|-------|-------------|
| `.sheet(detents:)` | Presents as a sheet with configurable detents (default: `[.large]`) |
| `.fullScreenCover` | Presents as a full-screen cover |

- `present(_:style:)` — sets `sheetNavigation` or `fullScreenCoverNavigation` on the coordinator
- `dismiss()` — priority: fullScreenCover > sheet > parent onDismiss

---

## App Layer: Connecting Features

### AppNavigationRedirect

```swift
// App/Sources/Navigation/AppNavigationRedirect.swift
import ChallengeCharacter
import ChallengeCore
import ChallengeHome

struct AppNavigationRedirect: NavigationRedirectContract {
    func redirect(_ navigation: any NavigationContract) -> (any NavigationContract)? {
        switch navigation {
        case let outgoing as HomeOutgoingNavigation:
            return redirect(outgoing)
        default:
            return nil
        }
    }

    // MARK: - Private

    private func redirect(_ navigation: HomeOutgoingNavigation) -> any NavigationContract {
        switch navigation {
        case .characters:
            return CharacterIncomingNavigation.list
        }
    }
}
```

**Rules:**
- Centralized place to connect features
- Maps Outgoing → Incoming navigation
- Only place that imports multiple features

### NavigationContainerView (AppKit)

Reusable container that encapsulates `NavigationStack` + push destinations + modal bindings:

```swift
// AppKit/Sources/Presentation/Views/NavigationContainerView.swift

struct NavigationContainerView<Content: View>: View {
    @Bindable var navigationCoordinator: NavigationCoordinator
    let appContainer: AppContainer
    @ViewBuilder let content: Content

    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            content
                .navigationDestination(for: AnyNavigation.self) { navigation in
                    appContainer.resolve(navigation.wrapped, navigator: navigationCoordinator)
                }
        }
        .sheet(item: $navigationCoordinator.sheetNavigation) { modal in
            ModalContainerView(modal: modal, appContainer: appContainer) {
                navigationCoordinator.sheetNavigation = nil
            }
            .presentationDetents(modal.detents)
        }
        .fullScreenCover(item: $navigationCoordinator.fullScreenCoverNavigation) { modal in
            ModalContainerView(modal: modal, appContainer: appContainer) {
                navigationCoordinator.fullScreenCoverNavigation = nil
            }
        }
    }
}
```

### ModalContainerView (AppKit)

Creates its own `NavigationCoordinator` and delegates to `NavigationContainerView`:

```swift
// AppKit/Sources/Presentation/Views/ModalContainerView.swift

struct ModalContainerView: View {
    let modal: ModalNavigation
    let appContainer: AppContainer
    let onDismiss: () -> Void

    @State private var navigationCoordinator: NavigationCoordinator

    init(modal: ModalNavigation, appContainer: AppContainer, onDismiss: @escaping () -> Void) {
        self.modal = modal
        self.appContainer = appContainer
        self.onDismiss = onDismiss
        _navigationCoordinator = State(initialValue: NavigationCoordinator(
            redirector: AppNavigationRedirect(),
            onDismiss: onDismiss
        ))
    }

    var body: some View {
        NavigationContainerView(navigationCoordinator: navigationCoordinator, appContainer: appContainer) {
            appContainer.resolve(modal.navigation.wrapped, navigator: navigationCoordinator)
        }
    }
}
```

### Feature Struct

```swift
// Features/{Feature}/Sources/{Feature}Feature.swift
import ChallengeCore
import ChallengeNetworking
import SwiftUI

public struct {Feature}Feature: FeatureContract {
    private let container: {Feature}Container

    public init(httpClient: any HTTPClientContract) {
        self.container = {Feature}Container(httpClient: httpClient)
    }

    public var deepLinkHandler: (any DeepLinkHandlerContract)? {
        {Feature}DeepLinkHandler()
    }

    public func makeMainView(navigator: any NavigatorContract) -> AnyView {
        AnyView({Name}ListView(
            viewModel: container.make{Name}ListViewModel(navigator: navigator)
        ))
    }

    public func resolve(
        _ navigation: any NavigationContract,
        navigator: any NavigatorContract
    ) -> AnyView? {
        guard let navigation = navigation as? {Feature}IncomingNavigation else {
            return nil
        }
        switch navigation {
        case .list:
            return makeMainView(navigator: navigator)
        case .detail(let identifier):
            return AnyView({Name}DetailView(
                viewModel: container.make{Name}DetailViewModel(
                    identifier: identifier,
                    navigator: navigator
                )
            ))
        }
    }
}
```

### RootContainerView

```swift
// AppKit/Sources/Presentation/Views/RootContainerView.swift
import ChallengeCore
import SwiftUI

public struct RootContainerView: View {
    public let appContainer: AppContainer

    @State private var navigationCoordinator = NavigationCoordinator(redirector: AppNavigationRedirect())

    public init(appContainer: AppContainer) {
        self.appContainer = appContainer
    }

    public var body: some View {
        NavigationContainerView(navigationCoordinator: navigationCoordinator, appContainer: appContainer) {
            appContainer.makeRootView(navigator: navigationCoordinator)
        }
        .onOpenURL { url in
            appContainer.handle(url: url, navigator: navigationCoordinator)
        }
    }
}

/*
#Preview {
    RootContainerView(appContainer: AppContainer())
}
*/
```
