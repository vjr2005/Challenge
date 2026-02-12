---
name: snapshot
description: Creates Snapshot Tests for SwiftUI Views using ChallengeSnapshotTestKit. Use when creating visual regression tests for views with DSAsyncImage support.
---

# Skill: Snapshot Tests

Guide for creating Snapshot Tests using `ChallengeSnapshotTestKit`. Tests only use `ChallengeSnapshotTestKit`'s public API. See the [module README](../../../Libraries/SnapshotTestKit/README.md) for internal details.

## References

- **Concrete test examples**: See [references/examples.md](references/examples.md)

---

## Prerequisites

1. `ChallengeSnapshotTestKit` dependency in snapshot test targets (added automatically by Tuist)
2. `DSAsyncImage` component (replaces `AsyncImage`)
3. `ImageLoaderMock` in CoreMocks
4. Test image in `Tests/Shared/Resources/`

## File Structure

```
Tests/
├── Snapshots/
│   └── Presentation/
│       └── {Name}/
│           ├── {Name}ViewSnapshotTests.swift
│           └── __Snapshots__/
└── Shared/
    ├── Stubs/
    │   └── {Name}ViewModelStub.swift
    └── Resources/
        └── test-avatar.jpg
```

---

## Test Structure

Uses instance variables pattern for cleaner tests:

```swift
struct {Name}ViewSnapshotTests {
    // MARK: - Properties

    private let imageLoader: ImageLoaderMock

    // MARK: - Initialization

    init() {
        UIView.setAnimationsEnabled(false)
        imageLoader = ImageLoaderMock(cachedImage: .stub, asyncImage: .stub)
    }

    // MARK: - Tests

    @Test("Renders loading state correctly")
    func loadingState() {
        // Given
        let viewModel = {Name}ViewModelStub(state: .loading)

        // When
        let view = NavigationStack {
            {Name}View(viewModel: viewModel)
        }
        .imageLoader(imageLoader)

        // Then
        assertSnapshot(of: view, as: .device)
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
2. Use `.device` strategy for full-screen views, `.image` for components, `.component(size:)` for components that wrap a `Button`
3. Apply `imageLoader` modifier

### Naming

- Test file: `{Name}ViewSnapshotTests.swift`
- Test method: `{stateName}State()` (e.g., `loadingState`)
- **Test description**: `@Test("Renders {state} state correctly")`
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
rm -rf Tests/Snapshots/Presentation/{Name}/__Snapshots__
tuist test {Module}  # Run twice
```

---

## Checklist

### Setup (once per feature)

- [ ] `ChallengeSnapshotTestKit` is automatically included by Tuist in snapshot test targets
- [ ] Create test image in `Tests/Shared/Resources/`
- [ ] Create ViewModel stub in `Tests/Shared/Stubs/`
- [ ] Create ViewModel protocol

### Per View

- [ ] Use `DSAsyncImage` in View
- [ ] Create snapshot tests file in `Tests/Snapshots/`
- [ ] **All `@Test` attributes include a description**
- [ ] Initialize `ImageLoaderMock`
- [ ] Test each state
- [ ] Use `.device` strategy for full-screen views
- [ ] Run tests twice (record + verify)
