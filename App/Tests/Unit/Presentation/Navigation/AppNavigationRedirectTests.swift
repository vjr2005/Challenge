import ChallengeCharacter
import ChallengeHome
import Testing

@testable import Challenge

struct AppNavigationRedirectTests {
    // MARK: - Properties

    private let sut = AppNavigationRedirect()

    // MARK: - Tests

    @Test
    func redirectHomeOutgoingCharactersToCharacterList() throws {
        // When
        let result = sut.redirect(HomeOutgoingNavigation.characters)

        // Then
        let characterNavigation = try #require(result as? CharacterIncomingNavigation)
        #expect(characterNavigation == .list)
    }

    @Test
    func redirectUnknownNavigationReturnsNil() {
        // When
        let result = sut.redirect(CharacterIncomingNavigation.list)

        // Then
        #expect(result == nil)
    }

    @Test
    func redirectCharacterDetailReturnsNil() {
        // When
        let result = sut.redirect(CharacterIncomingNavigation.detail(identifier: 1))

        // Then
        #expect(result == nil)
    }
}
