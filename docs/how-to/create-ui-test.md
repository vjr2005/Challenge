# How To: Create UI Test

Create end-to-end UI tests using XCTest with the Robot pattern and SwiftMockServer.

## Scope & Boundaries

This guide covers UI test classes, Robot structs, mock server scenarios, and accessibility identifiers for UI testing.

| Need | Delegate to |
|------|-------------|
| View implementation | [Create View](create-view.md) |
| Snapshot tests | Snapshot skill |
| Unit tests | [Testing documentation](../Testing.md) |

## Prerequisites

- View exists with accessibility identifiers (see [Create View](create-view.md))
- Screen supports deep linking (see [Deep Linking documentation](../DeepLinking.md))

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    UI Test Class                         │
│  extends UITestCase (mock server, launch, robot DSL)    │
│                                                         │
│  1. Configure scenarios (mock server responses)         │
│  2. Launch app (normal or deep link)                    │
│  3. Interact via Robots                                 │
└─────────────────────┬───────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
┌──────────────┐ ┌──────────┐ ┌──────────────┐
│    Robot     │ │  Robot   │ │    Robot     │
│  (Screen A)  │ │(Screen B)│ │  (Screen C)  │
│  Actions +   │ │          │ │              │
│ Verifications│ │          │ │              │
└──────────────┘ └──────────┘ └──────────────┘
```

Each Robot encapsulates all UI interactions and verifications for a single screen. Tests compose Robots to describe user flows.

## Test Types

| Type | Launch method | When to use |
|------|--------------|-------------|
| **Screen test** | `launch(deepLink: url)` | Test a specific screen end-to-end (error, retry, interactions, navigation) |
| **Flow test** | `launch()` | Test navigation from home through multiple screens |
| **Runtime deep link** | `launch()` + `app.open(url)` | Test deep links handled at runtime (e.g., invalid routes) |

## File Structure

```
App/Tests/
├── UI/                                   # One test class per screen
│   ├── HomeUITests.swift
│   ├── CharacterListUITests.swift
│   ├── CharacterDetailUITests.swift
│   ├── CharacterEpisodesUITests.swift
│   └── NotFoundUITests.swift
│
└── Shared/
    ├── Robots/                           # One Robot per screen + base class
    │   ├── Robot.swift                   # UITestCase base class
    │   ├── HomeRobot.swift
    │   ├── AboutRobot.swift
    │   ├── CharacterListRobot.swift
    │   ├── CharacterDetailRobot.swift
    │   ├── CharacterFilterRobot.swift
    │   ├── CharacterEpisodesRobot.swift
    │   └── NotFoundRobot.swift
    ├── Scenarios/
    │   └── UITestCase+Scenarios.swift    # Mock server configurations
    ├── Fixtures/                          # JSON response files
    ├── Stubs/
    │   └── Data+Stub.swift               # Avatar image + fixture loader
    ├── Extensions/
    │   └── Bundle+Module.swift
    └── Resources/
        └── test-avatar.jpg
```

---

## Workflow

### Step 1 — Add Accessibility Identifiers to the View

Every interactive or verifiable element needs an accessibility identifier. Add a private `AccessibilityIdentifier` enum at the bottom of the View file:

```swift
// In SettingsView.swift

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel

    var body: some View {
        ScrollView {
            Text(viewModel.username)
                .accessibilityIdentifier(AccessibilityIdentifier.username)

            Button("Log out") {
                viewModel.didTapLogout()
            }
            .accessibilityIdentifier(AccessibilityIdentifier.logoutButton)
        }
        .accessibilityIdentifier(AccessibilityIdentifier.scrollView)
    }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let scrollView = "settings.scrollView"
    static let username = "settings.username"
    static let logoutButton = "settings.logoutButton"
}
```

**Naming rules:**
- Format: `{screenName}.{elementName}` (e.g., `settings.logoutButton`)
- Dynamic IDs use functions: `static func row(id: Int) -> String { "settings.row.\(id)" }`
- DS components: pass `accessibilityIdentifier:` parameter — children get `.image`, `.title`, `.status` suffixes
- Error views: use `{screenName}.errorView` prefix — DSErrorView generates `.title` and `.button`

---

### Step 2 — Create the Robot

Create `App/Tests/Shared/Robots/SettingsRobot.swift`:

```swift
import XCTest

struct SettingsRobot {
    let app: XCUIApplication
}

// MARK: - Actions

extension SettingsRobot {
    @discardableResult
    func tapLogout(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let button = app.buttons[AccessibilityIdentifier.logoutButton]
        XCTAssertTrue(button.waitForExistence(timeout: 5), file: file, line: line)
        button.tap()
        return self
    }

    @discardableResult
    func tapBack(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), file: file, line: line)
        backButton.tap()
        return self
    }

    @discardableResult
    func tapRetry(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let retryButton = app.buttons[AccessibilityIdentifier.retryButton]
        XCTAssertTrue(retryButton.waitForExistence(timeout: 5), file: file, line: line)
        retryButton.tap()
        return self
    }

    @discardableResult
    func pullToRefresh(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let scrollView = app.scrollViews[AccessibilityIdentifier.scrollView]
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), file: file, line: line)
        let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
        let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        start.press(forDuration: 0.1, thenDragTo: end)
        return self
    }
}

// MARK: - Verifications

extension SettingsRobot {
    @discardableResult
    func verifyIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let scrollView = app.scrollViews[AccessibilityIdentifier.scrollView]
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), file: file, line: line)
        return self
    }

    @discardableResult
    func verifyErrorIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let errorTitle = app.descendants(matching: .any)[AccessibilityIdentifier.errorTitle]
        XCTAssertTrue(errorTitle.waitForExistence(timeout: 5), file: file, line: line)
        return self
    }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let scrollView = "settings.scrollView"
    static let logoutButton = "settings.logoutButton"
    static let errorTitle = "settings.errorView.title"
    static let retryButton = "settings.errorView.button"
}
```

**Robot rules:**
- Plain struct with `let app: XCUIApplication`
- Actions and Verifications in separate extensions
- All methods return `Self` with `@discardableResult` (enables chaining)
- All methods accept `file: StaticString = #filePath, line: UInt = #line` for accurate failure locations
- Always `waitForExistence(timeout:)` before interacting with an element
- Use `.firstMatch` when multiple elements may share an identifier
- Identifiers are **duplicated** in the Robot (black-box principle — no imports from the app)

---

### Step 3 — Register Robot in UITestCase

Add a factory method in `App/Tests/Shared/Robots/Robot.swift`:

```swift
@MainActor
func settings(actions: (SettingsRobot) -> Void) {
    actions(SettingsRobot(app: app))
}
```

This enables the DSL syntax: `settings { robot in robot.verifyIsVisible() }`.

---

### Step 4 — Create JSON Fixtures

Add JSON files in `App/Tests/Shared/Fixtures/`. Use `{{BASE_URL}}` as placeholder for dynamic URLs:

```json
{
    "username": "Rick Sanchez",
    "avatar": "{{BASE_URL}}/avatar/1.jpeg"
}
```

Loaded in scenarios via:

```swift
let data = Data.fixture("settings_response", baseURL: baseURL)
```

The `Data.fixture(_:baseURL:)` helper replaces `{{BASE_URL}}` with the mock server URL at runtime.

---

### Step 5 — Create Scenarios

Add scenario methods in `App/Tests/Shared/Scenarios/UITestCase+Scenarios.swift`.

#### Initial scenarios (before `launch()`)

Use `registerCatchAll` to configure all routes:

```swift
func givenSettingsSucceeds() async throws {
    let baseURL = try XCTUnwrap(serverBaseURL)
    let settingsData = Data.fixture("settings_response", baseURL: baseURL)
    let imageData = Data.stubAvatarImage

    await serverMock.registerCatchAll { request in
        if request.path.contains("/avatar/") {
            return .image(imageData)
        }
        if request.path.contains("/settings") {
            return .json(settingsData)
        }
        return .status(.notFound)
    }
}
```

#### Recovery scenarios (mid-test, after initial failure)

Two options for configuring responses mid-test:

**Option A — Targeted override** (adds specific routes that take priority over catch-all):

```swift
func givenSettingsRecovers() async throws {
    let baseURL = try XCTUnwrap(serverBaseURL)
    let settingsData = Data.fixture("settings_response", baseURL: baseURL)
    let imageData = Data.stubAvatarImage

    await serverMock.registerPrefix(.GET, "/avatar/") { _ in .image(imageData) }
    await serverMock.register(.GET, "/api/settings") { _ in .json(settingsData) }
}
```

**Option B — Catch-all replacement** (replaces entire catch-all):

```swift
func givenSettingsRecovers() async throws {
    let baseURL = try XCTUnwrap(serverBaseURL)
    let settingsData = Data.fixture("settings_response", baseURL: baseURL)

    await serverMock.registerCatchAll { request in
        if request.path.contains("/settings") {
            return .json(settingsData)
        }
        return .status(.notFound)
    }
}
```

**Naming conventions:**

| Pattern | Purpose | Example |
|---------|---------|---------|
| `given{Feature}Succeeds()` | Happy path (before launch) | `givenSettingsSucceeds()` |
| `given{Feature}Recovers()` | Mid-test recovery (after error) | `givenSettingsRecovers()` |
| `given{Feature}Fails()` | Error scenario | `givenSettingsFails()` |
| `givenAllRequestsFail()` | All routes return 500 | Already exists |
| `givenAllRequestsReturnNotFound()` | All routes return 404 | Already exists |

**Response types:**

```swift
.json(data)                    // JSON response (200)
.image(data)                   // Image response (200)
.status(.notFound)             // 404
.status(.internalServerError)  // 500
```

---

### Step 6 — Write the Test

Create `App/Tests/UI/SettingsUITests.swift`. One class per screen, one comprehensive test method.

#### Screen Test (most common)

Tests a screen end-to-end via deep link: error → retry → interactions → forward navigation → back.

```swift
import XCTest

/// UI tests for the settings screen.
final class SettingsUITests: UITestCase {
    @MainActor
    func testSettingsErrorRetryRefreshAndBack() async throws {
        // Given — all requests fail
        await givenAllRequestsFail()

        let url = try XCTUnwrap(URL(string: "challenge://settings"))

        // When — launch with deep link
        launch(deepLink: url)

        // Then — error screen
        settings { robot in
            robot.verifyErrorIsVisible()
        }

        // Recovery — configure responses
        try await givenSettingsRecovers()

        // Retry — content loads
        settings { robot in
            robot.tapRetry()
            robot.verifyIsVisible()

            // Pull to refresh
            robot.pullToRefresh()
            robot.verifyIsVisible()

            // Logout
            robot.tapLogout()
        }

        // Verify navigated back to home
        home { robot in
            robot.verifyIsVisible()
        }
    }
}
```

**Screen Test Flow Pattern** — each screen test follows:

1. **Error** — `givenAllRequestsFail()` + `launch(deepLink: url)` → verify error
2. **Recovery** — register success scenario mid-test
3. **Retry** — tap retry → verify content loads
4. **Interactions** — pull-to-refresh, pagination, filters, etc.
5. **Navigation** — navigate to related screen → verify → tap back → verify return

#### Flow Test (navigate from home)

Tests multi-screen navigation starting from the home screen.

```swift
import XCTest

/// UI tests for the home screen flow.
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

#### Runtime Deep Link Test

For deep links processed at runtime (not at launch). Required for invalid/unknown routes.

```swift
import XCTest

/// UI tests for the Not Found screen shown on invalid deep links.
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

**Test rules:**
- `@MainActor` + `async throws` on test methods
- `// swiftlint:disable:next function_body_length` for long test methods
- `// Given` / `// When` / `// Then` comments
- End screen tests with back navigation to verify return

---

### Step 7 — Run & Verify

Run a specific test class:

```bash
mise x -- tuist test ChallengeUITests -- -only-testing:ChallengeUITests/SettingsUITests
```

Run all UI tests:

```bash
mise x -- tuist test --skip-unit-tests 2>&1 | tee /tmp/ui-tests.txt | tail -30
```

Verify results:

```bash
grep -E "Suite .*(passed|failed)" /tmp/ui-tests.txt
```

---

## Common Robot Actions Reference

```swift
// Tap a button by accessibility identifier
let button = app.buttons[identifier]
button.tap()

// Tap a descendant element
let element = app.descendants(matching: .any)[identifier].firstMatch
element.tap()

// Type text in a text field
let textField = app.textFields[identifier]
textField.tap()
textField.typeText("Hello")

// Search field interactions
let searchField = app.searchFields.firstMatch
searchField.tap()
searchField.typeText("query")
searchField.buttons["Clear text"].tap()  // clear (stays active)
app.buttons["close"].tap()               // cancel search (lowercase)

// Pull to refresh
let scrollView = app.scrollViews[identifier]
let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
start.press(forDuration: 0.1, thenDragTo: end)

// Tap back button in navigation bar
let backButton = app.navigationBars.buttons.element(boundBy: 0)
backButton.tap()

// Swipe to delete
suggestion.swipeLeft()
app.buttons["Delete"].firstMatch.tap()

// Wait for element
XCTAssertTrue(element.waitForExistence(timeout: 5))

// Verify element does NOT exist (short timeout)
XCTAssertFalse(element.waitForExistence(timeout: 2))

// Verify button is disabled
XCTAssertFalse(button.isEnabled)

// Scroll until element is hittable
var attempts = 0
while !row.isHittable && attempts < 10 {
    scrollView.swipeUp()
    attempts += 1
}
```

---

## Deep Link URLs

| Screen | URL |
|--------|-----|
| Character List | `challenge://character/list` |
| Character Detail | `challenge://character/detail/{id}` |
| Character Episodes | `challenge://episode/character/{id}` |

---

## Checklist

### View (accessibility)
- [ ] Private `AccessibilityIdentifier` enum in View file
- [ ] Format `{screenName}.{elementType}`
- [ ] `.accessibilityIdentifier()` on SwiftUI elements
- [ ] `accessibilityIdentifier:` parameter on DS components
- [ ] Static functions for dynamic IDs

### Robot
- [ ] Struct with `let app: XCUIApplication`
- [ ] Actions extension with `@discardableResult` methods
- [ ] Verifications extension with `@discardableResult` methods
- [ ] Private `AccessibilityIdentifier` enum (duplicated from View)
- [ ] `file: StaticString = #filePath, line: UInt = #line` on all methods
- [ ] `waitForExistence(timeout:)` before interactions
- [ ] `.firstMatch` for dynamic elements
- [ ] Robot DSL method registered in `Robot.swift`

### Scenarios
- [ ] Initial scenario for happy path (`given{Feature}Succeeds`)
- [ ] Recovery scenario for retry flow (`given{Feature}Recovers`)
- [ ] JSON fixtures in `App/Tests/Shared/Fixtures/` (if needed)

### Test
- [ ] Extends `UITestCase`
- [ ] `@MainActor` + `async throws` on test methods
- [ ] `// Given` / `// When` / `// Then` structure
- [ ] Screen tests: error → recovery → retry → interactions → navigation → back
- [ ] Flow tests: launch → navigate multiple screens → verify
- [ ] All tests pass locally

---

## See also

- [Create View](create-view.md) — View implementation with accessibility identifiers
- [Create Navigator](create-navigator.md) — Deep link handling
- [Testing](../Testing.md) — Testing overview and parallelization
