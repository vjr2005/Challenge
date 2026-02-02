# How To: Create Feature

Create a new feature module with all layers (Domain, Data, Presentation).

## Prerequisites

- Feature name decided (e.g., `Settings`)
- API endpoints identified (if applicable)

## Steps

### 1. Create directory structure

```
Features/{Feature}/
├── Sources/
│   ├── {Feature}Feature.swift
│   ├── {Feature}Container.swift
│   ├── Domain/
│   │   ├── Models/
│   │   ├── UseCases/
│   │   └── Repositories/
│   ├── Data/
│   │   ├── DataSources/
│   │   ├── DTOs/
│   │   └── Repositories/
│   └── Presentation/
│       └── Navigation/
│           ├── {Feature}IncomingNavigation.swift
│           └── {Feature}DeepLinkHandler.swift
├── Tests/
│   ├── Unit/
│   │   ├── Feature/
│   │   │   └── {Feature}FeatureTests.swift
│   │   └── Container/
│   │       └── {Feature}ContainerTests.swift
│   ├── Snapshots/
│   └── Shared/
│       ├── Stubs/
│       ├── Mocks/
│       ├── Extensions/
│       │   └── Bundle+Module.swift
│       └── Fixtures/
└── Mocks/
```

### 2. Create Tuist module

Create `Tuist/ProjectDescriptionHelpers/Modules/{Feature}Module.swift`:

```swift
import ProjectDescription

public enum {Feature}Module {
    public static let module = FrameworkModule.create(
        name: "{Feature}",
        baseFolder: "Features",
        path: "{Feature}",
        dependencies: [
            .target(name: "\(appName)Core"),
            .target(name: "\(appName)Networking"),
            .target(name: "\(appName)Resources"),
            .target(name: "\(appName)DesignSystem"),
        ],
        testDependencies: [
            .target(name: "\(appName)CoreMocks"),
            .target(name: "\(appName)NetworkingMocks"),
        ],
        snapshotTestDependencies: [
            .target(name: "\(appName)CoreMocks"),
            .target(name: "\(appName)NetworkingMocks"),
        ]
    )

    public static let targetReferences: [TargetReference] = [
        .target("\(appName){Feature}"),
    ]
}
```

> **Note:** Tuist automatically detects folders to create targets:
> - `Mocks/` → Target `Challenge{Feature}Mocks`
> - `Tests/Unit/` → Target `Challenge{Feature}Tests`
> - `Tests/Snapshots/` → Target `Challenge{Feature}SnapshotTests`
>
> The contents of `Tests/Shared/` are automatically included in Unit and Snapshot test targets (it does not create its own target).

### 3. Register module

Edit `Tuist/ProjectDescriptionHelpers/Modules.swift`:

```swift
// In 'all', add before AppKitModule:
{Feature}Module.module,

// In 'codeCoverageTargets', add:
+ {Feature}Module.targetReferences
```

### 4. Create IncomingNavigation

Create `Sources/Presentation/Navigation/{Feature}IncomingNavigation.swift`:

```swift
import ChallengeCore

public enum {Feature}IncomingNavigation: IncomingNavigationContract {
    case main
}
```

### 5. Create DeepLinkHandler (optional)

Create `Sources/Presentation/Navigation/{Feature}DeepLinkHandler.swift`:

```swift
import ChallengeCore
import Foundation

struct {Feature}DeepLinkHandler: DeepLinkHandlerContract {
    let scheme = "challenge"
    let host = "{feature}"  // lowercase

    func resolve(_ url: URL) -> (any NavigationContract)? {
        switch url.path {
        case "/main", "":
            return {Feature}IncomingNavigation.main
        default:
            return nil
        }
    }
}
```

### 6. Create Container

Create `Sources/{Feature}Container.swift`:

```swift
import ChallengeCore
import ChallengeNetworking

public final class {Feature}Container: Sendable {
    private let httpClient: any HTTPClientContract

    public init(httpClient: any HTTPClientContract) {
        self.httpClient = httpClient
    }

    // MARK: - Factory Methods

    func make{Feature}ViewModel(navigator: any NavigatorContract) -> {Feature}ViewModel {
        {Feature}ViewModel(
            navigator: {Feature}Navigator(navigator: navigator)
        )
    }
}
```

### 7. Create Feature

Create `Sources/{Feature}Feature.swift`:

```swift
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
        // TODO: Implement when View exists
        AnyView(EmptyView())
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

### 8. Create Bundle+Module for tests

Create `Tests/Shared/Extensions/Bundle+Module.swift`:

```swift
import Foundation

private final class BundleFinder {}

extension Bundle {
    static let module = Bundle(for: BundleFinder.self)
}
```

### 9. Create Feature tests

Create `Tests/Unit/Feature/{Feature}FeatureTests.swift`:

```swift
import ChallengeCore
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Testing

@testable import Challenge{Feature}

struct {Feature}FeatureTests {
    private let httpClientMock = HTTPClientMock()
    private let sut: {Feature}Feature

    init() {
        sut = {Feature}Feature(httpClient: httpClientMock)
    }

    // MARK: - Deep Link Handler

    @Test("Deep link handler returns {Feature}DeepLinkHandler")
    func deepLinkHandlerReturns{Feature}DeepLinkHandler() {
        // When
        let result = sut.deepLinkHandler

        // Then
        #expect(result is {Feature}DeepLinkHandler)
    }

    // MARK: - Resolve

    @Test("Resolve returns nil for unknown navigation")
    func resolveReturnsNilForUnknownNavigation() {
        // Given
        let navigatorMock = NavigatorMock()

        // When
        let result = sut.resolve(TestNavigation.other, navigator: navigatorMock)

        // Then
        #expect(result == nil)
    }
}

// MARK: - Test Helpers

private enum TestNavigation: NavigationContract {
    case other
}
```

### 10. Create Container tests

Create `Tests/Unit/Container/{Feature}ContainerTests.swift`:

```swift
import ChallengeCoreMocks
import ChallengeNetworkingMocks
import Testing

@testable import Challenge{Feature}

struct {Feature}ContainerTests {
    private let httpClientMock = HTTPClientMock()
    private let sut: {Feature}Container

    init() {
        sut = {Feature}Container(httpClient: httpClientMock)
    }

    // MARK: - Factory Methods

    @Test("make{Feature}ViewModel returns configured instance")
    func make{Feature}ViewModelReturnsConfiguredInstance() {
        // Given
        let navigatorMock = NavigatorMock()

        // When
        let viewModel = sut.make{Feature}ViewModel(navigator: navigatorMock)

        // Then
        #expect(viewModel.state == .idle)
    }
}
```

### 11. Register in AppContainer

Edit `AppKit/Sources/AppContainer.swift`:

```swift
// Add import
import Challenge{Feature}

// In the 'features' array, add:
{Feature}Feature(httpClient: self.httpClient),
```

### 12. Generate project and verify

```bash
./generate.sh
```

## Next steps

- [Create DataSource](create-datasource.md) - Create data access
- [Create Repository](create-repository.md) - Create data abstraction
- [Create UseCase](create-usecase.md) - Create business logic
- [Create ViewModel](create-viewmodel.md) - Create state management
- [Create View](create-view.md) - Create user interface
- [Create Navigator](create-navigator.md) - Create navigation between screens

## See also

- [Project Structure](../ProjectStructure.md)
- [Dependency Injection](../DependencyInjection.md)
