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
│       ├── {Name}List/                     # Group by screen/feature
│       │   ├── Views/
│       │   │   └── {Name}ListView.swift
│       │   └── ViewModels/
│       │       └── {Name}ListViewModel.swift
│       └── {Name}Detail/                   # Group by screen/feature
│           ├── Views/
│           │   └── {Name}DetailView.swift
│           └── ViewModels/
│               └── {Name}DetailViewModel.swift
└── Tests/
    └── Presentation/
        ├── {Name}List/
        │   ├── ViewModels/
        │   │   └── {Name}ListViewModelTests.swift
        │   └── Snapshots/
        │       └── {Name}ListViewSnapshotTests.swift
        └── {Name}Detail/
            ├── ViewModels/
            │   └── {Name}DetailViewModelTests.swift
            └── Snapshots/
                └── {Name}DetailViewSnapshotTests.swift
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

All Views must include previews. For Views with state-driven content, create a preview for **each state except `idle`**.

### Preview Rules

- **Skip `idle` state** - it's a transient state with no visual content
- **One preview per visual state** - Loading, Loaded, Empty, Error, etc.
- **Use descriptive names** - `#Preview("Loading")`, `#Preview("Error")`
- **Wrap in NavigationStack** - when the view uses navigation features
- **Create private preview mocks** - with configurable behavior (delay, isEmpty, shouldFail)

### Preview Mocks Pattern

Previews use **private mocks** defined at the bottom of the View file:

```swift
// MARK: - Preview Mocks

private final class Get{Name}UseCasePreviewMock: Get{Name}UseCaseContract {
    private let delay: Bool
    private let isEmpty: Bool
    private let shouldFail: Bool

    init(delay: Bool = false, isEmpty: Bool = false, shouldFail: Bool = false) {
        self.delay = delay
        self.isEmpty = isEmpty
        self.shouldFail = shouldFail
    }

    func execute() async throws -> {Name} {
        if delay {
            try? await Task.sleep(for: .seconds(100))
        }
        if shouldFail {
            throw PreviewError.failed
        }
        if isEmpty {
            return {Name}(items: [])
        }
        return {Name}.stubForPreview()
    }
}

private enum PreviewError: Error {
    case failed
}

private final class RouterPreviewMock: RouterContract {
    func navigate(to destination: any Navigation) {}
    func goBack() {}
}
```

### Previews for Views with State

```swift
#Preview("Loading") {
    NavigationStack {
        CharacterListView(
            viewModel: CharacterListViewModel(
                getCharactersUseCase: GetCharactersUseCasePreviewMock(delay: true),
                router: RouterPreviewMock()
            )
        )
    }
}

#Preview("Loaded") {
    NavigationStack {
        CharacterListView(
            viewModel: CharacterListViewModel(
                getCharactersUseCase: GetCharactersUseCasePreviewMock(),
                router: RouterPreviewMock()
            )
        )
    }
}

#Preview("Empty") {
    NavigationStack {
        CharacterListView(
            viewModel: CharacterListViewModel(
                getCharactersUseCase: GetCharactersUseCasePreviewMock(isEmpty: true),
                router: RouterPreviewMock()
            )
        )
    }
}

#Preview("Error") {
    NavigationStack {
        CharacterListView(
            viewModel: CharacterListViewModel(
                getCharactersUseCase: GetCharactersUseCasePreviewMock(shouldFail: true),
                router: RouterPreviewMock()
            )
        )
    }
}
```

### Previews for Stateless Views

Stateless views (no ViewState) need only one preview:

```swift
#Preview {
    HomeView(viewModel: HomeViewModel(router: RouterPreviewMock()))
}

// MARK: - Preview Mocks

private final class RouterPreviewMock: RouterContract {
    func navigate(to destination: any Navigation) {}
    func goBack() {}
}
```

---

## Example: CharacterListView

```swift
// Sources/Presentation/CharacterList/Views/CharacterListView.swift
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

// MARK: - Previews

#Preview("Loading") {
    NavigationStack {
        CharacterListView(
            viewModel: CharacterListViewModel(
                getCharactersUseCase: GetCharactersUseCasePreviewMock(delay: true),
                router: RouterPreviewMock()
            )
        )
    }
}

#Preview("Loaded") {
    NavigationStack {
        CharacterListView(
            viewModel: CharacterListViewModel(
                getCharactersUseCase: GetCharactersUseCasePreviewMock(),
                router: RouterPreviewMock()
            )
        )
    }
}

// MARK: - Preview Mocks

private final class GetCharactersUseCasePreviewMock: GetCharactersUseCaseContract {
    private let delay: Bool

    init(delay: Bool = false) {
        self.delay = delay
    }

    func execute() async throws -> [Character] {
        if delay {
            try? await Task.sleep(for: .seconds(100))
        }
        return [Character.stub()]
    }
}

private final class RouterPreviewMock: RouterContract {
    func navigate(to destination: any Navigation) {}
    func goBack() {}
}
```

---

## Example: CharacterDetailView

```swift
// Sources/Presentation/CharacterDetail/Views/CharacterDetailView.swift
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

// MARK: - Previews

#Preview("Loading") {
    NavigationStack {
        CharacterDetailView(
            viewModel: CharacterDetailViewModel(
                identifier: 1,
                getCharacterUseCase: GetCharacterUseCasePreviewMock(delay: true),
                router: RouterPreviewMock()
            )
        )
    }
}

#Preview("Loaded") {
    NavigationStack {
        CharacterDetailView(
            viewModel: CharacterDetailViewModel(
                identifier: 1,
                getCharacterUseCase: GetCharacterUseCasePreviewMock(),
                router: RouterPreviewMock()
            )
        )
    }
}

#Preview("Error") {
    NavigationStack {
        CharacterDetailView(
            viewModel: CharacterDetailViewModel(
                identifier: 1,
                getCharacterUseCase: GetCharacterUseCasePreviewMock(shouldFail: true),
                router: RouterPreviewMock()
            )
        )
    }
}

// MARK: - Preview Mocks

private final class GetCharacterUseCasePreviewMock: GetCharacterUseCaseContract {
    private let delay: Bool
    private let shouldFail: Bool

    init(delay: Bool = false, shouldFail: Bool = false) {
        self.delay = delay
        self.shouldFail = shouldFail
    }

    func execute(identifier: Int) async throws -> Character {
        if delay {
            try? await Task.sleep(for: .seconds(100))
        }
        if shouldFail {
            throw PreviewError.failed
        }
        return Character.stub()
    }
}

private enum PreviewError: Error {
    case failed
}

private final class RouterPreviewMock: RouterContract {
    func navigate(to destination: any Navigation) {}
    func goBack() {}
}
```

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| ListView / DetailView | internal | `Sources/Presentation/{FeatureName}/Views/` |

---

## Checklist

- [ ] Create View struct with init receiving ViewModel only
- [ ] Use `_viewModel = State(initialValue:)` in init
- [ ] Delegate user actions to ViewModel methods (e.g., `didSelect`)
- [ ] Implement `body` with `.task` modifier for loading
- [ ] Implement `content` with switch on `viewModel.state`
- [ ] Handle all ViewState cases (idle, loading, loaded, error)
- [ ] Add Previews for each state (except idle) with private preview mocks
