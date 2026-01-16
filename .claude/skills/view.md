---
name: view
description: Creates SwiftUI Views with ViewModel integration. Use when creating views, integrating with ViewModels, or adding SwiftUI previews.
---

# Skill: View

Guide for creating SwiftUI Views that use ViewModels with dependency injection.

## When to use this skill

- Create a new View for a feature
- Integrate View with ViewModel via init
- Add SwiftUI Previews with mocks

## File structure

```
Libraries/Features/{FeatureName}/
├── Sources/
│   ├── {Feature}Feature.swift              # Public entry point (see /dependencyInjection)
│   ├── Container/
│   │   └── {Feature}Container.swift        # See /dependencyInjection skill
│   └── Presentation/
│       ├── Views/
│       │   ├── {Feature}RootView.swift     # Root view (owns Container and Router)
│       │   ├── {Name}ListView.swift        # List view (receives ViewModel only)
│       │   └── {Name}DetailView.swift      # Detail view (receives ViewModel only)
│       ├── ViewModels/
│       │   └── {Name}ViewModel.swift       # See /viewmodel skill
│       └── Router/
│           └── {Feature}Router.swift       # See /router skill
└── Tests/
    └── Presentation/
        └── Snapshots/
            └── {Name}ViewSnapshotTests.swift  # Optional
```

---

## View Pattern (with dependency injection)

Views receive their ViewModel via init using `_viewModel = State(initialValue:)`:

```swift
import SwiftUI

struct {Name}View: View {
    @State private var viewModel: {Name}ViewModel

    init(viewModel: {Name}ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .task {
                await viewModel.load()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
        case .loading:
            ProgressView()
        case .loaded(let data):
            Text(data.name)
        case .error:
            ContentUnavailableView(
                "Error",
                systemImage: "exclamationmark.triangle"
            )
        }
    }
}
```

**Rules:**
- **Init for ViewModel** - Use `_viewModel = State(initialValue:)` pattern
- **RootView creates Views** - RootView creates child Views with injected ViewModels
- **Switch on state** - Use `switch` on `viewModel.state` to render content
- **@ViewBuilder** - Use for computed properties returning Views
- **Internal visibility** (not public)

---

## Root View Pattern

RootView owns Container and Router, creates ViewModels for child Views:

```swift
import SwiftUI

struct {Feature}RootView: View {
    private let container: {Feature}Container
    @State private var router: {Feature}Router

    init() {
        let container = {Feature}Container()
        self.container = container
        _router = State(initialValue: container.makeRouter())
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            {Name}ListView(
                viewModel: container.makeListViewModel(router: router)
            )
            .navigationDestination(for: {Feature}Router.Destination.self) { destination in
                destinationView(for: destination)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for destination: {Feature}Router.Destination) -> some View {
        switch destination {
        case .detail(let item):
            {Name}DetailView(
                viewModel: container.makeDetailViewModel(itemId: item.id)
            )
        }
    }
}
```

**Rules:**
- **RootView owns Container** - Creates instance in init
- **RootView owns Router** - Uses `_router = State(initialValue:)`
- **Container creates ViewModels** - With Router injected where needed
- **Child Views only receive ViewModel** - No Container or Router access

---

## List View Pattern (with navigation)

List Views delegate navigation to ViewModel:

```swift
import SwiftUI

struct {Name}ListView: View {
    @State private var viewModel: {Name}ListViewModel

    init(viewModel: {Name}ListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .task {
                await viewModel.load()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
        case .loading:
            ProgressView()
        case .loaded(let items):
            List(items) { item in
                Button(item.name) {
                    viewModel.didSelect(item)  // Delegate to ViewModel
                }
            }
        case .error:
            ContentUnavailableView(
                "Error",
                systemImage: "exclamationmark.triangle"
            )
        }
    }
}
```

**Rules:**
- **View only knows ViewModel** - No Router dependency in View
- **Delegate actions** - User actions call ViewModel methods (e.g., `didSelect`)
- **ViewModel handles navigation** - See `/viewmodel` skill

---

## State Rendering

Always use a `switch` statement to render based on ViewState:

```swift
@ViewBuilder
private var content: some View {
    switch viewModel.state {
    case .idle:
        Color.clear
    case .loading:
        ProgressView()
    case .loaded(let data):
        DataView(data: data)
    case .error:
        ContentUnavailableView(
            "Error",
            systemImage: "exclamationmark.triangle"
        )
    }
}
```

**For lists with empty state** (use `case .empty` from ViewState):

```swift
case .empty:
    ContentUnavailableView(
        "No items",
        systemImage: "tray"
    )
case .loaded(let items):
    List(items) { item in
        ItemRow(item: item)
    }
```

> **Note:** The ViewModel handles the empty check and sets `.empty` state. See `/viewmodel` skill for the ViewState definition.

---

## Previews

Previews create ViewModels with mocks:

```swift
#Preview {
    let mock = GetCharacterUseCaseMock()
    mock.result = .success(.stub())
    return CharacterDetailView(
        viewModel: CharacterDetailViewModel(
            getCharacterUseCase: mock
        )
    )
}
```

**Multiple states:**

```swift
#Preview("Loading") {
    CharacterDetailView(
        viewModel: CharacterDetailViewModel(
            getCharacterUseCase: GetCharacterUseCaseMock()
        )
    )
}

#Preview("Loaded") {
    let mock = GetCharacterUseCaseMock()
    mock.result = .success(.stub())
    return CharacterDetailView(
        viewModel: CharacterDetailViewModel(
            getCharacterUseCase: mock
        )
    )
}
```

---

## Example: CharacterRootView

```swift
// Sources/Presentation/Views/CharacterRootView.swift
import SwiftUI

struct CharacterRootView: View {
    private let container: CharacterContainer
    @State private var router: CharacterRouter

    init() {
        let container = CharacterContainer()
        self.container = container
        _router = State(initialValue: container.makeRouter())
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            CharacterListView(
                viewModel: container.makeListViewModel(router: router)
            )
            .navigationDestination(for: CharacterRouter.Destination.self) { destination in
                destinationView(for: destination)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for destination: CharacterRouter.Destination) -> some View {
        switch destination {
        case .detail(let character):
            CharacterDetailView(
                viewModel: container.makeDetailViewModel(characterId: character.id)
            )
        }
    }
}
```

---

## Example: CharacterListView

```swift
// Sources/Presentation/Views/CharacterListView.swift
import SwiftUI

struct CharacterListView: View {
    @State private var viewModel: CharacterListViewModel

    init(viewModel: CharacterListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .task {
                await viewModel.load()
            }
            .navigationTitle("Characters")
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
        case .loading:
            ProgressView()
        case .empty:
            ContentUnavailableView(
                "No characters",
                systemImage: "person.slash"
            )
        case .loaded(let characters):
            List(characters) { character in
                Button(character.name) {
                    viewModel.didSelect(character)
                }
            }
        case .error:
            ContentUnavailableView(
                "Error loading characters",
                systemImage: "exclamationmark.triangle"
            )
        }
    }
}

#Preview {
    CharacterListView(
        viewModel: CharacterListViewModel(
            getCharactersUseCase: GetCharactersUseCaseMock(),
            router: CharacterRouter()
        )
    )
}
```

---

## Example: CharacterDetailView

```swift
// Sources/Presentation/Views/CharacterDetailView.swift
import SwiftUI

struct CharacterDetailView: View {
    @State private var viewModel: CharacterDetailViewModel

    init(viewModel: CharacterDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .task {
                await viewModel.load()
            }
            .navigationTitle("Character")
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
        case .loading:
            ProgressView()
        case .loaded(let character):
            ScrollView {
                VStack(spacing: 16) {
                    AsyncImage(url: character.imageURL) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 200, height: 200)

                    Text(character.name)
                        .font(.title)
                    Text(character.status.rawValue)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        case .error:
            ContentUnavailableView(
                "Error loading character",
                systemImage: "exclamationmark.triangle"
            )
        }
    }
}

#Preview {
    let mock = GetCharacterUseCaseMock()
    mock.result = .success(.stub())
    return NavigationStack {
        CharacterDetailView(
            viewModel: CharacterDetailViewModel(
                getCharacterUseCase: mock
            )
        )
    }
}
```

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| RootView | internal | `Sources/Presentation/Views/` |
| ListView / DetailView | internal | `Sources/Presentation/Views/` |

---

## Checklist

### RootView
- [ ] Create RootView that owns Container and Router
- [ ] Use `_router = State(initialValue:)` for Router
- [ ] Create NavigationStack with `path: $router.path`
- [ ] Create child Views with ViewModels from Container

### Child Views (ListView, DetailView)
- [ ] Create View struct with init receiving ViewModel only
- [ ] Use `_viewModel = State(initialValue:)` in init
- [ ] Delegate user actions to ViewModel methods (e.g., `didSelect`)
- [ ] Implement `body` with `.task` modifier for loading
- [ ] Implement `content` with switch on `viewModel.state`
- [ ] Handle all ViewState cases (idle, loading, loaded, error)
- [ ] Add Previews with mock UseCases
