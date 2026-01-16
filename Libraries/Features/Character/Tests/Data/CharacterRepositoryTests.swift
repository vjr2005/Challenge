import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterRepositoryTests {
	// MARK: - Cache Hit Tests

	@Test
	func returnsCachedCharacterWhenAvailable() async throws {
		// Given
		let expected = Character.stub()
		let remoteDataSource = CharacterRemoteDataSourceMock()
		let memoryDataSource = CharacterMemoryDataSourceMock()
		await memoryDataSource.saveCharacter(.stub())
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When
		let value = try await sut.getCharacter(identifier: 1)

		// Then
		#expect(value == expected)
	}

	@Test
	func doesNotCallRemoteWhenCacheHit() async throws {
		// Given
		let remoteDataSource = CharacterRemoteDataSourceMock()
		let memoryDataSource = CharacterMemoryDataSourceMock()
		await memoryDataSource.saveCharacter(.stub())
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When
		_ = try await sut.getCharacter(identifier: 1)

		// Then
		#expect(remoteDataSource.fetchCharacterCallCount == 0)
	}

	// MARK: - Cache Miss Tests

	@Test
	func fetchesFromRemoteWhenCacheMiss() async throws {
		// Given
		let expected = Character.stub()
		let remoteDataSource = CharacterRemoteDataSourceMock()
		remoteDataSource.result = .success(.stub())
		let memoryDataSource = CharacterMemoryDataSourceMock()
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When
		let value = try await sut.getCharacter(identifier: 1)

		// Then
		#expect(value == expected)
		#expect(remoteDataSource.fetchCharacterCallCount == 1)
	}

	@Test
	func savesToCacheAfterRemoteFetch() async throws {
		// Given
		let remoteDataSource = CharacterRemoteDataSourceMock()
		remoteDataSource.result = .success(.stub())
		let memoryDataSource = CharacterMemoryDataSourceMock()
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When
		_ = try await sut.getCharacter(identifier: 1)
		let cachedValue = await memoryDataSource.getCharacter(identifier: 1)

		// Then
		#expect(cachedValue == .stub())
		#expect(await memoryDataSource.saveCharacterCallCount == 1)
	}

	@Test
	func callsRemoteDataSourceWithCorrectId() async throws {
		// Given
		let remoteDataSource = CharacterRemoteDataSourceMock()
		remoteDataSource.result = .success(.stub())
		let memoryDataSource = CharacterMemoryDataSourceMock()
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When
		_ = try await sut.getCharacter(identifier: 42)

		// Then
		#expect(remoteDataSource.fetchCharacterCallCount == 1)
		#expect(remoteDataSource.lastFetchedIdentifier == 42)
	}

	// MARK: - Transformation Tests

	@Test
	func transformsDeadStatus() async throws {
		// Given
		let expected = Character.stub(status: .dead)
		let remoteDataSource = CharacterRemoteDataSourceMock()
		remoteDataSource.result = .success(.stub(status: "Dead"))
		let memoryDataSource = CharacterMemoryDataSourceMock()
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When
		let value = try await sut.getCharacter(identifier: 1)

		// Then
		#expect(value == expected)
	}

	@Test
	func transformsUnknownStatus() async throws {
		// Given
		let expected = Character.stub(status: .unknown)
		let remoteDataSource = CharacterRemoteDataSourceMock()
		remoteDataSource.result = .success(.stub(status: "InvalidStatus"))
		let memoryDataSource = CharacterMemoryDataSourceMock()
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When
		let value = try await sut.getCharacter(identifier: 1)

		// Then
		#expect(value == expected)
	}

	// MARK: - Error Tests

	@Test
	func propagatesRemoteErrorOnCacheMiss() async throws {
		// Given
		let remoteDataSource = CharacterRemoteDataSourceMock()
		remoteDataSource.result = .failure(TestError.network)
		let memoryDataSource = CharacterMemoryDataSourceMock()
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When / Then
		await #expect(throws: TestError.network) {
			_ = try await sut.getCharacter(identifier: 1)
		}
	}

	@Test
	func doesNotSaveToCacheOnRemoteError() async throws {
		// Given
		let remoteDataSource = CharacterRemoteDataSourceMock()
		remoteDataSource.result = .failure(TestError.network)
		let memoryDataSource = CharacterMemoryDataSourceMock()
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When
		_ = try? await sut.getCharacter(identifier: 1)

		// Then
		#expect(await memoryDataSource.saveCharacterCallCount == 0)
	}

	// MARK: - Get Characters (Paginated) - Cache Hit

	@Test
	func getCharactersReturnsCachedPageWhenAvailable() async throws {
		// Given
		let expected = CharactersPage.stub()
		let remoteDataSource = CharacterRemoteDataSourceMock()
		let memoryDataSource = CharacterMemoryDataSourceMock()
		await memoryDataSource.setPageStorage([1: .stub()])
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When
		let value = try await sut.getCharacters(page: 1)

		// Then
		#expect(value == expected)
	}

	@Test
	func getCharactersDoesNotCallRemoteWhenCacheHit() async throws {
		// Given
		let remoteDataSource = CharacterRemoteDataSourceMock()
		let memoryDataSource = CharacterMemoryDataSourceMock()
		await memoryDataSource.setPageStorage([1: .stub()])
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When
		_ = try await sut.getCharacters(page: 1)

		// Then
		#expect(remoteDataSource.fetchCharactersCallCount == 0)
	}

	// MARK: - Get Characters (Paginated) - Cache Miss

	@Test
	func getCharactersFetchesFromRemoteWhenCacheMiss() async throws {
		// Given
		let expected = CharactersPage.stub()
		let remoteDataSource = CharacterRemoteDataSourceMock()
		remoteDataSource.charactersResult = .success(.stub())
		let memoryDataSource = CharacterMemoryDataSourceMock()
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When
		let value = try await sut.getCharacters(page: 1)

		// Then
		#expect(value == expected)
		#expect(remoteDataSource.fetchCharactersCallCount == 1)
	}

	@Test
	func getCharactersCallsRemoteWithCorrectPage() async throws {
		// Given
		let remoteDataSource = CharacterRemoteDataSourceMock()
		remoteDataSource.charactersResult = .success(.stub())
		let memoryDataSource = CharacterMemoryDataSourceMock()
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When
		_ = try await sut.getCharacters(page: 5)

		// Then
		#expect(remoteDataSource.fetchCharactersCallCount == 1)
		#expect(remoteDataSource.lastFetchedPage == 5)
	}

	@Test
	func getCharactersSavesPageToCache() async throws {
		// Given
		let characters = [CharacterDTO.stub(id: 1), CharacterDTO.stub(id: 2)]
		let remoteDataSource = CharacterRemoteDataSourceMock()
		remoteDataSource.charactersResult = .success(.stub(results: characters))
		let memoryDataSource = CharacterMemoryDataSourceMock()
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When
		_ = try await sut.getCharacters(page: 1)

		// Then
		#expect(await memoryDataSource.savePageCallCount == 1)
		let cachedPage = await memoryDataSource.getPage(1)
		#expect(cachedPage != nil)
	}

	@Test
	func getCharactersSavesIndividualCharactersToCache() async throws {
		// Given
		let characters = [CharacterDTO.stub(id: 1), CharacterDTO.stub(id: 2)]
		let remoteDataSource = CharacterRemoteDataSourceMock()
		remoteDataSource.charactersResult = .success(.stub(results: characters))
		let memoryDataSource = CharacterMemoryDataSourceMock()
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When
		_ = try await sut.getCharacters(page: 1)

		// Then
		let cached = await memoryDataSource.getAllCharacters()
		#expect(cached.count == 2)
	}

	@Test
	func getCharactersTransformsPaginationInfo() async throws {
		// Given
		let remoteDataSource = CharacterRemoteDataSourceMock()
		remoteDataSource.charactersResult = .success(.stub(
			info: .stub(count: 100, pages: 5, next: "url", prev: nil)
		))
		let memoryDataSource = CharacterMemoryDataSourceMock()
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When
		let value = try await sut.getCharacters(page: 1)

		// Then
		#expect(value.totalCount == 100)
		#expect(value.totalPages == 5)
		#expect(value.hasNextPage == true)
		#expect(value.hasPreviousPage == false)
	}

	// MARK: - Get Characters (Paginated) - Errors

	@Test
	func getCharactersPropagatesRemoteErrorOnCacheMiss() async throws {
		// Given
		let remoteDataSource = CharacterRemoteDataSourceMock()
		remoteDataSource.charactersResult = .failure(TestError.network)
		let memoryDataSource = CharacterMemoryDataSourceMock()
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When / Then
		await #expect(throws: TestError.network) {
			_ = try await sut.getCharacters(page: 1)
		}
	}

	@Test
	func getCharactersDoesNotSaveToCacheOnError() async throws {
		// Given
		let remoteDataSource = CharacterRemoteDataSourceMock()
		remoteDataSource.charactersResult = .failure(TestError.network)
		let memoryDataSource = CharacterMemoryDataSourceMock()
		let sut = CharacterRepository(
			remoteDataSource: remoteDataSource,
			memoryDataSource: memoryDataSource
		)

		// When
		_ = try? await sut.getCharacters(page: 1)

		// Then
		#expect(await memoryDataSource.savePageCallCount == 0)
	}
}

private enum TestError: Error {
	case network
}
