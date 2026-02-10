import ChallengeCore

enum CharacterEpisodesEvent: TrackingEventContract {
	case screenViewed(characterIdentifier: Int)
	case retryButtonTapped
	case pullToRefreshTriggered
	case loadError(description: String)
	case refreshError(description: String)

	var name: String {
		switch self {
		case .screenViewed:
			"character_episodes_viewed"
		case .retryButtonTapped:
			"character_episodes_retry_tapped"
		case .pullToRefreshTriggered:
			"character_episodes_pull_to_refresh"
		case .loadError:
			"character_episodes_load_error"
		case .refreshError:
			"character_episodes_refresh_error"
		}
	}

	var properties: [String: String] {
		switch self {
		case .screenViewed(let characterIdentifier):
			["character_id": "\(characterIdentifier)"]
		case .loadError(let description), .refreshError(let description):
			["description": description]
		default:
			[:]
		}
	}
}
