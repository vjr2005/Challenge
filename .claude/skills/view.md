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
│   ├── {Feature}Navigation.swift           # Navigation destinations (see /router)
│   ├── Container/
│   │   └── {Feature}Container.swift        # See /dependencyInjection skill
│   └── Presentation/
│       ├── Views/
│       │   ├── {Name}ListView.swift        # List view (receives ViewModel only)
│       │   └── {Name}DetailView.swift      # Detail view (receives ViewModel only)
│       └── ViewModels/
│           └── {Name}ViewModel.swift       # See /viewmodel skill
└── Tests/
    └── Presentation/
        └── Snapshots/
            └── {Name}ViewSnapshotTests.swift  # Optional
```

**Notes:**
- Views receive **only ViewModel** via init
- Navigation is handled by App using Router (see `/router` skill)
- No Router folder needed - Router lives in Core module

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
- **Switch on state** - Use `switch` on `viewModel.state` to render content
- **@ViewBuilder** - Use for computed properties returning Views
- **Internal visibility** (not public)
- **No Router in View** - Views delegate actions to ViewModel (see `/viewmodel` and `/router` skills)

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
            router: RouterMock()
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
| ListView / DetailView | internal | `Sources/Presentation/Views/` |

---

## Checklist

- [ ] Create View struct with init receiving ViewModel only
- [ ] Use `_viewModel = State(initialValue:)` in init
- [ ] Delegate user actions to ViewModel methods (e.g., `didSelect`)
- [ ] Implement `body` with `.task` modifier for loading
- [ ] Implement `content` with switch on `viewModel.state`
- [ ] Handle all ViewState cases (idle, loading, loaded, error)
- [ ] Add Previews with mock UseCases and RouterMock
