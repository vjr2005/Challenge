import ChallengeCore

enum CharacterDetailEvent: TrackingEvent {
    case screenViewed(identifier: Int)
    case retryButtonTapped
    case pullToRefreshTriggered
    case backButtonTapped

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
        }
    }

    var properties: [String: String] {
        switch self {
        case .screenViewed(let identifier):
            ["id": "\(identifier)"]
        default:
            [:]
        }
    }
}
