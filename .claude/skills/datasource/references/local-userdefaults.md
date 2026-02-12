# UserDefaults DataSource Templates

Placeholders: `{Name}` (PascalCase entity), `{Feature}` (PascalCase module), `{storageKey}` (UserDefaults key string).

---

### {Name}LocalDataSourceContract.swift — `Sources/Data/DataSources/Local/`

```swift
protocol {Name}LocalDataSourceContract: Actor {
	func getItems() -> [String]
	func saveItem(_ item: String)
	func deleteItem(_ item: String)
}
```

Rules: `: Actor`. Methods are actor-isolated (implicitly `async` from caller). Adapt return types and parameters to the specific data being stored.

### {Name}UserDefaultsDataSource.swift — `Sources/Data/DataSources/Local/`

```swift
import Foundation

actor {Name}UserDefaultsDataSource: {Name}LocalDataSourceContract {
	private let userDefaults: UserDefaults
	private let key = "{storageKey}"

	init(userDefaults: UserDefaults = .standard) {
		self.userDefaults = userDefaults
	}

	func getItems() -> [String] {
		userDefaults.stringArray(forKey: key) ?? []
	}

	func saveItem(_ item: String) {
		var items = getItems()
		// Remove duplicates (case-insensitive)
		items.removeAll { $0.caseInsensitiveCompare(item) == .orderedSame }
		items.insert(item, at: 0)
		// Enforce limit
		if items.count > 5 {
			items = Array(items.prefix(5))
		}
		userDefaults.set(items, forKey: key)
	}

	func deleteItem(_ item: String) {
		var items = getItems()
		items.removeAll { $0.caseInsensitiveCompare(item) == .orderedSame }
		userDefaults.set(items, forKey: key)
	}
}
```

`private let userDefaults` — no `nonisolated(unsafe)` needed inside the actor. Actor isolation is sufficient. `UserDefaults` is thread-safe so it doesn't need additional protection.

Adapt business rules (deduplication, ordering, limits) to the specific use case.

### {Name}LocalDataSourceMock.swift — `Tests/Shared/Mocks/`

```swift
import Foundation

@testable import Challenge{Feature}

actor {Name}LocalDataSourceMock: {Name}LocalDataSourceContract {
	// MARK: - Configurable Returns

	private(set) var items: [String] = []

	func setItems(_ items: [String]) {
		self.items = items
	}

	// MARK: - Call Tracking

	private(set) var getItemsCallCount = 0
	private(set) var saveItemCallCount = 0
	private(set) var lastSavedItem: String?
	private(set) var deleteItemCallCount = 0
	private(set) var lastDeletedItem: String?

	// MARK: - {Name}LocalDataSourceContract

	func getItems() -> [String] {
		getItemsCallCount += 1
		return items
	}

	func saveItem(_ item: String) {
		saveItemCallCount += 1
		lastSavedItem = item
	}

	func deleteItem(_ item: String) {
		deleteItemCallCount += 1
		lastDeletedItem = item
	}
}
```

### {Name}UserDefaultsDataSourceTests.swift — `Tests/Unit/Data/`

```swift
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Name}UserDefaultsDataSourceTests {
	// MARK: - Properties

	private let sut: {Name}UserDefaultsDataSource
	private nonisolated(unsafe) let userDefaults: UserDefaults

	// MARK: - Init

	init() {
		let suite = UserDefaults(suiteName: "\(type(of: self))")!
		suite.removePersistentDomain(forName: "\(type(of: self))")
		self.userDefaults = suite
		sut = {Name}UserDefaultsDataSource(userDefaults: suite)
	}

	// MARK: - Get

	@Test("Returns empty array initially")
	func returnsEmptyArrayInitially() async {
		let result = await sut.getItems()
		#expect(result.isEmpty)
	}

	// MARK: - Save

	@Test("Saves and retrieves item")
	func savesAndRetrievesItem() async {
		// When
		await sut.saveItem("test")

		// Then
		let result = await sut.getItems()
		#expect(result == ["test"])
	}

	@Test("Most recent item is first")
	func mostRecentItemIsFirst() async {
		// Given
		await sut.saveItem("first")

		// When
		await sut.saveItem("second")

		// Then
		let result = await sut.getItems()
		#expect(result == ["second", "first"])
	}

	@Test("Deduplicates case-insensitively")
	func deduplicatesCaseInsensitively() async {
		// Given
		await sut.saveItem("Test")

		// When
		await sut.saveItem("test")

		// Then
		let result = await sut.getItems()
		#expect(result == ["test"])
	}

	@Test("Enforces maximum limit")
	func enforcesMaximumLimit() async {
		// Given
		for i in 1...6 {
			await sut.saveItem("item\(i)")
		}

		// Then
		let result = await sut.getItems()
		#expect(result.count == 5)
		#expect(result.first == "item6")
	}

	// MARK: - Delete

	@Test("Deletes item case-insensitively")
	func deletesItemCaseInsensitively() async {
		// Given
		await sut.saveItem("Test")

		// When
		await sut.deleteItem("test")

		// Then
		let result = await sut.getItems()
		#expect(result.isEmpty)
	}

	// MARK: - Persistence

	@Test("Persists across instances")
	func persistsAcrossInstances() async {
		// Given
		await sut.saveItem("persisted")

		// When
		let otherInstance = {Name}UserDefaultsDataSource(userDefaults: userDefaults)
		let result = await otherInstance.getItems()

		// Then
		#expect(result == ["persisted"])
	}
}
```

**Key:** `nonisolated(unsafe)` on the test's `userDefaults` property — needed because `UserDefaults` is not `Sendable` and crosses isolation boundaries when passed to the actor init. The `nonisolated(unsafe)` belongs at the **call site** (sender), not inside the actor.

Each test uses a dedicated `UserDefaults` suite to avoid cross-test contamination. The `init` clears the suite before each test.
