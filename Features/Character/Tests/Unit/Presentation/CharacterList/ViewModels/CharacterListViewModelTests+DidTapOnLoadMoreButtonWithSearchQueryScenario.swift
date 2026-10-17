import Testing

@testable import ChallengeCharacter

extension CharacterListViewModelTests {
    nonisolated struct DidTapOnLoadMoreButtonWithSearchQueryScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let charactersPageResult: Result<CharactersPage, CharactersPageError>
            let searchQuery: String
        }

        struct Expected: Sendable {
            let state: CharacterListViewState
            let loadMoreErrorDescriptions: [String]
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [Self] = [
            Self(
                testDescription: "On success appends characters and updates state",
                given: Given(
                    charactersPageResult: .success(.stub(
                        characters: [Character.stub(id: 2)],
                        currentPage: 2,
                        hasNextPage: false
                    )),
                    searchQuery: "Summer"
                ),
                expected: Expected(
                    state: .loaded(.stub(
                        characters: [Character.stub(id: 1), Character.stub(id: 2)],
                        currentPage: 2,
                        hasNextPage: false,
                        hasPreviousPage: false
                    )),
                    loadMoreErrorDescriptions: []
                )
            ),
            Self(
                testDescription: "On failure keeps existing data and tracks load more error",
                given: Given(
                    charactersPageResult: .failure(.loadFailed()),
                    searchQuery: "Summer"
                ),
                expected: Expected(
                    state: .loaded(.stub(
                        characters: [Character.stub(id: 1)],
                        currentPage: 1,
                        hasNextPage: true
                    )),
                    loadMoreErrorDescriptions: [CharactersPageError.loadFailed().debugDescription]
                )
            )
        ]
    }
}
