import ChallengeCore
import ChallengeNetworking
import Foundation

struct CharactersPageErrorMapperInput {
	let error: any Error
	let page: Int
}

struct CharactersPageErrorMapper: MapperContract {
	func map(_ input: CharactersPageErrorMapperInput) -> CharactersPageError {
		guard let apiError = input.error as? APIError else {
			return .loadFailed(description: String(describing: input.error))
		}
		return switch apiError {
		case .notFound:
			.invalidPage(page: input.page)
		case .invalidRequest, .invalidResponse, .serverError, .decodingFailed:
			.loadFailed(description: String(describing: apiError))
		}
	}
}
