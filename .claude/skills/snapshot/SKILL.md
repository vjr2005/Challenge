---
name: snapshot
description: Creates Snapshot Tests for SwiftUI Views using SnapshotTesting. Use when creating visual regression tests for views with DSAsyncImage support.
---

# Skill: Snapshot Tests

Guide for creating Snapshot Tests using Point-Free's SnapshotTesting library.

## When to use this skill

- Create snapshot tests for a View
- Test different view states visually
- Ensure visual regression prevention

## Additional resources

- For complete implementation examples, see [examples.md](examples.md)

## Prerequisites

1. `SnapshotTesting` dependency in test targets
2. `DSAsyncImage` component (replaces `AsyncImage`)
3. `ImageLoaderMock` in CoreMocks
4. Test image in `Tests/Resources/`

## File structure

```
Tests/
└── Presentation/
    ├── Helpers/
    │   ├── {Name}ViewModelStub.swift
    │   └── SnapshotStubs.swift
    └── {Name}/
        └── Snapshots/
            ├── {Name}ViewSnapshotTests.swift
            └── __Snapshots__/
```

---

## Key Components

### DSAsyncImage

Views must use `DSAsyncImage` instead of `AsyncImage`. Uses `AsyncImagePhase` for handling states:

```swift
DSAsyncImage(url: character.imageURL) { phase in
    switch phase {
    case .success(let image):
        image.resizable().scaledToFill()
    case .empty:
        ProgressView()
    case .failure:
        Image(systemName: "photo")
    @unknown default:
        ProgressView()
    }
}
```

### ViewModel Protocol

Create a protocol for stub injection:

```swift
protocol {Name}ViewModelContract: AnyObject {
    var state: {Name}ViewState { get }
    func load() async
}
```

### ViewModel Stub

Returns fixed state without logic:

```swift
@Observable
final class {Name}ViewModelStub: {Name}ViewModelContract {
    var state: {Name}ViewState

    init(state: {Name}ViewState) {
        self.state = state
    }

    func load() async { }
}
```

### SnapshotStubs

```swift
enum SnapshotStubs {
    static var testImage: UIImage? {
        guard let path = Bundle.module.path(forResource: "test-avatar", ofType: "jpg") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
}
```

---

## Test Structure

```swift
struct {Name}ViewSnapshotTests {
    private let imageLoader: ImageLoaderMock

    init() {
        UIView.setAnimationsEnabled(false)
        imageLoader = ImageLoaderMock(image: SnapshotStubs.testImage)
    }

    @Test
    func loadingState() {
        // Given
        let viewModel = {Name}ViewModelStub(state: .loading)

        // When
        let view = NavigationStack {
            {Name}View(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
    }
}
```

---

## Key Rules

### Test Setup

1. Disable animations: `UIView.setAnimationsEnabled(false)`
2. Create `ImageLoaderMock` with test image
3. Inject `.imageLoader(imageLoader)` on view

### View Configuration

1. Wrap in `NavigationStack`
2. Use `.iPhone13ProMax` device config
3. Apply `imageLoader` modifier

### Naming

- Test file: `{Name}ViewSnapshotTests.swift`
- Test method: `{stateName}State()` (e.g., `loadingState`)
- Snapshots folder: `__Snapshots__/{Name}ViewSnapshotTests/`

---

## Running Tests

### First Run (Recording)

```bash
tuist test {Module}
```

First run creates references and **fails** (expected).

### Subsequent Runs

```bash
tuist test {Module}
```

### Regenerate Snapshots

```bash
rm -rf Tests/Presentation/{Name}/Snapshots/__Snapshots__
tuist test {Module}  # Run twice
```

---

## Checklist

### Setup (once per feature)

- [ ] Add `SnapshotTesting` to testDependencies
- [ ] Create test image in `Tests/Resources/`
- [ ] Create `SnapshotStubs.swift`
- [ ] Create ViewModel protocol
- [ ] Create ViewModel stub

### Per View

- [ ] Use `DSAsyncImage` in View
- [ ] Create snapshot tests file
- [ ] Initialize `ImageLoaderMock`
- [ ] Test each state
- [ ] Use `.iPhone13ProMax` config
- [ ] Run tests twice (record + verify)
