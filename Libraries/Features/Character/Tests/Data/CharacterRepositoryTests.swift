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
		let value = try await sut.getCharacter(id: 1)

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
		_ = try await sut.getCharacter(id: 1)

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
		let value = try await sut.getCharacter(id: 1)

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
		_ = try await sut.getCharacter(id: 1)
		let cachedValue = await memoryDataSource.getCharacter(id: 1)

		// Then
		#expect(cachedValue == .stub())
		#expect(await memoryDataSource.saveCallCount == 1)
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
		_ = try await sut.getCharacter(id: 42)

		// Then
		#expect(remoteDataSource.fetchCharacterCallCount == 1)
		#expect(remoteDataSource.lastFetchedId == 42)
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
		let value = try await sut.getCharacter(id: 1)

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
		let value = try await sut.getCharacter(id: 1)

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
			_ = try await sut.getCharacter(id: 1)
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
		_ = try? await sut.getCharacter(id: 1)

		// Then
		#expect(await memoryDataSource.saveCallCount == 0)
	}
}

private enum TestError: Error {
	case network
}
