import ChallengeCoreMocks
import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterDetailViewModelTests {
	@Test
	func initialStateIsIdle() {
		// Given
		let useCase = GetCharacterUseCaseMock()
		let router = RouterMock()
		let sut = CharacterDetailViewModel(identifier: 1, getCharacterUseCase: useCase, router: router)

		// Then
		#expect(sut.state == .idle)
	}

	@Test
	func loadSetsLoadedStateOnSuccess() async {
		// Given
		let expected = Character.stub()
		let useCase = GetCharacterUseCaseMock()
		useCase.result = .success(expected)
		let router = RouterMock()
		let sut = CharacterDetailViewModel(identifier: 1, getCharacterUseCase: useCase, router: router)

		// When
		await sut.load()

		// Then
		#expect(sut.state == .loaded(expected))
	}

	@Test
	func loadSetsErrorStateOnFailure() async {
		// Given
		let useCase = GetCharacterUseCaseMock()
		useCase.result = .failure(TestError.network)
		let router = RouterMock()
		let sut = CharacterDetailViewModel(identifier: 1, getCharacterUseCase: useCase, router: router)

		// When
		await sut.load()

		// Then
		#expect(sut.state == .error(TestError.network))
	}

	@Test
	func loadCallsUseCaseWithCorrectIdentifier() async {
		// Given
		let identifier = 42
		let useCase = GetCharacterUseCaseMock()
		useCase.result = .success(.stub())
		let router = RouterMock()
		let sut = CharacterDetailViewModel(identifier: identifier, getCharacterUseCase: useCase, router: router)

		// When
		await sut.load()

		// Then
		#expect(useCase.executeCallCount == 1)
		#expect(useCase.lastRequestedIdentifier == identifier)
	}

	@Test
	func didTapOnBackCallsRouterGoBack() {
		// Given
		let useCase = GetCharacterUseCaseMock()
		let router = RouterMock()
		let sut = CharacterDetailViewModel(identifier: 1, getCharacterUseCase: useCase, router: router)

		// When
		sut.didTapOnBack()

		// Then
		#expect(router.goBackCallCount == 1)
	}
}

private enum TestError: Error {
	case network
}
