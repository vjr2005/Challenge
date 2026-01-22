# Plan: Navigation System con Router Genérico en Core

## Principios

1. **Un solo protocolo** → `Navigation` con `presentationType`
2. **Router genérico en Core** → Reutilizable, type-safe
3. **NavigationContainer en Core** → Wrapper genérico
4. **Un solo enum en App** → `AppNavigation` con todos los destinos
5. **Features sin navegación** → ViewModels con closures
6. **Deep Links en App** → URL → AppNavigation

---

## Arquitectura

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                 Core                                     │
│                                                                          │
│  Navigation (protocol)         Router<N> (@Observable)                  │
│  ├── presentationType          ├── navigationStackPath: [N]             │
│  └── id                        ├── presentingSheet: N?                  │
│                                ├── presentingFullScreen: N?             │
│  PresentationType (enum)       └── navigate(to:)                        │
│  ├── push                                                               │
│  ├── sheet                     NavigationContainer<N, Content>          │
│  └── fullScreen                └── Wrapper con stack/sheet/fullscreen   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                                 App                                      │
│                                                                          │
│  AppNavigation (enum: Navigation)                                       │
│  ├── characterList        → .push                                       │
│  ├── characterDetail(id)  → .push                                       │
│  ├── locationDetail(id)   → .push                                       │
│  ├── characterFilter      → .sheet                                      │
│  ├── settings             → .sheet                                      │
│  ├── imageGallery(id)     → .fullScreen                                 │
│  └── onboarding           → .fullScreen                                 │
│                                                                          │
│  AppNavigation+View (view mapping)                                      │
│  DeepLink (URL → AppNavigation)                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                              Features                                    │
│                                                                          │
│  ViewModel (con closures)      View                                     │
│  ├── onSelectCharacter         └── Recibe ViewModel                     │
│  ├── onBack                                                             │
│  └── onShowFilter              NO conocen Router ni Navigation          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Estructura de Archivos

```
Libraries/Core/
├── Sources/
│   └── Navigation/
│       ├── Navigation.swift           # Protocolo + PresentationType
│       ├── Router.swift               # @Observable genérico
│       └── NavigationContainer.swift  # View wrapper genérico
├── Mocks/
│   └── RouterMock.swift               # Mock genérico para tests
└── Tests/
    └── Navigation/
        └── RouterTests.swift

Libraries/Features/{Feature}/
├── Sources/
│   ├── {Feature}Feature.swift         # Entry point (sin navegación)
│   ├── Container/
│   │   └── {Feature}Container.swift   # Sin router
│   ├── Presentation/
│   │   └── {Screen}/
│   │       └── ViewModels/
│   │           └── {Screen}ViewModel.swift  # Con closures
│   └── ...

App/
├── Sources/
│   ├── Navigation/
│   │   ├── AppNavigation.swift        # Enum con todos los destinos
│   │   ├── AppNavigation+View.swift   # Mapping destination → View
│   │   └── DeepLink.swift             # URL → AppNavigation
│   └── ContentView.swift
└── Tests/
    └── Navigation/
        ├── AppNavigationTests.swift
        └── DeepLinkTests.swift
```

---

## Implementación

### 1. Core - Navigation Protocol

```swift
// Libraries/Core/Sources/Navigation/Navigation.swift

/// Defines how a destination should be presented.
public enum PresentationType: Sendable {
    case push
    case sheet
    case fullScreen
}

/// Protocol for navigation destinations.
/// Each destination defines its preferred presentation type.
public protocol Navigation: Hashable, Sendable, Identifiable {
    /// How this destination should be presented.
    var presentationType: PresentationType { get }
}
```

---

### 2. Core - Router

```swift
// Libraries/Core/Sources/Navigation/Router.swift
import Observation
import SwiftUI

/// Generic router that manages navigation state.
/// - Parameter N: The navigation destination type.
@Observable
public final class Router<N: Navigation> {
    public let id = UUID()
    public let level: Int

    /// Navigation stack for push destinations.
    public var navigationStackPath: [N] = []

    /// Currently presented sheet destination.
    public var presentingSheet: N?

    /// Currently presented full screen destination.
    public var presentingFullScreen: N?

    /// Reference to parent router (for modal hierarchy).
    public weak var parent: Router<N>?

    /// Whether this router is currently active.
    public private(set) var isActive = false

    public init(level: Int = 0, parent: Router<N>? = nil) {
        self.level = level
        self.parent = parent
    }

    // MARK: - Navigation

    /// Navigate to a destination using its preferred presentation type.
    public func navigate(to destination: N) {
        switch destination.presentationType {
        case .push:
            navigationStackPath.append(destination)
        case .sheet:
            presentingSheet = destination
        case .fullScreen:
            presentingFullScreen = destination
        }
    }

    /// Pop the last destination from the navigation stack.
    public func pop() {
        guard !navigationStackPath.isEmpty else { return }
        navigationStackPath.removeLast()
    }

    /// Pop to the root of the navigation stack.
    public func popToRoot() {
        navigationStackPath.removeAll()
    }

    /// Dismiss the currently presented sheet.
    public func dismissSheet() {
        presentingSheet = nil
    }

    /// Dismiss the currently presented full screen.
    public func dismissFullScreen() {
        presentingFullScreen = nil
    }

    /// Dismiss any modal (sheet or full screen).
    public func dismissModal() {
        presentingSheet = nil
        presentingFullScreen = nil
    }

    // MARK: - Active State

    public func setActive() {
        isActive = true
    }

    public func resignActive() {
        isActive = false
    }
}
```

---

### 3. Core - NavigationContainer

```swift
// Libraries/Core/Sources/Navigation/NavigationContainer.swift
import SwiftUI

/// Generic navigation container that handles push, sheet, and full screen presentations.
/// - Parameters:
///   - N: The navigation destination type.
///   - Content: The root content view type.
public struct NavigationContainer<N: Navigation, Content: View>: View {
    @State private var router: Router<N>
    private let content: () -> Content
    private let destinationView: (N) -> AnyView

    /// Creates a navigation container.
    /// - Parameters:
    ///   - level: The hierarchy level (0 for root).
    ///   - parent: The parent router for modal hierarchy.
    ///   - destinationView: Closure that maps destinations to views.
    ///   - content: The root content view.
    public init(
        level: Int = 0,
        parent: Router<N>? = nil,
        destinationView: @escaping (N) -> AnyView,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._router = State(wrappedValue: Router(level: level, parent: parent))
        self.destinationView = destinationView
        self.content = content
    }

    public var body: some View {
        NavigationStack(path: $router.navigationStackPath) {
            content()
                .navigationDestination(for: N.self) { destination in
                    destinationView(destination)
                }
        }
        .sheet(item: $router.presentingSheet) { destination in
            sheetContainer(for: destination)
        }
        .fullScreenCover(item: $router.presentingFullScreen) { destination in
            fullScreenContainer(for: destination)
        }
        .environment(router)
        .onAppear { router.setActive() }
        .onDisappear { router.resignActive() }
    }

    @ViewBuilder
    private func sheetContainer(for destination: N) -> some View {
        NavigationContainer(
            level: router.level + 1,
            parent: router,
            destinationView: destinationView
        ) {
            destinationView(destination)
        }
    }

    @ViewBuilder
    private func fullScreenContainer(for destination: N) -> some View {
        NavigationContainer(
            level: router.level + 1,
            parent: router,
            destinationView: destinationView
        ) {
            destinationView(destination)
        }
    }
}

// MARK: - Convenience init without parent

public extension NavigationContainer {
    /// Creates a root navigation container.
    init(
        destinationView: @escaping (N) -> AnyView,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(level: 0, parent: nil, destinationView: destinationView, content: content)
    }
}
```

---

### 4. Core - RouterMock

```swift
// Libraries/Core/Mocks/RouterMock.swift
import ChallengeCore

/// Mock router for testing navigation.
public final class RouterMock<N: Navigation>: @unchecked Sendable {
    public private(set) var navigatedDestinations: [N] = []
    public private(set) var popCallCount = 0
    public private(set) var popToRootCallCount = 0
    public private(set) var dismissSheetCallCount = 0
    public private(set) var dismissFullScreenCallCount = 0

    public init() {}

    public func navigate(to destination: N) {
        navigatedDestinations.append(destination)
    }

    public func pop() {
        popCallCount += 1
    }

    public func popToRoot() {
        popToRootCallCount += 1
    }

    public func dismissSheet() {
        dismissSheetCallCount += 1
    }

    public func dismissFullScreen() {
        dismissFullScreenCallCount += 1
    }

    // MARK: - Test Helpers

    public var lastDestination: N? {
        navigatedDestinations.last
    }

    public var pushDestinations: [N] {
        navigatedDestinations.filter { $0.presentationType == .push }
    }

    public var sheetDestinations: [N] {
        navigatedDestinations.filter { $0.presentationType == .sheet }
    }

    public var fullScreenDestinations: [N] {
        navigatedDestinations.filter { $0.presentationType == .fullScreen }
    }
}
```

---

### 5. App - AppNavigation

```swift
// App/Sources/Navigation/AppNavigation.swift
import ChallengeCore

/// All navigation destinations in the app.
enum AppNavigation: Navigation {
    // MARK: - Push Destinations

    case characterList
    case characterDetail(id: Int)
    case locationDetail(id: Int)
    case episodeList
    case episodeDetail(id: Int)

    // MARK: - Sheet Destinations

    case characterFilter
    case settings

    // MARK: - Full Screen Destinations

    case imageGallery(characterId: Int)
    case onboarding

    // MARK: - Navigation Protocol

    var presentationType: PresentationType {
        switch self {
        case .characterList,
             .characterDetail,
             .locationDetail,
             .episodeList,
             .episodeDetail:
            return .push

        case .characterFilter,
             .settings:
            return .sheet

        case .imageGallery,
             .onboarding:
            return .fullScreen
        }
    }

    var id: Self { self }
}
```

---

### 6. App - View Mapping

```swift
// App/Sources/Navigation/AppNavigation+View.swift
import ChallengeCharacter
import ChallengeCore
import ChallengeLocation
import SwiftUI

extension AppNavigation {
    /// Maps a navigation destination to its view.
    @ViewBuilder
    func view(router: Router<AppNavigation>) -> some View {
        switch self {
        // MARK: - Character

        case .characterList:
            Self.characterListView(router: router)

        case .characterDetail(let id):
            Self.characterDetailView(id: id, router: router)

        // MARK: - Location

        case .locationDetail(let id):
            Self.locationDetailView(id: id, router: router)

        // MARK: - Episode

        case .episodeList:
            Self.episodeListView(router: router)

        case .episodeDetail(let id):
            Self.episodeDetailView(id: id, router: router)

        // MARK: - Sheets

        case .characterFilter:
            CharacterFilterView()

        case .settings:
            SettingsView()

        // MARK: - Full Screen

        case .imageGallery(let characterId):
            ImageGalleryView(characterId: characterId)

        case .onboarding:
            OnboardingView()
        }
    }
}

// MARK: - View Factories (wire closures)

private extension AppNavigation {
    static func characterListView(router: Router<AppNavigation>) -> some View {
        let viewModel = CharacterFeature.makeListViewModel()

        viewModel.onSelectCharacter = { id in
            router.navigate(to: .characterDetail(id: id))
        }
        viewModel.onShowFilter = {
            router.navigate(to: .characterFilter)
        }

        return CharacterListView(viewModel: viewModel)
    }

    static func characterDetailView(id: Int, router: Router<AppNavigation>) -> some View {
        let viewModel = CharacterFeature.makeDetailViewModel(id: id)

        viewModel.onBack = {
            router.pop()
        }
        viewModel.onSelectLocation = { locationId in
            router.navigate(to: .locationDetail(id: locationId))
        }
        viewModel.onSelectEpisode = { episodeId in
            router.navigate(to: .episodeDetail(id: episodeId))
        }
        viewModel.onShowGallery = {
            router.navigate(to: .imageGallery(characterId: id))
        }

        return CharacterDetailView(viewModel: viewModel)
    }

    static func locationDetailView(id: Int, router: Router<AppNavigation>) -> some View {
        let viewModel = LocationFeature.makeDetailViewModel(id: id)

        viewModel.onBack = {
            router.pop()
        }
        viewModel.onSelectCharacter = { characterId in
            router.navigate(to: .characterDetail(id: characterId))
        }

        return LocationDetailView(viewModel: viewModel)
    }

    static func episodeListView(router: Router<AppNavigation>) -> some View {
        let viewModel = EpisodeFeature.makeListViewModel()

        viewModel.onSelectEpisode = { id in
            router.navigate(to: .episodeDetail(id: id))
        }

        return EpisodeListView(viewModel: viewModel)
    }

    static func episodeDetailView(id: Int, router: Router<AppNavigation>) -> some View {
        let viewModel = EpisodeFeature.makeDetailViewModel(id: id)

        viewModel.onBack = {
            router.pop()
        }
        viewModel.onSelectCharacter = { characterId in
            router.navigate(to: .characterDetail(id: characterId))
        }

        return EpisodeDetailView(viewModel: viewModel)
    }
}
```

---

### 7. App - DeepLink

```swift
// App/Sources/Navigation/DeepLink.swift
import ChallengeCore
import Foundation

enum DeepLink {
    static let scheme = "challenge"

    /// Parse a URL into a navigation destination.
    static func destination(from url: URL) -> AppNavigation? {
        guard url.scheme == scheme,
              let host = url.host
        else { return nil }

        let pathComponents = url.pathComponents.filter { $0 != "/" }

        switch host {
        case "character":
            return parseCharacter(pathComponents: pathComponents)

        case "location":
            return parseLocation(pathComponents: pathComponents)

        case "episode":
            return parseEpisode(pathComponents: pathComponents)

        default:
            return nil
        }
    }

    // MARK: - Parsers

    private static func parseCharacter(pathComponents: [String]) -> AppNavigation? {
        guard let first = pathComponents.first else {
            return .characterList
        }

        if first == "list" {
            return .characterList
        } else if let id = Int(first) {
            return .characterDetail(id: id)
        }

        return nil
    }

    private static func parseLocation(pathComponents: [String]) -> AppNavigation? {
        guard let first = pathComponents.first,
              let id = Int(first)
        else { return nil }

        return .locationDetail(id: id)
    }

    private static func parseEpisode(pathComponents: [String]) -> AppNavigation? {
        guard let first = pathComponents.first else {
            return .episodeList
        }

        if first == "list" {
            return .episodeList
        } else if let id = Int(first) {
            return .episodeDetail(id: id)
        }

        return nil
    }
}
```

---

### 8. App - ContentView

```swift
// App/Sources/ContentView.swift
import ChallengeCore
import ChallengeHome
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationContainer(
            destinationView: { destination in
                AnyView(destination.view(router: ???))  // Problema: necesitamos el router
            }
        ) {
            homeView()
        }
    }
}
```

**Problema:** El `destinationView` closure necesita acceso al router, pero el router se crea dentro de NavigationContainer.

**Solución:** Pasar el router al closure:

```swift
// Libraries/Core/Sources/Navigation/NavigationContainer.swift (actualizado)

public struct NavigationContainer<N: Navigation, Content: View>: View {
    @State private var router: Router<N>
    private let content: (Router<N>) -> Content
    private let destinationView: (N, Router<N>) -> AnyView

    public init(
        level: Int = 0,
        parent: Router<N>? = nil,
        destinationView: @escaping (N, Router<N>) -> AnyView,
        @ViewBuilder content: @escaping (Router<N>) -> Content
    ) {
        self._router = State(wrappedValue: Router(level: level, parent: parent))
        self.destinationView = destinationView
        self.content = content
    }

    public var body: some View {
        NavigationStack(path: $router.navigationStackPath) {
            content(router)
                .navigationDestination(for: N.self) { destination in
                    destinationView(destination, router)
                }
        }
        .sheet(item: $router.presentingSheet) { destination in
            NavigationContainer(
                level: router.level + 1,
                parent: router,
                destinationView: destinationView
            ) { childRouter in
                destinationView(destination, childRouter)
            }
        }
        .fullScreenCover(item: $router.presentingFullScreen) { destination in
            NavigationContainer(
                level: router.level + 1,
                parent: router,
                destinationView: destinationView
            ) { childRouter in
                destinationView(destination, childRouter)
            }
        }
        .environment(router)
        .onAppear { router.setActive() }
        .onDisappear { router.resignActive() }
        .onOpenURL { url in
            if router.isActive, let destination = DeepLink.destination(from: url) as? N {
                router.navigate(to: destination)
            }
        }
    }
}
```

```swift
// App/Sources/ContentView.swift (actualizado)
import ChallengeCore
import ChallengeHome
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationContainer(
            destinationView: { destination, router in
                AnyView(destination.view(router: router))
            }
        ) { router in
            homeView(router: router)
        }
    }

    @ViewBuilder
    private func homeView(router: Router<AppNavigation>) -> some View {
        let viewModel = HomeFeature.makeViewModel()

        viewModel.onGoToCharacters = {
            router.navigate(to: .characterList)
        }

        return HomeView(viewModel: viewModel)
    }
}
```

---

### 9. Feature - ViewModel con Closures

```swift
// Libraries/Features/Character/Sources/Presentation/CharacterList/ViewModels/CharacterListViewModel.swift

@Observable
public final class CharacterListViewModel: CharacterListViewModelContract {
    public private(set) var state: CharacterListViewState = .idle

    private let getCharactersUseCase: GetCharactersUseCaseContract

    // MARK: - Navigation Actions

    public var onSelectCharacter: ((Int) -> Void)?
    public var onShowFilter: (() -> Void)?

    init(getCharactersUseCase: GetCharactersUseCaseContract) {
        self.getCharactersUseCase = getCharactersUseCase
    }

    public func didSelect(_ character: Character) {
        onSelectCharacter?(character.id)
    }

    public func didTapFilter() {
        onShowFilter?()
    }

    // ... rest of implementation
}
```

```swift
// Libraries/Features/Character/Sources/Presentation/CharacterDetail/ViewModels/CharacterDetailViewModel.swift

@Observable
public final class CharacterDetailViewModel: CharacterDetailViewModelContract {
    public private(set) var state: CharacterDetailViewState = .idle

    private let identifier: Int
    private let getCharacterUseCase: GetCharacterUseCaseContract

    // MARK: - Navigation Actions

    public var onBack: (() -> Void)?
    public var onSelectLocation: ((Int) -> Void)?
    public var onSelectEpisode: ((Int) -> Void)?
    public var onShowGallery: (() -> Void)?

    init(identifier: Int, getCharacterUseCase: GetCharacterUseCaseContract) {
        self.identifier = identifier
        self.getCharacterUseCase = getCharacterUseCase
    }

    public func didTapOnBack() {
        onBack?()
    }

    public func didTapOnLocation(_ location: Location) {
        guard let id = location.identifier else { return }
        onSelectLocation?(id)
    }

    // ... rest of implementation
}
```

---

### 10. Feature - Container (sin router)

```swift
// Libraries/Features/Character/Sources/Container/CharacterContainer.swift
import ChallengeCrossData
import ChallengeNetworking

final class CharacterContainer {
    private let httpClient: any HTTPClientContract
    private let memoryDataSource = CharacterMemoryDataSource()

    private lazy var repository: any CharacterRepositoryContract = CharacterRepository(
        remoteDataSource: CharacterRemoteDataSource(httpClient: httpClient),
        memoryDataSource: memoryDataSource
    )

    init(httpClient: (any HTTPClientContract)? = nil) {
        self.httpClient = httpClient ?? HTTPClient(
            baseURL: AppEnvironment.current.rickAndMorty.baseURL
        )
    }

    func makeCharacterListViewModel() -> CharacterListViewModel {
        CharacterListViewModel(
            getCharactersUseCase: makeGetCharactersUseCase()
        )
    }

    func makeCharacterDetailViewModel(id: Int) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            identifier: id,
            getCharacterUseCase: makeGetCharacterUseCase()
        )
    }

    private func makeGetCharactersUseCase() -> some GetCharactersUseCaseContract {
        GetCharactersUseCase(repository: repository)
    }

    private func makeGetCharacterUseCase() -> some GetCharacterUseCaseContract {
        GetCharacterUseCase(repository: repository)
    }
}
```

---

### 11. Feature - Public API

```swift
// Libraries/Features/Character/Sources/CharacterFeature.swift
import SwiftUI

public enum CharacterFeature {
    private static let container = CharacterContainer()

    public static func makeListViewModel() -> CharacterListViewModel {
        container.makeCharacterListViewModel()
    }

    public static func makeDetailViewModel(id: Int) -> CharacterDetailViewModel {
        container.makeCharacterDetailViewModel(id: id)
    }
}
```

---

## Diagrama de Dependencias

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                 App                                      │
│  ├── AppNavigation (enum: Navigation)                                   │
│  ├── AppNavigation+View (destination → View + closures)                 │
│  ├── DeepLink (URL → AppNavigation)                                     │
│  └── ContentView                                                        │
└─────────────────────────────────────────────────────────────────────────┘
        │
        ├─────────────────────┬─────────────────────┐
        ▼                     ▼                     ▼
   ┌─────────┐          ┌─────────┐          ┌─────────┐
   │  Home   │          │Character│          │Location │
   │         │          │         │          │         │
   │ViewModel│          │ViewModel│          │ViewModel│
   │+closures│          │+closures│          │+closures│
   └─────────┘          └─────────┘          └─────────┘
        │                     │                     │
        └─────────────────────┴─────────────────────┘
                              │
                              ▼
                    ┌───────────────────┐
                    │       Core        │
                    │                   │
                    │ Navigation        │
                    │ PresentationType  │
                    │ Router<N>         │
                    │ NavigationContainer│
                    └───────────────────┘
```

---

## Deep Link Schema

| URL | AppNavigation |
|-----|---------------|
| `challenge://character/list` | `.characterList` |
| `challenge://character/{id}` | `.characterDetail(id)` |
| `challenge://location/{id}` | `.locationDetail(id)` |
| `challenge://episode/list` | `.episodeList` |
| `challenge://episode/{id}` | `.episodeDetail(id)` |

---

## Checklist de Implementación

### Fase 1: Core - Navigation Infrastructure

- [ ] Actualizar `Navigation.swift` (añadir `PresentationType`, `presentationType`)
- [ ] Crear `Router.swift` (genérico)
- [ ] Crear `NavigationContainer.swift` (genérico)
- [ ] Crear `RouterMock.swift` (genérico)
- [ ] Crear tests para Router

### Fase 2: App - Navigation

- [ ] Crear `AppNavigation.swift`
- [ ] Crear `AppNavigation+View.swift`
- [ ] Crear `DeepLink.swift`
- [ ] Actualizar `ContentView.swift`
- [ ] Crear tests para AppNavigation
- [ ] Crear tests para DeepLink

### Fase 3: Features - Actualizar ViewModels

- [ ] Actualizar `CharacterListViewModel` (añadir closures, eliminar router)
- [ ] Actualizar `CharacterDetailViewModel` (añadir closures, eliminar router)
- [ ] Actualizar `HomeViewModel` (añadir closures)
- [ ] Actualizar Containers (eliminar router de init)
- [ ] Actualizar Features (simplificar API)
- [ ] Actualizar tests de ViewModels

### Fase 4: Core - Limpiar

- [ ] Eliminar `RouterContract.swift` (ya no existe)
- [ ] Eliminar `Router.swift` viejo (reemplazado por genérico)

### Fase 5: Tuist

- [ ] Home ya no depende de Character
- [ ] Verificar dependencias de cada feature

### Fase 6: Documentación

- [ ] Crear/actualizar skill `/navigation`
- [ ] Actualizar skill `/dependency-injection`
- [ ] Actualizar skill `/viewmodel`
- [ ] Actualizar skill `/project-structure`

### Fase 7: Verificación

- [ ] `tuist test` compila y pasa todos los tests
- [ ] Probar navegación push/sheet/fullscreen
- [ ] Probar deep links con `xcrun simctl openurl booted "challenge://character/list"`

---

## Beneficios

| Aspecto | Descripción |
|---------|-------------|
| **Un solo protocolo** | `Navigation` con `presentationType` |
| **Router reutilizable** | Genérico en Core, type-safe |
| **Features aisladas** | No conocen Router ni AppNavigation |
| **Closures testeables** | ViewModels fáciles de testear |
| **Sheets con navegación** | Cada modal tiene su Router hijo |
| **Deep links centralizados** | Un solo lugar para parsing |
| **Type-safe** | Enum con associated values |
| **Escalable** | Añadir destino = añadir case + view mapping |
