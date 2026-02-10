import ChallengeCore

enum CharacterDetailEvent: TrackingEventContract {
    case screenViewed(identifier: Int)
    case retryButtonTapped
    case pullToRefreshTriggered
    case backButtonTapped
    case loadError(description: String)
    case episodesButtonTapped(identifier: Int)
    case refreshError(description: String)

    var name: String {
        switch self {
        case .screenViewed:
            "character_detail_viewed"
        case .retryButtonTapped:
            "character_detail_retry_tapped"
        case .pullToRefreshTriggered:
            "character_detail_pull_to_refresh"
        case .backButtonTapped:
            "character_detail_back_tapped"
        case .episodesButtonTapped:
            "character_detail_episodes_tapped"
        case .loadError:
            "character_detail_load_error"
        case .refreshError:
            "character_detail_refresh_error"
        }
    }

    var properties: [String: String] {
        switch self {
        case .screenViewed(let identifier), .episodesButtonTapped(let identifier):
            ["id": "\(identifier)"]
        case .loadError(let description), .refreshError(let description):
            ["description": description]
        default:
            [:]
        }
    }
}
