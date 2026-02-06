import Foundation

@Observable
final class CharacterListViewModel: CharacterListViewModelContract {
    private(set) var state: CharacterListViewState = .idle
    private(set) var recentSearches: [String] = []
    var searchQuery: String = "" {
        didSet {
            if searchQuery != oldValue {
                searchQueryDidChange()
            }
        }
    }

    private let getCharactersUseCase: GetCharactersUseCaseContract
    private let refreshCharactersUseCase: RefreshCharactersUseCaseContract
    private let searchCharactersUseCase: SearchCharactersUseCaseContract
    private let getRecentSearchesUseCase: GetRecentSearchesUseCaseContract
    private let saveRecentSearchUseCase: SaveRecentSearchUseCaseContract
    private let deleteRecentSearchUseCase: DeleteRecentSearchUseCaseContract
    private let navigator: CharacterListNavigatorContract
    private let tracker: CharacterListTrackerContract
    private let debounceInterval: Duration
    private var currentPage = 1
    private var isLoadingMore = false
    private(set) var searchTask: Task<Void, Never>?

    init(
        getCharactersUseCase: GetCharactersUseCaseContract,
        refreshCharactersUseCase: RefreshCharactersUseCaseContract,
        searchCharactersUseCase: SearchCharactersUseCaseContract,
        getRecentSearchesUseCase: GetRecentSearchesUseCaseContract,
        saveRecentSearchUseCase: SaveRecentSearchUseCaseContract,
        deleteRecentSearchUseCase: DeleteRecentSearchUseCaseContract,
        navigator: CharacterListNavigatorContract,
        tracker: CharacterListTrackerContract,
        debounceInterval: Duration = .milliseconds(300)
    ) {
        self.getCharactersUseCase = getCharactersUseCase
        self.refreshCharactersUseCase = refreshCharactersUseCase
        self.searchCharactersUseCase = searchCharactersUseCase
        self.getRecentSearchesUseCase = getRecentSearchesUseCase
        self.saveRecentSearchUseCase = saveRecentSearchUseCase
        self.deleteRecentSearchUseCase = deleteRecentSearchUseCase
        self.navigator = navigator
        self.tracker = tracker
        self.debounceInterval = debounceInterval
    }

    func didAppear() async {
        tracker.trackScreenViewed()
        loadRecentSearches()
        await load()
    }

    func didTapOnRetryButton() async {
        tracker.trackRetryButtonTapped()
        await load()
    }

    func didPullToRefresh() async {
        tracker.trackPullToRefreshTriggered()
        await refreshCharacters()
    }

    func didTapOnLoadMoreButton() async {
        guard case .loaded(let page) = state,
              page.hasNextPage,
              !isLoadingMore else {
            return
        }

        tracker.trackLoadMoreButtonTapped()
        isLoadingMore = true
        await fetchMoreCharacters(existingPage: page)
        isLoadingMore = false
    }

    func didSelect(_ character: Character) {
        tracker.trackCharacterSelected(identifier: character.id)
        navigator.navigateToDetail(identifier: character.id)
    }

    func didSelectRecentSearch(_ query: String) async {
        searchQuery = query
        searchTask?.cancel()
        saveRecentSearchUseCase.execute(query: query)
        loadRecentSearches()
        tracker.trackSearchPerformed(query: query)
        await fetchCharacters()
    }

    func didDeleteRecentSearch(_ query: String) {
        deleteRecentSearchUseCase.execute(query: query)
        loadRecentSearches()
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
            try? await Task.sleep(for: debounceInterval)
            if !Task.isCancelled {
                if let query = normalizedQuery {
                    tracker.trackSearchPerformed(query: query)
                    saveRecentSearchUseCase.execute(query: query)
                    loadRecentSearches()
                }
                await fetchCharacters()
            }
        }
    }

    func load() async {
        state = .loading
        await fetchCharacters()
    }

    func fetchCharacters() async {
        do {
            currentPage = 1
            let result: CharactersPage
            if let query = normalizedQuery {
                result = try await searchCharactersUseCase.execute(page: currentPage, query: query)
            } else {
                result = try await getCharactersUseCase.execute(page: currentPage)
            }

            if result.characters.isEmpty {
                state = normalizedQuery != nil ? .emptySearch : .empty
            } else {
                state = .loaded(result)
            }
        } catch {
            state = .error(error)
        }
    }

    func refreshCharacters() async {
        do {
            currentPage = 1
            let result = try await refreshCharactersUseCase.execute(page: currentPage)
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
            currentPage += 1
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

    func loadRecentSearches() {
        recentSearches = getRecentSearchesUseCase.execute()
    }
}
