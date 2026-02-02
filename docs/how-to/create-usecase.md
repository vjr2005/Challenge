# How To: Create UseCase

Create UseCases for business logic. UseCases have a single responsibility and one `execute` method.

## Prerequisites

- Feature module exists (see [Create Feature](create-feature.md))
- Repository exists (see [Create Repository](create-repository.md))
- Domain error type defined

## File structure

```
Features/{Feature}/
├── Sources/
│   └── Domain/
│       └── UseCases/
│           └── {Action}{Name}UseCase.swift
└── Tests/
    ├── Unit/
    │   └── Domain/
    │       └── UseCases/
    │           └── {Action}{Name}UseCaseTests.swift
    └── Shared/
        └── Mocks/
            └── {Action}{Name}UseCaseMock.swift
```

## Naming conventions

| Prefix | Purpose | Example |
|--------|---------|---------|
| Get | Fetch single item | `GetCharacterUseCase` |
| Get (plural) | Fetch collection | `GetCharactersUseCase` |
| Search | Search with query | `SearchCharactersUseCase` |
| Create | Create new item | `CreateOrderUseCase` |
| Update | Update existing item | `UpdateProfileUseCase` |
| Delete | Delete item | `DeleteCartItemUseCase` |
| Validate | Validate data | `ValidateEmailUseCase` |

---

## Option A: Simple UseCase with CachePolicy

For UseCases that fetch data with caching support.

### 1. Create UseCase

Create `Sources/Domain/UseCases/Get{Name}UseCase.swift`:

```swift
import Foundation

protocol Get{Name}UseCaseContract: Sendable {
    func execute(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name}
}

// MARK: - Default Parameters

extension Get{Name}UseCaseContract {
    func execute(identifier: Int) async throws({Feature}Error) -> {Name} {
        try await execute(identifier: identifier, cachePolicy: .localFirst)
    }
}

struct Get{Name}UseCase: Get{Name}UseCaseContract {
    private let repository: {Name}RepositoryContract

    init(repository: {Name}RepositoryContract) {
        self.repository = repository
    }

    func execute(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name} {
        try await repository.get{Name}(identifier: identifier, cachePolicy: cachePolicy)
    }
}
```

> **Note:** The protocol extension provides a default `localFirst` cache policy, making the common case simple while allowing explicit control when needed.

### 2. Create Mock

Create `Tests/Shared/Mocks/Get{Name}UseCaseMock.swift`:

```swift
import Foundation

@testable import Challenge{Feature}

final class Get{Name}UseCaseMock: Get{Name}UseCaseContract, @unchecked Sendable {
    var result: Result<{Name}, {Feature}Error> = .failure(.loadFailed)
    private(set) var executeCallCount = 0
    private(set) var lastRequestedIdentifier: Int?
    private(set) var lastCachePolicy: CachePolicy?

    func execute(identifier: Int, cachePolicy: CachePolicy) async throws({Feature}Error) -> {Name} {
        executeCallCount += 1
        lastRequestedIdentifier = identifier
        lastCachePolicy = cachePolicy
        return try result.get()
    }
}
```

### 3. Create tests

Create `Tests/Unit/Domain/UseCases/Get{Name}UseCaseTests.swift`:

```swift
import Foundation
import Testing

@testable import Challenge{Feature}

@Suite(.timeLimit(.minutes(1)))
struct Get{Name}UseCaseTests {
    private let repositoryMock = {Name}RepositoryMock()
    private let sut: Get{Name}UseCase

    init() {
        sut = Get{Name}UseCase(repository: repositoryMock)
    }

    // MARK: - Execute with CachePolicy

    @Test("Returns item from repository with specified cache policy")
    func returnsItemWithCachePolicy() async throws {
        // Given
        let expected = {Name}.stub()
        repositoryMock.result = .success(expected)

        // When
        let value = try await sut.execute(identifier: 1, cachePolicy: .remoteFirst)

        // Then
        #expect(value == expected)
    }

    @Test("Calls repository with correct identifier and cache policy")
    func callsRepositoryWithCorrectIdAndCachePolicy() async throws {
        // Given
        repositoryMock.result = .success(.stub())

        // When
        _ = try await sut.execute(identifier: 42, cachePolicy: .remoteFirst)

        // Then
        #expect(repositoryMock.get{Name}CallCount == 1)
        #expect(repositoryMock.lastRequestedIdentifier == 42)
        #expect(repositoryMock.lastCachePolicy == .remoteFirst)
    }

    @Test("Propagates repository error")
    func propagatesRepositoryError() async throws {
        // Given
        repositoryMock.result = .failure(.loadFailed)

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed) {
            _ = try await sut.execute(identifier: 1, cachePolicy: .localFirst)
        }
    }

    // MARK: - Default Extension

    @Test("Default execute uses localFirst cache policy")
    func defaultExecuteUsesLocalFirstCachePolicy() async throws {
        // Given
        repositoryMock.result = .success(.stub())

        // When
        _ = try await sut.execute(identifier: 1)

        // Then
        #expect(repositoryMock.lastCachePolicy == .localFirst)
    }
}
```

---

## Option B: Search UseCase (no cache)

For UseCases that search with dynamic queries (caching not applicable).

### 1. Create UseCase

Create `Sources/Domain/UseCases/Search{Name}sUseCase.swift`:

```swift
import Foundation

protocol Search{Name}sUseCaseContract: Sendable {
    func execute(page: Int, query: String) async throws({Feature}Error) -> {Name}sPage
}

struct Search{Name}sUseCase: Search{Name}sUseCaseContract {
    private let repository: {Name}RepositoryContract

    init(repository: {Name}RepositoryContract) {
        self.repository = repository
    }

    func execute(page: Int, query: String) async throws({Feature}Error) -> {Name}sPage {
        try await repository.search{Name}s(page: page, query: query)
    }
}
```

### 2. Create Mock

Create `Tests/Shared/Mocks/Search{Name}sUseCaseMock.swift`:

```swift
import Foundation

@testable import Challenge{Feature}

final class Search{Name}sUseCaseMock: Search{Name}sUseCaseContract, @unchecked Sendable {
    var result: Result<{Name}sPage, {Feature}Error> = .failure(.loadFailed)
    private(set) var executeCallCount = 0
    private(set) var lastPage: Int?
    private(set) var lastQuery: String?

    func execute(page: Int, query: String) async throws({Feature}Error) -> {Name}sPage {
        executeCallCount += 1
        lastPage = page
        lastQuery = query
        return try result.get()
    }
}
```

### 3. Create tests

Create `Tests/Unit/Domain/UseCases/Search{Name}sUseCaseTests.swift`:

```swift
import Foundation
import Testing

@testable import Challenge{Feature}

@Suite(.timeLimit(.minutes(1)))
struct Search{Name}sUseCaseTests {
    private let repositoryMock = {Name}RepositoryMock()
    private let sut: Search{Name}sUseCase

    init() {
        sut = Search{Name}sUseCase(repository: repositoryMock)
    }

    // MARK: - Tests

    @Test("Execute returns page from repository search")
    func executeReturnsPage() async throws {
        // Given
        let expected = {Name}sPage.stub()
        repositoryMock.searchResult = .success(expected)

        // When
        let value = try await sut.execute(page: 1, query: "test")

        // Then
        #expect(value == expected)
    }

    @Test("Execute calls repository with correct page and query")
    func executeCallsRepositoryWithCorrectPageAndQuery() async throws {
        // Given
        repositoryMock.searchResult = .success(.stub())

        // When
        _ = try await sut.execute(page: 3, query: "search term")

        // Then
        #expect(repositoryMock.search{Name}sCallCount == 1)
        #expect(repositoryMock.lastSearchedPage == 3)
        #expect(repositoryMock.lastSearchedQuery == "search term")
    }

    @Test("Execute propagates repository error")
    func executePropagatesError() async throws {
        // Given
        repositoryMock.searchResult = .failure(.loadFailed)

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed) {
            _ = try await sut.execute(page: 1, query: "test")
        }
    }
}
```

---

## Option C: UseCase with Business Logic

For UseCases that contain domain rules beyond simple delegation.

### 1. Create UseCase

Create `Sources/Domain/UseCases/Calculate{Name}UseCase.swift`:

```swift
import Foundation

protocol Calculate{Name}UseCaseContract: Sendable {
    func execute(items: [CartItem]) async throws({Feature}Error) -> OrderTotal
}

struct Calculate{Name}UseCase: Calculate{Name}UseCaseContract {
    private let discountRepository: DiscountRepositoryContract

    init(discountRepository: DiscountRepositoryContract) {
        self.discountRepository = discountRepository
    }

    func execute(items: [CartItem]) async throws({Feature}Error) -> OrderTotal {
        // Business logic: calculate subtotal
        let subtotal = items.reduce(0) { $0 + ($1.price * Decimal($1.quantity)) }

        // Fetch applicable discount from repository
        let discount = try await discountRepository.getDiscount(for: subtotal)

        // Business logic: apply discount
        let discountAmount = subtotal * discount.percentage
        let total = subtotal - discountAmount

        return OrderTotal(
            subtotal: subtotal,
            discount: discountAmount,
            total: total
        )
    }
}
```

### 2. Create Mock

Create `Tests/Shared/Mocks/Calculate{Name}UseCaseMock.swift`:

```swift
import Foundation

@testable import Challenge{Feature}

final class Calculate{Name}UseCaseMock: Calculate{Name}UseCaseContract, @unchecked Sendable {
    var result: Result<OrderTotal, {Feature}Error> = .failure(.calculationFailed)
    private(set) var executeCallCount = 0
    private(set) var lastItems: [CartItem]?

    func execute(items: [CartItem]) async throws({Feature}Error) -> OrderTotal {
        executeCallCount += 1
        lastItems = items
        return try result.get()
    }
}
```

### 3. Create tests

Create `Tests/Unit/Domain/UseCases/Calculate{Name}UseCaseTests.swift`:

```swift
import Foundation
import Testing

@testable import Challenge{Feature}

@Suite(.timeLimit(.minutes(1)))
struct Calculate{Name}UseCaseTests {
    private let discountRepositoryMock = DiscountRepositoryMock()
    private let sut: Calculate{Name}UseCase

    init() {
        sut = Calculate{Name}UseCase(discountRepository: discountRepositoryMock)
    }

    // MARK: - Calculation Tests

    @Test("Calculates correct subtotal from items")
    func calculatesCorrectSubtotal() async throws {
        // Given
        let items = [
            CartItem(id: 1, price: Decimal(10), quantity: 2),  // 20
            CartItem(id: 2, price: Decimal(5), quantity: 3)    // 15
        ]
        discountRepositoryMock.result = .success(Discount(percentage: 0))

        // When
        let result = try await sut.execute(items: items)

        // Then
        #expect(result.subtotal == Decimal(35))
    }

    @Test("Applies discount correctly")
    func appliesDiscountCorrectly() async throws {
        // Given
        let items = [CartItem(id: 1, price: Decimal(100), quantity: 1)]
        discountRepositoryMock.result = .success(Discount(percentage: Decimal(0.1)))  // 10%

        // When
        let result = try await sut.execute(items: items)

        // Then
        #expect(result.subtotal == Decimal(100))
        #expect(result.discount == Decimal(10))
        #expect(result.total == Decimal(90))
    }

    @Test("Returns zero total for empty cart")
    func returnsZeroForEmptyCart() async throws {
        // Given
        discountRepositoryMock.result = .success(Discount(percentage: 0))

        // When
        let result = try await sut.execute(items: [])

        // Then
        #expect(result.total == Decimal(0))
    }

    // MARK: - Error Tests

    @Test("Propagates discount repository error")
    func propagatesDiscountError() async throws {
        // Given
        let items = [CartItem(id: 1, price: Decimal(10), quantity: 1)]
        discountRepositoryMock.result = .failure(.loadFailed)

        // When / Then
        await #expect(throws: {Feature}Error.loadFailed) {
            _ = try await sut.execute(items: items)
        }
    }
}
```

---

## Option D: UseCase with Validation

For UseCases that validate input before processing.

### 1. Create UseCase

Create `Sources/Domain/UseCases/Validate{Name}UseCase.swift`:

```swift
import Foundation

protocol Validate{Name}UseCaseContract: Sendable {
    func execute(email: String) throws({Feature}Error) -> ValidatedEmail
}

struct Validate{Name}UseCase: Validate{Name}UseCaseContract {
    func execute(email: String) throws({Feature}Error) -> ValidatedEmail {
        // Validation: not empty
        guard !email.isEmpty else {
            throw {Feature}Error.validation(.emailEmpty)
        }

        // Validation: valid format
        let emailRegex = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/
            .ignoresCase()
        guard email.wholeMatch(of: emailRegex) != nil else {
            throw {Feature}Error.validation(.emailInvalid)
        }

        return ValidatedEmail(value: email.lowercased())
    }
}
```

> **Note:** Validation UseCases are often synchronous (no `async`) when they don't need external data.

### 2. Create Mock

Create `Tests/Shared/Mocks/Validate{Name}UseCaseMock.swift`:

```swift
import Foundation

@testable import Challenge{Feature}

final class Validate{Name}UseCaseMock: Validate{Name}UseCaseContract, @unchecked Sendable {
    var result: Result<ValidatedEmail, {Feature}Error> = .failure(.validation(.emailInvalid))
    private(set) var executeCallCount = 0
    private(set) var lastEmail: String?

    func execute(email: String) throws({Feature}Error) -> ValidatedEmail {
        executeCallCount += 1
        lastEmail = email
        return try result.get()
    }
}
```

### 3. Create tests

Create `Tests/Unit/Domain/UseCases/Validate{Name}UseCaseTests.swift`:

```swift
import Foundation
import Testing

@testable import Challenge{Feature}

@Suite(.timeLimit(.minutes(1)))
struct Validate{Name}UseCaseTests {
    private let sut = Validate{Name}UseCase()

    // MARK: - Valid Email Tests

    @Test("Valid email returns validated email")
    func validEmailReturnsValidatedEmail() throws {
        // When
        let result = try sut.execute(email: "user@example.com")

        // Then
        #expect(result.value == "user@example.com")
    }

    @Test("Valid email is lowercased")
    func validEmailIsLowercased() throws {
        // When
        let result = try sut.execute(email: "User@Example.COM")

        // Then
        #expect(result.value == "user@example.com")
    }

    // MARK: - Invalid Email Tests

    @Test("Empty email throws validation error")
    func emptyEmailThrowsError() {
        // When / Then
        #expect(throws: {Feature}Error.validation(.emailEmpty)) {
            _ = try sut.execute(email: "")
        }
    }

    @Test("Invalid format throws validation error")
    func invalidFormatThrowsError() {
        // When / Then
        #expect(throws: {Feature}Error.validation(.emailInvalid)) {
            _ = try sut.execute(email: "not-an-email")
        }
    }

    @Test(
        "Various invalid emails throw error",
        arguments: ["@example.com", "user@", "user@.com", "user"]
    )
    func invalidEmailsThrowError(email: String) {
        // When / Then
        #expect(throws: {Feature}Error.validation(.emailInvalid)) {
            _ = try sut.execute(email: email)
        }
    }
}
```

---

## Generate and verify

```bash
./generate.sh
```

## Next steps

- [Create ViewModel](create-viewmodel.md) - Create state management that uses the UseCase

## See also

- [Create Repository](create-repository.md) - Repository that UseCase depends on
- [Testing](../Testing.md)
