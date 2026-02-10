import ChallengeResources
import Foundation

public enum EpisodeError: Error, Equatable, LocalizedError {
	case loadFailed(description: String = "")
	case notFound(identifier: Int)

	public static func == (lhs: EpisodeError, rhs: EpisodeError) -> Bool {
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
			"episodeError.loadFailed".localized()
		case .notFound(let identifier):
			"episodeError.notFound %lld".localized(identifier)
		}
	}
}

extension EpisodeError: CustomDebugStringConvertible {
	public var debugDescription: String {
		switch self {
		case .loadFailed(let description):
			description
		case .notFound(let identifier):
			"notFound(identifier: \(identifier))"
		}
	}
}
