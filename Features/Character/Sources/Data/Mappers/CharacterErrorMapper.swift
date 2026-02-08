import ChallengeCore
import ChallengeNetworking
import Foundation

struct CharacterErrorMapperInput {
	let error: any Error
	let identifier: Int
}

struct CharacterErrorMapper: MapperContract {
	func map(_ input: CharacterErrorMapperInput) -> CharacterError {
		guard let httpError = input.error as? HTTPError else {
			return .loadFailed(description: String(describing: input.error))
		}
		return switch httpError {
		case .statusCode(404, _):
			.notFound(identifier: input.identifier)
		case .invalidURL, .invalidResponse, .statusCode:
			.loadFailed(description: String(describing: httpError))
		}
	}
}
