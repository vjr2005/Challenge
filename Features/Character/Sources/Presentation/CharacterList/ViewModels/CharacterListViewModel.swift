import Foundation

@Observable
final class CharacterListViewModel: CharacterListViewModelContract {
    private let debounceMilliseconds = 300

    private(set) var state: CharacterListViewState = .idle
    var searchQuery: String = "" {
        didSet {
            if searchQuery != oldValue {
                searchQueryDidChange()
            }
        }
    }

    private let getCharactersUseCase: GetCharactersUseCaseContract
    private let searchCharactersUseCase: SearchCharactersUseCaseContract
    private let navigator: CharacterListNavigatorContract
    private var currentPage = 1
    private var isLoadingMore = false
    private var searchTask: Task<Void, Never>?

    init(
        getCharactersUseCase: GetCharactersUseCaseContract,
        searchCharactersUseCase: SearchCharactersUseCaseContract,
        navigator: CharacterListNavigatorContract
    ) {
        self.getCharactersUseCase = getCharactersUseCase
        self.searchCharactersUseCase = searchCharactersUseCase
        self.navigator = navigator
    }

    func loadIfNeeded() async {
        switch state {
        case .idle, .error:
            await load()
        case .loading, .loaded, .empty:
            break
        }
    }

    func refresh() async {
        state = .loading
        currentPage = 1
        await fetchCharacters(cachePolicy: .remoteFirst)
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
        navigator.navigateToDetail(identifier: character.id)
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

    func load() async {
        state = .loading
        currentPage = 1
        await fetchCharacters()
    }

    func fetchCharacters(cachePolicy: CachePolicy = .localFirst) async {
        do {
            let result: CharactersPage
            if let query = normalizedQuery {
                result = try await searchCharactersUseCase.execute(page: currentPage, query: query)
            } else {
                result = try await getCharactersUseCase.execute(page: currentPage, cachePolicy: cachePolicy)
            }

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
            let result: CharactersPage
            if let query = normalizedQuery {
                result = try await searchCharactersUseCase.execute(page: currentPage, query: query)
            } else {
                result = try await getCharactersUseCase.execute(page: currentPage)
            }

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
