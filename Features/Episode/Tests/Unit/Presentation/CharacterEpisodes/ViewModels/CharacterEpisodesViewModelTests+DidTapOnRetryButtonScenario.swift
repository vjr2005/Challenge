import Testing

@testable import ChallengeEpisode

extension CharacterEpisodesViewModelTests {
	nonisolated struct DidTapOnRetryButtonScenario: Sendable, CustomTestStringConvertible {
		struct Given: Sendable {
			let characterWithEpisodesResult: Result<EpisodeCharacterWithEpisodes, EpisodeError>
		}

		struct Expected: Sendable {
			let state: CharacterEpisodesViewState
			let loadErrorDescriptions: [String]
		}

		let testDescription: String
		let given: Given
		let expected: Expected

		static let all: [Self] = [
			Self(
				testDescription: "On success sets loaded state without tracking error",
				given: Given(characterWithEpisodesResult: .success(.stub())),
				expected: Expected(state: .loaded(.stub()), loadErrorDescriptions: [])
			),
			Self(
				testDescription: "On failure sets error state and tracks load error",
				given: Given(characterWithEpisodesResult: .failure(.loadFailed())),
				expected: Expected(
					state: .error(.loadFailed()),
					loadErrorDescriptions: [EpisodeError.loadFailed().debugDescription]
				)
			)
		]
	}
}
