# Robots

## UITestCase Base Class

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

## CharacterListRobot

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

## HomeRobot

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

---

## CharacterDetailRobot

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
