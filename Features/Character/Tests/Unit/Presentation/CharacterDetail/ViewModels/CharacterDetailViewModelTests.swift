import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterDetailViewModelTests {
    // MARK: - Properties

    private let identifier = 1
    private let useCaseMock = GetCharacterUseCaseMock()
    private let navigatorMock = CharacterDetailNavigatorMock()
    private let sut: CharacterDetailViewModel

    // MARK: - Initialization

    init() {
        sut = CharacterDetailViewModel(
            identifier: identifier,
            getCharacterUseCase: useCaseMock,
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
        useCaseMock.result = .success(expected)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test("Load if needed sets error state on failure")
    func loadIfNeededSetsErrorStateOnFailure() async {
        // Given
        useCaseMock.result = .failure(.loadFailed)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    @Test("Load if needed calls use case with correct character identifier")
    func loadIfNeededCallsUseCaseWithCorrectIdentifier() async {
        // Given
        useCaseMock.result = .success(.stub())

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.executeCallCount == 1)
        #expect(useCaseMock.lastRequestedIdentifier == identifier)
    }

    @Test("Load if needed uses localFirst cache policy by default")
    func loadIfNeededUsesLocalFirstCachePolicy() async {
        // Given
        useCaseMock.result = .success(.stub())

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.lastCachePolicy == .localFirst)
    }

    @Test("Load if needed does nothing when already loaded")
    func loadIfNeededDoesNothingWhenLoaded() async {
        // Given
        let expected = Character.stub()
        useCaseMock.result = .success(expected)
        await sut.loadIfNeeded()
        let callCountAfterFirstLoad = useCaseMock.executeCallCount

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.executeCallCount == callCountAfterFirstLoad)
    }

    @Test("Load if needed retries when in error state")
    func loadIfNeededRetriesWhenError() async {
        // Given
        useCaseMock.result = .failure(.loadFailed)
        await sut.loadIfNeeded()
        let callCountAfterFirstLoad = useCaseMock.executeCallCount

        // When
        useCaseMock.result = .success(.stub())
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.executeCallCount == callCountAfterFirstLoad + 1)
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
        await sut.loadIfNeeded()
        useCaseMock.result = .success(refreshedCharacter)

        // When
        await sut.refresh()

        // Then
        #expect(useCaseMock.executeCallCount == 2)
        #expect(sut.state == .loaded(refreshedCharacter))
    }

    @Test("Refresh calls use case with correct character identifier")
    func refreshCallsUseCaseWithCorrectIdentifier() async {
        // Given
        useCaseMock.result = .success(.stub())

        // When
        await sut.refresh()

        // Then
        #expect(useCaseMock.lastRequestedIdentifier == identifier)
    }

    @Test("Refresh uses remoteFirst cache policy")
    func refreshUsesRemoteFirstCachePolicy() async {
        // Given
        useCaseMock.result = .success(.stub())

        // When
        await sut.refresh()

        // Then
        #expect(useCaseMock.lastCachePolicy == .remoteFirst)
    }

    @Test("Refresh sets error state on failure")
    func refreshSetsErrorStateOnFailure() async {
        // Given
        useCaseMock.result = .failure(.loadFailed)

        // When
        await sut.refresh()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }
}
