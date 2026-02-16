# Robots

## UITestCase Base Class

```swift
import SwiftMockServer
import XCTest

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
        await attachNetworkLogIfFailed()

        await serverMock.stop()
        serverMock = nil
        serverBaseURL = nil
        app = nil
        try await super.tearDown()
    }

    /// Launches the app with the mock server configured.
    /// - Parameter deepLink: Optional deep link URL to navigate to on launch.
    @MainActor
    @discardableResult
    func launch(deepLink url: URL? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        var environment: [String: String] = ["API_BASE_URL": serverBaseURL]
        if let url {
            environment["DEEP_LINK_URL"] = url.absoluteString
        }
        app.launchEnvironment = environment
        app.launch()

        let isRunning = app.wait(for: .runningForeground, timeout: 10)
        XCTAssertTrue(isRunning, "App failed to reach foreground state")

        self.app = app
        return app
    }

    // MARK: - Robot DSL

    @MainActor func home(actions: (HomeRobot) -> Void) { actions(HomeRobot(app: app)) }
    @MainActor func about(actions: (AboutRobot) -> Void) { actions(AboutRobot(app: app)) }
    @MainActor func notFound(actions: (NotFoundRobot) -> Void) { actions(NotFoundRobot(app: app)) }
    @MainActor func characterList(actions: (CharacterListRobot) -> Void) { actions(CharacterListRobot(app: app)) }
    @MainActor func characterDetail(actions: (CharacterDetailRobot) -> Void) { actions(CharacterDetailRobot(app: app)) }
    @MainActor func characterFilter(actions: (CharacterFilterRobot) -> Void) { actions(CharacterFilterRobot(app: app)) }
    @MainActor func characterEpisodes(actions: (CharacterEpisodesRobot) -> Void) { actions(CharacterEpisodesRobot(app: app)) }
}
```

---

## Robot Structure

All robots follow the same structure: plain struct with `let app`, Actions extension, Verifications extension, and private AccessibilityIdentifier enum.

```swift
import XCTest

struct CharacterListRobot {
    let app: XCUIApplication
}

// MARK: - Actions

extension CharacterListRobot {
    @discardableResult
    func tapCharacter(identifier: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
        let accessibilityId = AccessibilityIdentifier.row(identifier: identifier)
        let row = app.descendants(matching: .any)[accessibilityId].firstMatch
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

extension CharacterListRobot {
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

    @discardableResult
    func verifyCharacterExists(identifier: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
        let accessibilityId = AccessibilityIdentifier.row(identifier: identifier)
        let row = app.descendants(matching: .any)[accessibilityId].firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10), file: file, line: line)
        return self
    }

    @discardableResult
    func verifyCharacterDoesNotExist(identifier: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
        let accessibilityId = AccessibilityIdentifier.row(identifier: identifier)
        let row = app.descendants(matching: .any)[accessibilityId].firstMatch
        XCTAssertFalse(row.waitForExistence(timeout: 2), file: file, line: line)
        return self
    }
}

// MARK: - AccessibilityIdentifiers

private enum AccessibilityIdentifier {
    static let scrollView = "characterList.scrollView"
    static let errorTitle = "characterList.errorView.title"
    static let retryButton = "characterList.errorView.button"

    static func row(identifier: Int) -> String {
        "characterList.row.\(identifier)"
    }
}
```

---

## Common Actions

```swift
// Tap a button
let button = app.buttons[identifier]
button.tap()

// Tap a descendant element by identifier
let element = app.descendants(matching: .any)[identifier].firstMatch
element.tap()

// Type text in a text field
let textField = app.textFields[identifier]
textField.tap()
textField.typeText("Hello")

// Pull to refresh on a scroll view
let scrollView = app.scrollViews[identifier]
let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
start.press(forDuration: 0.1, thenDragTo: end)

// Tap back button in navigation bar
let backButton = app.navigationBars.buttons.element(boundBy: 0)
backButton.tap()

// Wait for element
XCTAssertTrue(element.waitForExistence(timeout: 10))

// Verify element does NOT exist (short timeout)
XCTAssertFalse(element.waitForExistence(timeout: 2))

// Verify button is disabled
XCTAssertFalse(button.isEnabled)

// Search field — tap, type, clear, cancel
let searchField = app.searchFields.firstMatch
searchField.tap()
searchField.typeText("query")
searchField.buttons["Clear text"].tap()  // clear text (stays active)
app.buttons["close"].tap()               // cancel search (lowercase "close")

// Swipe to delete (e.g., recent search suggestions)
let suggestion = app.buttons[identifier].firstMatch
suggestion.swipeLeft()
app.buttons["Delete"].firstMatch.tap()

// Scroll to make element visible
var attempts = 0
while !row.isHittable && attempts < 10 {
    scrollView.swipeUp()
    attempts += 1
}
```

---

## Accessibility Identifiers in Views

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

When using `accessibilityIdentifier: "characterList.row.1"` on `DSCardInfoRow`:
- Container: `characterList.row.1`
- Image (via `DSAsyncImage` + SwiftUI modifier): `characterList.row.1.image`
- Title text: `characterList.row.1.title`
- `DSStatusIndicator`: `characterList.row.1.status`
