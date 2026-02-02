import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterDetailViewModelTests {
    // MARK: - Properties

    private let identifier = 1
    private let getCharacterDetailUseCaseMock = GetCharacterDetailUseCaseMock()
    private let refreshCharacterDetailUseCaseMock = RefreshCharacterDetailUseCaseMock()
    private let navigatorMock = CharacterDetailNavigatorMock()
    private let sut: CharacterDetailViewModel

    // MARK: - Initialization

    init() {
        sut = CharacterDetailViewModel(
            identifier: identifier,
            getCharacterDetailUseCase: getCharacterDetailUseCaseMock,
            refreshCharacterDetailUseCase: refreshCharacterDetailUseCaseMock,
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
        getCharacterDetailUseCaseMock.result = .success(expected)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test("Load if needed sets error state on failure")
    func loadIfNeededSetsErrorStateOnFailure() async {
        // Given
        getCharacterDetailUseCaseMock.result = .failure(.loadFailed)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    @Test("Load if needed calls use case with correct character identifier")
    func loadIfNeededCallsUseCaseWithCorrectIdentifier() async {
        // Given
        getCharacterDetailUseCaseMock.result = .success(.stub())

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(getCharacterDetailUseCaseMock.executeCallCount == 1)
        #expect(getCharacterDetailUseCaseMock.lastRequestedIdentifier == identifier)
    }

    @Test("Load if needed does nothing when already loaded")
    func loadIfNeededDoesNothingWhenLoaded() async {
        // Given
        let expected = Character.stub()
        getCharacterDetailUseCaseMock.result = .success(expected)
        await sut.loadIfNeeded()
        let callCountAfterFirstLoad = getCharacterDetailUseCaseMock.executeCallCount

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(getCharacterDetailUseCaseMock.executeCallCount == callCountAfterFirstLoad)
    }

    @Test("Load if needed retries when in error state")
    func loadIfNeededRetriesWhenError() async {
        // Given
        getCharacterDetailUseCaseMock.result = .failure(.loadFailed)
        await sut.loadIfNeeded()
        let callCountAfterFirstLoad = getCharacterDetailUseCaseMock.executeCallCount

        // When
        getCharacterDetailUseCaseMock.result = .success(.stub())
        await sut.loadIfNeeded()

        // Then
        #expect(getCharacterDetailUseCaseMock.executeCallCount == callCountAfterFirstLoad + 1)
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
        getCharacterDetailUseCaseMock.result = .success(initialCharacter)
        await sut.loadIfNeeded()
        refreshCharacterDetailUseCaseMock.result = .success(refreshedCharacter)

        // When
        await sut.refresh()

        // Then
        #expect(refreshCharacterDetailUseCaseMock.executeCallCount == 1)
        #expect(sut.state == .loaded(refreshedCharacter))
    }

    @Test("Refresh calls use case with correct character identifier")
    func refreshCallsUseCaseWithCorrectIdentifier() async {
        // Given
        refreshCharacterDetailUseCaseMock.result = .success(.stub())

        // When
        await sut.refresh()

        // Then
        #expect(refreshCharacterDetailUseCaseMock.lastRequestedIdentifier == identifier)
    }

    @Test("Refresh sets error state on failure")
    func refreshSetsErrorStateOnFailure() async {
        // Given
        refreshCharacterDetailUseCaseMock.result = .failure(.loadFailed)

        // When
        await sut.refresh()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    @Test("Refresh keeps loaded state visible during network request")
    func refreshKeepsLoadedStateDuringRequest() async {
        // Given
        let loadedCharacter = Character.stub()
        getCharacterDetailUseCaseMock.result = .success(loadedCharacter)
        await sut.loadIfNeeded()
        refreshCharacterDetailUseCaseMock.result = .success(.stub())

        var statesDuringRefresh: [CharacterDetailViewState] = []
        refreshCharacterDetailUseCaseMock.onExecute = { [weak sut] in
            guard let sut else { return }
            statesDuringRefresh.append(sut.state)
        }

        // When
        await sut.refresh()

        // Then
        #expect(statesDuringRefresh.count == 1)
        #expect(statesDuringRefresh.first == .loaded(loadedCharacter))
    }
}
