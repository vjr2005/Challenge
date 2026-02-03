---
name: ui-tests
description: UI tests with Robot pattern. Use when creating UI tests, implementing Robot classes, or adding accessibility identifiers.
---

# Skill: UI Tests

Guide for creating UI tests using XCTest with the Robot pattern.

## When to use this skill

- Create UI tests for user flows
- Implement Robot classes for screens
- Add accessibility identifiers to views
- Test navigation and user interactions

---

## File Structure

```
App/Tests/UI/
├── CharacterFlowUITests.swift   # Character flow tests
└── DeepLinkUITests.swift        # Deep link tests

App/Tests/Shared/
├── Robots/
│   ├── Robot.swift                        # UITestCase base class + RobotContract
│   ├── HomeRobot.swift
│   ├── CharacterListRobot.swift
│   ├── CharacterDetailRobot.swift
│   └── NotFoundRobot.swift
└── Scenarios/
    └── UITestCase+Scenarios.swift         # Reusable mock server configurations
```

---

## Robot Protocol

```swift
import SwiftMockServer
import XCTest

/// Base protocol for all screen robots.
protocol RobotContract {
    var app: XCUIApplication { get }
}

/// Base class for UI tests with mock server support.
nonisolated class UITestCase: XCTestCase {
    private(set) var serverMock: MockServer!
    private(set) var serverBaseURL: String!
    private(set) var app: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        executionTimeAllowance = 60

        serverMock = try await MockServer.create()
        serverBaseURL = await serverMock.baseURL
    }

    override func tearDown() async throws {
        await serverMock.stop()
        serverMock = nil
        serverBaseURL = nil
        app = nil
        try await super.tearDown()
    }

    @MainActor
    @discardableResult
    func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["API_BASE_URL": serverBaseURL]
        app.launch()

        let isRunning = app.wait(for: .runningForeground, timeout: 10)
        XCTAssertTrue(isRunning, "App failed to reach foreground state")

        self.app = app
        return app
    }

    @MainActor
    func home(actions: (HomeRobot) -> Void) {
        actions(HomeRobot(app: app))
    }

    @MainActor
    func characterList(actions: (CharacterListRobot) -> Void) {
        actions(CharacterListRobot(app: app))
    }
}
```

---

## Robot Implementation

Each Robot has its own copy of accessibility identifiers (black-box testing principle):

```swift
import XCTest

struct CharacterListRobot: RobotContract {
    let app: XCUIApplication
}

// MARK: - Actions

extension CharacterListRobot {
    @discardableResult
    func tapCharacter(id: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
        let identifier = AccessibilityIdentifier.row(id: id)
        let row = app.descendants(matching: .any)[identifier].firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10), file: file, line: line)
        row.tap()
        return self
    }

    @discardableResult
    func tapBack(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), file: file, line: line)
        backButton.tap()
        return self
    }
}

// MARK: - Verifications

extension CharacterListRobot {
    @discardableResult
    func verifyIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let scrollView = app.scrollViews[AccessibilityIdentifier.scrollView]
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), file: file, line: line)
        return self
    }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let scrollView = "characterList.scrollView"

    static func row(id: Int) -> String {
        "characterList.row.\(id)"
    }
}
```

---

## SwiftMockServer

UI tests use [SwiftMockServer](https://github.com/nicklama/SwiftMockServer) to intercept HTTP requests with a local mock server. `UITestCase` manages the server lifecycle automatically:

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

## Scenarios

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

### Scenario Implementation Pattern

```swift
// Initial scenario — uses registerCatchAll
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

// Recovery scenario — uses register/registerPrefix to override specific routes
func givenCharacterListRecovers() async throws {
    let baseURL = try XCTUnwrap(serverBaseURL)
    let charactersData = Data.fixture("characters_response", baseURL: baseURL)
    let imageData = Data.stubAvatarImage

    await serverMock.registerPrefix(.GET, "/avatar/") { _ in .image(imageData) }
    await serverMock.register(.GET, "/character") { _ in .json(charactersData) }
}
```

### Naming Convention

- **Prefix**: `given` (follows Given/When/Then pattern)
- **Success**: `given{Feature}Succeeds()` — happy path
- **Failure**: `given{Feature}Fails()` or `givenAllRequestsFail()` — error scenarios
- **Recovery**: `given{Feature}Recovers()` — mid-test overrides for retry flows
- **Signature**: `async throws` when using `XCTUnwrap(serverBaseURL)`, `async` when not needed

---

## UI Test Structure

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

## Robot Pattern Rules

| Rule | Description |
|------|-------------|
| Extend `UITestCase` | Inherits mock server setup, teardown, and robot DSL |
| `async throws` on test methods | Required for `await serverMock.registerCatchAll` |
| `@MainActor` on test methods | Required for UI interactions (XCUIApplication) |
| `RobotContract` protocol | Base protocol with `app: XCUIApplication` |
| Actions section | Methods that perform UI interactions (tap, swipe, type) |
| Verifications section | Methods that assert UI state |
| `@discardableResult` | All robot methods return `Self` for chaining |
| `#filePath` and `line` | Pass through for accurate test failure locations |
| Private AccessibilityIdentifier | Each Robot has its own copy of identifiers |
| `.firstMatch` | Use when multiple elements may match an identifier |

---

## Accessibility Identifiers in Views

Views must define **private accessibility identifiers** for UI testing. Pass the `accessibilityIdentifier:` parameter to DS components for automatic propagation.

### Pattern with DS Components

When using DS components (like `DSCardInfoRow`), pass the identifier as a constructor parameter and it propagates automatically to child DS atoms:

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

### Rules

- **Private to each View** - Identifiers are defined as a private enum at the bottom of the View file
- **Naming convention** - Use format `{screenName}.{elementType}` (e.g., `home.characterButton`)
- **Dynamic identifiers** - Use static functions for elements with IDs (e.g., `row(id:)`)
- **Place before Previews** - The AccessibilityIdentifier enum goes after the View implementation
- **DS propagation** - Pass `accessibilityIdentifier:` parameter to DS components for child propagation

---

## Robot Examples

### HomeRobot

```swift
import XCTest

struct HomeRobot: RobotContract {
    let app: XCUIApplication
}

// MARK: - Actions

extension HomeRobot {
    @discardableResult
    func tapCharacterButton(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let button = app.buttons[AccessibilityIdentifier.characterButton]
        XCTAssertTrue(button.waitForExistence(timeout: 5), file: file, line: line)
        button.tap()
        return self
    }
}

// MARK: - Verifications

extension HomeRobot {
    @discardableResult
    func verifyIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let view = app.otherElements[AccessibilityIdentifier.view]
        XCTAssertTrue(view.waitForExistence(timeout: 5), file: file, line: line)
        return self
    }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let view = "home.view"
    static let characterButton = "home.characterButton"
}
```

### CharacterDetailRobot

```swift
import XCTest

struct CharacterDetailRobot: RobotContract {
    let app: XCUIApplication
}

// MARK: - Actions

extension CharacterDetailRobot {
    @discardableResult
    func tapBack(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), file: file, line: line)
        backButton.tap()
        return self
    }
}

// MARK: - Verifications

extension CharacterDetailRobot {
    @discardableResult
    func verifyIsVisible(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let view = app.scrollViews[AccessibilityIdentifier.scrollView]
        XCTAssertTrue(view.waitForExistence(timeout: 5), file: file, line: line)
        return self
    }

    @discardableResult
    func verifyCharacterName(
        _ name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Self {
        let label = app.staticTexts[name]
        XCTAssertTrue(label.waitForExistence(timeout: 5), file: file, line: line)
        return self
    }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let scrollView = "characterDetail.scrollView"
    static let nameLabel = "characterDetail.nameLabel"
    static let statusLabel = "characterDetail.statusLabel"
}
```

---

## Common Actions

```swift
// Tap a button
let button = app.buttons[identifier]
button.tap()

// Tap a cell/row
let cell = app.cells[identifier]
cell.tap()

// Type text
let textField = app.textFields[identifier]
textField.tap()
textField.typeText("Hello")

// Swipe
app.swipeUp()
app.swipeDown()

// Pull to refresh
let firstCell = app.cells.element(boundBy: 0)
let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
let end = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 5))
start.press(forDuration: 0, thenDragTo: end)

// Wait for element
XCTAssertTrue(element.waitForExistence(timeout: 10))
```

---

## Checklist

### Robot Implementation

- [ ] Create Robot struct conforming to `RobotContract`
- [ ] Add Actions extension with `@discardableResult` methods
- [ ] Add Verifications extension with `@discardableResult` methods
- [ ] Add private `AccessibilityIdentifier` enum
- [ ] Pass `#filePath` and `line` for accurate failure locations
- [ ] Use `.firstMatch` for dynamic elements

### UI Test

- [ ] Extend `UITestCase` (provides `serverMock`, `serverBaseURL`, `launch()`)
- [ ] Mark test methods with `@MainActor` and `async throws`
- [ ] Use scenario methods from `UITestCase+Scenarios` (or create new ones)
- [ ] Follow `// Given` / `// When` / `// Then` structure
- [ ] Call `launch()` after scenario setup (synchronous, no `await`)
- [ ] Use Robot DSL methods (`home`, `characterList`, etc.)
- [ ] Chain robot actions fluently
- [ ] Verify navigation with `verifyIsVisible()`
- [ ] For retry flows: use recovery scenarios mid-test after verifying error state

### View Accessibility

- [ ] Add private `AccessibilityIdentifier` enum to View
- [ ] Use format `{screenName}.{elementType}` for identifiers
- [ ] Apply `.accessibilityIdentifier()` to standard SwiftUI elements
- [ ] Pass `accessibilityIdentifier:` parameter to DS components for propagation
- [ ] Use static functions for dynamic identifiers (e.g., `row(id:)`)
