# Navigation Tests

## Navigator Mock

```swift
// Features/{Feature}/Tests/Mocks/{Screen}NavigatorMock.swift
@testable import Challenge{Feature}

final class {Screen}NavigatorMock: {Screen}NavigatorContract {
    private(set) var navigateToDetailIds: [Int] = []
    private(set) var goBackCallCount = 0

    func navigateToDetail(id: Int) {
        navigateToDetailIds.append(id)
    }

    func goBack() {
        goBackCallCount += 1
    }
}
```

---

## Navigator Tests

```swift
// Features/{Feature}/Tests/Presentation/{Screen}/Navigator/{Screen}NavigatorTests.swift
import ChallengeCoreMocks
import Testing

@testable import Challenge{Feature}

struct {Screen}NavigatorTests {
    @Test("Navigate to detail uses correct navigation")
    func navigateToDetailUsesCorrectNavigation() {
        // Given
        let navigatorMock = NavigatorMock()
        let sut = {Screen}Navigator(navigator: navigatorMock)

        // When
        sut.navigateToDetail(id: 42)

        // Then
        let destination = navigatorMock.navigatedDestinations.first as? {Feature}IncomingNavigation
        #expect(destination == .detail(identifier: 42))
    }
}
```

---

## Modal Navigation Tests

```swift
@Test("Present filter presents sheet with correct detents")
func presentFilterPresentsSheet() {
    // Given
    let navigatorMock = NavigatorMock()
    let sut = FilterNavigator(navigator: navigatorMock)

    // When
    sut.presentFilter()

    // Then
    let modal = navigatorMock.presentedModals.first
    let destination = modal?.destination as? FeatureIncomingNavigation
    #expect(destination == .filter)
    #expect(modal?.style == .sheet(detents: [.medium, .large]))
}

@Test("Dismiss calls navigator dismiss")
func dismissCallsNavigatorDismiss() {
    // Given
    let navigatorMock = NavigatorMock()
    let sut = FilterNavigator(navigator: navigatorMock)

    // When
    sut.dismiss()

    // Then
    #expect(navigatorMock.dismissCallCount == 1)
}
```

---

## AppNavigationRedirect Tests

```swift
// App/Tests/Navigation/AppNavigationRedirectTests.swift
import ChallengeCharacter
import ChallengeHome
import Testing

@testable import Challenge

struct AppNavigationRedirectTests {
    @Test("Redirect home outgoing characters to character list")
    func redirectHomeOutgoingCharactersToCharacterList() throws {
        // Given
        let sut = AppNavigationRedirect()

        // When
        let result = sut.redirect(HomeOutgoingNavigation.characters)

        // Then
        let characterNavigation = try #require(result as? CharacterIncomingNavigation)
        #expect(characterNavigation == .list)
    }

    @Test("Redirect unknown navigation returns nil")
    func redirectUnknownNavigationReturnsNil() {
        // Given
        let sut = AppNavigationRedirect()

        // When
        let result = sut.redirect(CharacterIncomingNavigation.list)

        // Then
        #expect(result == nil)
    }
}
```

---

## DeepLinkHandler Tests

```swift
import ChallengeCore
import Foundation
import Testing

@testable import Challenge{Feature}

struct {Feature}DeepLinkHandlerTests {
    @Test("Resolve list path returns list navigation")
    func resolveListPathReturnsListNavigation() throws {
        // Given
        let sut = {Feature}DeepLinkHandler()
        let url = try #require(URL(string: "challenge://{feature}/list"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result as? {Feature}IncomingNavigation == .list)
    }

    @Test("Resolve detail path with valid id returns detail navigation")
    func resolveDetailPathWithValidIdReturnsDetailNavigation() throws {
        // Given
        let sut = {Feature}DeepLinkHandler()
        let url = try #require(URL(string: "challenge://{feature}/detail/42"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result as? {Feature}IncomingNavigation == .detail(identifier: 42))
    }

    @Test("Resolve detail path without id returns nil")
    func resolveDetailPathWithoutIdReturnsNil() throws {
        // Given
        let sut = {Feature}DeepLinkHandler()
        let url = try #require(URL(string: "challenge://{feature}/detail"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result == nil)
    }

    @Test("Resolve unknown path returns nil")
    func resolveUnknownPathReturnsNil() throws {
        // Given
        let sut = {Feature}DeepLinkHandler()
        let url = try #require(URL(string: "challenge://{feature}/unknown"))

        // When
        let result = sut.resolve(url)

        // Then
        #expect(result == nil)
    }
}
```
