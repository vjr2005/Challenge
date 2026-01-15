import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterRepositoryTests {
	@Test
	func getCharacterReturnsTransformedModel() async throws {
		// Given
		let expected = Character.stub()
		let dataSource = CharacterRemoteDataSourceMock()
		dataSource.result = .success(.stub())
		let sut = CharacterRepository(remoteDataSource: dataSource)

		// When
		let value = try await sut.getCharacter(id: 1)

		// Then
		#expect(value == expected)
	}

	@Test
	func getCharacterCallsDataSourceWithCorrectId() async throws {
		// Given
		let dataSource = CharacterRemoteDataSourceMock()
		dataSource.result = .success(.stub())
		let sut = CharacterRepository(remoteDataSource: dataSource)

		// When
		_ = try await sut.getCharacter(id: 42)

		// Then
		#expect(dataSource.fetchCharacterCallCount == 1)
		#expect(dataSource.lastFetchedId == 42)
	}

	@Test
	func getCharacterTransformsDeadStatus() async throws {
		// Given
		let expected = Character.stub(status: .dead)
		let dataSource = CharacterRemoteDataSourceMock()
		dataSource.result = .success(.stub(status: "Dead"))
		let sut = CharacterRepository(remoteDataSource: dataSource)

		// When
		let value = try await sut.getCharacter(id: 1)

		// Then
		#expect(value == expected)
	}

	@Test
	func getCharacterTransformsUnknownStatus() async throws {
		// Given
		let expected = Character.stub(status: .unknown)
		let dataSource = CharacterRemoteDataSourceMock()
		dataSource.result = .success(.stub(status: "InvalidStatus"))
		let sut = CharacterRepository(remoteDataSource: dataSource)

		// When
		let value = try await sut.getCharacter(id: 1)

		// Then
		#expect(value == expected)
	}

	@Test
	func getCharacterPropagatesError() async throws {
		// Given
		let dataSource = CharacterRemoteDataSourceMock()
		dataSource.result = .failure(TestError.network)
		let sut = CharacterRepository(remoteDataSource: dataSource)

		// When / Then
		await #expect(throws: TestError.network) {
			_ = try await sut.getCharacter(id: 1)
		}
	}
}

private enum TestError: Error {
	case network
}
