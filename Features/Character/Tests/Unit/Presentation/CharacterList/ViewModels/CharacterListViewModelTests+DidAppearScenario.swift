import Testing

@testable import ChallengeCharacter

extension CharacterListViewModelTests {
    nonisolated struct DidAppearScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let charactersPageResult: Result<CharactersPage, CharactersPageError>
            let recentSearches: [String]
            let searchQuery: String
        }

        struct Expected: Sendable {
            let state: CharacterListViewState
            let fetchErrorDescriptions: [String]
            let recentSearches: [String]
            let getCharactersPageExecuteCallCount: Int
            let lastRequestedPage: Int?
            let searchCharactersPageExecuteCallCount: Int
            let searchFilterName: String?
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [Self] = [
            Self(
                testDescription: "On success sets loaded state without tracking error",
                given: Given(charactersPageResult: .success(.stub()), recentSearches: [], searchQuery: ""),
                expected: Expected(
                    state: .loaded(.stub()),
                    fetchErrorDescriptions: [],
                    recentSearches: [],
                    getCharactersPageExecuteCallCount: 1,
                    lastRequestedPage: 1,
                    searchCharactersPageExecuteCallCount: 0,
                    searchFilterName: nil
                )
            ),
            Self(
                testDescription: "On success with empty characters sets empty state",
                given: Given(charactersPageResult: .success(.stub(characters: [])), recentSearches: [], searchQuery: ""),
                expected: Expected(
                    state: .empty,
                    fetchErrorDescriptions: [],
                    recentSearches: [],
                    getCharactersPageExecuteCallCount: 1,
                    lastRequestedPage: 1,
                    searchCharactersPageExecuteCallCount: 0,
                    searchFilterName: nil
                )
            ),
            Self(
                testDescription: "On failure sets error state and tracks fetch error",
                given: Given(charactersPageResult: .failure(.loadFailed()), recentSearches: [], searchQuery: ""),
                expected: Expected(
                    state: .error(.loadFailed()),
                    fetchErrorDescriptions: [CharactersPageError.loadFailed().debugDescription],
                    recentSearches: [],
                    getCharactersPageExecuteCallCount: 1,
                    lastRequestedPage: 1,
                    searchCharactersPageExecuteCallCount: 0,
                    searchFilterName: nil
                )
            ),
            Self(
                testDescription: "On success loads recent searches",
                given: Given(charactersPageResult: .success(.stub()), recentSearches: ["Rick", "Morty"], searchQuery: ""),
                expected: Expected(
                    state: .loaded(.stub()),
                    fetchErrorDescriptions: [],
                    recentSearches: ["Rick", "Morty"],
                    getCharactersPageExecuteCallCount: 1,
                    lastRequestedPage: 1,
                    searchCharactersPageExecuteCallCount: 0,
                    searchFilterName: nil
                )
            ),
            Self(
                testDescription: "With search query uses search use case instead of get characters",
                given: Given(charactersPageResult: .success(.stub()), recentSearches: [], searchQuery: "Morty"),
                expected: Expected(
                    state: .loaded(.stub()),
                    fetchErrorDescriptions: [],
                    recentSearches: [],
                    getCharactersPageExecuteCallCount: 0,
                    lastRequestedPage: nil,
                    searchCharactersPageExecuteCallCount: 1,
                    searchFilterName: "Morty"
                )
            )
        ]
    }
}
