import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct GetCharactersUseCaseTests {
	// MARK: - Without Query (uses getCharacters)

	@Test
	func executeWithoutQueryReturnsCharactersPage() async throws {
		// Given
		let expected = CharactersPage.stub()
		let repositoryMock = CharacterRepositoryMock()
		repositoryMock.charactersResult = .success(expected)
		let sut = GetCharactersUseCase(repository: repositoryMock)

		// When
		let value = try await sut.execute(page: 1, query: nil)

		// Then
		#expect(value == expected)
	}

	@Test
	func executeWithoutQueryCallsGetCharacters() async throws {
		// Given
		let repositoryMock = CharacterRepositoryMock()
		repositoryMock.charactersResult = .success(.stub())
		let sut = GetCharactersUseCase(repository: repositoryMock)

		// When
		_ = try await sut.execute(page: 5, query: nil)

		// Then
		#expect(repositoryMock.getCharactersCallCount == 1)
		#expect(repositoryMock.lastRequestedPage == 5)
		#expect(repositoryMock.searchCharactersCallCount == 0)
	}

	@Test
	func executeWithEmptyQueryCallsGetCharacters() async throws {
		// Given
		let repositoryMock = CharacterRepositoryMock()
		repositoryMock.charactersResult = .success(.stub())
		let sut = GetCharactersUseCase(repository: repositoryMock)

		// When
		_ = try await sut.execute(page: 1, query: "")

		// Then
		#expect(repositoryMock.getCharactersCallCount == 1)
		#expect(repositoryMock.searchCharactersCallCount == 0)
	}

	@Test
	func executeWithoutQueryPropagatesError() async throws {
		// Given
		let repositoryMock = CharacterRepositoryMock()
		repositoryMock.charactersResult = .failure(.loadFailed)
		let sut = GetCharactersUseCase(repository: repositoryMock)

		// When / Then
		await #expect(throws: CharacterError.loadFailed) {
			_ = try await sut.execute(page: 1, query: nil)
		}
	}

	// MARK: - With Query (uses searchCharacters)

	@Test
	func executeWithQueryReturnsCharactersPage() async throws {
		// Given
		let expected = CharactersPage.stub()
		let repositoryMock = CharacterRepositoryMock()
		repositoryMock.searchResult = .success(expected)
		let sut = GetCharactersUseCase(repository: repositoryMock)

		// When
		let value = try await sut.execute(page: 1, query: "Rick")

		// Then
		#expect(value == expected)
	}

	@Test
	func executeWithQueryCallsSearchCharacters() async throws {
		// Given
		let repositoryMock = CharacterRepositoryMock()
		repositoryMock.searchResult = .success(.stub())
		let sut = GetCharactersUseCase(repository: repositoryMock)

		// When
		_ = try await sut.execute(page: 3, query: "Morty")

		// Then
		#expect(repositoryMock.searchCharactersCallCount == 1)
		#expect(repositoryMock.lastSearchedPage == 3)
		#expect(repositoryMock.lastSearchedQuery == "Morty")
		#expect(repositoryMock.getCharactersCallCount == 0)
	}

	@Test
	func executeWithQueryPropagatesError() async throws {
		// Given
		let repositoryMock = CharacterRepositoryMock()
		repositoryMock.searchResult = .failure(.loadFailed)
		let sut = GetCharactersUseCase(repository: repositoryMock)

		// When / Then
		await #expect(throws: CharacterError.loadFailed) {
			_ = try await sut.execute(page: 1, query: "Rick")
		}
	}
}
