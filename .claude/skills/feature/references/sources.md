# Source Templates

Placeholders:
- `{Feature}` — PascalCase feature name (e.g., `Episode`)
- `{Screen}` — PascalCase screen name (e.g., `EpisodeList`)
- `{feature}` — lowercase deep link host (e.g., `episode`)
- `{deepLinkPath}` — deep link path (e.g., `/list`)
- `{eventPrefix}` — snake_case of Screen (e.g., `episode_list`)

---

## Navigation

### {Feature}IncomingNavigation.swift

Path: `Sources/Presentation/Navigation/{Feature}IncomingNavigation.swift`

```swift
import ChallengeCore

public enum {Feature}IncomingNavigation: IncomingNavigationContract {
    case main
}
```

### {Feature}DeepLinkHandler.swift

Path: `Sources/Presentation/Navigation/{Feature}DeepLinkHandler.swift`

```swift
import ChallengeCore
import Foundation

struct {Feature}DeepLinkHandler: DeepLinkHandlerContract {
    let scheme = "challenge"
    let host = "{feature}"

    func resolve(_ url: URL) -> (any NavigationContract)? {
        switch url.path {
        case "{deepLinkPath}":
            {Feature}IncomingNavigation.main

        default:
            nil
        }
    }
}
```

---

## Navigator

### {Screen}NavigatorContract.swift

Path: `Sources/Presentation/{Screen}/Navigator/{Screen}NavigatorContract.swift`

```swift
protocol {Screen}NavigatorContract {
    // Add navigation methods as the feature grows
}
```

### {Screen}Navigator.swift

Path: `Sources/Presentation/{Screen}/Navigator/{Screen}Navigator.swift`

No `any` on internal `NavigatorContract` — follows project convention.

```swift
import ChallengeCore

struct {Screen}Navigator: {Screen}NavigatorContract {
    private let navigator: NavigatorContract

    init(navigator: NavigatorContract) {
        self.navigator = navigator
    }
}
```

---

## Tracker

### {Screen}TrackerContract.swift

Path: `Sources/Presentation/{Screen}/Tracker/{Screen}TrackerContract.swift`

```swift
protocol {Screen}TrackerContract {
    func trackScreenViewed()
}
```

### {Screen}Tracker.swift

Path: `Sources/Presentation/{Screen}/Tracker/{Screen}Tracker.swift`

No `any` on internal `TrackerContract`.

```swift
import ChallengeCore

struct {Screen}Tracker: {Screen}TrackerContract {
    private let tracker: TrackerContract

    init(tracker: TrackerContract) {
        self.tracker = tracker
    }

    func trackScreenViewed() {
        tracker.track({Screen}Event.screenViewed)
    }
}
```

### {Screen}Event.swift

Path: `Sources/Presentation/{Screen}/Tracker/{Screen}Event.swift`

```swift
import ChallengeCore

enum {Screen}Event: TrackingEventContract {
    case screenViewed

    var name: String {
        switch self {
        case .screenViewed:
            "{eventPrefix}_viewed"
        }
    }

    var properties: [String: String] {
        switch self {
        case .screenViewed:
            [:]
        }
    }
}
```

---

## ViewModel

### {Screen}ViewModelContract.swift

Path: `Sources/Presentation/{Screen}/ViewModels/{Screen}ViewModelContract.swift`

```swift
protocol {Screen}ViewModelContract: AnyObject {
    func didAppear()
}
```

### {Screen}ViewModel.swift

Path: `Sources/Presentation/{Screen}/ViewModels/{Screen}ViewModel.swift`

No `@Observable` (no observable state), no imports (all types internal), no `any`.

```swift
final class {Screen}ViewModel: {Screen}ViewModelContract {
    // MARK: - Dependencies

    private let navigator: {Screen}NavigatorContract
    private let tracker: {Screen}TrackerContract

    // MARK: - Init

    init(
        navigator: {Screen}NavigatorContract,
        tracker: {Screen}TrackerContract
    ) {
        self.navigator = navigator
        self.tracker = tracker
    }

    // MARK: - {Screen}ViewModelContract

    func didAppear() {
        tracker.trackScreenViewed()
    }
}
```

---

## View

### {Screen}View.swift

Path: `Sources/Presentation/{Screen}/Views/{Screen}View.swift`

```swift
import ChallengeDesignSystem
import SwiftUI

struct {Screen}View<ViewModel: {Screen}ViewModelContract>: View {
    // MARK: - Properties

    @State private var viewModel: ViewModel

    // MARK: - Init

    init(viewModel: ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        Text("{Feature}")
            .onFirstAppear {
                viewModel.didAppear()
            }
    }
}

/*
#if DEBUG
#Preview {
    {Screen}View(viewModel: {Screen}ViewModelStub())
}
#endif
*/
```

---

## Container

### {Feature}Container.swift

Path: `Sources/{Feature}Container.swift`

Uses `any` only on public protocols from Core module.

```swift
import ChallengeCore

public final class {Feature}Container {
    // MARK: - Dependencies

    private let tracker: any TrackerContract

    // MARK: - Init

    public init(tracker: any TrackerContract) {
        self.tracker = tracker
    }

    // MARK: - Factories

    func make{Screen}ViewModel(navigator: any NavigatorContract) -> {Screen}ViewModel {
        {Screen}ViewModel(
            navigator: {Screen}Navigator(navigator: navigator),
            tracker: {Screen}Tracker(tracker: tracker)
        )
    }
}
```

---

## Feature

### {Feature}Feature.swift

Path: `Sources/{Feature}Feature.swift`

```swift
import ChallengeCore
import SwiftUI

public struct {Feature}Feature: FeatureContract {
    // MARK: - Dependencies

    private let container: {Feature}Container

    // MARK: - Init

    public init(tracker: any TrackerContract) {
        self.container = {Feature}Container(tracker: tracker)
    }

    // MARK: - FeatureContract

    public var deepLinkHandler: (any DeepLinkHandlerContract)? {
        {Feature}DeepLinkHandler()
    }

    public func makeMainView(navigator: any NavigatorContract) -> AnyView {
        AnyView({Screen}View(viewModel: container.make{Screen}ViewModel(navigator: navigator)))
    }

    public func resolve(
        _ navigation: any NavigationContract,
        navigator: any NavigatorContract
    ) -> AnyView? {
        guard let navigation = navigation as? {Feature}IncomingNavigation else {
            return nil
        }
        switch navigation {
        case .main:
            return makeMainView(navigator: navigator)
        }
    }
}
```
