import Testing

@testable import ChallengeEpisode

extension CharacterEpisodesViewModelTests {
	nonisolated struct DidPullToRefreshScenario: Sendable, CustomTestStringConvertible {
		struct Given: Sendable {
			let characterWithEpisodesResult: Result<EpisodeCharacterWithEpisodes, EpisodeError>
		}

		struct Expected: Sendable {
			let state: CharacterEpisodesViewState
			let refreshErrorDescriptions: [String]
		}

		let testDescription: String
		let given: Given
		let expected: Expected

		static let all: [Self] = [
			Self(
				testDescription: "On success sets loaded state without tracking error",
				given: Given(characterWithEpisodesResult: .success(.stub())),
				expected: Expected(state: .loaded(.stub()), refreshErrorDescriptions: [])
			),
			Self(
				testDescription: "On failure sets error state and tracks refresh error",
				given: Given(characterWithEpisodesResult: .failure(.loadFailed())),
				expected: Expected(
					state: .error(.loadFailed()),
					refreshErrorDescriptions: [EpisodeError.loadFailed().debugDescription]
				)
			)
		]
	}
}
