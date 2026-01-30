---
name: e2e-tests
description: End-to-end UI tests with Robot pattern. Use when creating E2E tests, implementing Robot classes, or adding accessibility identifiers.
---

# Skill: E2E Tests

Guide for creating End-to-End UI tests using XCTest with the Robot pattern.

## When to use this skill

- Create E2E tests for user flows
- Implement Robot classes for screens
- Add accessibility identifiers to views
- Test navigation and user interactions

---

## File Structure

```
App/Tests/E2E/
├── Robots/
│   ├── Robot.swift              # Base protocol and DSL
│   ├── HomeRobot.swift
│   ├── CharacterListRobot.swift
│   └── CharacterDetailRobot.swift
└── Tests/
    └── CharacterFlowE2ETests.swift
```

---

## Robot Protocol

```swift
import XCTest

/// Base protocol for all screen robots.
protocol RobotContract {
    var app: XCUIApplication { get }
}

/// Provides DSL for robot-based testing.
extension XCTestCase {
    func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    func home(app: XCUIApplication, actions: (HomeRobot) -> Void) {
        actions(HomeRobot(app: app))
    }

    func characterList(app: XCUIApplication, actions: (CharacterListRobot) -> Void) {
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

## E2E Test Structure

```swift
import XCTest

nonisolated final class CharacterFlowE2ETests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCharacterBrowsingFlow() throws {
        let app = launch()

        home(app: app) { robot in
            robot.tapCharacterButton()
        }

        characterList(app: app) { robot in
            robot.tapCharacter(id: 1)
        }

        characterDetail(app: app) { robot in
            robot.verifyIsVisible()
            robot.tapBack()
        }

        characterList(app: app) { robot in
            robot.verifyIsVisible()
            robot.tapBack()
        }

        home(app: app) { robot in
            robot.verifyIsVisible()
        }
    }
}
```

---

## Robot Pattern Rules

| Rule | Description |
|------|-------------|
| `nonisolated` on test class | Required to avoid actor isolation conflicts with XCTestCase |
| `@MainActor` on test methods | Add when tests interact with UI (XCUIApplication) |
| `RobotContract` protocol | Base protocol with `app: XCUIApplication` |
| Actions section | Methods that perform UI interactions (tap, swipe, type) |
| Verifications section | Methods that assert UI state |
| `@discardableResult` | All robot methods return `Self` for chaining |
| `#filePath` and `line` | Pass through for accurate test failure locations |
| Private AccessibilityIdentifier | Each Robot has its own copy of identifiers |
| `.firstMatch` | Use when multiple elements may match an identifier |

---

## Accessibility Identifiers in Views

Views must define **private accessibility identifiers** for E2E testing.

### Pattern

```swift
struct CharacterListView: View {
    @State private var viewModel: CharacterListViewModel

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.characters) { character in
                    CharacterRowView(character: character)
                        .accessibilityIdentifier(AccessibilityIdentifier.row(id: character.id))
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

### Rules

- **Private to each View** - Identifiers are defined as a private enum at the bottom of the View file
- **Naming convention** - Use format `{screenName}.{elementType}` (e.g., `home.characterButton`)
- **Dynamic identifiers** - Use static functions for elements with IDs (e.g., `row(id:)`)
- **Place before Previews** - The AccessibilityIdentifier enum goes after the View implementation

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

### E2E Test

- [ ] Mark test class as `nonisolated`
- [ ] Mark test methods with `@MainActor`
- [ ] Set `continueAfterFailure = false` in setup
- [ ] Use Robot DSL methods from XCTestCase extension
- [ ] Chain robot actions fluently
- [ ] Verify navigation with `verifyIsVisible()`

### View Accessibility

- [ ] Add private `AccessibilityIdentifier` enum to View
- [ ] Use format `{screenName}.{elementType}` for identifiers
- [ ] Apply `.accessibilityIdentifier()` to interactive elements
- [ ] Use static functions for dynamic identifiers (e.g., `row(id:)`)
