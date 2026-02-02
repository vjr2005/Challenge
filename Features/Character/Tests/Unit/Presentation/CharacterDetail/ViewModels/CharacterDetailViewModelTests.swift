import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterDetailViewModelTests {
    // MARK: - Properties

    private let identifier = 1
    private let getCharacterUseCaseMock = GetCharacterUseCaseMock()
    private let refreshCharacterUseCaseMock = RefreshCharacterUseCaseMock()
    private let navigatorMock = CharacterDetailNavigatorMock()
    private let sut: CharacterDetailViewModel

    // MARK: - Initialization

    init() {
        sut = CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: getCharacterUseCaseMock,
            refreshCharacterUseCase: refreshCharacterUseCaseMock,
            navigator: navigatorMock
        )
    }

    // MARK: - Tests

    @Test("Initial state is idle before loading")
    func initialStateIsIdle() {
        // Then
        #expect(sut.state == .idle)
    }

    @Test("Load if needed sets loaded state with character on success")
    func loadIfNeededSetsLoadedStateOnSuccess() async {
        // Given
        let expected = Character.stub()
        getCharacterUseCaseMock.result = .success(expected)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test("Load if needed sets error state on failure")
    func loadIfNeededSetsErrorStateOnFailure() async {
        // Given
        getCharacterUseCaseMock.result = .failure(.loadFailed)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    @Test("Load if needed calls use case with correct character identifier")
    func loadIfNeededCallsUseCaseWithCorrectIdentifier() async {
        // Given
        getCharacterUseCaseMock.result = .success(.stub())

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(getCharacterUseCaseMock.executeCallCount == 1)
        #expect(getCharacterUseCaseMock.lastRequestedIdentifier == identifier)
    }

    @Test("Load if needed does nothing when already loaded")
    func loadIfNeededDoesNothingWhenLoaded() async {
        // Given
        let expected = Character.stub()
        getCharacterUseCaseMock.result = .success(expected)
        await sut.loadIfNeeded()
        let callCountAfterFirstLoad = getCharacterUseCaseMock.executeCallCount

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(getCharacterUseCaseMock.executeCallCount == callCountAfterFirstLoad)
    }

    @Test("Load if needed retries when in error state")
    func loadIfNeededRetriesWhenError() async {
        // Given
        getCharacterUseCaseMock.result = .failure(.loadFailed)
        await sut.loadIfNeeded()
        let callCountAfterFirstLoad = getCharacterUseCaseMock.executeCallCount

        // When
        getCharacterUseCaseMock.result = .success(.stub())
        await sut.loadIfNeeded()

        // Then
        #expect(getCharacterUseCaseMock.executeCallCount == callCountAfterFirstLoad + 1)
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
        getCharacterUseCaseMock.result = .success(initialCharacter)
        await sut.loadIfNeeded()
        refreshCharacterUseCaseMock.result = .success(refreshedCharacter)

        // When
        await sut.refresh()

        // Then
        #expect(refreshCharacterUseCaseMock.executeCallCount == 1)
        #expect(sut.state == .loaded(refreshedCharacter))
    }

    @Test("Refresh calls use case with correct character identifier")
    func refreshCallsUseCaseWithCorrectIdentifier() async {
        // Given
        refreshCharacterUseCaseMock.result = .success(.stub())

        // When
        await sut.refresh()

        // Then
        #expect(refreshCharacterUseCaseMock.lastRequestedIdentifier == identifier)
    }

    @Test("Refresh sets error state on failure")
    func refreshSetsErrorStateOnFailure() async {
        // Given
        refreshCharacterUseCaseMock.result = .failure(.loadFailed)

        // When
        await sut.refresh()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }
}
