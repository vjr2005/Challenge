import Foundation

@testable import ChallengeEpisode

final class RefreshCharacterEpisodesUseCaseMock: RefreshCharacterEpisodesUseCaseContract, @unchecked Sendable {
	var result: Result<EpisodeCharacterWithEpisodes, EpisodeError> = .failure(.loadFailed())
	var onExecute: (() -> Void)?
	private(set) var executeCallCount = 0
	private(set) var lastRequestedCharacterIdentifier: Int?

	func execute(characterIdentifier: Int) async throws(EpisodeError) -> EpisodeCharacterWithEpisodes {
		executeCallCount += 1
		lastRequestedCharacterIdentifier = characterIdentifier
		onExecute?()
		return try result.get()
	}
}
