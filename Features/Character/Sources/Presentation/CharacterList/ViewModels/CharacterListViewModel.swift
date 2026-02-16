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

    var activeFilterCount: Int {
        characterFilter.activeFilterCount
    }

    func applyCharacterFilters(_ filter: CharacterFilter) async {
        characterFilter = filter
        await fetchCharacters()
    }

    private let getCharactersPageUseCase: GetCharactersPageUseCaseContract
    private let refreshCharactersPageUseCase: RefreshCharactersPageUseCaseContract
    private let searchCharactersPageUseCase: SearchCharactersPageUseCaseContract
    private let getRecentSearchesUseCase: GetRecentSearchesUseCaseContract
    private let saveRecentSearchUseCase: SaveRecentSearchUseCaseContract
    private let deleteRecentSearchUseCase: DeleteRecentSearchUseCaseContract
    private let navigator: CharacterListNavigatorContract
    private let tracker: CharacterListTrackerContract
    private var characterFilter = CharacterFilter.empty
    private let debounceInterval: Duration
    private var currentPage = 1
    private var isLoadingMore = false
    private(set) var searchTask: Task<Void, Never>?

    init(
        getCharactersPageUseCase: GetCharactersPageUseCaseContract,
        refreshCharactersPageUseCase: RefreshCharactersPageUseCaseContract,
        searchCharactersPageUseCase: SearchCharactersPageUseCaseContract,
        getRecentSearchesUseCase: GetRecentSearchesUseCaseContract,
        saveRecentSearchUseCase: SaveRecentSearchUseCaseContract,
        deleteRecentSearchUseCase: DeleteRecentSearchUseCaseContract,
        navigator: CharacterListNavigatorContract,
        tracker: CharacterListTrackerContract,
        debounceInterval: Duration = .milliseconds(300)
    ) {
        self.getCharactersPageUseCase = getCharactersPageUseCase
        self.refreshCharactersPageUseCase = refreshCharactersPageUseCase
        self.searchCharactersPageUseCase = searchCharactersPageUseCase
        self.getRecentSearchesUseCase = getRecentSearchesUseCase
        self.saveRecentSearchUseCase = saveRecentSearchUseCase
        self.deleteRecentSearchUseCase = deleteRecentSearchUseCase
        self.navigator = navigator
        self.tracker = tracker
        self.debounceInterval = debounceInterval
    }

    func didAppear() async {
        tracker.trackScreenViewed()
        await loadRecentSearches()
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
        await saveRecentSearchUseCase.execute(query: query)
        await loadRecentSearches()
        tracker.trackSearchPerformed(query: query)
        await fetchCharacters()
    }

    func didDeleteRecentSearch(_ query: String) async {
        await deleteRecentSearchUseCase.execute(query: query)
        await loadRecentSearches()
    }

    func didTapCharacterFilterButton() {
        tracker.trackCharacterFilterButtonTapped()
        navigator.presentCharacterFilter(delegate: self)
    }
}

// MARK: - CharacterFilterDelegate

extension CharacterListViewModel: CharacterFilterDelegate {
    var currentFilter: CharacterFilter { characterFilter }

    func didApplyFilter(_ filter: CharacterFilter) {
        Task { await applyCharacterFilters(filter) }
    }
}

// MARK: - Private

private extension CharacterListViewModel {
    var normalizedQuery: String? {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }

    var effectiveFilter: CharacterFilter {
        var filter = characterFilter
        filter.name = normalizedQuery
        return filter
    }

    func searchQueryDidChange() {
        searchTask?.cancel()
        searchTask = Task { [weak self, debounceInterval] in
            try? await Task.sleep(for: debounceInterval)
            guard let self, !Task.isCancelled else { return }
            if let name = normalizedQuery {
                tracker.trackSearchPerformed(query: name)
                await saveRecentSearchUseCase.execute(query: name)
                await loadRecentSearches()
            }
            await fetchCharacters()
        }
    }

    func load() async {
        state = .loading
        await fetchCharacters()
    }

    func fetchCharacters() async {
        do {
            currentPage = 1
            let filter = effectiveFilter
            let result: CharactersPage
            if filter.isEmpty {
                result = try await getCharactersPageUseCase.execute(page: currentPage)
            } else {
                result = try await searchCharactersPageUseCase.execute(page: currentPage, filter: filter)
            }

            if result.characters.isEmpty {
                state = filter.isEmpty ? .empty : .emptySearch
            } else {
                state = .loaded(result)
            }
        } catch {
            guard !Task.isCancelled else { return }
            tracker.trackFetchError(description: error.debugDescription)
            state = .error(error)
        }
    }

    func refreshCharacters() async {
        do {
            currentPage = 1
            let result = try await refreshCharactersPageUseCase.execute(page: currentPage)
            if result.characters.isEmpty {
                state = .empty
            } else {
                state = .loaded(result)
            }
        } catch {
            tracker.trackRefreshError(description: error.debugDescription)
            state = .error(error)
        }
    }

    func fetchMoreCharacters(existingPage: CharactersPage) async {
        do {
            currentPage += 1
            let filter = effectiveFilter
            let result: CharactersPage
            if filter.isEmpty {
                result = try await getCharactersPageUseCase.execute(page: currentPage)
            } else {
                result = try await searchCharactersPageUseCase.execute(page: currentPage, filter: filter)
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
            tracker.trackLoadMoreError(description: error.debugDescription)
            currentPage -= 1
        }
    }

    func loadRecentSearches() async {
        recentSearches = await getRecentSearchesUseCase.execute()
    }
}
