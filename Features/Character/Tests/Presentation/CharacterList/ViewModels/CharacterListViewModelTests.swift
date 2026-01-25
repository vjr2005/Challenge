import Foundation
import Testing

@testable import ChallengeCharacter

struct CharacterListViewModelTests {
    // MARK: - Initial State

    @Test
    func initialStateIsIdle() {
        // Given
        let useCaseMock = GetCharactersUseCaseMock()
        let navigatorMock = CharacterListNavigatorMock()
        let sut = CharacterListViewModel(getCharactersUseCase: useCaseMock, navigator: navigatorMock)

        // Then
        #expect(sut.state == .idle)
    }

    // MARK: - Load

    @Test
    func loadSetsLoadedStateOnSuccess() async {
        // Given
        let expected = CharactersPage.stub()
        let useCaseMock = GetCharactersUseCaseMock()
        useCaseMock.result = .success(expected)
        let navigatorMock = CharacterListNavigatorMock()
        let sut = CharacterListViewModel(getCharactersUseCase: useCaseMock, navigator: navigatorMock)

        // When
        await sut.load()

        // Then
        #expect(sut.state == .loaded(expected))
    }

    @Test
    func loadSetsEmptyStateWhenNoCharacters() async {
        // Given
        let emptyPage = CharactersPage.stub(characters: [])
        let useCaseMock = GetCharactersUseCaseMock()
        useCaseMock.result = .success(emptyPage)
        let navigatorMock = CharacterListNavigatorMock()
        let sut = CharacterListViewModel(getCharactersUseCase: useCaseMock, navigator: navigatorMock)

        // When
        await sut.load()

        // Then
        #expect(sut.state == .empty)
    }

    @Test
    func loadSetsErrorStateOnFailure() async {
        // Given
        let useCaseMock = GetCharactersUseCaseMock()
        useCaseMock.result = .failure(TestError.network)
        let navigatorMock = CharacterListNavigatorMock()
        let sut = CharacterListViewModel(getCharactersUseCase: useCaseMock, navigator: navigatorMock)

        // When
        await sut.load()

        // Then
        #expect(sut.state == .error(TestError.network))
    }

    @Test
    func loadCallsUseCaseWithPageOne() async {
        // Given
        let useCaseMock = GetCharactersUseCaseMock()
        useCaseMock.result = .success(.stub())
        let navigatorMock = CharacterListNavigatorMock()
        let sut = CharacterListViewModel(getCharactersUseCase: useCaseMock, navigator: navigatorMock)

        // When
        await sut.load()

        // Then
        #expect(useCaseMock.executeCallCount == 1)
        #expect(useCaseMock.lastRequestedPage == 1)
    }

    // MARK: - Load More

    @Test
    func loadMoreAppendsCharactersToExistingPage() async {
        // Given
        let firstPageCharacters = [Character.stub(id: 1)]
        let secondPageCharacters = [Character.stub(id: 2)]
        let firstPage = CharactersPage.stub(characters: firstPageCharacters, currentPage: 1, hasNextPage: true)
        let secondPage = CharactersPage.stub(characters: secondPageCharacters, currentPage: 2, hasNextPage: false)

        let useCaseMock = GetCharactersUseCaseMock()
        useCaseMock.result = .success(firstPage)
        let navigatorMock = CharacterListNavigatorMock()
        let sut = CharacterListViewModel(getCharactersUseCase: useCaseMock, navigator: navigatorMock)

        await sut.load()
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
        let useCaseMock = GetCharactersUseCaseMock()
        useCaseMock.result = .success(firstPage)
        let navigatorMock = CharacterListNavigatorMock()
        let sut = CharacterListViewModel(getCharactersUseCase: useCaseMock, navigator: navigatorMock)

        await sut.load()

        // When
        await sut.loadMore()

        // Then
        #expect(useCaseMock.lastRequestedPage == 2)
    }

    @Test
    func loadMoreDoesNothingWhenNoNextPage() async {
        // Given
        let lastPage = CharactersPage.stub(hasNextPage: false)
        let useCaseMock = GetCharactersUseCaseMock()
        useCaseMock.result = .success(lastPage)
        let navigatorMock = CharacterListNavigatorMock()
        let sut = CharacterListViewModel(getCharactersUseCase: useCaseMock, navigator: navigatorMock)

        await sut.load()
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
        let useCaseMock = GetCharactersUseCaseMock()
        useCaseMock.result = .success(firstPage)
        let navigatorMock = CharacterListNavigatorMock()
        let sut = CharacterListViewModel(getCharactersUseCase: useCaseMock, navigator: navigatorMock)

        await sut.load()
        useCaseMock.result = .failure(TestError.network)

        // When
        await sut.loadMore()

        // Then
        #expect(sut.state == .loaded(firstPage))
    }

    @Test
    func loadMoreRevertsPageOnError() async {
        // Given
        let firstPage = CharactersPage.stub(currentPage: 1, hasNextPage: true)
        let useCaseMock = GetCharactersUseCaseMock()
        useCaseMock.result = .success(firstPage)
        let navigatorMock = CharacterListNavigatorMock()
        let sut = CharacterListViewModel(getCharactersUseCase: useCaseMock, navigator: navigatorMock)

        await sut.load()
        useCaseMock.result = .failure(TestError.network)
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
        let useCaseMock = GetCharactersUseCaseMock()
        let navigatorMock = CharacterListNavigatorMock()
        let sut = CharacterListViewModel(getCharactersUseCase: useCaseMock, navigator: navigatorMock)

        // When
        sut.didSelect(character)

        // Then
        #expect(navigatorMock.navigateToDetailIds == [42])
    }
}

private enum TestError: Error {
    case network
}
