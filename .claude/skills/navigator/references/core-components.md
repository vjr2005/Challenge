# Core Navigation Components

All components live in `Libraries/Core/Sources/Navigation/`.

---

## NavigatorContract

```swift
// Libraries/Core/Sources/Navigation/NavigatorContract.swift
import Foundation

public protocol NavigatorContract {
    func navigate(to destination: any NavigationContract)
    func present(_ destination: any NavigationContract, style: ModalPresentationStyle)
    func dismiss()
    func goBack()
}
```

---

## NavigationContract

```swift
// Libraries/Core/Sources/Navigation/Navigation.swift
nonisolated public protocol NavigationContract: Hashable, Sendable {}
nonisolated public protocol IncomingNavigationContract: NavigationContract {}
nonisolated public protocol OutgoingNavigationContract: NavigationContract {}
```

---

## ModalPresentationStyle

```swift
// Libraries/Core/Sources/Navigation/ModalPresentationStyle.swift
import SwiftUI

public enum ModalPresentationStyle: Hashable {
    case sheet(detents: Set<PresentationDetent> = [.large])
    case fullScreenCover
}
```

---

## ModalNavigation

```swift
// Libraries/Core/Sources/Navigation/ModalNavigation.swift
import SwiftUI

public struct ModalNavigation: Identifiable {
    public let id = UUID()
    public let navigation: AnyNavigation
    public let style: ModalPresentationStyle

    public init(navigation: any NavigationContract, style: ModalPresentationStyle) {
        self.navigation = AnyNavigation(navigation)
        self.style = style
    }

    public var detents: Set<PresentationDetent> {
        if case .sheet(let detents) = style {
            return detents
        }
        return []
    }
}
```

---

## NavigationCoordinator

```swift
// Libraries/Core/Sources/Navigation/NavigationCoordinator.swift
import Foundation
import SwiftUI

@Observable
public final class NavigationCoordinator: NavigatorContract {
    public var path = NavigationPath()
    public var sheetNavigation: ModalNavigation?
    public var fullScreenCoverNavigation: ModalNavigation?

    private let redirector: (any NavigationRedirectContract)?
    private let onDismiss: (() -> Void)?

    public init(
        redirector: (any NavigationRedirectContract)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.redirector = redirector
        self.onDismiss = onDismiss
    }

    public func navigate(to destination: any NavigationContract) {
        let resolved = resolveRedirect(destination)
        path.append(AnyNavigation(resolved))
    }

    public func present(_ destination: any NavigationContract, style: ModalPresentationStyle) {
        let resolved = resolveRedirect(destination)
        let modal = ModalNavigation(navigation: resolved, style: style)
        switch style {
        case .sheet:
            sheetNavigation = modal
        case .fullScreenCover:
            fullScreenCoverNavigation = modal
        }
    }

    public func dismiss() {
        if fullScreenCoverNavigation != nil {
            fullScreenCoverNavigation = nil
        } else if sheetNavigation != nil {
            sheetNavigation = nil
        } else {
            onDismiss?()
        }
    }

    public func goBack() {
        guard !path.isEmpty else {
            return
        }
        path.removeLast()
    }

    // MARK: - Private

    private func resolveRedirect(_ destination: any NavigationContract) -> any NavigationContract {
        if destination is any OutgoingNavigationContract {
            if let redirected = redirector?.redirect(destination) {
                return redirected
            }
            return UnknownNavigation.notFound
        }
        return destination
    }
}
```

---

## NavigationRedirectContract

```swift
// Libraries/Core/Sources/Navigation/NavigationRedirectContract.swift
import Foundation

public protocol NavigationRedirectContract: Sendable {
    func redirect(_ navigation: any NavigationContract) -> (any NavigationContract)?
}
```

---

## FeatureContract

```swift
// Libraries/Core/Sources/Feature/Feature.swift
import SwiftUI

public protocol FeatureContract {
    var deepLinkHandler: (any DeepLinkHandlerContract)? { get }
    func makeMainView(navigator: any NavigatorContract) -> AnyView
    func resolve(_ navigation: any NavigationContract, navigator: any NavigatorContract) -> AnyView?
}

public extension FeatureContract {
    var deepLinkHandler: (any DeepLinkHandlerContract)? { nil }
}
```

---

## DeepLinkHandlerContract

```swift
// Libraries/Core/Sources/Navigation/DeepLinkHandler.swift
import Foundation

public protocol DeepLinkHandlerContract: Sendable {
    var scheme: String { get }
    var host: String { get }
    func resolve(_ url: URL) -> (any NavigationContract)?
}
```

---

## NavigatorMock (for testing)

```swift
// Libraries/Core/Mocks/NavigatorMock.swift
import ChallengeCore
import Foundation

public final class NavigatorMock: NavigatorContract {
    public private(set) var navigatedDestinations: [any NavigationContract] = []
    public private(set) var presentedModals: [(destination: any NavigationContract, style: ModalPresentationStyle)] = []
    public private(set) var dismissCallCount = 0
    public private(set) var goBackCallCount = 0

    public init() {}

    public func navigate(to destination: any NavigationContract) {
        navigatedDestinations.append(destination)
    }

    public func present(_ destination: any NavigationContract, style: ModalPresentationStyle) {
        presentedModals.append((destination: destination, style: style))
    }

    public func dismiss() {
        dismissCallCount += 1
    }

    public func goBack() {
        goBackCallCount += 1
    }
}
```
