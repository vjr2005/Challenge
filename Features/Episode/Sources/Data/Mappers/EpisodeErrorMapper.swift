import ChallengeCore
import ChallengeNetworking
import Foundation

nonisolated struct EpisodeErrorMapperInput {
	let error: any Error
	let characterIdentifier: Int
}

nonisolated struct EpisodeErrorMapper: MapperContract {
	func map(_ input: EpisodeErrorMapperInput) -> EpisodeError {
		guard let apiError = input.error as? APIError else {
			return .loadFailed(description: String(describing: input.error))
		}
		return switch apiError {
		case .notFound:
			.notFound(identifier: input.characterIdentifier)
		case .invalidRequest, .invalidResponse, .serverError, .decodingFailed:
			.loadFailed(description: String(describing: apiError))
		}
	}
}
