# Scenarios & SwiftMockServer

## SwiftMockServer

UI tests use [SwiftMockServer](https://github.com/vjr2005/SwiftMockServer) to intercept HTTP requests with a local mock server. `UITestCase` manages the server lifecycle automatically:

- **`setUp()`**: Creates a `MockServer` instance and stores `serverBaseURL`
- **`launch()`**: Passes `serverBaseURL` via `API_BASE_URL` environment variable, waits for the app to reach foreground state
- **`tearDown()`**: Stops the server

### Route Registration

SwiftMockServer provides three registration methods:

| Method | Purpose |
|--------|---------|
| `registerCatchAll { request in }` | Handles all unmatched requests (initial scenarios) |
| `register(.GET, "/path") { request in }` | Exact path match (recovery overrides) |
| `registerPrefix(.GET, "/path/") { request in }` | Prefix path match (recovery overrides) |

Specific routes (`register`/`registerPrefix`) take priority over `registerCatchAll`. This enables recovery scenarios: register a catch-all that fails, then override specific routes mid-test for retry flows.

### Response Types

```swift
.json(data)                    // JSON response (200)
.image(data)                   // Image response (200)
.status(.notFound)             // Status code only (404)
.status(.internalServerError)  // Status code only (500)
```

---

## Scenario Patterns

Mock server configurations are extracted into reusable methods on `UITestCase` in `App/Tests/Shared/Scenarios/UITestCase+Scenarios.swift`.

### Initial Scenarios (before `launch()`)

Use `registerCatchAll` to configure all routes for the test:

| Method | Description |
|--------|-------------|
| `givenCharacterListSucceeds()` | Avatars + character list |
| `givenCharacterListAndDetailSucceeds()` | Avatars + list + detail |
| `givenCharacterListWithPaginationSucceeds()` | Avatars + list + page 2 |
| `givenCharacterListWithEmptySearchSucceeds()` | Avatars + list + empty search |
| `givenCharacterDetailSucceeds()` | Avatars + detail (no list) |
| `givenCharacterDetailFailsButListSucceeds()` | Avatars + list OK, detail 500 |
| `givenAllRequestsFail()` | All requests return 500 |
| `givenAllRequestsReturnNotFound()` | All requests return 404 |

### Recovery Scenarios (mid-test, after initial failure)

Use `register`/`registerPrefix` to override specific routes without replacing the catch-all:

| Method | Description |
|--------|-------------|
| `givenCharacterListRecovers()` | Registers avatar + list routes |
| `givenCharacterDetailRecovers()` | Registers detail route |

### Naming Convention

- **Prefix**: `given` (follows Given/When/Then pattern)
- **Success**: `given{Feature}Succeeds()` — happy path
- **Failure**: `given{Feature}Fails()` or `givenAllRequestsFail()` — error scenarios
- **Recovery**: `given{Feature}Recovers()` — mid-test overrides for retry flows
- **Signature**: `async throws` when using `XCTUnwrap(serverBaseURL)`, `async` when not needed

---

## Scenario Implementation

### Initial Scenario

```swift
// Uses registerCatchAll — handles all requests
func givenCharacterListSucceeds() async throws {
    let baseURL = try XCTUnwrap(serverBaseURL)
    let charactersData = Data.fixture("characters_response", baseURL: baseURL)
    let imageData = Data.stubAvatarImage

    await serverMock.registerCatchAll { request in
        if request.path.contains("/avatar/") {
            return .image(imageData)
        }
        if request.path.contains("/character") {
            return .json(charactersData)
        }
        return .status(.notFound)
    }
}
```

### Recovery Scenario

```swift
// Uses register/registerPrefix — overrides specific routes
func givenCharacterListRecovers() async throws {
    let baseURL = try XCTUnwrap(serverBaseURL)
    let charactersData = Data.fixture("characters_response", baseURL: baseURL)
    let imageData = Data.stubAvatarImage

    await serverMock.registerPrefix(.GET, "/avatar/") { _ in .image(imageData) }
    await serverMock.register(.GET, "/character") { _ in .json(charactersData) }
}
```

---

## UI Test Examples

### Navigation Flow

```swift
import XCTest

final class CharacterFlowUITests: UITestCase {
    @MainActor
    func testNavigationFromListToDetailAndBack() async throws {
        // Given
        try await givenCharacterListAndDetailSucceeds()

        // When
        launch()

        // Then
        home { robot in
            robot.tapCharacterButton()
        }

        characterList { robot in
            robot.verifyIsVisible()
            robot.tapCharacter(identifier: 1)
        }

        characterDetail { robot in
            robot.verifyIsVisible()
            robot.tapBack()
        }

        characterList { robot in
            robot.verifyIsVisible()
            robot.tapBack()
        }

        home { robot in
            robot.verifyIsVisible()
        }
    }
}
```

### Error and Retry Flow

```swift
@MainActor
func testListShowsErrorAndRetryLoadsContent() async throws {
    // Given
    await givenAllRequestsFail()

    // When
    launch()

    // Then
    home { robot in
        robot.tapCharacterButton()
    }

    characterList { robot in
        robot.verifyErrorIsVisible()
    }

    try await givenCharacterListRecovers()

    characterList { robot in
        robot.tapRetry()
        robot.verifyIsVisible()
        robot.verifyCharacterExists(identifier: 1)
    }
}
```

---

## Accessibility Identifiers in Views

Views must define **private accessibility identifiers** for UI testing. Pass the `accessibilityIdentifier:` parameter to DS components for automatic propagation.

### Pattern with DS Components

```swift
struct CharacterListView: View {
    @State private var viewModel: CharacterListViewModel

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.characters) { character in
                    DSCardInfoRow(
                        imageURL: character.imageURL,
                        title: character.name,
                        status: DSStatus.from(character.status.rawValue),
                        accessibilityIdentifier: AccessibilityIdentifier.row(id: character.id)
                    )
                    .onTapGesture {
                        viewModel.didSelect(character)
                    }
                }
            }
        }
        .accessibilityIdentifier(AccessibilityIdentifier.scrollView)
    }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let scrollView = "characterList.scrollView"
    static let loadMoreButton = "characterList.loadMoreButton"

    static func row(id: Int) -> String {
        "characterList.row.\(id)"
    }
}
```

### Propagated Identifiers

When using `accessibilityIdentifier: "characterList.row.1"`:
- Container: `characterList.row.1`
- `DSAsyncImage`: `characterList.row.1.image`
- Title text: `characterList.row.1.title`
- `DSStatusIndicator`: `characterList.row.1.status`
