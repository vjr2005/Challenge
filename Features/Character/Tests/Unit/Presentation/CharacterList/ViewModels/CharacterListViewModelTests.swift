import Foundation
import Testing

@testable import ChallengeCharacter

@Suite(.timeLimit(.minutes(1)))
struct CharacterListViewModelTests {
    // MARK: - Properties

    private let useCaseMock = GetCharactersUseCaseMock()
    private let clearCacheMock = ClearCharactersCacheUseCaseMock()
    private let navigatorMock = CharacterListNavigatorMock()
    private let sut: CharacterListViewModel

    // MARK: - Initialization

    init() {
        sut = CharacterListViewModel(
            getCharactersUseCase: useCaseMock,
            clearCacheUseCase: clearCacheMock,
            navigator: navigatorMock
        )
    }

    // MARK: - Initial State

    @Test
    func initialStateIsIdle() {
        // Then
        #expect(sut.state == .idle)
    }

    // MARK: - Load

    @Test
    func loadSetsLoadedStateOnSuccess() async {
        // Given
        let expected = CharactersPage.stub()
        useCaseMock.result = .success(expected)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test
    func loadSetsEmptyStateWhenNoCharacters() async {
        // Given
        let emptyPage = CharactersPage.stub(characters: [])
        useCaseMock.result = .success(emptyPage)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .empty)
    }

    @Test
    func loadSetsErrorStateOnFailure() async {
        // Given
        useCaseMock.result = .failure(.loadFailed)

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(sut.state == .error(.loadFailed))
    }

    @Test
    func loadCallsUseCaseWithPageOne() async {
        // Given
        useCaseMock.result = .success(.stub())

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.executeCallCount == 1)
        #expect(useCaseMock.lastRequestedPage == 1)
    }

    @Test
    func loadIfNeededDoesNothingWhenLoaded() async {
        // Given
        useCaseMock.result = .success(.stub())
        await sut.loadIfNeeded()
        let callCountAfterFirstLoad = useCaseMock.executeCallCount

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.executeCallCount == callCountAfterFirstLoad)
    }

    @Test
    func loadIfNeededDoesNothingWhenEmpty() async {
        // Given
        let emptyPage = CharactersPage.stub(characters: [])
        useCaseMock.result = .success(emptyPage)
        await sut.loadIfNeeded()
        let callCountAfterFirstLoad = useCaseMock.executeCallCount

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.executeCallCount == callCountAfterFirstLoad)
    }

    @Test
    func loadIfNeededLoadsWhenError() async {
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

    // MARK: - Load More

    @Test
    func loadMoreAppendsCharactersToExistingPage() async {
        // Given
        let firstPageCharacters = [Character.stub(id: 1)]
        let secondPageCharacters = [Character.stub(id: 2)]
        let firstPage = CharactersPage.stub(characters: firstPageCharacters, currentPage: 1, hasNextPage: true)
        let secondPage = CharactersPage.stub(characters: secondPageCharacters, currentPage: 2, hasNextPage: false)
        useCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()
        useCaseMock.result = .success(secondPage)

        // When
        await sut.loadMore()

        // Then
        let expected = CharactersPage.stub(
            characters: [Character.stub(id: 1), Character.stub(id: 2)],
            currentPage: 2,
            hasNextPage: false,
            hasPreviousPage: false
        )
        #expect(sut.state == .loaded(expected))
    }

    @Test
    func loadMoreIncrementsPage() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        useCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()

        // When
        await sut.loadMore()

        // Then
        #expect(useCaseMock.lastRequestedPage == 2)
    }

    @Test
    func loadMoreDoesNothingWhenNoNextPage() async {
        // Given
        let lastPage = CharactersPage.stub(hasNextPage: false)
        useCaseMock.result = .success(lastPage)
        await sut.loadIfNeeded()
        let callCountAfterLoad = useCaseMock.executeCallCount

        // When
        await sut.loadMore()

        // Then
        #expect(useCaseMock.executeCallCount == callCountAfterLoad)
    }

    @Test
    func loadMoreKeepsExistingDataOnError() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        useCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()
        useCaseMock.result = .failure(.loadFailed)

        // When
        await sut.loadMore()

        // Then
        #expect(sut.state == .loaded(firstPage))
    }

    @Test
    func loadMoreRevertsPageOnError() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        useCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()
        useCaseMock.result = .failure(.loadFailed)
        await sut.loadMore()

        // When - retry after error
        useCaseMock.result = .success(CharactersPage.stub(currentPage: 2))
        await sut.loadMore()

        // Then - should request page 2 again, not page 3
        #expect(useCaseMock.lastRequestedPage == 2)
    }

    // MARK: - Navigation

    @Test
    func didSelectNavigatesToCharacterDetail() {
        // Given
        let character = Character.stub(id: 42)

        // When
        sut.didSelect(character)

        // Then
        #expect(navigatorMock.navigateToDetailIds == [42])
    }

    // MARK: - Search

    @Test
    func initialSearchQueryIsEmpty() {
        // Then
        #expect(sut.searchQuery == "")
    }

    @Test
    func searchQueryChangeTriggersLoadAfterDebounce() async throws {
        // Given
        useCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "Rick"
        try await Task.sleep(for: .milliseconds(400))

        // Then
        #expect(useCaseMock.lastRequestedQuery == "Rick")
    }

    @Test
    func rapidSearchQueryChangesOnlyTriggersOneLoad() async throws {
        // Given
        useCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "R"
        try await Task.sleep(for: .milliseconds(100))
        sut.searchQuery = "Ri"
        try await Task.sleep(for: .milliseconds(100))
        sut.searchQuery = "Rick"
        try await Task.sleep(for: .milliseconds(400))

        // Then
        #expect(useCaseMock.executeCallCount == 1)
        #expect(useCaseMock.lastRequestedQuery == "Rick")
    }

    @Test
    func loadUsesCurrentSearchQuery() async {
        // Given
        useCaseMock.result = .success(.stub())
        sut.searchQuery = "Morty"

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.lastRequestedQuery == "Morty")
    }

    @Test
    func loadMoreUsesCurrentSearchQuery() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        useCaseMock.result = .success(firstPage)
        sut.searchQuery = "Summer"
        await sut.loadIfNeeded()

        // When
        await sut.loadMore()

        // Then
        #expect(useCaseMock.lastRequestedQuery == "Summer")
    }

    @Test
    func emptySearchQueryPassesNilToUseCase() async {
        // Given
        useCaseMock.result = .success(.stub())
        sut.searchQuery = ""

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.lastRequestedQuery == nil)
    }

    @Test
    func whitespaceOnlySearchQueryPassesNilToUseCase() async {
        // Given
        useCaseMock.result = .success(.stub())
        sut.searchQuery = "   "

        // When
        await sut.loadIfNeeded()

        // Then
        #expect(useCaseMock.lastRequestedQuery == nil)
    }

    @Test
    func searchQueryChangeResetsToPageOne() async throws {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        let secondPage = CharactersPage.stub(currentPage: 2, hasNextPage: false)
        useCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()
        useCaseMock.result = .success(secondPage)
        await sut.loadMore()

        // When
        sut.searchQuery = "Rick"
        try await Task.sleep(for: .milliseconds(400))

        // Then
        #expect(useCaseMock.lastRequestedPage == 1)
    }

    @Test
    func clearingSearchQueryBeforeDebounceOnlyTriggersOneLoad() async throws {
        // Given
        useCaseMock.result = .success(.stub())

        // When
        sut.searchQuery = "Rick"
        try await Task.sleep(for: .milliseconds(100))
        sut.searchQuery = ""
        try await Task.sleep(for: .milliseconds(400))

        // Then
        #expect(useCaseMock.executeCallCount == 1)
        #expect(useCaseMock.lastRequestedQuery == nil)
    }

    // MARK: - Refresh

    @Test
    func refreshClearsCacheAndReloads() async {
        // Given
        useCaseMock.result = .success(.stub())
        await sut.loadIfNeeded()
        let callCountAfterLoad = useCaseMock.executeCallCount

        // When
        await sut.refresh()

        // Then
        #expect(clearCacheMock.executeCallCount == 1)
        #expect(useCaseMock.executeCallCount == callCountAfterLoad + 1)
    }

    @Test
    func refreshResetsToPageOne() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        let secondPage = CharactersPage.stub(currentPage: 2, hasNextPage: false)
        useCaseMock.result = .success(firstPage)
        await sut.loadIfNeeded()
        useCaseMock.result = .success(secondPage)
        await sut.loadMore()

        // When
        await sut.refresh()

        // Then
        #expect(useCaseMock.lastRequestedPage == 1)
    }
}
