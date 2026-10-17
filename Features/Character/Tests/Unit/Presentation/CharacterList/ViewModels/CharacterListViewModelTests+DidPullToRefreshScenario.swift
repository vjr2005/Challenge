import Testing

@testable import ChallengeCharacter

extension CharacterListViewModelTests {
    nonisolated struct DidPullToRefreshScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let charactersPageResult: Result<CharactersPage, CharactersPageError>
            let loadMoreBeforeRefresh: Bool
        }

        struct Expected: Sendable {
            let state: CharacterListViewState
            let refreshErrorDescriptions: [String]
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [Self] = [
            Self(
                testDescription: "On success sets loaded state without tracking error",
                given: Given(charactersPageResult: .success(.stub()), loadMoreBeforeRefresh: false),
                expected: Expected(state: .loaded(.stub()), refreshErrorDescriptions: [])
            ),
            Self(
                testDescription: "On success with empty characters sets empty state",
                given: Given(charactersPageResult: .success(.stub(characters: [])), loadMoreBeforeRefresh: false),
                expected: Expected(state: .empty, refreshErrorDescriptions: [])
            ),
            Self(
                testDescription: "On failure sets error state and tracks refresh error",
                given: Given(charactersPageResult: .failure(.loadFailed()), loadMoreBeforeRefresh: false),
                expected: Expected(
                    state: .error(.loadFailed()),
                    refreshErrorDescriptions: [CharactersPageError.loadFailed().debugDescription]
                )
            ),
            Self(
                testDescription: "After loading more pages resets to page one on success",
                given: Given(charactersPageResult: .success(.stub()), loadMoreBeforeRefresh: true),
                expected: Expected(state: .loaded(.stub()), refreshErrorDescriptions: [])
            )
        ]
    }
}
