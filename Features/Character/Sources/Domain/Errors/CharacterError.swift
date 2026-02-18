import ChallengeResources
import Foundation

/// Errors that can occur when working with character detail.
nonisolated public enum CharacterError: Error, Equatable, LocalizedError {
	case loadFailed(description: String = "")
	case notFound(identifier: Int)

	public static func == (lhs: CharacterError, rhs: CharacterError) -> Bool {
		switch (lhs, rhs) {
		case (.loadFailed, .loadFailed):
			true
		case let (.notFound(lhsId), .notFound(rhsId)):
			lhsId == rhsId
		default:
			false
		}
	}

	public var errorDescription: String? {
		switch self {
		case .loadFailed:
			"characterError.loadFailed".localized()
		case .notFound(let identifier):
			"characterError.notFound %lld".localized(identifier)
		}
	}
}

nonisolated extension CharacterError: CustomDebugStringConvertible {
	public var debugDescription: String {
		switch self {
		case .loadFailed(let description):
			description
		case .notFound(let identifier):
			"notFound(identifier: \(identifier))"
		}
	}
}
