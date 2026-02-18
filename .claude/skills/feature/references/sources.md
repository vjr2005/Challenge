# Source Templates

Placeholders: `{Feature}` (PascalCase), `{Screen}` (PascalCase), `{feature}` (lowercase host), `{deepLinkPath}` (path segment, no slash, e.g. `list`), `{eventPrefix}` (snake_case of Screen).

---

### {Feature}IncomingNavigation.swift — `Sources/Presentation/Navigation/`

```swift
import ChallengeCore

public enum {Feature}IncomingNavigation: IncomingNavigationContract {
	case main
}
```

### {Feature}DeepLinkHandler.swift — `Sources/Presentation/Navigation/`

```swift
import ChallengeCore
import Foundation

struct {Feature}DeepLinkHandler: DeepLinkHandlerContract {
	let scheme = "challenge"
	let host = "{feature}"

	func resolve(_ url: URL) -> (any NavigationContract)? {
		let pathComponents = url.pathComponents
		guard pathComponents.count >= 2 else {
			return nil
		}
		switch pathComponents[1] {
		case "{deepLinkPath}":
			return {Feature}IncomingNavigation.main

		default:
			return nil
		}
	}
}
```

> **Convention:** Deep links use path-based URLs — parameters are embedded in the path (e.g., `challenge://episode/character/42`), never as query items. When the feature grows and needs parameterized routes, parse `pathComponents` (e.g., `pathComponents[2]` for an identifier).

### {Screen}NavigatorContract.swift — `Sources/Presentation/{Screen}/Navigator/`

```swift
protocol {Screen}NavigatorContract {
	// Add navigation methods as the feature grows
}
```

### {Screen}Navigator.swift — `Sources/Presentation/{Screen}/Navigator/`

```swift
import ChallengeCore

struct {Screen}Navigator: {Screen}NavigatorContract {
	private let navigator: NavigatorContract

	init(navigator: NavigatorContract) {
		self.navigator = navigator
	}
}
```

### {Screen}TrackerContract.swift — `Sources/Presentation/{Screen}/Tracker/`

```swift
protocol {Screen}TrackerContract {
	func trackScreenViewed()
}
```

### {Screen}Tracker.swift — `Sources/Presentation/{Screen}/Tracker/`

```swift
import ChallengeCore

struct {Screen}Tracker: {Screen}TrackerContract {
	private let tracker: TrackerContract

	init(tracker: TrackerContract) {
		self.tracker = tracker
	}

	func trackScreenViewed() {
		tracker.track({Screen}Event.screenViewed)
	}
}
```

### {Screen}Event.swift — `Sources/Presentation/{Screen}/Tracker/`

```swift
import ChallengeCore

enum {Screen}Event: TrackingEventContract {
	case screenViewed

	var name: String {
		switch self {
		case .screenViewed:
			"{eventPrefix}_viewed"
		}
	}

	var properties: [String: String] {
		switch self {
		case .screenViewed:
			[:]
		}
	}
}
```

### {Screen}ViewModelContract.swift — `Sources/Presentation/{Screen}/ViewModels/`

```swift
protocol {Screen}ViewModelContract: AnyObject {
	func didAppear()
}
```

### {Screen}ViewModel.swift — `Sources/Presentation/{Screen}/ViewModels/`

```swift
final class {Screen}ViewModel: {Screen}ViewModelContract {
	// MARK: - Dependencies

	private let navigator: {Screen}NavigatorContract
	private let tracker: {Screen}TrackerContract

	// MARK: - Init

	init(
		navigator: {Screen}NavigatorContract,
		tracker: {Screen}TrackerContract
	) {
		self.navigator = navigator
		self.tracker = tracker
	}

	// MARK: - {Screen}ViewModelContract

	func didAppear() {
		tracker.trackScreenViewed()
	}
}
```

### {Screen}View.swift — `Sources/Presentation/{Screen}/Views/`

```swift
import ChallengeDesignSystem
import SwiftUI

struct {Screen}View<ViewModel: {Screen}ViewModelContract>: View {
	// MARK: - Properties

	@State private var viewModel: ViewModel

	// MARK: - Init

	init(viewModel: ViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	// MARK: - Body

	var body: some View {
		Text("{Feature}")
			.onFirstAppear {
				viewModel.didAppear()
			}
	}
}

/*
#if DEBUG
#Preview {
	{Screen}View(viewModel: {Screen}ViewModelStub())
}
#endif
*/
```

### {Feature}Container.swift — `Sources/`

Without networking (default for minimal features):

```swift
import ChallengeCore

struct {Feature}Container {
	// MARK: - Dependencies

	private let tracker: any TrackerContract

	// MARK: - Init

	init(tracker: any TrackerContract) {
		self.tracker = tracker
	}

	// MARK: - Factories

	func make{Screen}ViewModel(navigator: any NavigatorContract) -> {Screen}ViewModel {
		{Screen}ViewModel(
			navigator: {Screen}Navigator(navigator: navigator),
			tracker: {Screen}Tracker(tracker: tracker)
		)
	}
}
```

With networking (when DataSources/Repositories are added later):

```swift
import ChallengeCore
import ChallengeNetworking

struct {Feature}Container {
	// MARK: - Dependencies

	private let tracker: any TrackerContract

	// MARK: - Repositories

	private let {name}Repository: {Name}RepositoryContract

	// MARK: - Init

	init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
		self.tracker = tracker
		// Container creates specific clients internally — features never receive them
		let graphQLClient = GraphQLClient(httpClient: httpClient)
		let remoteDataSource = {Name}GraphQLDataSource(graphQLClient: graphQLClient)
		let memoryDataSource = {Name}MemoryDataSource()
		self.{name}Repository = {Name}Repository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)
	}

	// MARK: - Factories

	func make{Screen}ViewModel(navigator: any NavigatorContract) -> {Screen}ViewModel {
		{Screen}ViewModel(
			navigator: {Screen}Navigator(navigator: navigator),
			tracker: {Screen}Tracker(tracker: tracker)
		)
	}
}
```

> **Important:** Features always receive `HTTPClientContract` — never specific clients like `GraphQLClientContract`. The Container is responsible for creating transport-specific clients (e.g., `GraphQLClient`, `HTTPClient`) from the `HTTPClientContract`.

### {Feature}Feature.swift — `Sources/`

Without networking:

```swift
import ChallengeCore
import SwiftUI

public struct {Feature}Feature: FeatureContract {
	// MARK: - Dependencies

	private let container: {Feature}Container

	// MARK: - Init

	public init(tracker: any TrackerContract) {
		self.container = {Feature}Container(tracker: tracker)
	}

	// MARK: - FeatureContract

	public var deepLinkHandler: (any DeepLinkHandlerContract)? {
		{Feature}DeepLinkHandler()
	}

	public func makeMainView(navigator: any NavigatorContract) -> AnyView {
		AnyView({Screen}View(viewModel: container.make{Screen}ViewModel(navigator: navigator)))
	}

	public func resolve(
		_ navigation: any NavigationContract,
		navigator: any NavigatorContract
	) -> AnyView? {
		guard let navigation = navigation as? {Feature}IncomingNavigation else {
			return nil
		}
		switch navigation {
		case .main:
			return makeMainView(navigator: navigator)
		}
	}
}
```

With networking (when DataSources/Repositories are added later):

```swift
import ChallengeCore
import ChallengeNetworking
import SwiftUI

public struct {Feature}Feature: FeatureContract {
	// MARK: - Dependencies

	private let container: {Feature}Container

	// MARK: - Init

	public init(httpClient: any HTTPClientContract, tracker: any TrackerContract) {
		self.container = {Feature}Container(httpClient: httpClient, tracker: tracker)
	}

	// MARK: - FeatureContract

	public var deepLinkHandler: (any DeepLinkHandlerContract)? {
		{Feature}DeepLinkHandler()
	}

	public func makeMainView(navigator: any NavigatorContract) -> AnyView {
		AnyView({Screen}View(viewModel: container.make{Screen}ViewModel(navigator: navigator)))
	}

	public func resolve(
		_ navigation: any NavigationContract,
		navigator: any NavigatorContract
	) -> AnyView? {
		guard let navigation = navigation as? {Feature}IncomingNavigation else {
			return nil
		}
		switch navigation {
		case .main:
			return makeMainView(navigator: navigator)
		}
	}
}
```
