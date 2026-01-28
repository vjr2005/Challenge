import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterDetailViewModelTests {
    @Test
    func initialStateIsIdle() {
        // Given
        let useCaseMock = GetCharacterUseCaseMock()
        let navigatorMock = CharacterDetailNavigatorMock()
        let sut = CharacterDetailViewModel(identifier: 1, getCharacterUseCase: useCaseMock, navigator: navigatorMock)

        // Then
        #expect(sut.state == .idle)
    }

    @Test
    func loadSetsLoadedStateOnSuccess() async {
        // Given
        let expected = Character.stub()
        let useCaseMock = GetCharacterUseCaseMock()
        useCaseMock.result = .success(expected)
        let navigatorMock = CharacterDetailNavigatorMock()
        let sut = CharacterDetailViewModel(identifier: 1, getCharacterUseCase: useCaseMock, navigator: navigatorMock)

        // When
        await sut.load()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test
    func loadSetsErrorStateOnFailure() async {
        // Given
        let useCaseMock = GetCharacterUseCaseMock()
        useCaseMock.result = .failure(.loadFailed)
        let navigatorMock = CharacterDetailNavigatorMock()
        let sut = CharacterDetailViewModel(identifier: 1, getCharacterUseCase: useCaseMock, navigator: navigatorMock)

        // When
        await sut.load()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    @Test
    func loadCallsUseCaseWithCorrectIdentifier() async {
        // Given
        let identifier = 42
        let useCaseMock = GetCharacterUseCaseMock()
        useCaseMock.result = .success(.stub())
        let navigatorMock = CharacterDetailNavigatorMock()
        let sut = CharacterDetailViewModel(identifier: identifier, getCharacterUseCase: useCaseMock, navigator: navigatorMock)

        // When
        await sut.load()

        // Then
        #expect(useCaseMock.executeCallCount == 1)
        #expect(useCaseMock.lastRequestedIdentifier == identifier)
    }

    @Test
    func didTapOnBackCallsNavigatorGoBack() {
        // Given
        let useCaseMock = GetCharacterUseCaseMock()
        let navigatorMock = CharacterDetailNavigatorMock()
        let sut = CharacterDetailViewModel(identifier: 1, getCharacterUseCase: useCaseMock, navigator: navigatorMock)

        // When
        sut.didTapOnBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }
}
