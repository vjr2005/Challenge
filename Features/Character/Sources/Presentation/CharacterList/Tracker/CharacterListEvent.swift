import ChallengeCore

enum CharacterListEvent: TrackingEventContract {
    case screenViewed
    case characterSelected(identifier: Int)
    case searchPerformed(query: String)
    case retryButtonTapped
    case pullToRefreshTriggered
    case loadMoreButtonTapped

    var name: String {
        switch self {
        case .screenViewed:
            "character_list_viewed"
        case .characterSelected:
            "character_selected"
        case .searchPerformed:
            "search_performed"
        case .retryButtonTapped:
            "character_list_retry_tapped"
        case .pullToRefreshTriggered:
            "character_list_pull_to_refresh"
        case .loadMoreButtonTapped:
            "character_list_load_more_tapped"
        }
    }

    var properties: [String: String] {
        switch self {
        case .characterSelected(let identifier):
            ["id": "\(identifier)"]
        case .searchPerformed(let query):
            ["query": query]
        default:
            [:]
        }
    }
}
