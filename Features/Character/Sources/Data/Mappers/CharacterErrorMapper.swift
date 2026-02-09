import ChallengeCore
import ChallengeNetworking
import Foundation

struct CharacterErrorMapperInput {
	let error: any Error
	let identifier: Int
}

struct CharacterErrorMapper: MapperContract {
	func map(_ input: CharacterErrorMapperInput) -> CharacterError {
		guard let apiError = input.error as? APIError else {
			return .loadFailed(description: String(describing: input.error))
		}
		return switch apiError {
		case .notFound:
			.notFound(identifier: input.identifier)
		case .invalidRequest, .invalidResponse, .serverError, .decodingFailed:
			.loadFailed(description: String(describing: apiError))
		}
	}
}
