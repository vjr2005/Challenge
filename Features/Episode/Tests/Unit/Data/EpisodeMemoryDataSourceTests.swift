import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeEpisode

@Suite(.timeLimit(.minutes(1)))
struct EpisodeMemoryDataSourceTests {
	// MARK: - Properties

	private let sut = EpisodeMemoryDataSource()

	// MARK: - Get

	@Test("Returns nil when no episodes cached for character")
	func returnsNilWhenNoCachedEpisodes() async {
		// When
		let result = await sut.getEpisodes(characterIdentifier: 1)

		// Then
		#expect(result == nil)
	}

	@Test("Returns cached episodes for character")
	func returnsCachedEpisodes() async throws {
		// Given
		let dto: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		await sut.saveEpisodes(dto, characterIdentifier: 1)

		// When
		let result = await sut.getEpisodes(characterIdentifier: 1)

		// Then
		#expect(result == dto)
	}

	@Test("Returns nil for different character identifier")
	func returnsNilForDifferentCharacterIdentifier() async throws {
		// Given
		let dto: EpisodeCharacterWithEpisodesDTO = try loadJSON("episode_character_with_episodes")
		await sut.saveEpisodes(dto, characterIdentifier: 1)

		// When
		let result = await sut.getEpisodes(characterIdentifier: 2)

		// Then
		#expect(result == nil)
	}

	// MARK: - Save

	@Test("Overwrites previous episodes for same character")
	func overwritesPreviousEpisodes() async {
		// Given
		let firstDTO = EpisodeCharacterWithEpisodesDTO(
			id: "1",
			name: "Rick",
			image: "https://example.com/rick.jpeg",
			episodes: []
		)
		let secondDTO = EpisodeCharacterWithEpisodesDTO(
			id: "1",
			name: "Rick Sanchez",
			image: "https://example.com/rick-updated.jpeg",
			episodes: []
		)
		await sut.saveEpisodes(firstDTO, characterIdentifier: 1)

		// When
		await sut.saveEpisodes(secondDTO, characterIdentifier: 1)
		let result = await sut.getEpisodes(characterIdentifier: 1)

		// Then
		#expect(result == secondDTO)
	}
}

// MARK: - Private

private extension EpisodeMemoryDataSourceTests {
	func loadJSON<T: Decodable>(_ filename: String) throws -> T {
		try Bundle.module.loadJSON(filename)
	}
}
