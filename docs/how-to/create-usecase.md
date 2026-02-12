# How To: Create UseCase

Create UseCases for business logic. UseCases have a single responsibility and one `execute` method.

## Prerequisites

- Feature module exists (see [Create Feature](create-feature.md))
- Repository exists (see [Create Repository](create-repository.md))
- Domain error type defined

## UseCase types

| Type | When | Reference |
|------|------|-----------|
| Get / Refresh | CRUD with cache policy | Step 3a |
| Search | Query-based, always remote | Step 3b |
| Business Logic | Filtering, validation, transformation | Step 3c |
| Multiple Repositories | Coordinates data from 2+ repos | Step 3d |

## File structure

```
Features/{Feature}/
├── Sources/Domain/UseCases/
│   └── Get{Name}UseCase.swift       # Contract + Implementation
└── Tests/
    ├── Unit/Domain/UseCases/
    │   └── Get{Name}UseCaseTests.swift
    └── Shared/Mocks/
        └── Get{Name}UseCaseMock.swift
```

## Core Pattern

Each UseCase encapsulates **one business operation** with **exactly one method: `execute`**.

> **CRITICAL:** Never add multiple methods or cache policy parameters. Create separate UseCases instead:
> - `GetCharacterUseCase` (localFirst) + `RefreshCharacterUseCase` (remoteFirst)
> - `GetCharactersPageUseCase` (list) + `SearchCharactersPageUseCase` (search)

### Naming Convention

| Operation | UseCase Name | Cache Policy |
|-----------|--------------|--------------|
| Get single | `Get{Name}UseCase` | localFirst (implicit) |
| Refresh single | `Refresh{Name}UseCase` | remoteFirst (implicit) |
| Get list | `Get{Name}sPageUseCase` | localFirst (implicit) |
| Refresh list | `Refresh{Name}sPageUseCase` | remoteFirst (implicit) |
| Search | `Search{Name}sPageUseCase` | none (always remote) |
| Create / Update / Delete | `{Action}{Name}UseCase` | — |

> **Note:** Use singular names for single-item UseCases and `Page` suffix for list UseCases to distinguish them (`GetCharacterUseCase` vs `GetCharactersPageUseCase`).

---

## Workflow

### Step 1 — Identify UseCase Type

See the UseCase types table above.

### Step 2 — Ensure Repository Exists

Before creating a UseCase, verify the required Repository exists in `Sources/Domain/Repositories/`.

- **Repository found?** → Go to Step 3
- **No Repository found?** → Invoke the `/repository` skill first. Return here after completion.

### Step 3 — Implement UseCase

Read the appropriate section below and implement:
1. Contract + Implementation in `Sources/Domain/UseCases/`
2. Mock in `Tests/Shared/Mocks/`
3. Tests in `Tests/Unit/Domain/UseCases/`
4. Run tests

---

## Step 3a: Get & Refresh UseCases

Separate UseCases for different cache behaviors instead of exposing `cachePolicy` parameter. This follows the Single Responsibility Principle.

### Get UseCase (localFirst)

Create `Sources/Domain/UseCases/Get{Name}UseCase.swift`:

```swift
protocol Get{Name}UseCaseContract: Sendable {
	func execute(identifier: Int) async throws({Feature}Error) -> {Name}
}

struct Get{Name}UseCase: Get{Name}UseCaseContract {
	private let repository: {Name}RepositoryContract

	init(repository: {Name}RepositoryContract) {
		self.repository = repository
	}

	func execute(identifier: Int) async throws({Feature}Error) -> {Name} {
		try await repository.get{Name}(identifier: identifier, cachePolicy: .localFirst)
	}
}
```

### Refresh UseCase (remoteFirst)

Create `Sources/Domain/UseCases/Refresh{Name}UseCase.swift`:

```swift
protocol Refresh{Name}UseCaseContract: Sendable {
	func execute(identifier: Int) async throws({Feature}Error) -> {Name}
}

struct Refresh{Name}UseCase: Refresh{Name}UseCaseContract {
	private let repository: {Name}RepositoryContract

	init(repository: {Name}RepositoryContract) {
		self.repository = repository
	}

	func execute(identifier: Int) async throws({Feature}Error) -> {Name} {
		try await repository.get{Name}(identifier: identifier, cachePolicy: .remoteFirst)
	}
}
```

> **Note:** The cache policy is encapsulated inside the UseCase. ViewModels don't know about cache policies — they just call the appropriate UseCase.

### List Variants

Same pattern with `page: Int` parameter:

```swift
// Get{Name}sPageUseCase
protocol Get{Name}sPageUseCaseContract: Sendable {
	func execute(page: Int) async throws({Feature}Error) -> {Name}sPage
}

struct Get{Name}sPageUseCase: Get{Name}sPageUseCaseContract {
	private let repository: {Name}sPageRepositoryContract

	init(repository: {Name}sPageRepositoryContract) {
		self.repository = repository
	}

	func execute(page: Int) async throws({Feature}Error) -> {Name}sPage {
		try await repository.get{Name}sPage(page: page, cachePolicy: .localFirst)
	}
}

// Refresh{Name}sPageUseCase
protocol Refresh{Name}sPageUseCaseContract: Sendable {
	func execute(page: Int) async throws({Feature}Error) -> {Name}sPage
}

struct Refresh{Name}sPageUseCase: Refresh{Name}sPageUseCaseContract {
	private let repository: {Name}sPageRepositoryContract

	init(repository: {Name}sPageRepositoryContract) {
		self.repository = repository
	}

	func execute(page: Int) async throws({Feature}Error) -> {Name}sPage {
		try await repository.get{Name}sPage(page: page, cachePolicy: .remoteFirst)
	}
}
```

### Mocks

Create `Tests/Shared/Mocks/Get{Name}UseCaseMock.swift`:

```swift
@testable import Challenge{Feature}

final class Get{Name}UseCaseMock: Get{Name}UseCaseContract, @unchecked Sendable {
	var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed())
	private(set) var executeCallCount = 0
	private(set) var lastRequestedIdentifier: Int?

	@MainActor init() {}

	func execute(identifier: Int) async throws({Feature}Error) -> {Name} {
		executeCallCount += 1
		lastRequestedIdentifier = identifier
		return try result.get()
	}
}
```

Create `Tests/Shared/Mocks/Refresh{Name}UseCaseMock.swift`:

```swift
@testable import Challenge{Feature}

final class Refresh{Name}UseCaseMock: Refresh{Name}UseCaseContract, @unchecked Sendable {
	var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed())
	private(set) var executeCallCount = 0
	private(set) var lastRequestedIdentifier: Int?

	@MainActor init() {}

	func execute(identifier: Int) async throws({Feature}Error) -> {Name} {
		executeCallCount += 1
		lastRequestedIdentifier = identifier
		return try result.get()
	}
}
```

### Tests

Create `Tests/Unit/Domain/UseCases/Get{Name}UseCaseTests.swift`:

```swift
import ChallengeCore
import Foundation
import Testing

@testable import Challenge{Feature}

struct Get{Name}UseCaseTests {
	@Test("Execute returns model from repository")
	func executeReturnsModel() async throws {
		// Given
		let expected = {Name}.stub()
		let repositoryMock = {Name}RepositoryMock()
		repositoryMock.result = .success(expected)
		let sut = Get{Name}UseCase(repository: repositoryMock)

		// When
		let value = try await sut.execute(identifier: 1)

		// Then
		#expect(value == expected)
	}

	@Test("Execute calls repository with correct identifier and localFirst cache policy")
	func executeCallsRepositoryWithLocalFirst() async throws {
		// Given
		let repositoryMock = {Name}RepositoryMock()
		repositoryMock.result = .success(.stub())
		let sut = Get{Name}UseCase(repository: repositoryMock)

		// When
		_ = try await sut.execute(identifier: 42)

		// Then
		#expect(repositoryMock.getCallCount == 1)
		#expect(repositoryMock.lastRequestedIdentifier == 42)
		#expect(repositoryMock.lastCachePolicy == .localFirst)
	}

	@Test("Execute propagates repository error")
	func executePropagatesError() async throws {
		// Given
		let repositoryMock = {Name}RepositoryMock()
		repositoryMock.result = .failure(.loadFailed())
		let sut = Get{Name}UseCase(repository: repositoryMock)

		// When / Then
		await #expect(throws: {Feature}Error.loadFailed()) {
			_ = try await sut.execute(identifier: 1)
		}
	}
}
```

For Refresh, replace `localFirst` with `remoteFirst` in test name and assertion.

---

## Step 3b: Search UseCase

Search bypasses cache — always remote, no `cachePolicy` parameter. Uses `filter: {Name}Filter` parameter.

### Implementation

Create `Sources/Domain/UseCases/Search{Name}sPageUseCase.swift`:

```swift
protocol Search{Name}sPageUseCaseContract: Sendable {
	func execute(page: Int, filter: {Name}Filter) async throws({Feature}Error) -> {Name}sPage
}

struct Search{Name}sPageUseCase: Search{Name}sPageUseCaseContract {
	private let repository: {Name}sPageRepositoryContract

	init(repository: {Name}sPageRepositoryContract) {
		self.repository = repository
	}

	func execute(page: Int, filter: {Name}Filter) async throws({Feature}Error) -> {Name}sPage {
		try await repository.search{Name}sPage(page: page, filter: filter)
	}
}
```

### Mock

Create `Tests/Shared/Mocks/Search{Name}sPageUseCaseMock.swift`:

```swift
@testable import Challenge{Feature}

final class Search{Name}sPageUseCaseMock: Search{Name}sPageUseCaseContract, @unchecked Sendable {
	var result: Result<{Name}sPage, {Feature}Error> = .failure(.loadFailed())
	private(set) var executeCallCount = 0
	private(set) var lastRequestedPage: Int?
	private(set) var lastRequestedFilter: {Name}Filter?

	@MainActor init() {}

	func execute(page: Int, filter: {Name}Filter) async throws({Feature}Error) -> {Name}sPage {
		executeCallCount += 1
		lastRequestedPage = page
		lastRequestedFilter = filter
		return try result.get()
	}
}
```

### Tests

Create `Tests/Unit/Domain/UseCases/Search{Name}sPageUseCaseTests.swift`:

```swift
import Foundation
import Testing

@testable import Challenge{Feature}

struct Search{Name}sPageUseCaseTests {
	@Test("Execute returns page from repository")
	func executeReturnsPage() async throws {
		// Given
		let expected = {Name}sPage.stub()
		let repositoryMock = {Name}sPageRepositoryMock()
		repositoryMock.searchResult = .success(expected)
		let sut = Search{Name}sPageUseCase(repository: repositoryMock)

		// When
		let value = try await sut.execute(page: 1, filter: .stub())

		// Then
		#expect(value == expected)
	}

	@Test("Execute calls repository with correct parameters")
	func executeCallsRepositoryWithCorrectParameters() async throws {
		// Given
		let filter = {Name}Filter.stub(name: "Rick")
		let repositoryMock = {Name}sPageRepositoryMock()
		repositoryMock.searchResult = .success(.stub())
		let sut = Search{Name}sPageUseCase(repository: repositoryMock)

		// When
		_ = try await sut.execute(page: 2, filter: filter)

		// Then
		#expect(repositoryMock.search{Name}sPageCallCount == 1)
		#expect(repositoryMock.lastRequestedPage == 2)
		#expect(repositoryMock.lastRequestedFilter == filter)
	}

	@Test("Execute propagates repository error")
	func executePropagatesError() async throws {
		// Given
		let repositoryMock = {Name}sPageRepositoryMock()
		repositoryMock.searchResult = .failure(.loadFailed())
		let sut = Search{Name}sPageUseCase(repository: repositoryMock)

		// When / Then
		await #expect(throws: {Feature}Error.loadFailed()) {
			_ = try await sut.execute(page: 1, filter: .stub())
		}
	}
}
```

---

## Step 3c: Business Logic UseCase

For operations that include domain rules: filtering, validation, transformation.

### Filtering Example

Create `Sources/Domain/UseCases/GetFiltered{Name}sUseCase.swift`:

```swift
protocol GetFiltered{Name}sUseCaseContract: Sendable {
	func execute(status: {Name}Status?) async throws({Feature}Error) -> [{Name}]
}

struct GetFiltered{Name}sUseCase: GetFiltered{Name}sUseCaseContract {
	private let repository: {Name}RepositoryContract

	init(repository: {Name}RepositoryContract) {
		self.repository = repository
	}

	func execute(status: {Name}Status?) async throws({Feature}Error) -> [{Name}] {
		let items = try await repository.getAll{Name}s()

		guard let status else {
			return items
		}

		return items.filter { $0.status == status }
	}
}
```

### Validation Example

Create `Sources/Domain/UseCases/Create{Name}UseCase.swift`:

```swift
protocol Create{Name}UseCaseContract: Sendable {
	func execute(name: String, status: String) async throws({Feature}Error) -> {Name}
}

struct Create{Name}UseCase: Create{Name}UseCaseContract {
	private let repository: {Name}RepositoryContract

	init(repository: {Name}RepositoryContract) {
		self.repository = repository
	}

	func execute(name: String, status: String) async throws({Feature}Error) -> {Name} {
		guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
			throw {Feature}Error.emptyName
		}

		guard {Name}Status(rawValue: status) != nil else {
			throw {Feature}Error.invalidStatus
		}

		return try await repository.create{Name}(name: name, status: status)
	}
}
```

> **Note:** Validation errors should be cases in the feature's Domain Error enum (see `/repository` skill), not a separate error type.

### Filtering Tests

Test all branches: happy path, each filter case, edge cases (empty results).

Create `Tests/Unit/Domain/UseCases/GetFiltered{Name}sUseCaseTests.swift`:

```swift
import Foundation
import Testing

@testable import Challenge{Feature}

struct GetFiltered{Name}sUseCaseTests {
	@Test("Returns all items when no filter is applied")
	func returnsAllItemsWhenNoFilter() async throws {
		// Given
		let items = [{Name}.stub(status: .active), {Name}.stub(status: .inactive)]
		let repositoryMock = {Name}RepositoryMock()
		repositoryMock.allResult = .success(items)
		let sut = GetFiltered{Name}sUseCase(repository: repositoryMock)

		// When
		let value = try await sut.execute(status: nil)

		// Then
		#expect(value.count == 2)
	}

	@Test("Filters items by status")
	func filtersItemsByStatus() async throws {
		// Given
		let items = [
			{Name}.stub(id: 1, status: .active),
			{Name}.stub(id: 2, status: .inactive),
			{Name}.stub(id: 3, status: .active),
		]
		let repositoryMock = {Name}RepositoryMock()
		repositoryMock.allResult = .success(items)
		let sut = GetFiltered{Name}sUseCase(repository: repositoryMock)

		// When
		let value = try await sut.execute(status: .active)

		// Then
		#expect(value.count == 2)
		#expect(value.allSatisfy { $0.status == .active })
	}

	@Test("Returns empty array when no items match filter")
	func returnsEmptyArrayWhenNoMatches() async throws {
		// Given
		let items = [{Name}.stub(status: .active)]
		let repositoryMock = {Name}RepositoryMock()
		repositoryMock.allResult = .success(items)
		let sut = GetFiltered{Name}sUseCase(repository: repositoryMock)

		// When
		let value = try await sut.execute(status: .inactive)

		// Then
		#expect(value.isEmpty)
	}
}
```

### Validation Tests

Test validation errors and verify repository is NOT called on validation failure.

Create `Tests/Unit/Domain/UseCases/Create{Name}UseCaseTests.swift`:

```swift
import Foundation
import Testing

@testable import Challenge{Feature}

struct Create{Name}UseCaseTests {
	@Test("Throws error for empty name")
	func throwsErrorForEmptyName() async throws {
		// Given
		let repositoryMock = {Name}RepositoryMock()
		let sut = Create{Name}UseCase(repository: repositoryMock)

		// When / Then
		await #expect(throws: {Feature}Error.emptyName) {
			_ = try await sut.execute(name: "   ", status: "Active")
		}
	}

	@Test("Does not call repository on validation error")
	func doesNotCallRepositoryOnValidationError() async throws {
		// Given
		let repositoryMock = {Name}RepositoryMock()
		let sut = Create{Name}UseCase(repository: repositoryMock)

		// When
		_ = try? await sut.execute(name: "", status: "Active")

		// Then
		#expect(repositoryMock.createCallCount == 0)
	}

	@Test("Creates item with valid input")
	func createsItemWithValidInput() async throws {
		// Given
		let expected = {Name}.stub()
		let repositoryMock = {Name}RepositoryMock()
		repositoryMock.createResult = .success(expected)
		let sut = Create{Name}UseCase(repository: repositoryMock)

		// When
		let value = try await sut.execute(name: "Rick", status: "Active")

		// Then
		#expect(value == expected)
		#expect(repositoryMock.createCallCount == 1)
	}
}
```

---

## Step 3d: Multiple Repositories UseCase

For operations that coordinate data from 2+ repositories.

### Implementation

Create `Sources/Domain/UseCases/Get{Name}With{Related}sUseCase.swift`:

```swift
protocol Get{Name}With{Related}sUseCaseContract: Sendable {
	func execute(identifier: Int) async throws({Feature}Error) -> {Name}With{Related}s
}

struct Get{Name}With{Related}sUseCase: Get{Name}With{Related}sUseCaseContract {
	private let {name}Repository: {Name}RepositoryContract
	private let {related}Repository: {Related}RepositoryContract

	init(
		{name}Repository: {Name}RepositoryContract,
		{related}Repository: {Related}RepositoryContract
	) {
		self.{name}Repository = {name}Repository
		self.{related}Repository = {related}Repository
	}

	func execute(identifier: Int) async throws({Feature}Error) -> {Name}With{Related}s {
		let item = try await {name}Repository.get{Name}(identifier: identifier, cachePolicy: .localFirst)
		let related = try await {related}Repository.get{Related}s(identifiers: item.{related}Identifiers, cachePolicy: .localFirst)

		return {Name}With{Related}s(
			{name}: item,
			{related}s: related
		)
	}
}
```

### Mock

Create `Tests/Shared/Mocks/Get{Name}With{Related}sUseCaseMock.swift`:

```swift
@testable import Challenge{Feature}

final class Get{Name}With{Related}sUseCaseMock: Get{Name}With{Related}sUseCaseContract, @unchecked Sendable {
	var result: Result<{Name}With{Related}s, {Feature}Error> = .failure(.loadFailed())
	private(set) var executeCallCount = 0
	private(set) var lastRequestedIdentifier: Int?

	@MainActor init() {}

	func execute(identifier: Int) async throws({Feature}Error) -> {Name}With{Related}s {
		executeCallCount += 1
		lastRequestedIdentifier = identifier
		return try result.get()
	}
}
```

### Tests

Test coordination and error propagation from each repository.

Create `Tests/Unit/Domain/UseCases/Get{Name}With{Related}sUseCaseTests.swift`:

```swift
import Foundation
import Testing

@testable import Challenge{Feature}

struct Get{Name}With{Related}sUseCaseTests {
	@Test("Returns combined model from both repositories")
	func returnsCombinedModel() async throws {
		// Given
		let item = {Name}.stub({related}Identifiers: [1, 2])
		let related = [{Related}.stub(id: 1), {Related}.stub(id: 2)]
		let {name}RepositoryMock = {Name}RepositoryMock()
		{name}RepositoryMock.result = .success(item)
		let {related}RepositoryMock = {Related}RepositoryMock()
		{related}RepositoryMock.result = .success(related)
		let sut = Get{Name}With{Related}sUseCase(
			{name}Repository: {name}RepositoryMock,
			{related}Repository: {related}RepositoryMock
		)

		// When
		let value = try await sut.execute(identifier: 1)

		// Then
		#expect(value.{name} == item)
		#expect(value.{related}s == related)
	}

	@Test("Propagates error from first repository")
	func propagatesFirstRepositoryError() async throws {
		// Given
		let {name}RepositoryMock = {Name}RepositoryMock()
		{name}RepositoryMock.result = .failure(.loadFailed())
		let {related}RepositoryMock = {Related}RepositoryMock()
		let sut = Get{Name}With{Related}sUseCase(
			{name}Repository: {name}RepositoryMock,
			{related}Repository: {related}RepositoryMock
		)

		// When / Then
		await #expect(throws: {Feature}Error.loadFailed()) {
			_ = try await sut.execute(identifier: 1)
		}
	}

	@Test("Propagates error from second repository")
	func propagatesSecondRepositoryError() async throws {
		// Given
		let {name}RepositoryMock = {Name}RepositoryMock()
		{name}RepositoryMock.result = .success(.stub())
		let {related}RepositoryMock = {Related}RepositoryMock()
		{related}RepositoryMock.result = .failure(.loadFailed())
		let sut = Get{Name}With{Related}sUseCase(
			{name}Repository: {name}RepositoryMock,
			{related}Repository: {related}RepositoryMock
		)

		// When / Then
		await #expect(throws: {Feature}Error.loadFailed()) {
			_ = try await sut.execute(identifier: 1)
		}
	}
}
```

---

## Visibility Summary

| Component | Visibility | Location |
|-----------|------------|----------|
| Contract | internal | `Sources/Domain/UseCases/` |
| Implementation | internal | `Sources/Domain/UseCases/` |
| Mock | internal | `Tests/Shared/Mocks/` |

## Generate and verify

```bash
mise x -- tuist test --skip-ui-tests
```

## Next steps

- [Create ViewModel](create-viewmodel.md) — Create state management that uses the UseCase

## See also

- [Create Repository](create-repository.md) — Repository that UseCase depends on
- [Testing](../Testing.md)
