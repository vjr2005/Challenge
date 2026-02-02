# Style Guide

Code style and formatting rules for this project. Based on the [Airbnb Swift Style Guide](https://github.com/airbnb/swift).

## Formatting

| Rule | Value |
|------|-------|
| Maximum line width | 140 characters |
| Trailing commas | Not used |
| Blank lines | Single blank line between declarations |
| End of file | Single newline at end |

## Spacing

```swift
// Colons: space after, not before
let name: String
func method(param: Int) -> String
let dict: [String: Int]

// Operators: space on both sides
let sum = a + b
let range = 0..<10

// Braces: space before opening, space inside for single-line
func method() { }
array.map { $0 * 2 }

// Parentheses: no space inside
func method(param: Int)
if condition {
```

## Imports

```swift
// Alphabetized, @testable after blank line
import Foundation
import SwiftUI
import UIKit

@testable import UserFeature
```

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Types, Protocols | PascalCase | `UserRepository`, `SpaceThing` |
| Variables, Functions | lowerCamelCase | `userName`, `fetchData()` |
| Booleans | is/has/can prefix | `isEnabled`, `hasLoaded`, `canSubmit` |
| **Protocols** | **`Contract` suffix** | `UserRepositoryContract` |
| **Mocks** | **`Mock` suffix only** | `UserRepositoryMock` |

### Mock Naming Rules

`Mock` must **only** be used as a suffix, **never as a prefix**:

```swift
// RIGHT - Mock as suffix for types
class UserRepositoryMock { }
class HTTPClientMock { }

// WRONG - Mock as prefix (PROHIBITED)
class MockUserRepository { }
enum MockError { }
struct MockData { }
```

### Mock Variable Naming

Variables holding mock instances must also use the `Mock` suffix:

```swift
// RIGHT - Variable with Mock suffix
let httpClientMock = HTTPClientMock()
let repositoryMock = UserRepositoryMock()
var dataSourceMock: CharacterDataSourceMock

// WRONG - Variable without Mock suffix or with mock prefix
let httpClient = HTTPClientMock()
let mockRepository = UserRepositoryMock()
var dataSource: CharacterDataSourceMock
```

### Identifier vs ID

Prefer `identifier` over `id` for variable and parameter names:

```swift
// RIGHT - Use 'identifier'
func getCharacter(identifier: Int) -> Character
case detail(identifier: Int)
let characterIdentifier = character.id

// WRONG - Avoid 'id' as variable/parameter name
func getCharacter(id: Int) -> Character
case detail(id: Int)
let characterId = character.id
```

> **Note:** Model properties from APIs may use `id` (e.g., `character.id`), but local variables and parameters should use `identifier`.

## Domain Model Types

Prefer **enums** over strings for values with a known finite set of options:

```swift
// RIGHT - Enum for finite set of values
enum CharacterGender: Sendable {
    case male
    case female
    case genderless
    case unknown

    init(from string: String) {
        switch string.lowercased() {
        case "male": self = .male
        case "female": self = .female
        case "genderless": self = .genderless
        default: self = .unknown
        }
    }
}

struct Character {
    let gender: CharacterGender  // Type-safe
}

// WRONG - String for finite set
struct Character {
    let gender: String  // No type safety
}
```

**Rules:**
- Use enums for status, type, category, and similar fields
- Add `init(from string:)` to parse API string values
- Include `.unknown` case for unexpected values
- Conform to `Sendable` for concurrency safety

## Access Modifiers

```swift
// WRONG - Explicit internal (redundant)
internal struct Character { }
internal func loadData() { }

// RIGHT - Implicit internal
struct Character { }
func loadData() { }

// RIGHT - Only explicit when necessary
public struct PublicAPI { }
private func helperMethod() { }
```

> **Rule:** Never use explicit `internal` - it's the default and adds noise. Only use access modifiers when the visibility differs from internal (`public`, `private`, `fileprivate`, `open`).

## Type Inference

```swift
// WRONG - Redundant type
let name: String = "John"
let count: Int = 0

// RIGHT - Inferred type
let name = "John"
let count = 0
```

## Self Usage

```swift
// WRONG - Using type name in static references
static func == (lhs: MyType, rhs: MyType) -> Bool

// RIGHT - Use Self
static func == (lhs: Self, rhs: Self) -> Bool
```

```swift
// WRONG - Unnecessary self
self.name = "John"
self.save()

// RIGHT - Omit self unless required
name = "John"
save()
```

## Pattern Matching

```swift
// WRONG - let/var inside each tuple element
case (.loaded(let lhsData), .loaded(let rhsData)):

// RIGHT - let/var outside the tuple
case let (.loaded(lhsData), .loaded(rhsData)):
```

## Implicit Returns

```swift
// WRONG - Explicit return in single expression
var body: some View {
    return Text("Hello")
}

// RIGHT - Implicit return
var body: some View {
    Text("Hello")
}
```

## Conditional Returns

Return statements in conditionals (`guard`, `if`) must be on a new line:

```swift
// WRONG - Return on same line
guard let url else { return nil }
guard let data else { return }
if condition { return }

// RIGHT - Return on new line
guard let url else {
    return nil
}

guard let data else {
    return
}

if condition {
    return
}
```

## Force Unwrap

**Never use force unwrap (`!`).** Always handle optionals safely:

```swift
// WRONG - Force unwrap
let url = URL(string: urlString)!
let user = users.first!
let value = dictionary["key"]!

// RIGHT - guard let
guard let url = URL(string: urlString) else {
    throw ConfigurationError.invalidURL
}

// RIGHT - if let
if let user = users.first {
    process(user)
}

// RIGHT - nil coalescing
let value = dictionary["key"] ?? defaultValue

// RIGHT - Optional chaining
let name = user?.profile?.name
```

**In tests**, use `#require` for safe unwrapping:

```swift
// RIGHT - #require in tests (fails test if nil)
let baseURL = try #require(URL(string: "https://api.example.com"))
let data = try #require(response.data)
let user = try #require(users.first)

// RIGHT - Optional comparison (no unwrap needed)
#expect(request.url?.absoluteString == "https://api.example.com/users")
```

## Avoiding Warnings

### Unused Variables

```swift
// WRONG - Unused variable
let client = HTTPClient(baseURL: url)
// client never used → warning

// RIGHT - Use the variable or don't declare it
let client = HTTPClient(baseURL: url)
let result = try await client.request(endpoint)

// RIGHT - If intentionally unused, use underscore
let _ = HTTPClient(baseURL: url)
```

### Unused Parameters

```swift
// WRONG - Unused parameter
func process(data: Data, options: Options) {
    print(data)
    // options never used → warning
}

// RIGHT - Use underscore for intentionally unused
func process(data: Data, options _: Options) {
    print(data)
}
```

### Unused Imports

```swift
// WRONG - Unused import
import UIKit  // Not used in this file

// RIGHT - Only import what you use
import Foundation
```

### Unused Results

```swift
// WRONG - Result of call unused
array.map { $0 * 2 }  // warning: result unused

// RIGHT - Assign or use @discardableResult
let doubled = array.map { $0 * 2 }

// RIGHT - Explicitly discard if intentional
_ = array.map { $0 * 2 }
```

## Protocol Conformance

```swift
// RIGHT - Separate extensions for protocol conformance
class MyViewController: UIViewController {
    // Core implementation
}

// MARK: - UITableViewDelegate

extension MyViewController: UITableViewDelegate {
    // Delegate methods
}
```

## Dependency Injection

```swift
// RIGHT - Protocol injection with contract type
final class UserListViewModel {
    private let useCase: GetUsersUseCaseContract

    init(useCase: GetUsersUseCaseContract) {
        self.useCase = useCase
    }
}

// WRONG - Concrete type (implementation exposed)
final class UserListViewModel {
    private let useCase: GetUsersUseCase
}
```

## Code Organization

Organize type contents in this order:

1. **Properties first** - All properties (private, internal, public) at the beginning
2. **Initializers** - init, deinit
3. **Public/Internal methods** - API methods
4. **Private methods** - In a `private extension` of the same type

```swift
// RIGHT - Properties first, private methods in extension
public actor HTTPClient {
    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = JSONDecoder()
    }

    public func request(_ endpoint: Endpoint) async throws -> Data {
        let request = try buildRequest(for: endpoint)
        // ...
    }
}

private extension HTTPClient {
    func buildRequest(for endpoint: Endpoint) throws -> URLRequest {
        // ...
    }
}
```

```swift
// WRONG - Mixed organization with MARK comments
public actor HTTPClient {
    // MARK: Lifecycle
    public init(...) { }

    // MARK: Public
    public func request(...) { }

    // MARK: Private
    private let session: URLSession
    private func buildRequest(...) { }
}
```

Use `// MARK:` only for protocol conformance extensions:

```swift
// MARK: - CustomStringConvertible

extension HTTPError: CustomStringConvertible {
    var description: String { ... }
}
```

## SwiftUI

```swift
// RIGHT - Implicit ViewBuilder, no redundant return
var body: some View {
    VStack {
        Text("Title")
        Button("Action") { }
    }
}

// WRONG - Explicit ViewBuilder and return
@ViewBuilder
var body: some View {
    return VStack {
        Text("Title")
        Button("Action") { }
    }
}
```

## SwiftLint

SwiftLint is installed via **mise** (not SPM). Configuration is in `.swiftlint.yml`.

```bash
mise x -- swiftlint          # Run linter
mise x -- swiftlint --fix    # Auto-fix issues
```

### Enforced Limits

| Rule | Warning | Error |
|------|---------|-------|
| Line length | 140 | 200 |
| File length | 500 | 1000 |
| Type body length | 300 | 500 |
| Function body length | 50 | 100 |
| Cyclomatic complexity | 10 | 20 |

### Custom Rules

| Rule | Severity | Description |
|------|----------|-------------|
| `protocol_contract_suffix` | warning | Protocols must end with `Contract` |
| `mock_suffix` | warning | Mocks must end with `Mock` |
| `no_mock_prefix` | error | `Mock` cannot be used as prefix |
| `no_dispatch_queue` | error | Use async/await, not DispatchQueue |
| `no_completion_handler` | warning | Use async/await, not completion handlers |
