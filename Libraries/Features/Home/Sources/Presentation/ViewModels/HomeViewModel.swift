import ChallengeCharacter
import ChallengeCore
import SwiftUI

@Observable
final class HomeViewModel {
    private let router: RouterContract

    init(router: RouterContract) {
        self.router = router
    }

    func didTapOnCharacterButton() {
        router.navigate(to: CharacterNavigation.list)
    }
}
