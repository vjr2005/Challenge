import Testing

@testable import ChallengeCharacter

extension CharacterListViewModelTests {
    nonisolated struct DidTapOnRetryButtonScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let charactersPageResult: Result<CharactersPage, CharactersPageError>
        }

        struct Expected: Sendable {
            let state: CharacterListViewState
            let fetchErrorDescriptions: [String]
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [Self] = [
            Self(
                testDescription: "On success sets loaded state without tracking error",
                given: Given(charactersPageResult: .success(.stub())),
                expected: Expected(state: .loaded(.stub()), fetchErrorDescriptions: [])
            ),
            Self(
                testDescription: "On failure sets error state and tracks fetch error",
                given: Given(charactersPageResult: .failure(.loadFailed())),
                expected: Expected(
                    state: .error(.loadFailed()),
                    fetchErrorDescriptions: [CharactersPageError.loadFailed().debugDescription]
                )
            )
        ]
    }
}
