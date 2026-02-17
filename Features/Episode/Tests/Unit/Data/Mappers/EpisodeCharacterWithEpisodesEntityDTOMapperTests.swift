import Foundation
import Testing

@testable import ChallengeEpisode

@Suite(.timeLimit(.minutes(1)))
struct EpisodeCharacterWithEpisodesEntityDTOMapperTests {
	// MARK: - Properties

	private let sut = EpisodeCharacterWithEpisodesEntityDTOMapper()

	// MARK: - Character Mapping

	@Test("Maps character identifier from entity to string")
	func mapsCharacterIdentifier() {
		// Given
		let entity = makeEntity()

		// When
		let result = sut.map(entity)

		// Then
		#expect(result.id == "1")
	}

	@Test("Maps character name from entity to DTO")
	func mapsCharacterName() {
		// Given
		let entity = makeEntity()

		// When
		let result = sut.map(entity)

		// Then
		#expect(result.name == "Rick Sanchez")
	}

	@Test("Maps character image from entity to DTO")
	func mapsCharacterImage() {
		// Given
		let entity = makeEntity()

		// When
		let result = sut.map(entity)

		// Then
		#expect(result.image == "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
	}

	// MARK: - Episode Mapping

	@Test("Maps episodes from entity to DTO")
	func mapsEpisodes() {
		// Given
		let entity = makeEntity()

		// When
		let result = sut.map(entity)

		// Then
		#expect(result.episodes.count == 2)
	}

	@Test("Maps episode properties from entity to DTO")
	func mapsEpisodeProperties() {
		// Given
		let entity = makeEntity()

		// When
		let result = sut.map(entity)

		// Then
		#expect(result.episodes[0].id == "1")
		#expect(result.episodes[0].name == "Pilot")
		#expect(result.episodes[0].airDate == "December 2, 2013")
		#expect(result.episodes[0].episode == "S01E01")
	}

	// MARK: - Nested Character Mapping

	@Test("Maps nested characters within episodes")
	func mapsNestedCharacters() {
		// Given
		let entity = makeEntity()

		// When
		let result = sut.map(entity)

		// Then
		#expect(result.episodes[0].characters.count == 2)
		#expect(result.episodes[0].characters[0].id == "1")
		#expect(result.episodes[0].characters[0].name == "Rick Sanchez")
		#expect(result.episodes[0].characters[0].image == "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
	}

	// MARK: - Sorting

	@Test("Sorts episodes by identifier in ascending order")
	func sortsEpisodesByIdentifier() {
		// Given
		let entity = EpisodeCharacterWithEpisodesEntity(
			identifier: 1,
			name: "Rick Sanchez",
			image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
			episodes: [
				EpisodeEntity(
					identifier: 3,
					name: "Episode Three",
					airDate: "January 1, 2014",
					episode: "S01E03",
					characters: []
				),
				EpisodeEntity(
					identifier: 1,
					name: "Episode One",
					airDate: "December 2, 2013",
					episode: "S01E01",
					characters: []
				)
			]
		)

		// When
		let result = sut.map(entity)

		// Then
		#expect(result.episodes[0].id == "1")
		#expect(result.episodes[1].id == "3")
	}

	@Test("Sorts nested characters by identifier in ascending order")
	func sortsNestedCharactersByIdentifier() {
		// Given
		let entity = EpisodeCharacterWithEpisodesEntity(
			identifier: 1,
			name: "Rick Sanchez",
			image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
			episodes: [
				EpisodeEntity(
					identifier: 1,
					name: "Pilot",
					airDate: "December 2, 2013",
					episode: "S01E01",
					characters: [
						EpisodeCharacterEntity(identifier: 3, name: "Summer Smith", image: "https://example.com/3.jpeg"),
						EpisodeCharacterEntity(identifier: 1, name: "Rick Sanchez", image: "https://example.com/1.jpeg")
					]
				)
			]
		)

		// When
		let result = sut.map(entity)

		// Then
		#expect(result.episodes[0].characters[0].id == "1")
		#expect(result.episodes[0].characters[1].id == "3")
	}

	// MARK: - Round-Trip Consistency

	@Test("DTO to entity to DTO produces equivalent result")
	func roundTripConsistency() {
		// Given
		let originalDTO = EpisodeCharacterWithEpisodesDTO(
			id: "1",
			name: "Rick Sanchez",
			image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
			episodes: [
				EpisodeDTO(
					id: "1",
					name: "Pilot",
					airDate: "December 2, 2013",
					episode: "S01E01",
					characters: [
						EpisodeCharacterDTO(id: "1", name: "Rick Sanchez", image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"),
						EpisodeCharacterDTO(id: "2", name: "Morty Smith", image: "https://rickandmortyapi.com/api/character/avatar/2.jpeg")
					]
				),
				EpisodeDTO(
					id: "2",
					name: "Lawnmower Dog",
					airDate: "December 9, 2013",
					episode: "S01E02",
					characters: [
						EpisodeCharacterDTO(id: "1", name: "Rick Sanchez", image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
					]
				)
			]
		)
		let entityMapper = EpisodeCharacterWithEpisodesEntityMapper()

		// When
		let entity = entityMapper.map(originalDTO)
		let result = sut.map(entity)

		// Then
		#expect(result == originalDTO)
	}
}

// MARK: - Private

private extension EpisodeCharacterWithEpisodesEntityDTOMapperTests {
	func makeEntity() -> EpisodeCharacterWithEpisodesEntity {
		EpisodeCharacterWithEpisodesEntity(
			identifier: 1,
			name: "Rick Sanchez",
			image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
			episodes: [
				EpisodeEntity(
					identifier: 1,
					name: "Pilot",
					airDate: "December 2, 2013",
					episode: "S01E01",
					characters: [
						EpisodeCharacterEntity(
							identifier: 1,
							name: "Rick Sanchez",
							image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"
						),
						EpisodeCharacterEntity(
							identifier: 2,
							name: "Morty Smith",
							image: "https://rickandmortyapi.com/api/character/avatar/2.jpeg"
						)
					]
				),
				EpisodeEntity(
					identifier: 2,
					name: "Lawnmower Dog",
					airDate: "December 9, 2013",
					episode: "S01E02",
					characters: [
						EpisodeCharacterEntity(
							identifier: 1,
							name: "Rick Sanchez",
							image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"
						)
					]
				)
			]
		)
	}
}
