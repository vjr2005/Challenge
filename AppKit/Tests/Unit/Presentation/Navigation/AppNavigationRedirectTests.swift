import ChallengeCharacter
import ChallengeEpisode
import ChallengeHome
import Testing

@testable import ChallengeAppKit

struct AppNavigationRedirectTests {
	// MARK: - Properties

	private let sut = AppNavigationRedirect()

	// MARK: - Tests

	@Test("Redirects home outgoing characters navigation to character list")
	func redirectHomeOutgoingCharactersToCharacterList() throws {
		// When
		let result = sut.redirect(HomeOutgoingNavigation.characters)

		// Then
		let characterNavigation = try #require(result as? CharacterIncomingNavigation)
		#expect(characterNavigation == .list)
	}

	@Test("Redirect returns nil for unknown navigation type")
	func redirectUnknownNavigationReturnsNil() {
		// When
		let result = sut.redirect(CharacterIncomingNavigation.list)

		// Then
		#expect(result == nil)
	}

	@Test("Redirect returns nil for character detail navigation")
	func redirectCharacterDetailReturnsNil() {
		// When
		let result = sut.redirect(CharacterIncomingNavigation.detail(identifier: 1))

		// Then
		#expect(result == nil)
	}

	@Test("Redirects character outgoing episodes navigation to episode character episodes")
	func redirectCharacterOutgoingEpisodesToEpisodeCharacterEpisodes() throws {
		// Given
		let characterIdentifier = 42

		// When
		let result = sut.redirect(CharacterOutgoingNavigation.episodes(characterIdentifier: characterIdentifier))

		// Then
		let episodeNavigation = try #require(result as? EpisodeIncomingNavigation)
		#expect(episodeNavigation == .characterEpisodes(characterIdentifier: characterIdentifier))
	}
}
