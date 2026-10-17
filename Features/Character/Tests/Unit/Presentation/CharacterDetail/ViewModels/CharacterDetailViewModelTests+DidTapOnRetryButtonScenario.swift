import Testing

@testable import ChallengeCharacter

extension CharacterDetailViewModelTests {
    nonisolated struct DidTapOnRetryButtonScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let characterResult: Result<Character, CharacterError>
        }

        struct Expected: Sendable {
            let state: CharacterDetailViewState
            let loadErrorDescriptions: [String]
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [Self] = [
            Self(
                testDescription: "On success sets loaded state without tracking error",
                given: Given(characterResult: .success(.stub())),
                expected: Expected(state: .loaded(.stub()), loadErrorDescriptions: [])
            ),
            Self(
                testDescription: "On failure sets error state and tracks load error",
                given: Given(characterResult: .failure(.loadFailed())),
                expected: Expected(
                    state: .error(.loadFailed()),
                    loadErrorDescriptions: [CharacterError.loadFailed().debugDescription]
                )
            )
        ]
    }
}
