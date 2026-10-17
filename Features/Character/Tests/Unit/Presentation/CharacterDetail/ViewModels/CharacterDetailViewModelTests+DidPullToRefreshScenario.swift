import Foundation
import Testing

@testable import ChallengeCharacter

extension CharacterDetailViewModelTests {
    nonisolated struct DidPullToRefreshScenario: Sendable, CustomTestStringConvertible {
        struct Given: Sendable {
            let characterResult: Result<Character, CharacterError>
        }

        struct Expected: Sendable {
            let state: CharacterDetailViewState
            let removeCachedImageCallCount: Int
            let imageRefreshIDChanged: Bool
            let refreshErrorDescriptions: [String]
        }

        let testDescription: String
        let given: Given
        let expected: Expected

        static let all: [Self] = [
            Self(
                testDescription: "On success with image URL invalidates cache and updates refresh ID",
                given: Given(characterResult: .success(.stub(imageURL: URL(string: "https://example.com/avatar.jpeg")))),
                expected: Expected(
                    state: .loaded(.stub(imageURL: URL(string: "https://example.com/avatar.jpeg"))),
                    removeCachedImageCallCount: 1,
                    imageRefreshIDChanged: true,
                    refreshErrorDescriptions: []
                )
            ),
            Self(
                testDescription: "On success without image URL skips cache invalidation",
                given: Given(characterResult: .success(.stub(imageURL: nil))),
                expected: Expected(
                    state: .loaded(.stub(imageURL: nil)),
                    removeCachedImageCallCount: 0,
                    imageRefreshIDChanged: false,
                    refreshErrorDescriptions: []
                )
            ),
            Self(
                testDescription: "On failure sets error state and tracks refresh error",
                given: Given(characterResult: .failure(.loadFailed())),
                expected: Expected(
                    state: .error(.loadFailed()),
                    removeCachedImageCallCount: 0,
                    imageRefreshIDChanged: false,
                    refreshErrorDescriptions: [CharacterError.loadFailed().debugDescription]
                )
            )
        ]
    }
}
