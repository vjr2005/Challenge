import Testing

@testable import ChallengeCharacter

extension CharacterListViewModelTests {
    nonisolated struct DidTapOnLoadMoreButtonWithCharacterFilterScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let charactersPageResult: Result<CharactersPage, CharactersPageError>
            let characterFilter: CharacterFilter
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
                    characterFilter: CharacterFilter(status: .dead)
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
                    characterFilter: CharacterFilter(status: .dead)
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
