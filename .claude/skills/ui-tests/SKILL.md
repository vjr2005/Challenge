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
├── CharacterFlowUITests.swift
└── DeepLinkUITests.swift

App/Tests/Shared/
├── Robots/
│   ├── Robot.swift                        # UITestCase base class + RobotContract
│   ├── HomeRobot.swift
│   ├── CharacterListRobot.swift
│   └── CharacterDetailRobot.swift
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
| `RobotContract` protocol | Base protocol with `app: XCUIApplication` |
| Actions section | Methods that perform UI interactions (tap, swipe, type) |
| Verifications section | Methods that assert UI state |
| `@discardableResult` | All robot methods return `Self` for chaining |
| `#filePath` and `line` | Pass through for accurate test failure locations |
| Private AccessibilityIdentifier | Each Robot has its own copy of identifiers |
| `.firstMatch` | Use when multiple elements may match an identifier |

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
        }
    }
}
```

---

## Accessibility Identifiers in Views

### Rules

- **Private to each View** — defined as a private enum at the bottom of the View file
- **Naming convention** — `{screenName}.{elementType}` (e.g., `home.characterButton`)
- **Dynamic identifiers** — use static functions for elements with IDs (e.g., `row(id:)`)
- **DS propagation** — pass `accessibilityIdentifier:` to DS components for child propagation

### Propagated Identifiers

When using `accessibilityIdentifier: "characterList.row.1"`:
- Container: `characterList.row.1`
- `DSAsyncImage`: `characterList.row.1.image`
- Title text: `characterList.row.1.title`
- `DSStatusIndicator`: `characterList.row.1.status`

---

## Build & Verify

After writing UI tests, run **only** the UI tests to verify compilation and execution:

```bash
mise x -- tuist test --skip-unit-tests 2>&1 | tee /tmp/ui-tests.txt | tail -30
```

Do **not** run the full test suite (`mise x -- tuist test`) — UI tests are independent and only need the UI test target.

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
