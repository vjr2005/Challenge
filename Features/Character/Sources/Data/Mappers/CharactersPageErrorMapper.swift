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
			return .loadFailed
		}
		return switch httpError {
		case .statusCode(404, _):
			.invalidPage(page: input.page)
		case .invalidURL, .invalidResponse, .statusCode:
			.loadFailed
		}
	}
}
