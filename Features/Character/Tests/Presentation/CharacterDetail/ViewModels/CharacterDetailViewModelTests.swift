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
        let sut = CharacterDetailViewModel(
            identifier: 1,
            getCharacterUseCase: useCaseMock,
            refreshCharacterUseCase: RefreshCharacterUseCaseMock(),
            navigator: navigatorMock
        )

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
        let sut = CharacterDetailViewModel(
            identifier: 1,
            getCharacterUseCase: useCaseMock,
            refreshCharacterUseCase: RefreshCharacterUseCaseMock(),
            navigator: navigatorMock
        )

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
        let sut = CharacterDetailViewModel(
            identifier: 1,
            getCharacterUseCase: useCaseMock,
            refreshCharacterUseCase: RefreshCharacterUseCaseMock(),
            navigator: navigatorMock
        )

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
        let sut = CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: useCaseMock,
            refreshCharacterUseCase: RefreshCharacterUseCaseMock(),
            navigator: navigatorMock
        )

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
        let sut = CharacterDetailViewModel(
            identifier: 1,
            getCharacterUseCase: useCaseMock,
            refreshCharacterUseCase: RefreshCharacterUseCaseMock(),
            navigator: navigatorMock
        )

        // When
        sut.didTapOnBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }

    // MARK: - Refresh

    @Test
    func refreshUpdatesCharacterFromAPI() async {
        // Given
        let initialCharacter = Character.stub(name: "Initial")
        let refreshedCharacter = Character.stub(name: "Refreshed")
        let useCaseMock = GetCharacterUseCaseMock()
        useCaseMock.result = .success(initialCharacter)
        let refreshMock = RefreshCharacterUseCaseMock()
        refreshMock.result = .success(refreshedCharacter)
        let navigatorMock = CharacterDetailNavigatorMock()
        let sut = CharacterDetailViewModel(
            identifier: 1,
            getCharacterUseCase: useCaseMock,
            refreshCharacterUseCase: refreshMock,
            navigator: navigatorMock
        )

        await sut.load()

        // When
        await sut.refresh()

        // Then
        #expect(refreshMock.executeCallCount == 1)
        #expect(sut.state == .loaded(refreshedCharacter))
    }

    @Test
    func refreshCallsUseCaseWithCorrectIdentifier() async {
        // Given
        let identifier = 42
        let refreshMock = RefreshCharacterUseCaseMock()
        refreshMock.result = .success(.stub())
        let sut = CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: GetCharacterUseCaseMock(),
            refreshCharacterUseCase: refreshMock,
            navigator: CharacterDetailNavigatorMock()
        )

        // When
        await sut.refresh()

        // Then
        #expect(refreshMock.lastRequestedIdentifier == identifier)
    }

    @Test
    func refreshSetsErrorStateOnFailure() async {
        // Given
        let refreshMock = RefreshCharacterUseCaseMock()
        refreshMock.result = .failure(.loadFailed)
        let sut = CharacterDetailViewModel(
            identifier: 1,
            getCharacterUseCase: GetCharacterUseCaseMock(),
            refreshCharacterUseCase: refreshMock,
            navigator: CharacterDetailNavigatorMock()
        )

        // When
        await sut.refresh()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }
}
