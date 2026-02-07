import ChallengeResources
import Foundation

/// Errors that can occur when working with character detail.
public enum CharacterError: Error, Equatable, Sendable, LocalizedError {
	case loadFailed
	case notFound(identifier: Int)

	public var errorDescription: String? {
		switch self {
		case .loadFailed:
			"characterError.loadFailed".localized()
		case .notFound(let identifier):
			"characterError.notFound %lld".localized(identifier)
		}
	}
}
