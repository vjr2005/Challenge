# Memory DataSource Templates

Placeholders: `{Name}` (PascalCase entity), `{Feature}` (PascalCase module), `{name}` (snake_case).

---

### {Name}LocalDataSourceContract.swift — `Sources/Data/DataSources/Local/`

Single item caching:

```swift
protocol {Name}LocalDataSourceContract: Actor {
	func get{Name}(identifier: Int) async -> {Name}DTO?
	func save{Name}(_ item: {Name}DTO) async
}
```

With paginated results:

```swift
protocol {Name}LocalDataSourceContract: Actor {
	// MARK: - Single Item
	func get{Name}(identifier: Int) async -> {Name}DTO?
	func save{Name}(_ item: {Name}DTO) async

	// MARK: - Paginated Results
	func getPage(_ page: Int) async -> {Name}sResponseDTO?
	func savePage(_ response: {Name}sResponseDTO, page: Int) async
}
```

Rules: `: Actor`, return optionals for get, `identifier` parameter name. Methods are actor-isolated (implicitly `async` from caller).

### {Name}MemoryDataSource.swift — `Sources/Data/DataSources/Local/`

```swift
actor {Name}MemoryDataSource: {Name}LocalDataSourceContract {
	private var items: [Int: {Name}DTO] = [:]
	private var pages: [Int: {Name}sResponseDTO] = [:]

	// MARK: - Single Item

	func get{Name}(identifier: Int) -> {Name}DTO? {
		items[identifier]
	}

	func save{Name}(_ item: {Name}DTO) {
		items[item.id] = item
	}

	// MARK: - Paginated Results

	func getPage(_ page: Int) -> {Name}sResponseDTO? {
		pages[page]
	}

	func savePage(_ response: {Name}sResponseDTO, page: Int) {
		pages[page] = response
	}
}
```

Actor methods omit `async` — actor isolation provides it implicitly.

### {Name}LocalDataSourceMock.swift — `Tests/Shared/Mocks/`

```swift
import Foundation

@testable import Challenge{Feature}

actor {Name}LocalDataSourceMock: {Name}LocalDataSourceContract {
	// MARK: - Configurable Returns

	private(set) var itemToReturn: {Name}DTO?
	private(set) var pageToReturn: {Name}sResponseDTO?

	func setItemToReturn(_ item: {Name}DTO?) {
		itemToReturn = item
	}

	func setPageToReturn(_ page: {Name}sResponseDTO?) {
		pageToReturn = page
	}

	// MARK: - Call Tracking

	private(set) var get{Name}CallCount = 0
	private(set) var save{Name}CallCount = 0
	private(set) var save{Name}LastValue: {Name}DTO?
	private(set) var getPageCallCount = 0
	private(set) var savePageCallCount = 0
	private(set) var savePageLastResponse: {Name}sResponseDTO?
	private(set) var savePageLastPage: Int?

	// MARK: - {Name}LocalDataSourceContract

	func get{Name}(identifier: Int) -> {Name}DTO? {
		get{Name}CallCount += 1
		return itemToReturn
	}

	func save{Name}(_ item: {Name}DTO) {
		save{Name}CallCount += 1
		save{Name}LastValue = item
	}

	func getPage(_ page: Int) -> {Name}sResponseDTO? {
		getPageCallCount += 1
		return pageToReturn
	}

	func savePage(_ response: {Name}sResponseDTO, page: Int) {
		savePageCallCount += 1
		savePageLastResponse = response
		savePageLastPage = page
	}
}
```

Actor mock: `private(set)` on configurable returns with setter methods. Tests use `await` for all property reads and setter calls.

### {Name}MemoryDataSourceTests.swift — `Tests/Unit/Data/`

No changes — tests already use `await` for actor method calls. The MemoryDataSource is tested directly (not via mock).
