import ChallengeCore
import ChallengeNetworking
import Foundation

struct CharactersPageErrorMapperInput {
	let error: any Error
	let page: Int
}

struct CharactersPageErrorMapper: MapperContract {
	func map(_ input: CharactersPageErrorMapperInput) -> CharactersPageError {
		guard let httpError = input.error as? HTTPError else {
			return .loadFailed(description: String(describing: input.error))
		}
		return switch httpError {
		case .statusCode(404, _):
			.invalidPage(page: input.page)
		case .invalidURL, .invalidResponse, .statusCode:
			.loadFailed(description: String(describing: httpError))
		}
	}
}
