import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterDetailViewModelTests {
    // MARK: - Properties

    private let identifier = 1
    private let useCaseMock = GetCharacterUseCaseMock()
    private let refreshMock = RefreshCharacterUseCaseMock()
    private let navigatorMock = CharacterDetailNavigatorMock()
    private let sut: CharacterDetailViewModel

    // MARK: - Initialization

    init() {
        sut = CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: useCaseMock,
            refreshCharacterUseCase: refreshMock,
            navigator: navigatorMock
        )
    }

    // MARK: - Tests

    @Test("Initial state is idle before loading")
    func initialStateIsIdle() {
        // Then
        #expect(sut.state == .idle)
    }

    @Test("Load sets loaded state with character on success")
    func loadSetsLoadedStateOnSuccess() async {
        // Given
        let expected = Character.stub()
        useCaseMock.result = .success(expected)

        // When
        await sut.load()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test("Load sets error state on failure")
    func loadSetsErrorStateOnFailure() async {
        // Given
        useCaseMock.result = .failure(.loadFailed)

        // When
        await sut.load()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    @Test("Load calls use case with correct character identifier")
    func loadCallsUseCaseWithCorrectIdentifier() async {
        // Given
        useCaseMock.result = .success(.stub())

        // When
        await sut.load()

        // Then
        #expect(useCaseMock.executeCallCount == 1)
        #expect(useCaseMock.lastRequestedIdentifier == identifier)
    }

    @Test("Tap on back navigates back")
    func didTapOnBackCallsNavigatorGoBack() {
        // When
        sut.didTapOnBack()

        // Then
        #expect(navigatorMock.goBackCallCount == 1)
    }

    // MARK: - Refresh

    @Test("Refresh updates character with fresh data from API")
    func refreshUpdatesCharacterFromAPI() async {
        // Given
        let initialCharacter = Character.stub(name: "Initial")
        let refreshedCharacter = Character.stub(name: "Refreshed")
        useCaseMock.result = .success(initialCharacter)
        refreshMock.result = .success(refreshedCharacter)
        await sut.load()

        // When
        await sut.refresh()

        // Then
        #expect(refreshMock.executeCallCount == 1)
        #expect(sut.state == .loaded(refreshedCharacter))
    }

    @Test("Refresh calls use case with correct character identifier")
    func refreshCallsUseCaseWithCorrectIdentifier() async {
        // Given
        refreshMock.result = .success(.stub())

        // When
        await sut.refresh()

        // Then
        #expect(refreshMock.lastRequestedIdentifier == identifier)
    }

    @Test("Refresh sets error state on failure")
    func refreshSetsErrorStateOnFailure() async {
        // Given
        refreshMock.result = .failure(.loadFailed)

        // When
        await sut.refresh()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }
}
