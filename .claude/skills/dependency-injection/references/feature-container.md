# Feature & Container

## Feature Container (Full Data Layer)

```swift
// Features/{Feature}/Sources/{Feature}Container.swift
import ChallengeCore
import ChallengeNetworking

struct {Feature}Container {
    // MARK: - Dependencies

    private let tracker: any TrackerContract

    // MARK: - Repositories

    private let repository: any {Name}RepositoryContract

    // MARK: - Init

    init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
        self.tracker = tracker
        let remoteDataSource = {Name}RemoteDataSource(httpClient: httpClient)
        let memoryDataSource = {Name}MemoryDataSource()
        self.repository = {Name}Repository(
            remoteDataSource: remoteDataSource,
            memoryDataSource: memoryDataSource
        )
    }

    // MARK: - Factories

    func make{Name}ListViewModel(navigator: any NavigatorContract) -> {Name}ListViewModel {
        {Name}ListViewModel(
            get{Name}sUseCase: Get{Name}sUseCase(repository: repository),
            refresh{Name}sUseCase: Refresh{Name}sUseCase(repository: repository),
            navigator: {Name}ListNavigator(navigator: navigator),
            tracker: {Name}ListTracker(tracker: tracker)
        )
    }

    func make{Name}DetailViewModel(
        identifier: Int,
        navigator: any NavigatorContract
    ) -> {Name}DetailViewModel {
        {Name}DetailViewModel(
            identifier: identifier,
            get{Name}UseCase: Get{Name}UseCase(repository: repository),
            refresh{Name}UseCase: Refresh{Name}UseCase(repository: repository),
            navigator: {Name}DetailNavigator(navigator: navigator),
            tracker: {Name}DetailTracker(tracker: tracker)
        )
    }
}
```

**Rules:**
- **internal struct** (only accessed by its Feature within the same module)
- Receives `httpClient` and `tracker` from Feature (injected by AppContainer)
- Only stores what factory methods need after `init` (`tracker`, repositories)
- DataSources are **local variables in `init`** — only needed to build repositories
- Repositories are **stored properties** (`private let`) built in `init`
- Contains all **factory methods** for ViewModels
- Factory methods receive `navigator: any NavigatorContract`
- Factory methods create screen-specific trackers: `{Name}ListTracker(tracker: tracker)`

---

## Feature Struct (Public Entry Point)

```swift
// Sources/{Feature}Feature.swift
import ChallengeCore
import ChallengeNetworking
import SwiftUI

public struct {Feature}Feature: FeatureContract {
    // MARK: - Dependencies

    private let container: {Feature}Container

    // MARK: - Init

    init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
        self.container = {Feature}Container(httpClient: httpClient, tracker: tracker)
    }

    // MARK: - Feature Protocol

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

**Rules:**
- **public struct** implementing `FeatureContract` protocol
- **Required httpClient and tracker** in init (injected by AppContainer)
- Creates and owns its **Container**
- **deepLinkHandler** property (optional) - Returns handler instance if feature handles deep links
- **makeMainView()** - Returns the default entry point view
- **resolve()** - Returns view for navigation or `nil` if not handled

---

## Simple Feature (No Data Layer)

```swift
// Sources/HomeFeature.swift
import ChallengeCore
import SwiftUI

public struct HomeFeature: FeatureContract {
    // MARK: - Dependencies

    private let container: HomeContainer

    // MARK: - Init

    init(tracker: any TrackerContract) {
        self.container = HomeContainer(tracker: tracker)
    }

    // MARK: - Feature Protocol

    public var deepLinkHandler: (any DeepLinkHandlerContract)? {
        HomeDeepLinkHandler()
    }

    public func makeMainView(navigator: any NavigatorContract) -> AnyView {
        AnyView(HomeView(viewModel: container.makeHomeViewModel(navigator: navigator)))
    }

    public func resolve(
        _ navigation: any NavigationContract,
        navigator: any NavigatorContract
    ) -> AnyView? {
        guard let navigation = navigation as? HomeIncomingNavigation else {
            return nil
        }
        switch navigation {
        case .main:
            return makeMainView(navigator: navigator)
        }
    }
}
```

```swift
// Sources/HomeContainer.swift
import ChallengeCore

struct HomeContainer {
    // MARK: - Dependencies

    private let tracker: any TrackerContract

    // MARK: - Init

    init(tracker: any TrackerContract) {
        self.tracker = tracker
    }

    // MARK: - Factories

    func makeHomeViewModel(navigator: any NavigatorContract) -> HomeViewModel {
        HomeViewModel(
            navigator: HomeNavigator(navigator: navigator),
            tracker: HomeTracker(tracker: tracker)
        )
    }
}
```

**Note:** Even simple features use Container for architectural consistency and future extensibility.

---

## Navigation Destinations

```swift
// Sources/Navigation/{Feature}IncomingNavigation.swift
import ChallengeCore

public enum {Feature}IncomingNavigation: IncomingNavigationContract {
    case list
    case detail(identifier: Int)
}
```

```swift
// Sources/Navigation/{Feature}OutgoingNavigation.swift
import ChallengeCore

public enum {Feature}OutgoingNavigation: OutgoingNavigationContract {
    case settings  // Navigates to Settings feature
}
```

**Rules:**
- Conform to `NavigationContract` protocol (from Core module)
- Use primitive types for parameters (Int, String, Bool, UUID)
- Never pass domain objects - only identifiers
- **IncomingNavigation**: Destinations this feature handles
- **OutgoingNavigation**: Destinations to other features (connected via AppNavigationRedirect)

---

## Deep Link Handler (Optional)

```swift
// Sources/Navigation/{Feature}DeepLinkHandler.swift
import ChallengeCore
import Foundation

struct {Feature}DeepLinkHandler: DeepLinkHandlerContract {
    let scheme = "challenge"
    let host = "{feature}"

    func resolve(_ url: URL) -> (any NavigationContract)? {
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        switch pathComponents.first {
        case "list", .none:
            return {Feature}IncomingNavigation.list

        case "detail":
            guard let idString = pathComponents.dropFirst().first,
                  let id = Int(idString) else {
                return nil
            }
            return {Feature}IncomingNavigation.detail(identifier: id)

        default:
            return nil
        }
    }
}
```

---

## Home Feature with External Navigation

```swift
// Sources/Presentation/Home/Navigator/HomeNavigatorContract.swift
protocol HomeNavigatorContract {
    func navigateToCharacters()
}
```

```swift
// Sources/Presentation/Home/Navigator/HomeNavigator.swift
import ChallengeCore

struct HomeNavigator: HomeNavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }

    func navigateToCharacters() {
        // Uses OutgoingNavigation - redirected by AppNavigationRedirect
        navigator.navigate(to: HomeOutgoingNavigation.characters)
    }
}
```

**Key Point:** HomeNavigator uses `OutgoingNavigation`, which is connected to `CharacterIncomingNavigation.list` via `AppNavigationRedirect`.
