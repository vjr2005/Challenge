import Foundation

@Observable
final class CharacterListViewModel: CharacterListViewModelContract {
    private let debounceMilliseconds = 300

    private(set) var state: CharacterListViewState = .idle
    var searchQuery: String = "" {
        didSet { searchQueryDidChange() }
    }

    private let getCharactersUseCase: GetCharactersUseCaseContract
    private let navigator: CharacterListNavigatorContract
    private var currentPage = 1
    private var isLoadingMore = false
    private var searchTask: Task<Void, Never>?

    init(getCharactersUseCase: GetCharactersUseCaseContract, navigator: CharacterListNavigatorContract) {
        self.getCharactersUseCase = getCharactersUseCase
        self.navigator = navigator
    }

    func load() async {
        state = .loading
        currentPage = 1
        await fetchCharacters()
    }

    func loadMore() async {
        guard case .loaded(let page) = state,
              page.hasNextPage,
              !isLoadingMore else {
            return
        }

        isLoadingMore = true
        currentPage += 1
        await fetchMoreCharacters(existingPage: page)
        isLoadingMore = false
    }

    func didSelect(_ character: Character) {
        navigator.navigateToDetail(id: character.id)
    }
}

// MARK: - Private

private extension CharacterListViewModel {
    var normalizedQuery: String? {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }

    func searchQueryDidChange() {
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(debounceMilliseconds))
            if !Task.isCancelled {
                await load()
            }
        }
    }

    func fetchCharacters() async {
        do {
            let result = try await getCharactersUseCase.execute(page: currentPage, query: normalizedQuery)
            if result.characters.isEmpty {
                state = .empty
            } else {
                state = .loaded(result)
            }
        } catch {
            state = .error(error)
        }
    }

    func fetchMoreCharacters(existingPage: CharactersPage) async {
        do {
            let result = try await getCharactersUseCase.execute(page: currentPage, query: normalizedQuery)
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
