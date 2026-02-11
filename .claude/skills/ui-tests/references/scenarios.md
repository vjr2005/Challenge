# Scenarios & SwiftMockServer

## SwiftMockServer

UI tests use [SwiftMockServer](https://github.com/vjr2005/SwiftMockServer) to intercept HTTP requests with a local mock server. `UITestCase` manages the server lifecycle automatically:

- **`setUp()`**: Creates a `MockServer` instance and stores `serverBaseURL`
- **`launch()`** / **`launch(deepLink:)`**: Passes `serverBaseURL` via `API_BASE_URL` environment variable (and optionally `DEEP_LINK_URL`), waits for the app to reach foreground state
- **`tearDown()`**: Stops the server, attaches network log on failure

### Route Registration

SwiftMockServer provides three registration methods:

| Method | Purpose |
|--------|---------|
| `registerCatchAll { request in }` | Handles all unmatched requests (initial and recovery scenarios) |
| `register(.GET, "/path") { request in }` | Exact path match (targeted overrides) |
| `registerPrefix(.GET, "/path/") { request in }` | Prefix path match (targeted overrides) |

Specific routes (`register`/`registerPrefix`) take priority over `registerCatchAll`. A new `registerCatchAll` replaces the previous one entirely.

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
| `givenCharacterListWithPaginationAndEmptySearchSucceeds()` | Avatars + list + page 2 + empty when `name` param present |
| `givenCharacterListWithEmptySearchSucceeds()` | Avatars + list + empty search |
| `givenCharacterDetailSucceeds()` | Avatars + detail (no list) |
| `givenCharacterListDetailAndEpisodesSucceeds()` | Avatars + list + detail + episodes (GraphQL) |
| `givenCharacterDetailFailsButListSucceeds()` | Avatars + list OK, detail 500 |
| `givenCharacterEpisodesFailsButListAndDetailSucceeds()` | Avatars + list + detail OK, GraphQL 500 |
| `givenAllRequestsFail()` | All requests return 500 |
| `givenAllRequestsReturnNotFound()` | All requests return 404 |

### Recovery Scenarios (mid-test, after initial failure)

Two approaches for recovery:

1. **Targeted overrides** — `register`/`registerPrefix` add routes that take priority over the existing catch-all:

| Method | Description |
|--------|-------------|
| `givenCharacterListRecovers()` | Registers avatar prefix + list exact route |
| `givenCharacterDetailRecovers()` | Registers detail prefix route |

2. **Catch-all replacement** — `registerCatchAll` replaces the previous catch-all entirely. Any initial scenario can be called mid-test as recovery:

| Method | Description |
|--------|-------------|
| `givenCharacterListWithPaginationSucceeds()` | Replaces catch-all with pagination support |
| `givenCharacterListWithPaginationAndEmptySearchSucceeds()` | Replaces catch-all with pagination + empty search |
| `givenCharacterDetailSucceeds()` | Replaces catch-all with detail + avatars |
| `givenCharacterEpisodesRecovers()` | Replaces catch-all with detail + avatars + episodes (GraphQL) |
| `givenCharacterEpisodesFails()` | Replaces catch-all with detail + avatars, GraphQL 500 |

### Naming Convention

- **Prefix**: `given` (follows Given/When/Then pattern)
- **Success**: `given{Feature}Succeeds()` — happy path
- **Failure**: `given{Feature}Fails()` or `givenAllRequestsFail()` — error scenarios
- **Recovery**: `given{Feature}Recovers()` — mid-test overrides for retry flows
- **Signature**: `async throws` when using `XCTUnwrap(serverBaseURL)`, `async` when not needed

---

## Scenario Implementation

### Initial Scenario (registerCatchAll)

```swift
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

### Recovery Scenario (targeted override)

```swift
func givenCharacterListRecovers() async throws {
    let baseURL = try XCTUnwrap(serverBaseURL)
    let charactersData = Data.fixture("characters_response", baseURL: baseURL)
    let imageData = Data.stubAvatarImage

    await serverMock.registerPrefix(.GET, "/avatar/") { _ in .image(imageData) }
    await serverMock.register(.GET, "/api/character") { _ in .json(charactersData) }
}
```

### Recovery Scenario (catch-all replacement)

```swift
func givenCharacterEpisodesRecovers() async throws {
    let baseURL = try XCTUnwrap(serverBaseURL)
    let characterData = Data.fixture("character", baseURL: baseURL)
    let episodesData = Data.fixture("episodes_by_character_response", baseURL: baseURL)
    let imageData = Data.stubAvatarImage

    await serverMock.registerCatchAll { request in
        if request.path.contains("/avatar/") {
            return .image(imageData)
        }
        if request.path.contains("/graphql") {
            return .json(episodesData)
        }
        if request.path.contains("/character/") {
            return .json(characterData)
        }
        return .status(.notFound)
    }
}
```

---

## UI Test Examples

### Flow Test — navigate from home

```swift
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
        }
    }
}
```

### Screen Test — deep link with error/retry flow

```swift
final class CharacterEpisodesUITests: UITestCase {
    @MainActor
    func testCharacterEpisodesErrorRetryRefreshCharacterDetailAndBack() async throws {
        // Given — all requests fail
        await givenAllRequestsFail()

        let url = try XCTUnwrap(URL(string: "challenge://episode/character/1"))

        // When — launch with deep link
        launch(deepLink: url)

        // Then — error screen
        characterEpisodes { robot in
            robot.verifyErrorIsVisible()
        }

        // Recovery
        try await givenCharacterEpisodesRecovers()

        // Retry — content loads
        characterEpisodes { robot in
            robot.tapRetry()
            robot.verifyIsVisible()
            robot.pullToRefresh()
            robot.verifyIsVisible()

            // Navigate to character detail
            robot.tapCharacter(identifier: 1)
        }

        characterDetail { robot in
            robot.verifyIsVisible()
            robot.tapBack()
        }

        characterEpisodes { robot in
            robot.verifyIsVisible()
        }
    }
}
```
