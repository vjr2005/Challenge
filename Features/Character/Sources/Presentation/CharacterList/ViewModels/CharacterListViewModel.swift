import Foundation

@Observable
final class CharacterListViewModel: CharacterListViewModelContract {
    private(set) var state: CharacterListViewState = .idle

    private let getCharactersUseCase: GetCharactersUseCaseContract
    private let navigator: CharacterListNavigatorContract
    private var currentPage = 1
    private var isLoadingMore = false

    init(getCharactersUseCase: GetCharactersUseCaseContract, navigator: CharacterListNavigatorContract) {
        self.getCharactersUseCase = getCharactersUseCase
        self.navigator = navigator
    }

    func load() async {
        state = .loading
        currentPage = 1
        await fetchCharacters(page: currentPage)
    }

    func loadMore() async {
        guard case .loaded(let page) = state,
              page.hasNextPage,
              !isLoadingMore else {
            return
        }

        isLoadingMore = true
        currentPage += 1
        await fetchMoreCharacters(page: currentPage, existingPage: page)
        isLoadingMore = false
    }

    func didSelect(_ character: Character) {
        navigator.navigateToDetail(id: character.id)
    }
}

// MARK: - Private

private extension CharacterListViewModel {
    func fetchCharacters(page: Int) async {
        do {
            let result = try await getCharactersUseCase.execute(page: page, query: nil)
            if result.characters.isEmpty {
                state = .empty
            } else {
                state = .loaded(result)
            }
        } catch {
            state = .error(error)
        }
    }

    func fetchMoreCharacters(page: Int, existingPage: CharactersPage) async {
        do {
            let result = try await getCharactersUseCase.execute(page: page, query: nil)
            let combinedCharacters = existingPage.characters + result.characters
            let updatedPage = CharactersPage(
                characters: combinedCharacters,
                currentPage: result.currentPage,
                totalPages: result.totalPages,
                totalCount: result.totalCount,
                hasNextPage: result.hasNextPage,
                hasPreviousPage: existingPage.hasPreviousPage
            )
            state = .loaded(updatedPage)
        } catch {
            currentPage -= 1
        }
    }
}
