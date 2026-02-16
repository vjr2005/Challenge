---
name: ui-tests
description: UI tests with Robot pattern. Use when creating UI tests, implementing Robot classes, or adding accessibility identifiers.
---

# Skill: UI Tests

Guide for creating UI tests using XCTest with the Robot pattern.

## References

- **Robot implementations** (UITestCase, robot examples): See [references/robots.md](references/robots.md)
- **Scenarios & SwiftMockServer** (mock server, scenario patterns): See [references/scenarios.md](references/scenarios.md)

---

## File Structure

```
App/Tests/UI/
├── HomeUITests.swift                    # Home screen flow (launch from home)
├── CharacterListUITests.swift           # Character list (deep link)
├── CharacterDetailUITests.swift         # Character detail (deep link)
├── CharacterEpisodesUITests.swift       # Character episodes (deep link)
└── NotFoundUITests.swift                # Invalid deep link → not found screen

App/Tests/Shared/
├── Robots/
│   ├── Robot.swift                      # UITestCase base class
│   ├── HomeRobot.swift
│   ├── AboutRobot.swift
│   ├── NotFoundRobot.swift
│   ├── CharacterListRobot.swift
│   ├── CharacterDetailRobot.swift
│   ├── CharacterFilterRobot.swift
│   └── CharacterEpisodesRobot.swift
└── Scenarios/
    └── UITestCase+Scenarios.swift
```

---

## Robot Pattern Rules

| Rule | Description |
|------|-------------|
| Extend `UITestCase` | Inherits mock server setup, teardown, and robot DSL |
| `async throws` on test methods | Required for `await serverMock.registerCatchAll` |
| `@MainActor` on test methods | Required for UI interactions (XCUIApplication) |
| Actions section | Methods that perform UI interactions (tap, swipe, type) |
| Verifications section | Methods that assert UI state |
| `@discardableResult` | All robot methods return `Self` for chaining |
| `#filePath` and `line` | Pass through for accurate test failure locations |
| Private AccessibilityIdentifier | Each Robot has its own copy of identifiers |
| `.firstMatch` | Use when multiple elements may match an identifier |

---

## Test Patterns

### Flow Tests — navigate through the app from home

Use `launch()` and navigate through the app via robots. Best for multi-screen flows starting from home. One comprehensive test per flow.

```swift
final class HomeUITests: UITestCase {
    @MainActor
    func testHomeFlowAboutSheetCharacterListAndBack() async throws {
        // Given
        try await givenCharacterListSucceeds()

        // When
        launch()

        // Then
        home { robot in
            robot.verifyIsVisible()
            robot.tapInfoButton()
        }

        about { robot in
            robot.verifyIsVisible()
            robot.swipeUp()
            robot.verifyCreditsExist()
            robot.tapClose()
        }

        home { robot in
            robot.verifyIsVisible()
            robot.tapCharacterButton()
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

### Screen Tests — deep link directly to a screen

Use `launch(deepLink: url)` to navigate directly to a specific screen. Best for comprehensive single-screen tests covering error/retry, main interactions, and navigation. One test class per screen with a single comprehensive test method. Use `// swiftlint:disable:next function_body_length` for long test methods.

```swift
final class CharacterDetailUITests: UITestCase {
    @MainActor
    func testCharacterDetailErrorRetryRefreshEpisodesAndBack() async throws {
        // Given — all requests fail
        await givenAllRequestsFail()

        let url = try XCTUnwrap(URL(string: "challenge://character/detail/1"))

        // When — launch with deep link
        launch(deepLink: url)

        // Then — error screen
        characterDetail { robot in
            robot.verifyErrorIsVisible()
        }

        // Recovery — configure responses
        try await givenCharacterDetailSucceeds()

        // Retry — content loads
        characterDetail { robot in
            robot.tapRetry()
            robot.verifyIsVisible()
            robot.pullToRefresh()
            robot.verifyIsVisible()
        }

        // Navigate forward and back
        try await givenCharacterEpisodesRecovers()

        characterDetail { robot in
            robot.tapEpisodes()
        }

        characterEpisodes { robot in
            robot.verifyIsVisible()
            robot.tapBack()
        }

        characterDetail { robot in
            robot.verifyIsVisible()
        }
    }
}
```

### Runtime Deep Link Tests — `launch()` + `app.open(url)`

Use `launch()` then `app.open(url)` when testing deep links that the app handles at **runtime** (not at launch). This is required for invalid/unknown routes because `DEEP_LINK_URL` env var only resolves known routes at launch time.

```swift
final class NotFoundUITests: UITestCase {
    @MainActor
    func testNotFoundScreenAndGoBack() async throws {
        // Given — all requests return 404
        await givenAllRequestsReturnNotFound()

        launch()
        let url = try XCTUnwrap(URL(string: "challenge://invalid/route"))

        // Verify home is visible
        home { robot in
            robot.verifyIsVisible()
        }

        // When — open invalid deep link
        app.open(url)

        // Then — not found screen is visible
        notFound { robot in
            robot.verifyIsVisible()
            robot.tapGoBack()
        }

        // Verify home is visible after going back
        home { robot in
            robot.verifyIsVisible()
        }
    }
}
```

### Deep Link URLs

| Screen | URL |
|--------|-----|
| Character List | `challenge://character/list` |
| Character Detail | `challenge://character/detail/{id}` |
| Character Episodes | `challenge://episode/character/{id}` |

### Screen Test Flow Pattern

Each screen test follows the same structure:

1. **Error** — `givenAllRequestsFail()` + `launch(deepLink: url)` → verify error
2. **Recovery** — register success scenario mid-test (replaces catch-all)
3. **Retry** — tap retry → verify content loads
4. **Interactions** — pull-to-refresh, pagination, filters, etc.
5. **Navigation** — navigate to related screen → verify → tap back → verify return

---

## Accessibility Identifiers in Views

### Rules

- **Private to each View** — defined as a private enum at the bottom of the View file
- **Naming convention** — `{screenName}.{elementType}` (e.g., `home.characterButton`)
- **Dynamic identifiers** — use static functions for elements with IDs (e.g., `row(id:)`)
- **DS propagation** — pass `accessibilityIdentifier:` to DS components for child propagation

### Propagated Identifiers

When using `accessibilityIdentifier: "characterList.row.1"` on `DSCardInfoRow`:
- Container: `characterList.row.1`
- Image (via `DSAsyncImage` + SwiftUI modifier): `characterList.row.1.image`
- Title text: `characterList.row.1.title`
- `DSStatusIndicator`: `characterList.row.1.status`

---

## Build & Verify

Run a specific test class:

```bash
mise x -- tuist test ChallengeUITests -- -only-testing:ChallengeUITests/CharacterDetailUITests
```

Run all UI tests:

```bash
mise x -- tuist test --skip-unit-tests 2>&1 | tee /tmp/ui-tests.txt | tail -30
```

---

## Checklist

### Robot Implementation

- [ ] Create Robot struct with `let app: XCUIApplication`
- [ ] Add Actions extension with `@discardableResult` methods
- [ ] Add Verifications extension with `@discardableResult` methods
- [ ] Add private `AccessibilityIdentifier` enum
- [ ] Pass `#filePath` and `line` for accurate failure locations
- [ ] Use `.firstMatch` for dynamic elements
- [ ] Add robot DSL method in `Robot.swift` (e.g., `func myScreen(actions:)`)

### UI Test

- [ ] Extend `UITestCase` (provides `serverMock`, `serverBaseURL`, `launch()`)
- [ ] Mark test methods with `@MainActor` and `async throws`
- [ ] Use scenario methods from `UITestCase+Scenarios` (or create new ones)
- [ ] Follow `// Given` / `// When` / `// Then` structure
- [ ] Choose test pattern: `launch()` for flow tests, `launch(deepLink: url)` for screen tests
- [ ] Use Robot DSL methods (`home`, `characterList`, etc.)
- [ ] Chain robot actions fluently
- [ ] Verify navigation with `verifyIsVisible()`
- [ ] For retry flows: register recovery scenarios mid-test after verifying error state
- [ ] End screen tests with back navigation to verify return

### View Accessibility

- [ ] Add private `AccessibilityIdentifier` enum to View
- [ ] Use format `{screenName}.{elementType}` for identifiers
- [ ] Apply `.accessibilityIdentifier()` to standard SwiftUI elements
- [ ] Pass `accessibilityIdentifier:` parameter to DS components for propagation
- [ ] Use static functions for dynamic identifiers (e.g., `row(id:)`)
