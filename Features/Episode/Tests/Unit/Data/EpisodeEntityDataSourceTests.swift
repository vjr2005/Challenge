import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeEpisode

@Suite(.timeLimit(.minutes(1)))
struct EpisodeEntityDataSourceTests {
	// MARK: - Properties

	private let sut: EpisodeEntityDataSource

	// MARK: - Initialization

	init() {
		let container = EpisodeModelContainer.create(inMemoryOnly: true)
		sut = EpisodeEntityDataSource(modelContainer: container)
	}

	// MARK: - getEpisodes

	@Test("Returns nil when no episodes cached for character")
	func returnsNilWhenNoCachedEpisodes() async {
		// When
		let result = await sut.getEpisodes(characterIdentifier: 999)

		// Then
		#expect(result == nil)
	}

	@Test("Returns cached episodes after saving")
	func returnsCachedEpisodesAfterSaving() async throws {
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

	// MARK: - saveEpisodes

	@Test("Upserts episodes for same character identifier")
	func upsertsEpisodesForSameCharacter() async {
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

	@Test("Stores episodes for different character identifiers independently")
	func storesEpisodesForDifferentCharacters() async {
		// Given
		let rickDTO = EpisodeCharacterWithEpisodesDTO(
			id: "1",
			name: "Rick Sanchez",
			image: "https://example.com/rick.jpeg",
			episodes: []
		)
		let mortyDTO = EpisodeCharacterWithEpisodesDTO(
			id: "2",
			name: "Morty Smith",
			image: "https://example.com/morty.jpeg",
			episodes: []
		)

		// When
		await sut.saveEpisodes(rickDTO, characterIdentifier: 1)
		await sut.saveEpisodes(mortyDTO, characterIdentifier: 2)

		// Then
		let rick = await sut.getEpisodes(characterIdentifier: 1)
		let morty = await sut.getEpisodes(characterIdentifier: 2)
		#expect(rick == rickDTO)
		#expect(morty == mortyDTO)
	}
}

// MARK: - Private

private extension EpisodeEntityDataSourceTests {
	func loadJSON<T: Decodable>(_ filename: String) throws -> T {
		try Bundle.module.loadJSON(filename)
	}
}
