import Foundation
import Testing

@testable import ChallengeCharacter

@MainActor
struct CharacterViewModelTests {
	@Test
	func initialStateIsIdle() {
		// Given
		let useCase = GetCharacterUseCaseMock()
		let sut = CharacterViewModel(getCharacterUseCase: useCase)

		// Then
		guard case .idle = sut.state else {
			Issue.record("Expected idle state")
			return
		}
	}

	@Test
	func loadSetsLoadedStateOnSuccess() async {
		// Given
		let expected = Character.stub()
		let useCase = GetCharacterUseCaseMock()
		useCase.result = .success(expected)
		let sut = CharacterViewModel(getCharacterUseCase: useCase)

		// When
		await sut.load(id: 1)

		// Then
		guard case .loaded(let value) = sut.state else {
			Issue.record("Expected loaded state")
			return
		}
		#expect(value == expected)
	}

	@Test
	func loadSetsErrorStateOnFailure() async {
		// Given
		let useCase = GetCharacterUseCaseMock()
		useCase.result = .failure(TestError.network)
		let sut = CharacterViewModel(getCharacterUseCase: useCase)

		// When
		await sut.load(id: 1)

		// Then
		guard case .error = sut.state else {
			Issue.record("Expected error state")
			return
		}
	}

	@Test
	func loadCallsUseCaseWithCorrectId() async {
		// Given
		let useCase = GetCharacterUseCaseMock()
		useCase.result = .success(.stub())
		let sut = CharacterViewModel(getCharacterUseCase: useCase)

		// When
		await sut.load(id: 42)

		// Then
		#expect(useCase.executeCallCount == 1)
		#expect(useCase.lastRequestedId == 42)
	}
}

private enum TestError: Error {
	case network
}
